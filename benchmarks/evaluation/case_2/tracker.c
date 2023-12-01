#include "tracker.h"
#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

/**
 * Log the time
 * @param eventList the event list
 * @param type the event type
 * @param payload the event payload
 */
void logTime(struct EventList *eventList, EventType type, char *payload) {
    struct Event *event = malloc(sizeof(struct Event));
    struct timespec now;
    clock_gettime(CLOCK_MONOTONIC, &now);
    event->time = now.tv_sec * 1000 + now.tv_nsec / 1000000;
    event->type = type;
    event->payload = payload;
    addEvent(event, eventList);
}

/**
 * Add an event to the event list at the end
 * @param event the event to add
 * @param eventList the event list
 */
void addEvent(struct Event *event, struct EventList *eventList) {
    struct EventNode *newEvent = malloc(sizeof(struct EventNode));
    newEvent->event = event;
    newEvent->next = NULL;

    if (eventList->head == NULL) {
        eventList->head = newEvent;
        eventList->tail = newEvent;
    } else {
        eventList->tail->next = newEvent;
        eventList->tail = newEvent;
    }
}

/**
 * Export the event list to a csv file in the folder `results` with the name `<client_id>.csv`
 * @param eventList the event list
 * @param client_id the client id
 */
void exportToCsv(struct EventList *eventList, char *client_id) {
    char *filename;
    asprintf(&filename, "results/%s.csv", client_id);
    FILE *fp = fopen(filename, "w+");
    fprintf(fp, "timestamp;event;payload\n");
    struct EventNode *current = eventList->head;
    while (current != NULL) {
        fprintf(fp, "%llu;%d;%s\n", current->event->time, current->event->type, current->event->payload);
        current = current->next;
    }
    fclose(fp);
}