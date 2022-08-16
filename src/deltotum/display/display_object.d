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

    @property double width = 0;
    @property double height = 0;

    @property double opacity = 1;
    @property double angle = 0;
    @property double scale = 1;

    @property Vector2d velocity;
    @property Vector2d acceleration;

    @property bool isRedraw = true;
    @property bool isRedrawChildren = true;
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

    private
    {
        @property double _x = 0;
        @property double _y = 0;
        @property double offsetX = 0;
        @property double offsetY = 0;
        @property bool isDrag = false;
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
                        debug writefln("Drag parent. x:%s, y:%s", x, y);
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
        foreach (DisplayObject child; children)
        {
            if (child.isVisible)
            {
                child.drawContent;
            }
        }
    }

    bool draw()
    {
        //TODO layer
        bool redraw;
        if (isVisible && isRedraw)
        {
            drawContent;
            redraw = true;
        }

        // if (isVisible && isRedrawChildren)
        // {
        //     foreach (DisplayObject child; children)
        //     {
        //         if (!child.isVisible || !child.isRedraw)
        //         {
        //             continue;
        //         }
        //         //child.draw;
        //         child.drawContent;
        //         if (!redraw)
        //         {
        //             redraw = true;
        //         }
        //     }
        // }

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
            child.update(delta);
            if (child.isManaged)
            {
                child.velocity.x = velocity.x;
                child.velocity.y = velocity.y;
                child.x = child.x + dx;
                child.y = child.y + dy;
            }
        }
    }

    Rect2d bounds()
    {
        const Rect2d bounds = {x, y, width, height};
        return bounds;
    }

    Rect2d geometryBounds()
    {
        const Rect2d bounds = {0, 0, width, height};
        return bounds;
    }

    void positionCenter(){
        positionCenterX;
        positionCenterY;
    }

    void positionCenterX()
    {
        if (width > 0)
        {
            x = window.getWidth / 2 - width / 2;
        }
    }

    void positionCenterY()
    {
        if (height > 0)
        {
            y = window.getHeight / 2 - height / 2;
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
}
