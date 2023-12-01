typedef enum {
    CS = 0, // Connection Start
    CA = 1, // Connection Ack
    CF = 2, // Connection Fail
    PS = 3, // Publish Start
    PA = 4, // Publish Ack
    PF = 5, // Publish Fail
    SS = 6, // Subscribe Start
    SA = 7, // Subscribe Ack
    SF = 8, // Subscribe Fail
    MR = 9, // Message Received
    RI = 10 // Rate increased
} EventType;

typedef struct Event {
    EventType type;
    long long unsigned int time;
    char *payload;
} Event;

typedef struct EventNode {
    Event *event;
    struct EventNode *next;
} EventNode;

typedef struct EventList {
    EventNode *head;
    EventNode *tail;
} EventList;

void logTime(struct EventList *eventList, EventType type, char *payload);
void addEvent(struct Event *event, struct EventList *eventList);
void exportToCsv(struct EventList *eventList, char *client_id);