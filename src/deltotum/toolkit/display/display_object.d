module deltotum.toolkit.display.display_object;

import deltotum.maths.vector2d : Vector2d;
import deltotum.maths.shapes.rect2d : Rect2d;
import deltotum.toolkit.display.alignment : Alignment;
import deltotum.maths.geometry.insets : Insets;
import deltotum.toolkit.display.layouts.layout : Layout;
import deltotum.platform.sdl.sdl_texture : SdlTexture;
import deltotum.toolkit.physics.physical_body : PhysicalBody;
import deltotum.toolkit.input.mouse.event.mouse_event : MouseEvent;
import deltotum.core.applications.events.application_event : ApplicationEvent;
import deltotum.toolkit.input.keyboard.event.key_event : KeyEvent;
import deltotum.toolkit.display.events.focus.focus_event : FocusEvent;
import deltotum.toolkit.input.joystick.event.joystick_event : JoystickEvent;
import deltotum.core.events.event_type : EventType;
import deltotum.core.utils.tostring;

import std.container : DList;
import std.math.operations : isClose;
import std.stdio;
import std.math.algebraic : abs;

/**
 * Authors: initkfs
 */
abstract class DisplayObject : PhysicalBody
{
    DisplayObject parent;

    double opacity = 1;
    double angle = 0;
    double scale = 1;

    Vector2d velocity;
    Vector2d acceleration;

    bool isRedraw = true;
    bool isRedrawChildren = true;
    bool isDrawAfterParent = true;
    bool isManaged = true;
    bool isUpdatable = true;
    bool isResizable = true;

    Insets padding;

    Layout layout;
    bool isLayoutManaged = true;
    Alignment alignment = Alignment.none;

    bool isCreated = false;
    bool isFocus = false;
    bool isDraggable = false;
    bool isVisible = true;

    mixin ToString;

    //protected
    //{
    DisplayObject[] children;
    //}

    bool delegate(double, double) onDrag;
    void delegate() invalidateListener;

    //old, new
    void delegate(double, double) onChangeWidthFromTo;
    void delegate(double, double) onChangeHeightFromTo;

    double minWidth = 0;
    double minHeight = 0;

    double maxWidth = double.max;
    double maxHeight = double.max;

    void delegate(double, double) onChangeXFromTo;
    void delegate(double, double) onChangeYFromTo;

    private
    {
        double _x = 0;
        double _y = 0;

        double _width = 0;
        double _height = 0;

        double offsetX = 0;
        double offsetY = 0;
        bool isDrag = false;
        bool valid = true;
    }

    void create()
    {
        super.createHandlers;
        eventMouseHandler = (e) {

            bool isConsumed = runListeners(e);

            if (isConsumed)
            {
                return isConsumed;
            }

            if (e.event == MouseEvent.Event.mouseDown)
            {
                if (isDraggable && bounds.contains(e.x, e.y))
                {
                    startDrag(e.x, e.y);
                }
            }
            else if (e.event == MouseEvent.Event.mouseMove)
            {
                if (isDrag)
                {
                    auto x = e.x + offsetX;
                    auto y = e.y + offsetY;
                    if (onDrag is null || onDrag(x, y))
                    {
                        this.x = x;
                        this.y = y;

                        debug
                        {
                            import std.format : format;

                            string dragInfo = format("Drag. x:%s, y:%s.", x, y);
                            if (parent !is null)
                            {
                                const xInParent = x - parent.x;
                                const yInParent = y - parent.y;
                                dragInfo ~= format("In parent x:%s, y:%s.", xInParent, yInParent);
                            }
                            writefln(dragInfo);
                        }
                    }
                }
            }
            else if (e.event == MouseEvent.Event.mouseUp)
            {
                if (isDraggable && isDrag)
                {
                    stopDrag;
                }

                foreach (DisplayObject child; children)
                {
                    if (child.isDraggable && child.isDrag)
                    {
                        child.stopDrag;
                    }
                }
            }

            return false;
        };

        isCreated = true;
    }

    void buildCreated(DisplayObject obj)
    {
        if (obj.isBuilt)
        {
            throw new Exception("Object already built");
        }

        build(obj);

        if (obj.isCreated)
        {
            throw new Exception("Object already created");
        }

        obj.create;
    }

    void startDrag(double x, double y)
    {
        //TODO parent coordinates
        offsetX = _x - x;
        offsetY = _y - y;
        this.isDrag = true;
    }

    void stopDrag()
    {
        offsetX = 0;
        offsetY = 0;
        this.isDrag = false;
    }

