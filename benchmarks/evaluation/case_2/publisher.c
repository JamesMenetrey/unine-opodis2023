#include <mosquitto.h>
#include <mqtt_protocol.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include "tracker.h"

int publishing_rate = 0;
int publish = 0;
int run = 1;
int disconnect = 0;
char *client_id_glob;

/**
 * Get the new message rate
 * @param current_rate the current rate
 * @return the new rate
 */
int get_new_message_rate(int current_rate) {
    switch(current_rate) {
        case 5:
            return 10;
        case 10:
            return 25;
        case 25:
            return 50;
        case 50:
            return 100;
        case 100:
            return 200;
        case 200:
            return 0;
        default:
            return 5;
    }
}

/**
 * Callback for connect
 */
void connect_callback_publisher(struct mosquitto *mosq, void *obj, int result) {
    struct EventList *eventList = (struct EventList *) obj;
    if(!result){
        publish = 1;
    } else {
        logTime(eventList, CF, "-1");
        disconnect = 1;
    }
}

/**
 * signal handler for publisher
 * SIGUSR1: increases the publishing rate by getting the new message rate using the get_new_message_rate method
 * Others: disconnect
 * @param signal the signal number
 */
void publisher_signal_handler(int signal) {
    switch(signal) {
        case SIGUSR1:
            // increase publishing rate
            publishing_rate = get_new_message_rate(publishing_rate);
            break;
        default:
            disconnect = 1;
            break;
    }
}

/**
 * Callback for disconnect
 */
void disconnect_callback_publisher(struct mosquitto *mosq, void *obj, int result) {
    run = 0;
}

/**
 * Callback for publish
 * This will log the time when the PUBACK has been received
 */
void publish_callback(struct mosquitto *mosq, void *obj, int mid, int reason_code, const mosquitto_property *props) {
    struct EventList *eventList = (struct EventList *) obj;
    char *log_payload;
    asprintf(&log_payload, "%s-%d", client_id_glob, mid);   
    if(reason_code != MQTT_RC_SUCCESS) {
        logTime(eventList, PF, log_payload);
    } else {
        logTime(eventList, PA, log_payload);
    }
    mosquitto_property_free_all(&props);
}

/**
 * Start the publisher
 * @param client_id the client id to use
 * @param qos the qos to use
 * @param fixed_rate the fixed rate to use
 * @return 0 if successful, 1 otherwise
 */
int start_publisher(char *client_id, int qos, int fixed_rate) {
    char *topic;
    struct EventList *eventList = malloc(sizeof(struct EventList));
    
    asprintf(&topic, "test/%s", client_id);
    client_id_glob = client_id;

    signal(SIGINT, publisher_signal_handler);
    signal(SIGUSR1, publisher_signal_handler);

    // Setup Mosquitto
    struct mosquitto *mosq = mosquitto_new(client_id, true, eventList);
    mosquitto_int_option(mosq, MOSQ_OPT_PROTOCOL_VERSION, MQTT_PROTOCOL_V5);
    if (mosq == NULL) {
        printf("Error creating mosquitto instance\n");
        exit(1);
        return 0;
    }
    mosquitto_connect_callback_set(mosq, connect_callback_publisher);
    mosquitto_publish_v5_callback_set(mosq, publish_callback);
    mosquitto_disconnect_callback_set(mosq, disconnect_callback_publisher);

#ifdef WITH_TLS
    int port = 8883;
#else
    int port = 1883;
#endif
    int rc;

#ifdef WITH_TLS
#ifdef WITH_MUTUAL_AUTH
    rc = mosquitto_tls_set(mosq, "certs/ca.crt", NULL, "certs/client.crt", "certs/client.key", NULL);
#else
    rc = mosquitto_tls_set(mosq, "certs/ca.crt", NULL, NULL, NULL, NULL);
#endif
	if(rc){
		mosquitto_destroy(mosq);
		return rc;
	}
    rc = mosquitto_tls_opts_set(mosq, 1, NULL, NULL);
	if(rc){
		mosquitto_destroy(mosq);
		return rc;
	}
#endif
    
    rc = mosquitto_connect(mosq, HOST_NAME, port, 60);
    if(rc != MOSQ_ERR_SUCCESS) {
        printf("Error connecting to broker: %s\n", mosquitto_strerror(rc));
        exit(1);
        return 0;
    }

    int mid = 0;

    char * filename;
    asprintf(&filename, "random/random-%s.txt", client_id);
    FILE *fp = fopen(filename, "r");
    if (fp == NULL) {
        printf("Error opening file %s\n", filename);
        exit(1);
        return 0;
    }

    // prepare nanosleep timespec
    // but we start with 0 messages per second
    // and increase it on every SIGUSR1 by 5
    int message_rate = 0;
    struct timespec *ts = malloc(sizeof(struct timespec));
    ts->tv_sec = 1;
    ts->tv_nsec = 0;

    mosquitto_loop_start(mosq);
    while(run) {
        // start only when we received the first SIGUSR1
        if(fixed_rate > 0 && publishing_rate > 0) {
            ts->tv_sec = 0;
            ts->tv_nsec = 1000000000/fixed_rate;
        } else if(message_rate != publishing_rate) {
            message_rate = publishing_rate;
            if(message_rate == 0) {
                ts->tv_sec = 1;
                ts->tv_nsec = 0;
            } else {
                ts->tv_sec = 0;
                ts->tv_nsec = 1000000000/message_rate;
            }
        }
        if(publishing_rate > 0 && publish > 0) {
            char *payload = NULL;
            // get next line from file
            size_t size = 16384;
            ssize_t read = getline(&payload, &size, fp);
            if (read == -1) {
                // end of file
                //publish = 0;
                //printf("End of file reached for publisher %s\n", client_id);
                fclose(fp);
                fp = fopen(filename, "r");
                read = getline(&payload, &size, fp);
            } 

            // remove newline character
            payload[strlen(payload) - 1] = '\0';

            char *custom_message_id;
            mid++;
            asprintf(&custom_message_id, "%s-%d", client_id, mid);
            struct mosquitto_property *proplist = NULL;
            int rc = mosquitto_property_add_string_pair(&proplist, MQTT_PROP_USER_PROPERTY, "cmid", custom_message_id);
            if(rc != MOSQ_ERR_SUCCESS) {
                printf("Error adding user property\n");
                disconnect = 1;
            } else {
                logTime(eventList, PS, custom_message_id);
                mosquitto_publish_v5(mosq, &mid, topic, strlen(payload), payload, qos, false, proplist);
                free(payload);
            }
            struct timespec *ts_sleep = malloc(sizeof(struct timespec));
            int erro = nanosleep(ts, ts_sleep);
            if(erro == -1) {
                erro = nanosleep(ts_sleep, NULL);
            }
            
            
        } else {
            sleep(1);
        }
        if(disconnect) {
            mosquitto_disconnect(mosq);
            disconnect = 0;
        }
    }
    exportToCsv(eventList, client_id);
    mosquitto_loop_stop(mosq, true);

    mosquitto_destroy(mosq);
    mosquitto_lib_cleanup();
    return 0;
}

#ifdef STANDALONE
int main(int argc, char *argv[]) {
    // first arg is client id
    // second arg is qos
    if(argc != 3) {
        printf("Error: wrong number of arguments\n");
        return 1;
    }
    char *client_id_str = argv[1];
    char *qos_str = argv[2];
    int qos = atoi(qos_str);
    start_publisher(client_id_str, qos);
}
#endif