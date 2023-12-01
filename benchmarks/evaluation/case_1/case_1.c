#include "connect_client.h"
#include "../case_2/tracker.h"

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

static int stop = 0;

/**
 * Signal handler
 * if we receive a signal we stop the clients
 * @param signum the signal number
 */
void sig_handler_case(int signum){
  stop = 1;
}

/**
 * Run the clients
 * This method effectively spins off the connecting clients
 * @param min_client_id the minimum client id
 * @param nb_of_clients the number of clients to run
 */
void run_clients(int min_client_id, int nb_of_clients) {
    int pids[nb_of_clients];
    int nb_clients = 0;

    for(int i = 0; i < nb_of_clients; i++) {
        int pid = fork();
        if(pid < 0) {
            perror("fork");
            stop = 1;
            break;
        } else if(pid == 0) {
            // Child process
            char* client_id_str = malloc(sizeof(char) * 11);
            sprintf(client_id_str, "%d", (min_client_id + nb_clients));
            connect_client(client_id_str);
            exit(0);
            return;
        } else {
            pids[nb_clients] = pid;
            nb_clients++;   
        }
    }

    for(int i = 0; i < nb_of_clients; i++) {
        wait(&pids[i]);
    }
    return;
}

/**
 * Return the next number of client to run
 * @param nb_client_per_seconds the current number of client per seconds
 * @return the next number of client to run
 */
int get_next_client_number(int nb_client_per_seconds) {
    if(nb_client_per_seconds == 1) {
        return 5;
    }
#ifdef WITH_TLS 
    if(nb_client_per_seconds > 0 && nb_client_per_seconds < 50) {
        return nb_client_per_seconds + 5;
    } else {
        return 0;
    }
#else 
    switch(nb_client_per_seconds) {
        case 10:
            return 20;
        case 20:
            return 50;
        case 50:
            return 100;
        case 100:
            return 200;
        case 200:
            return 500;
        case 500:
            return 1000;
        case 1000:
            return 4000;
        case 4000:
            return 0;
    }
#endif    
}

int main() {
    setbuf(stdout, NULL);
    setbuf(stderr, NULL);
    struct EventList *eventList = malloc(sizeof(struct EventList));
    int client_id = 0;
    int seconds = 0;
    int nb_client_per_seconds = 1;
    int nb_workers = 0;
    int pids[8000];

    char *nb_client_per_seconds_str = malloc(sizeof(char) * 12);
    sprintf(nb_client_per_seconds_str, "%d", nb_client_per_seconds);
    logTime(eventList, RI, nb_client_per_seconds_str);

    signal(SIGINT, sig_handler_case);


    while(nb_workers < 8000) {

        int pid = fork();

        if(pid < 0) {
            stop = 1;
        } else if(pid == 0) {
            run_clients(client_id, nb_client_per_seconds);
            exit(0);
            return 0;
        } else {
            client_id += nb_client_per_seconds;
            pids[nb_workers] = pid;
            nb_workers++;
        }
        sleep(1);
        seconds++;
        if(seconds % 10 == 0) {
            nb_client_per_seconds = get_next_client_number(nb_client_per_seconds);
            char *nb_client_per_seconds_str = malloc(sizeof(char) * 12);
            sprintf(nb_client_per_seconds_str, "%d", nb_client_per_seconds);
            logTime(eventList, RI, nb_client_per_seconds_str);
        }
        
        if(nb_client_per_seconds == 0) {
            stop = 1;
        }

        if(stop) {
            break;
        }
    }

    for(int i = 0; i < nb_workers; i++) {
        kill(pids[i], SIGINT);
    }

    exportToCsv(eventList, "orchestrator");

    sleep(10);

    exit(0);
}