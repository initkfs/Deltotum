module deltotum.display.display_object;

import deltotum.application.components.uni.uni_component : UniComponent;

import deltotum.math.vector2d : Vector2D;
import deltotum.math.rect : Rect;
import deltotum.hal.sdl.sdl_texture : SdlTexture;
import deltotum.physics.physical_body : PhysicalBody;

import std.math.operations : isClose;
import std.stdio;
import std.math.algebraic : abs;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
abstract class DisplayObject : PhysicalBody
{
    @property double width = 0;
    @property double height = 0;
    @property Vector2D* velocity;
    @property Vector2D* acceleration;
    @property bool isRedraw = false;
    @property double opacity = 1;
    @property double angle = 0;
    @property double scale = 1;
    @property bool isManaged = true;
    @property bool isDraggable = false;

    protected
    {
        @property DisplayObject[] children = [];
    }

    private
    {
        @property double _x = 0;
        @property double _y = 0;
        @property double offsetX = 0;
        @property double offsetY = 0;
        @property bool isDrag = false;
    }

    this()
    {
        super();
        //use initialization in constructor
        //TODO move to physical body?
        velocity = new Vector2D;
        acceleration = new Vector2D;
    }

    void create()
    {
        import deltotum.input.mouse.event.mouse_event : MouseEvent;

        //TODO add listeners
        events.onMouseListeners ~= (e) {
            if (e.event == MouseEvent.Event.MOUSE_DOWN)
            {
                if (isDraggable && bounds.contains(e.x, e.y))
                {
                    startDrag(e.x, e.y);
                }

                foreach (DisplayObject child; children)
                {
                    if (child.isDraggable)
                    {
                        auto localBounds = child.bounds;
                        localBounds.x = localBounds.x + _x;
                        localBounds.y = localBounds.y + _y;
                        if (localBounds.contains(e.x, e.y))
                        {
                            child.startDrag(e.x, e.y);
                        }

                    }
                }
            }
            else if (e.event == MouseEvent.Event.MOUSE_MOVE)
            {
                if (isDrag)
                {
                    x = e.x + offsetX;
                    y = e.y + offsetY;
                    debug writefln("Drag parent. x:%s, y:%s", x, y);
                }

                foreach (DisplayObject child; children)
                {
                    if (child.isDrag)
                    {
                        child.x = e.x + offsetX;
                        child.y = e.y + offsetY;
                        debug writefln("Drag child. x:%s, y:%s", child.x, child.y);
                    }
                }
            }
            else if (e.event == MouseEvent.Event.MOUSE_UP)
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
        };
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

    void drawContent()
    {

    }

    int drawTexture(SdlTexture texture, Rect textureBounds, int x = 0, int y = 0, double angle = 0, SDL_RendererFlip flip = SDL_RendererFlip
            .SDL_FLIP_NONE)
    {
        {
            SDL_Rect srcRect;
            srcRect.x = cast(int) textureBounds.x;
            srcRect.y = cast(int) textureBounds.y;
            srcRect.w = cast(int) textureBounds.width;
            srcRect.h = cast(int) textureBounds.height;

            Rect bounds = window.getScaleBounds;

            SDL_Rect destRect;
            destRect.x = cast(int)(x + bounds.x);
            destRect.y = cast(int)(y + bounds.y);
            destRect.w = cast(int) width;
            destRect.h = cast(int) height;

            //FIXME some texture sizes can crash when changing the angle
            //double newW = height * abs(Math.sinDeg(angle)) + width * abs(Math.cosDeg(angle));
            //double newH = height * abs(Math.cosDeg(angle)) + width * abs(Math.sinDeg(angle));

            //TODO compare double
            if (!isClose(texture.opacity, opacity))
            {
                texture.opacity = opacity;
            }
            return window.renderer.copyEx(texture, &srcRect, &destRect, angle, null, flip);
        }
    }

    final bool draw()
    {
        //TODO layer
        drawContent;

        foreach (DisplayObject child; children)
        {
            child.drawContent;
        }

        return true;
    }

    void requestRedraw()
    {
        isRedraw = true;
    }

    void update(double delta)
    {
        velocity.x += acceleration.x * delta;
        velocity.y += acceleration.y * delta;
        const dx = velocity.x * delta;
        const dy = velocity.y * delta;

        _x += dx;
        _y += dy;

        foreach (DisplayObject child; children)
        {
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

    Rect bounds()
    {
        const Rect bounds = {x, y, width, height};
        return bounds;
    }

    void destroy()
    {
        foreach (DisplayObject child; children)
        {
            child.destroy;
        }
    }

    void add(DisplayObject obj)
    {
        if (obj.isManaged)
        {
            obj.x = x + obj.x;
            obj.y = y + obj.y;
        }
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
            double dx = newX - _x;
            child.x = child.x + dx;
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
            double dy = newY - _y;
            child.y = child.y + dy;
        }
        _y = newY;
    }
}
