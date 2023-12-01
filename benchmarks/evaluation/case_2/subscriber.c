#include <mosquitto.h>
#include <mqtt_protocol.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include "tracker.h"

int run_subscriber = 1;
int disconnect_subscriber = 0;
int qos_selected = 0;
char *subscriber_topic;
bool log_payload = false;
bool shared_subscription = false;
bool subscribe_on_connect = false;
struct mosquitto *mosq;

/**
 * Trigger the subscribe to the static topic
 */
void subscribe() {
    printf("Subscribing to topic %s with qos %d\n", subscriber_topic, qos_selected);
    if(shared_subscription) {
        char *subs_topic = malloc(strlen(subscriber_topic) + 15);
        strcpy(subs_topic, "$share/mygroup/");
        strcat(subs_topic, subscriber_topic);
        mosquitto_subscribe_v5(mosq, NULL, subs_topic, qos_selected, 0, NULL);
    } else {
        mosquitto_subscribe_v5(mosq, NULL, subscriber_topic, qos_selected, 0, NULL);
    }
}

/**
 * Signal handler for subscriber
 * SIGUSR1: subscribe to the static topic
 * Others: disconnect
 * @param signal the signal number
 */
void subscriber_signal_handler(int signal) {
    // when signal SIGHUP is received, set disconnect_subscriber to 1
    switch(signal) {
        case SIGUSR1:
            subscribe();
            break;
        default:
            disconnect_subscriber = 1;
            break;
    }
}

/**
 * Callback for connect
 */
void connect_callback_subscriber(struct mosquitto *mosq, void *obj, int result) {
    if(result){
        run_subscriber = 0;
    } else if(subscribe_on_connect) {
        subscribe();
    }
}

/**
 * Callback for message
 * This will log the message_id and the time it received the message to the static event list
 * @param mosq the mosquitto instance
 * @param obj the object
 * @param message the message
 * @param props the properties
 */
void message_callback(struct mosquitto *mosq, void *obj, const struct mosquitto_message *message, const mosquitto_property *props) {
    struct EventList *eventList = (struct EventList *) obj;
    if(log_payload) {
        // copy message payload to a string
        char *payload = malloc(strlen(message->payload));
        memcpy(payload, message->payload, message->payloadlen);
        payload[message->payloadlen] = '\0';
        logTime(eventList, MR, payload);
    } else {
        char *property;
        char *value;
        // search for property with the name "cmid" in props
        mosquitto_property_read_string_pair(props, MQTT_PROP_USER_PROPERTY, &property, &value, false);
        
        while(property != NULL) {
            // check if property equals cmid
            if(strcmp(property, "cmid") == 0) {
                // assert that value is null terminated
                char *payload = malloc(strlen(value) + 1);
                memcpy(payload, value, strlen(value));
                payload[strlen(value)] = '\0';
                logTime(eventList, MR, payload);
                break;
            } else {
                free(property);
                free(value);
                mosquitto_property_read_string_pair(props, MQTT_PROP_USER_PROPERTY, &property, &value, false);
            }
        }
    }
}

/**
 * Callback for disconnect
 */
void disconnect_callback_subscriber(struct mosquitto *mosq, void *obj, int result) {
    struct EventList *eventList = (struct EventList *) obj;
    run_subscriber = 0;
}

/**
 * Start the subscriber, i.e.
 * - connect to the broker with the given client id
 * - subscribe to the static topic upon SIGUSR1 or after connect if subscribe_on_connect is true
 * - disconnect upon SIGINT
 * @param client_id the client id to use
 * @param qos the qos to use
 * @param topic the topic to subscribe to
 * @param log_payload_input if true, the message payload is logged, if false we search for the custom message id to log
 * @param shared_subscription_input if true, the subscriber will subscribe to a shared subscription, otherwise to a normal subscription
 */
int start_subscriber(char *client_id, int qos, char *topic, bool log_payload_input, bool shared_subscription_input) {
    struct EventList *eventList = malloc(sizeof(struct EventList));
    int rc;
    int port;

    log_payload = log_payload_input;
    shared_subscription = shared_subscription_input;
    subscriber_topic = topic; 

    signal(SIGINT, subscriber_signal_handler);
    signal(SIGUSR1, subscriber_signal_handler);

    qos_selected = qos;
   

    if(mosquitto_lib_init()){
        printf("Error: libmosquitto init failed\n");
        return 1;
    }

#ifdef WITH_TLS
    port = 8883;
#else
    port = 1883;
#endif
    mosq = mosquitto_new(client_id, true, eventList);
    mosquitto_int_option(mosq, MOSQ_OPT_PROTOCOL_VERSION, MQTT_PROTOCOL_V5);
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
    mosquitto_connect_callback_set(mosq, connect_callback_subscriber);
    mosquitto_message_v5_callback_set(mosq, message_callback);
    mosquitto_disconnect_callback_set(mosq, disconnect_callback_subscriber);
    rc = mosquitto_connect(mosq, HOST_NAME, port, 60);
    if(rc != MOSQ_ERR_SUCCESS){
        printf("Error: could not connect to broker\n");
        exit(1);
        return rc;
    }

    mosquitto_loop_start(mosq);
    while(run_subscriber) {
        sleep(1);
        if(disconnect_subscriber) {
            mosquitto_disconnect(mosq);
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
    // third arg is topic
    if(argc != 4) {
        printf("Error: wrong number of arguments\n");
        return 1;
    }
    char *client_id = argv[1];
    char *qos_str = argv[2];
    int qos = atoi(qos_str);
    char *topic = argv[3];

    subscribe_on_connect = true;
    start_subscriber(client_id, qos, topic, true, false);
    exit(0);
    return 0;
}
#endif