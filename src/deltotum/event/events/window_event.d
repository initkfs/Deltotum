module deltotum.event.events.window_event;

enum WindowEventType
{
    NONE,
    WINDOW_ACTIVATE,
    WINDOW_ENTER,
    WINDOW_EXPOSE,
    WINDOW_CLOSE,
    WINDOW_DEACTIVATE,
    WINDOW_FOCUS_IN,
    WINDOW_FOCUS_OUT,
    WINDOW_LEAVE,
    WINDOW_MAXIMIZE,
    WINDOW_MINIMIZE,
    WINDOW_MOVE,
    WINDOW_RESIZE,
    WINDOW_RESTORE,
}

struct WindowEvent
{
    int height;
    WindowEventType type;
    int width;
    int windowID;
    int x;
    int y;
}
