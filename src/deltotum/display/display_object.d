module deltotum.display.display_object;

import deltotum.application.components.uni.uni_component : UniComponent;

import deltotum.math.vector2d : Vector2d;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.display.alignment : Alignment;
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.physics.physical_body : PhysicalBody;
import deltotum.input.mouse.event.mouse_event : MouseEvent;
import deltotum.application.event.application_event : ApplicationEvent;
import deltotum.input.keyboard.event.key_event : KeyEvent;
import deltotum.input.joystick.event.joystick_event : JoystickEvent;
import deltotum.events.event_type : EventType;
import deltotum.utils.tostring;

import std.math.operations : isClose;
import std.stdio;
import std.math.algebraic : abs;

/**
 * Authors: initkfs
 */
abstract class DisplayObject : PhysicalBody
{
    @property DisplayObject parent;

    @property double opacity = 1;
    @property double angle = 0;
    @property double scale = 1;

    @property Vector2d velocity;
    @property Vector2d acceleration;

    @property bool isRedraw = true;
    @property bool isRedrawChildren = true;
    @property bool isDrawAfterParent = true;
    @property bool isManaged = true;
    @property bool isUpdatable = true;

    @property bool isLayoutManaged = true;
    @property Alignment alignment = Alignment.none;

    @property bool isCreated = false;
    @property bool isFocus = false;
    @property bool isDraggable = false;
    @property bool isVisible = true;

    mixin ToString;

    //protected
    //{
    @property DisplayObject[] children = [];
    //}

    @property bool delegate(double, double) onDrag;
    @property void delegate() invalidateListener;
    @property void delegate(double) onInvalidateWidth;
    @property void delegate(double) onInvalidateHeight;

    private
    {
        @property double _x = 0;
        @property double _y = 0;

        @property double _width = 0;
        @property double _height = 0;

        @property double offsetX = 0;
        @property double offsetY = 0;
        @property bool isDrag = false;
        @property bool valid = true;
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

    void dispatchEvent(T, E)(E e, ref T[] chain, bool isRoot = true)
    {
        static if (__traits(compiles, e.target))
        {
            if (e.target !is null)
            {
                if (e.target is this)
                {
                    chain ~= this;
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
                                        .windowId, e
                                        .x, e.y, e
                                        .button, e.movementX, e.movementY, false);
                                fireEvent(enteredEvent);
                            }

                            chain ~= this;
                        }
                        else if (e.isChained)
                        {
                            chain ~= this;
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
                                        .windowId, e
                                        .x, e.y, e
                                        .button, e.movementX, e.movementY, false);
                                fireEvent(exitedEvent);
                            }

                            chain ~= this;
                        }
                        else if (isDrag && e.isChained)
                        {
                            chain ~= this;
                        }
                    }

                    if (e.event == MouseEvent.Event.mouseMove && (isDrag || bounds.contains(e.x, e
                            .y)))
                    {
                        chain ~= this;
                    }
                }

                static if (is(E : KeyEvent))
                {
                    if (isFocus)
                    {
                        chain ~= this;
                    }
                }

                static if (is(E : JoystickEvent))
                {
                    chain ~= this;
                }
            }
        }

        if (children.length > 0)
        {
            foreach (DisplayObject child; children)
            {
                child.dispatchEvent(e, chain, false);
            }
        }

        if (isRoot && chain.length > 0)
        {
            foreach (DisplayObject eventTarget; chain)
            {
                const isConsumed = eventTarget.runEventFilters(e);
                if (isConsumed)
                {
                    return;
                }
            }

            foreach_reverse (DisplayObject eventTarget; chain)
            {
                const isConsumed = eventTarget.runEventHandlers(e);
                if (isConsumed)
                {
                    return;
                }
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

    @property double x() @nogc @safe pure nothrow
    {
        return _x;
    }

    @property void x(double newX) @nogc @safe pure nothrow
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

    @property double y() @nogc @safe pure nothrow
    {
        return _y;
    }

    @property void y(double newY) @nogc @safe pure nothrow
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

    @property double width() @nogc @safe pure nothrow
    {
        //TODO children?
        return _width;
    }

    @property void width(double value)
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

    @property double height() @nogc @safe pure nothrow
    {
        return _height;
    }

    @property void height(double value)
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

    @property bool isValid() @nogc @safe pure nothrow
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

    @property void setValid(bool isValidControl) @nogc @safe pure nothrow
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
        immutable string fullClassName = this.classinfo.name;

        import std.string : lastIndexOf;

        immutable lastDotPosIndex = fullClassName.lastIndexOf(".");
        if (lastDotPosIndex < 0)
        {
            return name;
        }
        name = fullClassName[lastDotPosIndex + 1 .. $];
        return name;
    }
}