    void dispatchEvent(Target : DisplayObject, Event)(Event e, ref DList!Target chain)
    {
        static if (__traits(compiles, e.target))
        {
            if (e.target !is null && e.target is this)
            {
                chain.insert(this);
                return;
            }
        }

        static if (is(Event : MouseEvent))
        {
            if (bounds.contains(e.x, e.y))
            {
                if (e.event == MouseEvent.Event.mouseMove)
                {
                    if (!isMouseOver)
                    {
                        isMouseOver = true;
                        auto enteredEvent = MouseEvent(EventType.mouse, MouseEvent.Event.mouseEntered, e
                                .ownerId, e
                                .x, e.y, e
                                .button, e.movementX, e.movementY, false);
                        fireEvent(enteredEvent);
                    }

                    chain.insert(this);
                }
                else if (e.isChained)
                {
                    chain.insert(this);
                }
            }
            else
            {
                if (e.event == MouseEvent.Event.mouseMove)
                {
                    if (isMouseOver)
                    {
                        isMouseOver = false;
                        auto exitedEvent = MouseEvent(EventType.mouse, MouseEvent.Event.mouseExited, e
                                .ownerId, e
                                .x, e.y, e
                                .button, e.movementX, e.movementY, false);
                        fireEvent(exitedEvent);
                    }

                    chain.insert(this);
                }
                else if (isDrag && e.isChained)
                {
                    chain.insert(this);
                }
            }

            if (e.event == MouseEvent.Event.mouseMove && (isDrag || bounds.contains(e.x, e
                    .y)))
            {
                chain.insert(this);
            }
        }

        static if (is(Event : KeyEvent))
        {
            if (isFocus)
            {
                chain.insert(this);
            }
        }

        static if (is(Event : JoystickEvent))
        {
            chain.insert(this);
        }

        static if (is(Event : FocusEvent))
        {
            if (e.isChained)
            {
                if (bounds.contains(e.x, e.y))
                {
                    if (!isFocus && e.event == FocusEvent.Event.focusIn)
                    {
                        //TODO move to parent
                        isFocus = true;
                        chain.insert(this);
                    }
                }
                else
                {
                    if (isFocus && e.event == FocusEvent
                        .Event.focusOut)
                    {
                        isFocus = false;
                        chain.insert(this);
                    }
                }

            }
        }

        if (children.length > 0)
        {
            foreach (DisplayObject child; children)
            {
                child.dispatchEvent(e, chain);
            }
        }
    }

    void drawContent()
    {

    }

    bool draw()
    {
        //TODO layer
        bool redraw;

        if (isVisible)
        {
            foreach (DisplayObject obj; children)
            {
                if (!obj.isDrawAfterParent && obj.isVisible)
                {
                    obj.draw;
                }
            }

            if (isRedraw)
            {
                drawContent;
                redraw = true;
            }

            foreach (DisplayObject obj; children)
            {
                if (obj.isDrawAfterParent && obj.isVisible)
                {
                    obj.draw;
                }
            }

        }

        return redraw;
    }

    void requestRedraw()
    {
        isRedraw = true;
    }

    void requestLayout()
    {
        if (layout !is null)
        {
            layout.layout(this);
        }
    }

    void update(double delta)
    {
        if (!isValid)
        {
            if (invalidateListener !is null)
            {
                invalidateListener();
            }

            requestLayout;

            setValid(true);
        }

        double dx = 0;
        double dy = 0;
        if (isUpdatable)
        {
            velocity.x += acceleration.x * delta;
            velocity.y += acceleration.y * delta;
            dx = velocity.x * delta;
            dy = velocity.y * delta;

            _x += dx;
            _y += dy;
        }

        foreach (DisplayObject child; children)
        {
            if (!child.isUpdatable)
            {
                continue;
            }

            if (child.isManaged)
            {
                child.velocity.x = velocity.x;
                child.velocity.y = velocity.y;
                //child.x = child.x + dx;
                //child.y = child.y + dy;
            }

            child.update(delta);
        }
    }

    Rect2d bounds()
    {
        const Rect2d bounds = {x, y, _width, _height};
        return bounds;
    }

    Rect2d geometryBounds()
    {
        const Rect2d bounds = {0, 0, _width, _height};
        return bounds;
    }

    void positionCenter()
    {
        positionCenterX;
        positionCenterY;
    }

    void positionCenterX()
    {
        if (_width > 0)
        {
            x = window.getWidth / 2 - _width / 2;
        }
    }

    void positionCenterY()
    {
        if (_height > 0)
        {
            y = window.getHeight / 2 - _height / 2;
        }
    }

    void destroy()
    {
        foreach (DisplayObject child; children)
        {
            child.parent = null;
            child.destroy;
        }
    }

    void addCreated(DisplayObject obj)
    {
        if (obj is null)
        {
            //TODO logging
            throw new Exception("Cannot add null object");
        }
        build(obj);
        obj.initialize;
        assert(obj.isInitialized);

        if (obj.isManaged)
        {
            obj.x = x + obj.x;
            obj.y = y + obj.y;
        }

        obj.create;

        add(obj);

        //TODO disable flag
        if (layout !is null)
        {
            requestLayout;
        }
    }

