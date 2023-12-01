#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <mosquitto.h>
#include <signal.h>
#include "connect_client.h"

#ifdef WITH_ATTESTATION
#include <wolfssl/options.h>
#include <wolfssl/ssl.h>
// attestation constants
#define BUF_SIZE 16384
static const word16 CHALLENGE_SIZE = 8;
static unsigned char ATT_TYPE[] = "Test";
static unsigned char ATT_DATA[] = "Hello Attestation";
#endif

// helper values for time conversion
enum { NS_PER_SECOND = 1000000000 };

// when did we start
struct timespec *start;
// should the client run the loop and wait
int run = 1;
// are we connected
int connected = 0;
// should we disconnect
int do_disconnect = 0;

#ifdef WITH_ATTESTATION

/**
 * Verify the attestation
 * @param req the attestation request
 * @param c the evidence
 * @return 0 if the attestation is valid, 1 otherwise
 */
int verify_attestation(const ATT_REQUEST *req, const byte *c) {
    // we accepted any evidence as we only test how long it takes for the broker to generate the evidence
	return 0;
}

/**
 * Generate an attestation
 * @param att_request the attestation request
 */
void generate_attestation(struct ATT_REQUEST *att_request) {
    WC_RNG rng;
    word64 nonce;
    byte buffer[BUF_SIZE] = {0};
    int num_read;
    word8 ret = 0;

    // generate nonce
    if (wc_InitRng(&rng) != 0) {
        perror("wc_InitRng() failure");
        return;
    }
    if (wc_RNG_GenerateBlock(&rng, (byte *) &nonce, sizeof(nonce)) != 0) {
        perror("wc_RNG_GenerateBlock() failure");
        return;
    }
    att_request->nonce = nonce;
    att_request->challengeSize = CHALLENGE_SIZE;
    att_request->size = sizeof(ATT_TYPE);
    att_request->data = ATT_TYPE;
}
#endif

/**
* subtract two timestpecs and put the difference into into td
*/
void sub_timespec(struct timespec *t1, struct timespec *t2, struct timespec *td)
{
    td->tv_nsec = t2->tv_nsec - t1->tv_nsec;
    td->tv_sec  = t2->tv_sec - t1->tv_sec;
    if (td->tv_sec > 0 && td->tv_nsec < 0)
    {
        td->tv_nsec += NS_PER_SECOND;
        td->tv_sec--;
    }
    else if (td->tv_sec < 0 && td->tv_nsec > 0)
    {
        td->tv_nsec -= NS_PER_SECOND;
        td->tv_sec++;
    }
}

/**
* Connection callback
* this calculates the connection latency
* and prints it
* afterward, it disconnects
*/
void on_connect(struct mosquitto *mosq, void *obj, int rc)
{
    uint64_t start_ms = start->tv_sec * 1000 + start->tv_nsec / 1000000;
	if(rc){
        printf("%lu;%d\n", start_ms, -1);
		exit(1);
	}else{
        // cast obj to struct timespec
        struct timespec now;
        struct timespec *td = malloc(sizeof(struct timespec));
        clock_gettime(CLOCK_MONOTONIC, &now);
        sub_timespec(start, &now, td);
        long long unsigned int time_ms = td->tv_sec * 1000 + td->tv_nsec / 1000000;
        printf("%lu;%llu\n", start_ms, time_ms);
        do_disconnect = 1;
        connected = 1;

        free(td);
	}
}

/**
 * Disconnect callback
 */
void on_disconnect(struct mosquitto *mosq, void *obj, int rc)
{
	run = 0;
}

/**
 * Connect with the given client_id to the broker and report the connection latency
 * 
 * Note: Will report -1 if could not connect within 5 seconds or if the connection failed
 * @param client_id the client id to use
 */
int connect_client(char *client_id) {
	int rc;
	int port;
	struct mosquitto *mosq;

    start = malloc(sizeof(struct timespec));

    if(mosquitto_lib_init()){
        return 1;
    }

#ifdef WITH_TLS
    port = 8883;
#else
    port = 1883;
#endif

	mosq = mosquitto_new(client_id, true, NULL);
#ifdef WITH_PSK
    port = 8884;
    char *prefix = "AAAAAAAAAAAAAAABCDEF";
    char *client_pass;
    asprintf(&client_pass, "%s%s", prefix, client_id);
    client_pass = client_pass + strlen(client_pass) - 20;
    char *client_id_psk;
    asprintf(&client_id_psk, "client_%s", client_id);
	rc = mosquitto_tls_psk_set(mosq, client_pass, client_id_psk, NULL);
	if(rc){
		mosquitto_destroy(mosq);
		return rc;
	}
#elif WITH_TLS
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
    
#ifdef WITH_ATTESTATION
    mosquitto_get_attestation_set(mosq, generate_attestation);
    mosquitto_verify_attestation_set(mosq, verify_attestation);
#endif
    mosquitto_connect_callback_set(mosq, on_connect);
	mosquitto_disconnect_callback_set(mosq, on_disconnect);

	clock_gettime(CLOCK_MONOTONIC, start);
    rc = mosquitto_connect(mosq, HOST_NAME, port, 300);
	if(rc){
		mosquitto_destroy(mosq);
		return rc;
	}


    mosquitto_loop_start(mosq);
    struct timespec now;
    struct timespec *td = malloc(sizeof(struct timespec));
    while(run == 1){
        clock_gettime(CLOCK_MONOTONIC, &now);
        sub_timespec(start, &now, td);
        if(td->tv_sec > 5 && connected == 0) {
            uint64_t start_ms = start->tv_sec * 1000 + start->tv_nsec / 1000000;
            printf("%lu;%d\n", start_ms, -1);
            run = 0;
        }
        if(do_disconnect) {
            mosquitto_disconnect(mosq);
        }
        sleep(1);
	}
    free(td);

    mosquitto_loop_stop(mosq, true);
	mosquitto_destroy(mosq);
	mosquitto_lib_cleanup();
	return 0;
}

#ifdef STANDALONE
int main(int argc, char *argv[])
{
    if(argc != 2) {
        printf("Usage: %s <client_id>\n", argv[0]);
        exit(1);
    }
    // get the client id from the arguments
    connect_client(argv[1]);
    exit(0);
}
#endif