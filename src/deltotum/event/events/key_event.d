module deltotum.event.events.key_event;

enum KeyEventType
{
    NONE,
    KEY_DOWN,
    KEY_UP
}

struct KeyEvent
{
    double keyCode;
    int modifier;
    KeyEventType type;
    int windowID;
}
