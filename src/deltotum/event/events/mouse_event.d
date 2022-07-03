module deltotum.event.events.mouse_event;

struct MouseEvent
{
    static enum MouseEventType
    {
        MOUSE_DOWN,
        MOUSE_UP,
        MOUSE_MOVE,
        MOUSE_WHEEL
    }

    int windowId;

    double x;
    double y;

    int button;
    
    double movementX;
    double movementY;
   
    MouseEventType type;
}
