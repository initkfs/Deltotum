module app.dm.kit.windows.window;

import app.dm.kit.components.graphics_component : GraphicsComponent;
import app.dm.com.com_native_ptr : ComNativePtr;
import app.dm.com.graphics.com_window : ComWindow;
import app.dm.math.rect2d : Rect2d;
import app.dm.math.vector2 : Vector2;

import app.dm.kit.scenes.scene_manager : SceneManager;
import app.dm.kit.windows.window_manager : WindowManager;
import app.dm.kit.screens.screen : Screen;

import std.logger.core : Logger;

import app.dm.com.graphics.com_renderer : ComRenderer;

/**
 * Authors: initkfs
 */
class Window : GraphicsComponent
{
    Window parent;
    Window delegate(dstring, int, int, int, int, Window) childWindowProvider;
    WindowManager windowManager;

    //import std.container : DList;
    //DList!(void delegate())
    void delegate(double)[] showingTasks;
    size_t showingTaskDelayTicks = 1;

    //Some delegates can be called by the event manager
    void delegate()[] onCreate;
    void delegate()[] onShow;
    void delegate()[] onHide;
    void delegate()[] onMinimize;
    void delegate()[] onMaximize;
    void delegate()[] onClose;
    void delegate()[] onBeforeDestroy;
    void delegate()[] onAfterDestroy;

    void delegate(double, double, double, double)[] onResizeOldNewWidthHeight;

    SceneManager scenes;

    ComRenderer renderer;

    double frameRate = 0;

    bool isDestroyScenes = true;
    bool isDestroyRenderer = true;

    bool isFocus;
    bool isShowing;
    bool isDisposed;

    protected
    {
        ComWindow nativeWindow;

        bool isClosing;
    }

    private
    {
        double lastChangedWidth = 0;
        double lastChangedHeight = 0;

        size_t lastShowingTick = 0;
    }

    this(ComWindow window)
    {
        import std.exception : enforce;

        enforce(window, "Window must not be null");
        this.nativeWindow = window;
    }

    override void initialize()
    {
        super.initialize;
        if (const err = nativeWindow.initialize)
        {
            const errorMessage = "Window initialization error. " ~ err.toString;
            if (logger)
            {
                logger.error(errorMessage);
            }
            throw new Exception(errorMessage);
        }
    }

    override void create()
    {
        super.create;
        if (const err = nativeWindow.create)
        {
            const errorMessage = "Window creation error. " ~ err.toString;
            if (logger)
            {
                logger.error(errorMessage);
            }
            throw new Exception(errorMessage);
        }

        logger.tracef("Create window '%s' with id %d", title, id);

        if (onCreate.length > 0)
        {
            foreach (dg; onCreate)
            {
                dg();
            }
        }
    }

    int id()
    {
        int winId;
        if (const err = nativeWindow.getId(winId))
        {
            logger.error("Error obtain window id", err.toString);
        }
        return winId;
    }

    bool isShown()
    {
        bool value;
        if (const err = nativeWindow.isShown(value))
        {
            logger.error("Error reading window shown state. ", err.toString);
        }
        return value;
    }

    void show()
    {
        if (isShowing)
        {
            //WARNING return
            return;
        }

        if (const err = nativeWindow.show)
        {
            logger.error("Error showing window. ", err.toString);
            //WARNING return
            return;
        }

        isShowing = true;
        //TODO from config
        focusRequest;

        logger.tracef("Show window '%s' with id %d", title, id);
    }

    bool isHidden()
    {
        bool value;
        if (const err = nativeWindow.isHidden(value))
        {
            logger.error("Error reading window hidden state. ", err.toString);
        }
        return value;
    }

    void hide()
    {
        if (!isShowing)
        {
            //WARNING return
            return;
        }

        if (const err = nativeWindow.hide)
        {
            logger.error("Error hiding window. ", err.toString);
            //WARNING return
            return;
        }

        isShowing = false;

        logger.tracef("Hide window '%s' with id %d", title, id);
    }

    void close()
    {
        if (isClosing)
        {
            //WARNING return
            return;
        }

        isClosing = true;
        isShowing = false;

        logger.tracef("Close window '%s' with id %d", title, id);

        dispose;
    }

    void focusRequest()
    {
        if (const err = nativeWindow.focusRequest)
        {
            logger.error("Request focus error in window. ", err.toString);
        }
    }

    bool isMinimized()
    {
        bool value;
        if (const err = nativeWindow.getMinimized(value))
        {
            logger.error("Error reading window minimized property.. ", err.toString);
        }
        return value;
    }

    void minimize()
    {
        if (const err = nativeWindow.setMinimized)
        {
            logger.error("Window minimizing error. ", err.toString);
        }
    }

    bool isMaximized()
    {
        bool value;
        if (const err = nativeWindow.getMaximized(value))
        {
            logger.error("Error reading window maximized property.. ", err.toString);
        }
        return value;
    }

    void maximize()
    {
        if (const err = nativeWindow.setMaximized)
        {
            logger.error("Window maximizing error. ", err.toString);
        }
    }

    void isFullScreen(bool value)
    {
        if (const err = nativeWindow.setFullScreen(value))
        {
            logger.error("Window fullscreen error. ", err.toString);
        }
    }

