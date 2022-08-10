module deltotum.window.window;

import deltotum.hal.sdl.sdl_window : SdlWindow;
import deltotum.hal.sdl.sdl_renderer : SdlRenderer;
import deltotum.math.shapes.rect2d : Rect2d;

//TODO move to deltotum.hal;
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Window
{
    @property SdlRenderer renderer;
    @property SdlWindow nativeWindow;
    //TODO remove
    @property double frameRate;

    this(SdlRenderer renderer, SdlWindow window)
    {
        this.renderer = renderer;
        this.nativeWindow = window;
    }

    void close()
    {
        destroy;
    }

    void present() @nogc nothrow
    {
        renderer.present;
    }

    void focus() @nogc nothrow
    {
        nativeWindow.focus;
    }

    int getWidth() @nogc nothrow
    {
        int width, height;
        nativeWindow.getSize(&width, &height);
        return width;
    }

    int getHeight() @nogc nothrow
    {
        int width, height;
        nativeWindow.getSize(&width, &height);
        return height;
    }

    uint getId() @nogc nothrow
    {
        return nativeWindow.getId;
    }

    int getX() @nogc nothrow
    {
        int x, y;
        nativeWindow.getPos(&x, &y);
        return x;
    }

    int getY() @nogc nothrow
    {
        int x, y;
        nativeWindow.getPos(&x, &y);
        return y;
    }

    Rect2d getWorldBounds() @nogc nothrow {
        auto bounds = nativeWindow.getWorldBounds;
        Rect2d boundsRect = {bounds.x, bounds.y, bounds.w, bounds.h};
        return boundsRect;
    }

    Rect2d getScaleBounds() @nogc nothrow
    {
        auto bounds = nativeWindow.getScaleBounds;
        Rect2d boundsRect = {bounds.x, bounds.y, bounds.w, bounds.h};
        return boundsRect;
    }

    double getScale() @nogc nothrow
    {
        int outputWidth;
        int outputHeight;

        //TODO check errors
        renderer.getOutputSize(&outputWidth, &outputHeight);

        int windowWidth;
        int windowHeight;

        nativeWindow.getSize(&windowWidth, &windowHeight);
        //TODO height
        double scale = (cast(double)(outputWidth)) / windowWidth;
        return scale;
    }

    void move(int x, int y) @nogc nothrow
    {
        //TODO check bounds
        nativeWindow.move(x, y);
    }

    void resize(int width, int height) @nogc nothrow
    {
        //TODO check bounds
        nativeWindow.resize(width, height);
    }

    void setBorder(bool border) @nogc nothrow
    {
        //TODO set lazy
        nativeWindow.setBordered(border);
    }

    void setMaximized(bool isMaximized) @nogc nothrow
    {
        if (isMaximized)
        {
            nativeWindow.maximize;
            return;
        }

        nativeWindow.restore;
    }

    void setMinimized(bool isMinimized) @nogc nothrow
    {
        if (isMinimized)
        {
            nativeWindow.minimize;
            return;
        }

        nativeWindow.restore;
    }

    void setResizable(bool isResizable) @nogc nothrow
    {
        nativeWindow.setResizable(isResizable);
    }

    void setTitle(string title) nothrow
    {
        nativeWindow.setTitle(title);
    }

    void destroy()
    {
        renderer.destroy;
        //after window
        nativeWindow.destroy;
    }
}
