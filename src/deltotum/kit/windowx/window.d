module deltotum.kit.windows.window;

import deltotum.core.applications.components.units.services.loggable_unit : LoggableUnit;
import deltotum.sys.sdl.sdl_window : SdlWindow;
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.vector2d : Vector2d;
import deltotum.kit.input.mouse.mouse_cursor_type : MouseCursorType;
import deltotum.kit.scene.scene_manager : SceneManager;
import deltotum.kit.windows.window_manager : WindowManager;

import std.logger.core : Logger;

//TODO move to deltotum.platforms;
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Window : LoggableUnit
{
    int id;

    size_t _width;
    size_t _height;

    long _x;
    long _y;

    Window parent;
    WindowManager windowManager;

    SceneManager scenes;

    //TODO remove
    double frameRate;

    bool isFocus;
    bool isShowing;

    bool isAlreadyOnTop;
    bool isFullscreen;
    bool isUndecorated;
    bool isResizable;
    bool isMinimized;
    bool isMaximized;

    //SDL_SetWindowModalFor(SDL_Window* modal_window, SDL_Window* parent_window);

    private
    {
        SdlRenderer renderer;
        SdlWindow nativeWindow;
    }

    this(Logger logger, SdlRenderer renderer, SdlWindow window)
    {
        super(logger);
        this.renderer = renderer;
        this.nativeWindow = window;
    }

    void show()
    {
        nativeWindow.minSize(cast(int) width, cast(int) height);
        if (const err = nativeWindow.show)
        {
            logger.errorf("Error when showing window: ", err.toString);
        }
    }

    void close()
    {
        destroy;
    }

    void focusRequest()
    {
        if (const err = nativeWindow.focusRequest)
        {
            logger.error("Request focus error in window: ", err.toString);
        }
    }

    int getWidth()
    {
        int width, height;
        nativeWindow.getSize(&width, &height);
        return width;
    }

    int getHeight()
    {
        int width, height;
        nativeWindow.getSize(&width, &height);
        return height;
    }

    uint getId()
    {
        return nativeWindow.getId;
    }

    int getX()
    {
        int x, y;
        nativeWindow.getPos(&x, &y);
        return x;
    }

    int getY()
    {
        int x, y;
        nativeWindow.getPos(&x, &y);
        return y;
    }

    Rect2d getWorldBounds()
    {
        auto bounds = nativeWindow.getWorldBounds;
        Rect2d boundsRect = {bounds.x, bounds.y, bounds.w, bounds.h};
        return boundsRect;
    }

    // Rect2d getScaleBounds() @nogc nothrow
    // {
    //     auto bounds = nativeWindow.getScaleBounds;
    //     Rect2d boundsRect = {bounds.x, bounds.y, bounds.w, bounds.h};
    //     return boundsRect;
    // }

    double getScale()
    {
        int outputWidth;
        int outputHeight;

        if (const err = renderer.getOutputSize(&outputWidth, &outputHeight))
        {
            //TODO logging
            return 0;
        }

        int windowWidth;
        int windowHeight;

        nativeWindow.getSize(&windowWidth, &windowHeight);
        //TODO height
        double scale = (cast(double)(outputWidth)) / windowWidth;
        return scale;
    }

    void move(int x, int y)
    {
        //TODO check bounds
        nativeWindow.move(x, y);
    }

    void resize(int width, int height)
    {
        //TODO check bounds
        nativeWindow.resize(width, height);
    }

    void setBorder(bool border)
    {
        //TODO set lazy
        if(const err = nativeWindow.setDecorated(border)){
            logger.error("Error changing window decoration property: ", err.toString);
        }
    }

    void setMaximized(bool isMaximized)
    {
        if (isMaximized)
        {
            if (const err = nativeWindow.maximize)
            {
                logger.error("Window maximizing error: ", err.toString);
            }
            return;
        }

        nativeWindow.restore;
    }

    void setMinimized(bool isMinimized)
    {
        if (isMinimized)
        {
            if(const err = nativeWindow.minimize){
                logger.error("Window minimizing error: ", err.toString);
            }
            return;
        }

        nativeWindow.restore;
    }

    void setResizable(bool isResizable)
    {
        if(const err = nativeWindow.setResizable(isResizable)){
            logger.error("Window resizable property change error: ", err.toString);
        }
    }

    void setTitle(string title) nothrow
    {
        nativeWindow.setTitle(title);
    }

    void restoreCursor()
    {
        if (const err = nativeWindow.restoreCursor)
        {
            //TODO logging
            throw new Exception(err.toString);
        }
    }

    void setCursor(MouseCursorType type)
    {
        if (const err = nativeWindow.setCursor(type))
        {
            //TODO logging
            throw new Exception(err.toString);
        }
    }

    Vector2d mousePos()
    {
        int x, y;
        nativeWindow.mousePos(&x, &y);
        return Vector2d(x, y);
    }

    void update(double delta)
    {
        scenes.currentScene.update(delta);
    }

    void destroy()
    {
        //TODO close child windows
        renderer.destroy;
        if (scenes !is null)
        {
            scenes.destroy;
        }
        //after window
        nativeWindow.destroy;
    }

    size_t width() const @nogc nothrow pure @safe
    {
        return _width;
    }

    void width(size_t value)
    {
        _width = value;
    }

    size_t height() const @nogc nothrow pure @safe
    {
        return _height;
    }

    void height(size_t value)
    {
        _height = value;
    }

    size_t x()
    {
        return _x;
    }

    void x(size_t value)
    {
        _x = value;
    }

    size_t y()
    {
        return _y;
    }

    void y(size_t value)
    {
        _y = value;
    }
}