    bool isFullScreen()
    {
        bool value;
        if (const err = nativeWindow.getFullScreen(value))
        {
            logger.error("Error reading window fullscreen state. ", err.toString);
        }
        return value;
    }

    void restore()
    {
        if (const err = nativeWindow.restore)
        {
            logger.error("Window restoring error. ", err.toString);
        }
    }

    void isDecorated(bool isDecorated)
    {
        if (const err = nativeWindow.setDecorated(isDecorated))
        {
            logger.error("Error changing window decoration property. ", err.toString);
        }
    }

    bool isDecorated()
    {
        bool decorated;
        if (const err = nativeWindow.getDecorated(decorated))
        {
            logger.error("Error changing window decoration property. ", err.toString);
        }
        return decorated;
    }

    void isResizable(bool isResizable)
    {
        if (const err = nativeWindow.setResizable(isResizable))
        {
            logger.error("Window resizable property change error. ", err.toString);
        }
    }

    bool isResizable()
    {
        bool resizable;
        if (const err = nativeWindow.getResizable(resizable))
        {
            logger.error("Error reading window resizable property. ", err.toString);
        }
        return resizable;
    }

    void resize(double newWidth, double newHeight)
    {
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
        if (onResizeOldNewWidthHeight.length > 0)
        {
            foreach (dg; onResizeOldNewWidthHeight)
            {
                dg(lastChangedWidth, lastChangedHeight, newWidth, newHeight);
            }
        }

        import std.math.operations : isClose;

        double factorWidth = isClose(lastChangedWidth, newWidth) ? 1 : newWidth / lastChangedWidth;
        double factorHeigth = isClose(lastChangedHeight, newHeight) ? 1 : newHeight / lastChangedHeight;

        lastChangedWidth = newWidth;
        lastChangedHeight = newHeight;

        scenes.currentScene.rescale(factorWidth, factorHeigth);
    }

    Rect2d bounds()
    {
        import app.dm.math.rect2d : Rect2d;

        Rect2d boundsRect = {x, y, width, height};
        return boundsRect;
    }

    Rect2d boundsLocal()
    {
        import app.dm.math.rect2d : Rect2d;

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

    void pos(int x, int y)
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

    dstring title()
    {
        dstring winTitle;
        if (const err = nativeWindow.getTitle(winTitle))
        {
            logger.tracef("Error getting window title. ", err.toString);
        }
        return winTitle;
    }

    void title(dstring title)
    {
        import std.string : toStringz;
        import std.conv : to;

        //TODO dup\copy?
        if (const err = nativeWindow.setTitle(title))
        {
            logger.error("Error setting window title: ", err.toString);
        }
    }

    void setNormalWindow()
    {
        isDecorated(true);
        isResizable(true);
    }

    int getScreenIndex()
    {
        size_t index;
        if (const err = nativeWindow.getScreenIndex(index))
        {
            logger.error("Error getting screen from window: ", err.toString);
            return -1;
        }
        import std.conv : to;

        //not cast(int) for overflow detection
        return index.to!int;
    }

    override void run()
    {
        super.run;
        scenes.run;
    }

    override void stop()
    {
        super.stop;
        scenes.stop;
    }

    bool draw(double alpha)
    {
        bool isDraw = scenes.draw(alpha);
        return isDraw;
    }

    void update(double delta)
    {
        scenes.update(delta);

        if (isShowing && showingTasks.length > 0)
        {
            lastShowingTick++;
            if (lastShowingTick >= showingTaskDelayTicks)
            {
                lastShowingTick = 0;
                foreach (task; showingTasks)
                {
                    task(delta);
                }
                showingTasks = null;
            }
        }
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

    void nativePtr(out ComNativePtr ptr)
    {
        if (const err = nativeWindow.nativePtr(ptr))
        {
            logger.error("Native window pointer is invalid");
        }
    }

    override void dispose()
    {
        assert(!isDisposed);

        const windowId = id;
        logger.tracef("Start dispose window '%s' with id %d", title, windowId);

        //TODO close child windows
        if (onBeforeDestroy.length > 0)
        {
            foreach (dg; onBeforeDestroy)
            {
                dg();
            }
        }

        if (const err = nativeWindow.close)
        {
            logger.error("Window closing error. ", err.toString);
            //WARNING return
            return;
        }

        super.dispose;

        if (renderer && isDestroyRenderer)
        {
            renderer.dispose;
            logger.trace("Dispose renderer in window with id: ", windowId);
        }

        if (scenes && isDestroyScenes)
        {
            scenes.dispose;
            logger.trace("Dispose scenes in window with id: ", windowId);
        }

        //after window
        nativeWindow.dispose;
        logger.trace("Dispose native window with id: ", windowId);

        parent = null;

        onCreate = null;
        onShow = null;
        onHide = null;
        onClose = null;
        onMinimize = null;
        onMaximize = null;
        onBeforeDestroy = null;
        onResizeOldNewWidthHeight = null;

        isDisposed = true;

        if (onAfterDestroy.length > 0)
        {
            foreach (dg; onAfterDestroy)
            {
                dg();
            }
        }

        onAfterDestroy = null;
    }
}
