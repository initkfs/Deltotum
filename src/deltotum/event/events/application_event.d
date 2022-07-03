module deltotum.event.events.application_event;

enum ApplicationEventType {
    EXIT
}

struct ApplicationEvent
{
    ApplicationEventType type;
}