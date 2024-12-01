module api.dm.kit.windows.window;

import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.kit.factories.factory_kit : FactoryKit;
import api.dm.kit.components.graphics_component : GraphicsComponent;
import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.com.graphics.com_window : ComWindow;
import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.vec2 : Vec2d;

import api.dm.kit.windows.window_manager : WindowManager;
import api.dm.kit.screens.screen : Screen;

import api.core.loggers.logging : Logging;

import api.dm.com.graphics.com_renderer : ComRenderer;

/**
 * Authors: initkfs
 */
class Window : GraphicsComponent
{
    protected
    {
        Scene2d[] _scenes;
    }

    FactoryKit factory;

    private
    {
        Scene2d _currentScene;
    }

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
            if (logging)
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
            const errorMessage = "Window FactoryKit error. " ~ err.toString;
            if (logging)
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

    Scene2d currentScene() @safe pure nothrow
    out (_currentScene; _currentScene !is null)
    {
        return _currentScene;
    }

    void currentScene(Scene2d scene) @safe pure
    {
        import std.exception : enforce;

        enforce(scene !is null, "Scene2d must not be null");

        foreach (currScene; _scenes)
        {
            if (currScene is scene)
            {
                _currentScene = scene;
                return;
            }
        }
        throw new Exception("Scene2d not found in scene list: " ~ scene.name);
    }

    alias build = GraphicsComponent.build;

    void build(Scene2d scene)
    {
        super.build(scene);

        assert(factory, "Scene2d factories must not be null");
        scene.factory = factory;
    }

    alias create = GraphicsComponent.create;

    void create(Scene2d scene)
    {
        import std.exception : enforce;

        enforce(scene !is null, "Scene2d must not be null");

        if (!scene.isBuilt)
        {
            build(scene);
            assert(scene.isBuilt);
        }

        scene.initialize;
        assert(scene.isInitialized);

        scene.create;
        assert(scene.isCreated);
    }

    bool addCreate(Scene2d scene)
    {
        create(scene);
        return add(scene);
    }

    bool add(Scene2d[] scenes...)
    {
        bool isAdd = true;
        foreach (Scene2d scene; scenes)
        {
            isAdd &= add(scene);
        }
        return isAdd;
    }

    bool add(Scene2d scene)
    {
        import std.exception : enforce;

        enforce(scene !is null, "Scene2d must not be null");

        foreach (sc; _scenes)
        {
            if (sc is scene)
            {
                return false;
            }
        }
        _scenes ~= scene;
        return true;
    }

    bool changeByName(string name)
    {
        foreach (sc; _scenes)
        {
            if (sc.name == name)
            {
                setCurrent(sc);
                return true;
            }
        }
        return false;
    }

    void change(Scene2d scene)
    {
        //TODO check in scenes
        import ConfigKeys = api.dm.kit.kit_config_keys;

        if (config.hasKey(ConfigKeys.sceneNameCurrent))
        {
            const sceneName = config.getNotEmptyString(ConfigKeys.sceneNameCurrent);
            if (!sceneName.isNull && changeByName(sceneName.get))
            {
                return;
            }
        }

        setCurrent(scene);
    }

    protected void setCurrent(Scene2d scene)
    {
        assert(scene);

        if (_currentScene && _currentScene.isDestructible)
        {
            _currentScene.dispose;
        }

        if (!scene.isBuilt || scene.isDestructible)
        {
            create(scene);
        }

        _currentScene = scene;
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

    bool draw(double alpha)
    {
        if (!_currentScene)
        {
            return false;
        }

        _currentScene.drawAll;
        return true;
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

        if (isDestroyScenes)
        {
            logger.trace("Start dispose all scenes");
            foreach (Scene2d scene; _scenes)
            {
                const sceneName = scene.name;
                if (scene.isComponentCreated)
                {
                    logger.trace("Found created scene in window: ", sceneName);
                    if (scene.isRunning)
                    {
                        scene.stop;
                        assert(scene.isStopped);
                        logger.trace("Stop created scene: ", sceneName);
                    }

                    scene.dispose;
                    logger.trace("Dispose created scene in window with name: ", sceneName);
                }
                else
                {
                    logger.trace("Scene2d not created, disposing skipped: ", sceneName);
                }
            }
        }

        //after window
        nativeWindow.dispose;
        logger.trace("Dispose native window with id: ", windowId);

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

    override void pause()
    {
        super.pause;
        if (!_currentScene)
        {
            return;
        }
        _currentScene.pause;
    }

    override void run()
    {
        super.run;
        if (!_currentScene)
        {
            return;
        }
        _currentScene.run;
    }

    override void stop()
    {
        super.stop;
        if (!_currentScene)
        {
            return;
        }
        if (_currentScene.isRunning)
        {
            _currentScene.stop;
        }
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

        currentScene.rescale(factorWidth, factorHeigth);
    }

    Rect2d bounds()
    {
        import api.math.geom2.rect2 : Rect2d;

        Rect2d boundsRect = {x, y, width, height};
        return boundsRect;
    }

    Rect2d boundsLocal()
    {
        import api.math.geom2.rect2 : Rect2d;

        Rect2d boundsRect = {0, 0, width, height};
        return boundsRect;
    }

    int halfWidth() => width / 2;
    int halfHeight() => height / 2;

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

    Vec2d pos() => Vec2d(x, y);

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

    void update(double delta)
    {
        if (_currentScene)
        {
            _currentScene.update(delta);
        }

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
}
