#include "publisher.h"
#include "subscriber.h"
#include "tracker.h"

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>

#ifndef HOST_NAME
#define HOST_NAME "172.28.1.59"
#endif

// variable to determine whether to continue running the case
int run_case = 1;

/**
 * Signal handler
 * if we receive a signal we stop the clients
 * @param signum the signal number
 */
void signal_handler(int signal) {
    run_case = 0;
}

/**
 * Helper to log the new message rate to the event list
 * @param eventList the event list
 * @param new_rate the new message rate
 */
void log_new_rate(struct EventList *eventList, int new_rate) {
    char *new_rate_str = malloc(sizeof(char) * 11);
    sprintf(new_rate_str, "%d", new_rate);
    logTime(eventList, RI, new_rate_str);
}

/**
 * This method runs the latency measurement case
 * depending on the use build flags it will scale the subscribers, the publishers, or the message rate
 */
int main() {
    struct EventList *eventList = malloc(sizeof(struct EventList));
    // in general everything is zero, but every "case" sets its own variables
    int nb_subscribers = 0;
    int nb_publishers = 0;
    int shared_subscription = 0;
    int message_rate = 0;
#ifdef MESSAGE_RATE_SCALE
    int time_to_increase_rate = 60;
    
    nb_subscribers = 1;
    nb_publishers = 1;
#endif

#ifdef SUBSCRIBER_SCALE
    int time_to_increase_subscribers = 60;
    message_rate = 25;
    shared_subscription = 1;
    
    nb_subscribers = 256;
    nb_publishers = 1;
#endif

#ifdef PUBLISHER_SCALE
    int time_to_increase_publishers = 60;
    message_rate = 5;
    nb_subscribers = 25;
    nb_publishers = 64;
#endif

    if(nb_subscribers == 0 || nb_publishers == 0) {
        printf("Please set the number of subscribers and publishers\n");
        exit(1);
    }
    
    int publishers[nb_publishers];
    int subscribers[nb_subscribers];
    int client_id = 0;
    int qos = 0;

    signal(SIGINT, signal_handler);

    printf(">>> Starting %d subscribers and %d publishers\n", nb_subscribers, nb_publishers);
    for(int i = 0; i < nb_subscribers; i++) {
        int pid = fork();
        if (pid < 0) {
            printf("Error forking process\n");
            exit(1);
            return 0;
        } else if (pid == 0) {
            // child process
            char *client_id_str;
            asprintf(&client_id_str, "%d", client_id + nb_publishers);
            start_subscriber(client_id_str, qos, "test/#", false, shared_subscription == 1);
            exit(0);
        } else {
            // parent process
            subscribers[i] = pid;
            client_id++;
        }

        if(i > 0 && i % 10 == 0) {
            // "fast" connect; sleep only every 20 subscribers
            sleep(1);
        }
    }

    printf(">>> Subscribers started\n");

    for (int i = 0; i < nb_publishers; i++) {
        int pid = fork();
        if (pid < 0) {
            printf("Error forking process\n");
            exit(1);
            return 0;
        } else if (pid == 0) {
            // child process
            char *client_id_str;
            asprintf(&client_id_str, "%d", client_id - nb_subscribers);
            start_publisher(client_id_str, qos, message_rate);
            exit(0);
        } else {
            // parent process
            publishers[i] = pid;
            client_id++;
        }
        if(i > 0 && i % 10 == 0) {
            // "fast" connect; sleep only every 20 publishers
            sleep(1);
        }
    }

    printf(">>> Publishers started\n");

#ifdef SUBSCRIBER_SCALE
    sleep(2);
    int nb_of_subscribed_clients = 1;
    // send signal to first subscriber to subscribe
    kill(subscribers[0], SIGUSR1);
    log_new_rate(eventList, nb_of_subscribed_clients);
    sleep(5);
    // send signal to all publishers to start publishing
    for(int i = 0; i < nb_publishers; i++) {
        kill(publishers[i], SIGUSR1);
    }
    while(run_case == 1) {
        sleep(time_to_increase_subscribers);
        printf(">>> Increasing number of subscribers to %d\n", nb_of_subscribed_clients * 2);
        for(int i = 0; i < nb_of_subscribed_clients; i++) {
            if(nb_subscribers > (i + nb_of_subscribed_clients)) {
                // wake up the new client
                kill(subscribers[i + nb_of_subscribed_clients], SIGUSR1);
            }
        }
        nb_of_subscribed_clients = nb_of_subscribed_clients * 2;
        log_new_rate(eventList, nb_of_subscribed_clients);
        // increase the rate every minute
        if(nb_of_subscribed_clients >= nb_subscribers) {
            run_case = 0;
            sleep(time_to_increase_subscribers);
        }
    }
#endif
#ifdef PUBLISHER_SCALE
    sleep(2);
    // send signal to all subscribers to subscribe
    for(int i = 0; i < nb_subscribers; i++) {
        kill(subscribers[i], SIGUSR1);
    }
    sleep(5);
    // send signal to publisher to start publishing
    int nb_of_publishing_clients = 0;
    int nb_of_initial_clients = 5;
    nb_of_publishing_clients = nb_of_initial_clients;
    log_new_rate(eventList, nb_of_publishing_clients);
    for(int i = 0; i < nb_of_initial_clients; i++) {
        kill(publishers[i], SIGUSR1);
    }
    while(run_case == 1) {
        sleep(time_to_increase_publishers);
        printf(">>> Increasing number of publishers to %d\n", nb_of_publishing_clients + nb_of_initial_clients);
        for(int i = 0; i < nb_of_initial_clients; i++) {
            if(nb_publishers > (i + nb_of_publishing_clients)) {
                // tell a new publisher to begin publishing
                kill(publishers[i + nb_of_publishing_clients], SIGUSR1);
            }
        }
        nb_of_publishing_clients = nb_of_publishing_clients + nb_of_initial_clients;
        if(nb_of_publishing_clients > nb_publishers) {
            nb_of_publishing_clients = nb_publishers;
        }
        log_new_rate(eventList, nb_of_publishing_clients);
        // increase the rate every minute
        if(nb_of_publishing_clients >= nb_publishers) {
            run_case = 0;
            sleep(time_to_increase_publishers);
        }
    }
#endif

#ifdef MESSAGE_RATE_SCALE
    sleep(2);
    // send signal to all subscribers to subscribe
    printf(">>> Subscribing all clients\n");
    for(int i = 0; i < nb_subscribers; i++) {
        kill(subscribers[i], SIGUSR1);
    }
    sleep(5);
    while(run_case == 1) {
        message_rate = get_new_message_rate(message_rate);
        printf(">>> Increasing message rate to %d\n", message_rate);
        for(int i = 0; i < nb_publishers; i++) {
            // tell publishers to increase their rate
            kill(publishers[i], SIGUSR1);
        }
        log_new_rate(eventList, message_rate);
        sleep(time_to_increase_rate);
        if(message_rate == 0) {
            run_case = 0;
        }
    }

#endif
    printf("Stopping...\n");
    
    for(int i = 0; i <  nb_publishers; i++) {
        if(publishers[i]) {
            kill(publishers[i], SIGINT);
        }
    }

    for(int i=0; i < nb_publishers; i++) {
        if(publishers[i]) {
            wait(&publishers[i]);
        }
    }
    
    for(int i = 0; i <  nb_subscribers; i++) {
        if(subscribers[i]) {
            kill(subscribers[i], SIGINT);
        }
    }
    for(int i=0; i < nb_subscribers; i++) {
        if(subscribers[i]) {
            wait(&subscribers[i]);
        }
    }

    exportToCsv(eventList, "orchestrator");
} 