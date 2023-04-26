module deltotum.kit.windows.window;

import deltotum.core.applications.components.units.services.loggable_unit : LoggableUnit;
import deltotum.com.windows.com_window : ComWindow;
import deltotum.sys.sdl.sdl_window : SdlWindow;
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.vector2d : Vector2d;

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
    Window parent;
    WindowManager windowManager;

    SceneManager scenes;

    //TODO remove
    double frameRate;

    bool isFocus;
    bool isShowing;
    bool isClosing;

    bool isResizable = true;
    bool isDecorated = true;

    bool isAlreadyOnTop = true;
    bool isFullscreen;

    bool isMinimized;
    bool isMaximized;

    protected
    {
        ComWindow nativeWindow;
    }

    //TODO remove renderer
    SdlRenderer renderer;

    this(Logger logger, ComWindow window)
    {
        super(logger);
        this.nativeWindow = window;
    }

    void create()
    {
        super.initialize;
        if (const err = nativeWindow.initialize)
        {
            logger.error("Window initialization error. ", err.toString);
        }

        if (const err = nativeWindow.create)
        {
            throw new Exception(err.toString);
        }

        setDecorated(isDecorated);
        setResizable(isResizable);
        
    }

    void show()
    {
        if (isShowing)
        {
            return;
        }

        if (const err = nativeWindow.show)
        {
            logger.error("Error showing window. ", err.toString);
        }
    }

    void close()
    {
        if (isClosing)
        {
            return;
        }

        if (const err = nativeWindow.close)
        {
            logger.error("Window closing error. ", err.toString);
            return;
        }

        isClosing = true;
    }

    void focusRequest()
    {
        if (const err = nativeWindow.focusRequest)
        {
            logger.error("Request focus error in window. ", err.toString);
        }
    }

    int width()
    {
        int width, height;
        if (const err = nativeWindow.getSize(width, height))
        {
            logger.error("Getting window size error for width. ", err.toString);
        }
        return width;
    }

    int height()
    {
        int width, height;
        if (const err = nativeWindow.getSize(width, height))
        {
            logger.error("Getting window size error for height. ", err.toString);
        }
        return height;
    }

    void setPos(int x, int y)
    {
        if (const err = nativeWindow.setPos(x, y))
        {
            logger.errorf("Window coordinate setting error, x: %s, y: %s. %s", x, y, err.toString);
        }
    }

    int x()
    {
        int x, y;
        if (const err = nativeWindow.getPos(x, y))
        {
            logger.tracef("Error getting window position 'x'. ", err.toString);
        }
        return x;
    }

    int y()
    {
        int x, y;
        if (const err = nativeWindow.getPos(x, y))
        {
            logger.tracef("Error getting window position 'y'. ", err.toString);
        }
        return y;
    }

    Rect2d getWorldBounds()
    {
        import deltotum.math.shapes.rect2d : Rect2d;

        Rect2d boundsRect = {x, y, width, height};
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

        long windowWidth = width;

        //TODO height
        double scale = (cast(double)(outputWidth)) / windowWidth;
        return scale;
    }

    void move(int x, int y)
    {
        //TODO check bounds
        if (const err = nativeWindow.setPos(x, y))
        {
            //TODO logging
        }
    }

    void setSize(int width, int height)
    {
        //TODO check bounds
        if (const err = nativeWindow.setSize(width, height))
        {
            //TODO logging;
        }
    }

    void setDecorated(bool isDecorated)
    {
        //TODO set lazy
        if (const err = nativeWindow.setDecorated(isDecorated))
        {
            logger.error("Error changing window decoration property. ", err.toString);
        }
    }

    void setMaximized(bool isMaximized)
    {
        if (isMaximized)
        {
            if (const err = nativeWindow.maximize)
            {
                logger.error("Window maximizing error. ", err.toString);
            }
            return;
        }

        if (const err = nativeWindow.restore)
        {
            //TODO logging;
        }
    }

    void setMinimized(bool isMinimized)
    {
        if (isMinimized)
        {
            if (const err = nativeWindow.minimize)
            {
                logger.error("Window minimizing error. ", err.toString);
            }
            return;
        }

        if (const err = nativeWindow.restore)
        {
            //TODO logging
        }
    }

    void setResizable(bool isResizable)
    {
        if (const err = nativeWindow.setResizable(isResizable))
        {
            logger.error("Window resizable property change error. ", err.toString);
        }
    }

    string getTitle()
    {
        const(char)[] buff;
        if (const err = nativeWindow.getTitle(buff))
        {
            //TODO logging
        }
        import std.conv : to;

        return buff.to!string;
    }

    int id()
    {
        int winId;
        if (const err = nativeWindow.obtainId(winId))
        {
            logger.error("Error getting window id", err.toString);
        }
        return winId;
    }

    void setTitle(dstring title)
    {
        import std.string : toStringz;
        import std.conv : to;

        if (const err = nativeWindow.setTitle(title.to!string.toStringz))
        {
            //TODO logging
        }
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
}
