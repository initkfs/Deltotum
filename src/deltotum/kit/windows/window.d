module deltotum.kit.windows.window;

import deltotum.com.windows.com_window : ComWindow;
import deltotum.sys.sdl.sdl_window : SdlWindow;
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.vector2d : Vector2d;

import deltotum.kit.scenes.scene_manager : SceneManager;
import deltotum.kit.windows.window_manager : WindowManager;
import deltotum.kit.windows.factories.window_factory : WindowFactory;
import deltotum.kit.screens.screen : Screen;

import std.logger.core : Logger;

//TODO move to deltotum.platforms;
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Window
{
    Window parent;
    Window delegate(dstring, int, int, int, int, WindowFactory) childWindowProvider;
    WindowManager windowManager;

    void delegate() onAfterDestroy;

    SceneManager scenes;

    //TODO remove
    double frameRate;

    bool isFocus;
    bool isShowing;
    bool isDestroyed;

    protected
    {
        ComWindow nativeWindow;

        bool isClosing;
    }

    private
    {
        Logger logger;
    }

    //TODO remove renderer
    SdlRenderer renderer;

    this(Logger logger, ComWindow window)
    {
        assert(logger);
        assert(window);
        this.logger = logger;
        this.nativeWindow = window;
    }

    void initialize()
    {
        if (const err = nativeWindow.initialize)
        {
            logger.error("Window initialization error. ", err.toString);
        }
    }

    void create()
    {
        if (const err = nativeWindow.create)
        {
            throw new Exception(err.toString);
        }
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

    void show()
    {
        if (isShowing)
        {
            return;
        }

        if (const err = nativeWindow.show)
        {
            logger.error("Error showing window. ", err.toString);
            return;
        }
        isShowing = true;

        //TODO from config
        focusRequest;
    }

    void hide()
    {
        if (!isShowing)
        {
            return;
        }

        if (const err = nativeWindow.hide)
        {
            logger.error("Error hiding window. ", err.toString);
            return;
        }
        isShowing = false;
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

        windowManager.remove(this);
        isClosing = true;
        destroy;
    }

    void focusRequest()
    {
        if (const err = nativeWindow.focusRequest)
        {
            logger.error("Request focus error in window. ", err.toString);
        }
    }

    void minimize()
    {
        if (const err = nativeWindow.minimize)
        {
            logger.error("Window minimizing error. ", err.toString);
        }
    }

    void maximize()
    {
        if (const err = nativeWindow.maximize)
        {
            logger.error("Window maximizing error. ", err.toString);
        }
    }

    void restore()
    {
        if (const err = nativeWindow.restore)
        {
            logger.error("Window restoring error. ", err.toString);
        }
    }

    void setDecorated(bool isDecorated)
    {
        if (const err = nativeWindow.setDecorated(isDecorated))
        {
            logger.error("Error changing window decoration property. ", err.toString);
        }
    }

    void setResizable(bool isResizable)
    {
        if (const err = nativeWindow.setResizable(isResizable))
        {
            logger.error("Window resizable property change error. ", err.toString);
        }
    }

    void setSize(int width, int height)
    {
        //TODO check bounds
        if (const err = nativeWindow.setSize(width, height))
        {
            logger.errorf("Resizing window error, new width %s, height %s, current width %s, height %s", width, height, this
                    .width, this.height);
        }
    }

    Rect2d bounds()
    {
        import deltotum.math.shapes.rect2d : Rect2d;

        Rect2d boundsRect = {x, y, width, height};
        return boundsRect;
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

    double getScaleFactor()
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

    void setTitle(dstring title)
    {
        import std.string : toStringz;
        import std.conv : to;

        if (const err = nativeWindow.setTitle(title.to!string.toStringz))
        {
            //TODO logging
        }
    }

    void setNormatWindow()
    {
        setDecorated(true);
        setResizable(true);
    }

    int getScreenIndex()
    {
        size_t screenIndex;
        if (const err = nativeWindow.getScreenIndex(screenIndex))
        {
            logger.error("Error getting screen from window: ", err.toString);
            return -1;
        }
        import std.conv : to;

        return screenIndex.to!int;
    }

    bool update(double delta)
    {
        auto currScene = scenes.currentScene;
        if (!currScene)
        {
            return false;
        }

        currScene.update(delta);
        currScene.draw;

        return true;
    }

    Window newChildWindow(dstring title = "New window", int width = 450, int height = 200, int x = -1, int y = -1, WindowFactory windowProvider = null)
    {
        Window win = newRootWindow(title, width, height, x, y, windowProvider);
        win.parent = this;
        return win;
    }

    Window newRootWindow(dstring title = "New window", int width = 450, int height = 200, int x = -1, int y = -1, WindowFactory windowProvider = null)
    {
        if (!childWindowProvider)
        {
            throw new Exception("Unable to open child windows. Window provider not installed");
        }

        Window newWindow = childWindowProvider(title, width, height, x, y, windowProvider);
        return newWindow;
    }

    void nativePtr(out void* ptr)
    {
        if (const err = nativeWindow.nativePtr(ptr))
        {
            logger.error("Native window pointer is invalid");
            ptr = null;
        }
    }

    void destroy()
    {
        parent = null;
        childWindowProvider = null;

        //TODO close child windows
        renderer.destroy;

        //after window
        nativeWindow.destroy;
        isDestroyed = true;

        if(onAfterDestroy){
            onAfterDestroy();
        }

        onAfterDestroy = null;
    }
}
