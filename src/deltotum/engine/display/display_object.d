module deltotum.engine.display.display_object;

import deltotum.core.maths.vector2d : Vector2d;
import deltotum.core.maths.shapes.rect2d : Rect2d;
import deltotum.engine.display.alignment : Alignment;
import deltotum.platforms.sdl.sdl_texture : SdlTexture;
import deltotum.engine.physics.physical_body : PhysicalBody;
import deltotum.engine.input.mouse.event.mouse_event : MouseEvent;
import deltotum.core.applications.events.application_event : ApplicationEvent;
import deltotum.engine.input.keyboard.event.key_event : KeyEvent;
import deltotum.engine.input.joystick.event.joystick_event : JoystickEvent;
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
    void delegate(double) onInvalidateWidth;
    void delegate(double) onInvalidateHeight;

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

    void dispatchEvent(T, E)(E e, ref DList!T chain)
    {
        static if (__traits(compiles, e.target))
        {
            if (e.target !is null)
            {
                if (e.target is this)
                {
                    chain.insert(this);
                }
            }
            else
            {
                static if (is(E : MouseEvent))
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

                static if (is(E : KeyEvent))
                {
                    if (isFocus)
                    {
                        chain.insert(this);
                    }
                }

                static if (is(E : JoystickEvent))
                {
                    chain.insert(this);
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

    void invalidate()
    {
        if (invalidateListener !is null)
        {
            invalidateListener();
        }
    }

    bool draw()
    {
        //TODO layer
        bool redraw;

        if (isVisible)
        {
            if (!isValid)
            {
                invalidate;
                setValid(true);
            }

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

    void update(double delta)
    {
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
        obj.create;
        add(obj);
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
        if (obj.isManaged)
        {
            obj.x = x + obj.x;
            obj.y = y + obj.y;
        }
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

    void xy(double x, double y) @nogc @safe pure nothrow
    {
        this.x = x;
        this.y = y;
    }

    double x() @nogc @safe pure nothrow
    {
        return _x;
    }

    void x(double newX) @nogc @safe pure nothrow
    {
        foreach (DisplayObject child; children)
        {
            if (child.isManaged)
            {
                double dx = newX - _x;
                child.x = child.x + dx;
            }
        }
        _x = newX;
    }

    double y() @nogc @safe pure nothrow
    {
        return _y;
    }

    void y(double newY) @nogc @safe pure nothrow
    {
        foreach (DisplayObject child; children)
        {
            if (child.isManaged)
            {
                double dy = newY - _y;
                child.y = child.y + dy;
            }
        }
        _y = newY;
    }

    double width() @nogc @safe pure nothrow
    {
        //TODO children?
        return _width;
    }

    void width(double value)
    {
        if (_width == value)
        {
            return;
        }

        if (isCreated && onInvalidateWidth !is null)
        {
            onInvalidateWidth(value);
            setInvalid;
        }
        _width = value;
    }

    double height() @nogc @safe pure nothrow
    {
        return _height;
    }

    void height(double value)
    {
        if (_height == value)
        {
            return;
        }

        if (isCreated && onInvalidateHeight !is null)
        {
            onInvalidateHeight(value);
            setInvalid;
        }

        _height = value;
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
}