    void addOrAddCreated(DisplayObject obj)
    {
        if (obj.isCreated)
        {
            add(obj);
        }
        else
        {
            addCreated(obj);
        }
    }

    void add(DisplayObject obj)
    {
        obj.parent = this;
        //TODO check if exists
        children ~= obj;
    }

    bool has(DisplayObject obj)
    {
        if (obj is null)
        {
            throw new Exception("Unable to check for child existence: object is null");
        }

        foreach (DisplayObject child; children)
        {
            if (obj is child)
            {
                return true;
            }
        }
        return false;
    }

    bool remove(DisplayObject obj)
    {
        if (!has(obj))
        {
            return false;
        }

        import std.algorithm.searching : countUntil;
        import std.algorithm.mutation : remove;

        auto mustBeIndex = children.countUntil(obj);
        if (mustBeIndex < 0)
        {
            return false;
        }

        children = children.remove(mustBeIndex);
        return true;
    }

    Vector2d position() @nogc @safe pure nothrow
    {
        return Vector2d(x, y);
    }

    void xy(double newX, double newY)
    {
        x(newX);
        y(newY);
    }

    double x() @nogc @safe pure nothrow
    {
        return _x;
    }

    void x(double newX)
    {
        foreach (DisplayObject child; children)
        {
            if (child.isManaged && child.layout is null)
            {
                double dx = newX - _x;
                child.x = child.x + dx;
            }
        }

        if (isCreated && onChangeXFromTo !is null)
        {
            onChangeXFromTo(_x, newX);
        }

        _x = newX;

        setInvalid;
    }

    double y() @nogc @safe pure nothrow
    {
        return _y;
    }

    void y(double newY)
    {
        foreach (DisplayObject child; children)
        {
            if (child.isManaged && child.layout is null)
            {
                double dy = newY - _y;
                child.y = child.y + dy;
            }
        }

        if (isCreated && onChangeYFromTo !is null)
        {
            onChangeYFromTo(_y, newY);
        }

        _y = newY;

        setInvalid;
    }

    double width() @nogc @safe pure nothrow
    {
        //TODO children?
        return _width;
    }

    void width(double value)
    {
        //quick but imprecise comparison 
        if (!isResizable || _width == value || value < minWidth || value > maxWidth)
        {
            return;
        }

        immutable double oldWidth = _width;
        _width = value;

        setInvalid;

        if (isCreated && onChangeWidthFromTo !is null)
        {
            onChangeWidthFromTo(oldWidth, _width);
        }

        if (children.length > 0)
        {
            immutable double dw = _width - oldWidth;
            foreach (child; children)
            {
                const newWidth = child.width + dw;
                child.width(newWidth);
            }
        }

    }

    double height() @nogc @safe pure nothrow
    {
        return _height;
    }

    void height(double value)
    {
        ////quick but imprecise comparison 
        if (!isResizable || _height == value || value < minHeight || value > maxHeight)
        {
            return;
        }

        immutable double oldHeight = _height;
        _height = value;

        setInvalid;

        if (isCreated && onChangeHeightFromTo !is null)
        {
            onChangeHeightFromTo(oldHeight, _height);
        }

        if (children.length > 0)
        {
            const dh = _height - oldHeight;
            foreach (child; children)
            {
                const newHeight = child.height + dh;
                child.height(newHeight);
            }
        }
    }

    bool isValid() @nogc @safe pure nothrow
    {
        bool isAllValid = valid;
        foreach (DisplayObject child; children)
        {
            if (!child.isValid && isAllValid)
            {
                isAllValid = false;
            }
        }
        return isAllValid;
    }

    void setValid(bool isValidControl) @nogc @safe pure nothrow
    {
        valid = isValidControl;
        if (valid)
        {
            foreach (DisplayObject child; children)
            {
                if (!child.isValid)
                {
                    child.setValid(true);
                }
            }
        }
    }

    void setInvalid() @nogc @safe pure nothrow
    {
        setValid(false);
    }

    string classnameShort()
    {
        string name;
        const string fullClassName = this.classinfo.name;

        import std.string : lastIndexOf;

        const lastDotPosIndex = fullClassName.lastIndexOf(".");
        if (lastDotPosIndex < 0)
        {
            return name;
        }
        name = fullClassName[lastDotPosIndex + 1 .. $];
        return name;
    }

    void drawBounds()
    {
        import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;
        import deltotum.toolkit.graphics.shapes.rectangle : Rectangle;
        import deltotum.toolkit.graphics.colors.rgba : RGBA;

        auto rect = new Rectangle(width, height, GraphicStyle(1, RGBA.red, false, RGBA.transparent));
        rect.isLayoutManaged = false;
        addCreated(rect);
    }
}
