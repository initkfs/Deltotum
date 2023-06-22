module deltotum.kit.windows.window;

import deltotum.core.apps.uni.uni_component : UniComponent;
import deltotum.com.gui.com_window : ComWindow;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.vector2d : Vector2d;

import deltotum.kit.scenes.scene_manager : SceneManager;
import deltotum.kit.windows.window_manager : WindowManager;
import deltotum.kit.screens.screen : Screen;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 *
 * Window cannot contain a circular reference to itself. Therefore, it cannot be a graphical component.
 *
 * Window does not contain a renderer because the rendering implementation may change in the future.
 */
class Window : UniComponent
{
    Window parent;
    Window delegate(dstring, int, int, int, int, Window) childWindowProvider;
    WindowManager windowManager;

    void delegate() onAfterDestroy;
    void delegate() onCreate;
    void delegate() onShow;
    void delegate() onHide;
    void delegate() onClose;
    void delegate(double, double, double, double) onResizeOldNewWidthHeight;

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
        double lastChangedWidth;
        double lastChangedHeight;
    }

    this(Logger logger, ComWindow window)
    {
        assert(logger);
        assert(window);
        this.logger = logger;
        this.nativeWindow = window;
    }

    override void initialize()
    {
        super.initialize;
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

        if (onCreate)
        {
            onCreate();
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

        if (onShow)
        {
            onShow();
        }
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

        if (onHide)
        {
            onHide();
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

        windowManager.remove(this);
        isClosing = true;
        destroy;

        if (onClose)
        {
            onClose();
        }
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

    void setSize(double newWidth, double newHeight)
    {
        //TODO check bounds
        if (const err = nativeWindow.setSize(cast(int) newWidth, cast(int) newHeight))
        {
            logger.errorf("Resizing window error, new width %s, height %s, current width %s, height %s", newWidth, newHeight, width, height);
            return;
        }
        lastChangedWidth = width;
        lastChangedHeight = height;
    }

    void confirmResize(double newWidth, double newHeight)
    {
        if (onResizeOldNewWidthHeight)
        {
            onResizeOldNewWidthHeight(lastChangedWidth, lastChangedHeight, newWidth, newHeight);
        }

        import std.math.operations : isClose;

        double factorWidth = isClose(lastChangedWidth, newWidth) ? 1 : newWidth / lastChangedWidth;
        double factorHeigth = isClose(lastChangedHeight, newHeight) ? 1 : newHeight / lastChangedHeight;

        lastChangedWidth = newWidth;
        lastChangedHeight = newHeight;

        scenes.currentScene.scale(factorWidth, factorHeigth);
    }

    Rect2d bounds()
    {
        import deltotum.math.shapes.rect2d : Rect2d;

        Rect2d boundsRect = {x, y, width, height};
        return boundsRect;
    }

    Rect2d boundsLocal()
    {
        import deltotum.math.shapes.rect2d : Rect2d;

        Rect2d boundsRect = {0, 0, width, height};
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
            logger.error("Error setting window title: ", err.toString);
        }
    }

    void setNormalWindow()
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

    bool draw()
    {
        auto currScene = scenes.currentScene;
        if (!currScene)
        {
            return false;
        }

        currScene.draw;
        return true;
    }

    bool update(double delta)
    {
        auto currScene = scenes.currentScene;
        if (!currScene)
        {
            return false;
        }

        currScene.update(delta);
        return true;
    }

    Window newChildWindow(dstring title = "New window", int width = 450, int height = 200, int x = -1, int y = -1)
    {
        Window win = newRootWindow(title, width, height, x, y, this);
        return win;
    }

    Window newRootWindow(dstring title = "New window", int width = 450, int height = 200, int x = -1, int y = -1, Window parent = null)
    {
        if (!childWindowProvider)
        {
            throw new Exception("Unable to open child windows. Window provider not installed");
        }

        Window newWindow = childWindowProvider(title, width, height, x, y, parent);
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

        //TODO close child windows

        //after window
        nativeWindow.destroy;
        isDestroyed = true;

        if (onAfterDestroy)
        {
            onAfterDestroy();
        }
    }
}
