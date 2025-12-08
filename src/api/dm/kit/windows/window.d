module api.dm.kit.windows.window;

import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.kit.scenes.scene3d : Scene3d;
import api.dm.com.graphics.com_screen : ComScreenId;
import api.dm.kit.factories.factory_kit : FactoryKit;
import api.dm.kit.components.graphic_component : GraphicComponent;
import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.com.graphics.com_window : ComWindowId, ComWindow, ComWindowProgressState;
import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.vec2 : Vec2d, Vec2i;

//TODO extract COM interfaces
import api.dm.back.sdl3.gpu.sdl_gpu_device : SdlGPUDevice;

import api.dm.kit.screens.single_screen : SingleScreen;

import api.core.loggers.logging : Logging;

import api.dm.com.graphics.com_renderer : ComRenderer;
import api.dm.gui.themes.icons.icon_name;

/**
 * Authors: initkfs
 */
class Window : GraphicComponent
{
    enum : int
    {
        defaultWidth = 400,
        defaultHeight = 400,
        defaultPosX = -1,
        defaultPosY = -1
    }

    protected
    {
        Scene2d[] _scenes;
        Scene2d _currentScene;

        ComWindow comWindow;

        bool isClosing;

        double lastChangedWidth = 0;
        double lastChangedHeight = 0;

        size_t lastShowingTick = 0;
    }

    Window parent;
    SingleScreen screen;
    FactoryKit factory;
    ComRenderer renderer;

    SdlGPUDevice gpuDevice;

    Window delegate(dstring, int, int, int, int, Window) childWindowProvider;
    void delegate(double, double, double, double)[] onResizeOldNewWidthHeight;

    void delegate(double)[] showingTasks;
    size_t showingTaskDelayTicks = 1;

    void delegate(double)[] drawingSceneTasks;

    //Some delegates can be called by the event manager
    void delegate()[] onCreate;
    void delegate()[] onShow;
    void delegate()[] onHide;
    void delegate()[] onMinimize;
    void delegate()[] onMaximize;
    void delegate()[] onClose;
    void delegate()[] onBeforeDestroy;
    void delegate()[] onAfterDestroy;

    double frameRate = 0;

    bool isDestroyScenes = true;
    bool isDestroyRenderer = true;

    bool isFocus;
    bool isShowing;
    bool isDisposed;

    this(ComWindow window)
    {
        import std.exception : enforce;

        enforce(window, "Window must not be null");
        this.comWindow = window;
    }

    override void create()
    {
        super.create;

        if (const err = comWindow.create)
        {
            throw new Exception(err.toString);
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

        enforce(scene, "Scene must not be null");

        foreach (currScene; _scenes)
        {
            if (currScene is scene)
            {
                _currentScene = scene;
                return;
            }
        }

        throw new Exception("Scene not found in scene list: " ~ scene.name);
    }

    alias build = GraphicComponent.build;

    void build(Scene2d scene)
    {
        super.build(scene);

        assert(factory, "Scene factories must not be null");
        scene.factory = factory;
    }

    alias create = GraphicComponent.create;

    void create(Scene2d scene)
    {
        import std.exception : enforce;

        enforce(scene, "Scene must not be null");

        if (!scene.isBuilt)
        {
            build(scene);
            assert(scene.isBuilt);
        }

        scene.initialize;
        assert(scene.isInitializing);

        scene.create;
        assert(scene.isCreating);

        if (gpu.isActive)
        {
            if (auto scene3d = cast(Scene3d) scene)
            {
                scene3d.uploadToGPU;
            }
        }
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

        enforce(scene !is null, "Scene must not be null");

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

    bool change(Scene2d scene)
    {
        //TODO check in scenes
        import ConfigKeys = api.dm.kit.kit_config_keys;

        if (config.hasKey(ConfigKeys.sceneNameCurrent))
        {
            const sceneName = config.getNotEmptyString(ConfigKeys.sceneNameCurrent);
            return changeByName(sceneName);
        }

        return setCurrent(scene);
    }

    protected bool setCurrent(Scene2d scene)
    {
        assert(scene);

        if (_currentScene is scene)
        {
            return false;
        }

        if (_currentScene && _currentScene.isDestructible)
        {
            _currentScene.dispose;
        }

        if (!scene.isBuilt || scene.isDestructible)
        {
            //TODO initialization
            create(scene);
        }

        _currentScene = scene;
        return true;
    }

    ComWindowId id()
    {
        ComWindowId winId;
        if (const err = comWindow.getId(winId))
        {
            logger.error(err.toString);
        }
        return winId;
    }

    bool isShown()
    {
        bool value;
        if (const err = comWindow.isShown(value))
        {
            logger.error(err.toString);
        }
        return value;
    }

    bool show()
    {
        if (isShowing)
        {
            //WARNING return
            return false;
        }

        if (const err = comWindow.show)
        {
            logger.error(err.toString);
            return false;
        }

        isShowing = true;
        //TODO from config
        focusRequest;

        logger.tracef("Show window '%s' with id %d", title, id);
        return true;
    }

    bool isHidden()
    {
        bool value;
        if (const err = comWindow.isHidden(value))
        {
            logger.error(err.toString);
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

        if (drawingSceneTasks.length > 0)
        {
            foreach (dg; drawingSceneTasks)
            {
                dg(alpha);
            }
            drawingSceneTasks = null;
        }

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

        if (const err = comWindow.close)
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
                        assert(scene.isStopping);
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
        comWindow.dispose;
        logger.trace("Dispose native window with id: ", windowId);

        //TODO all fields
        // onCreate = null;
        // onShow = null;
        // onHide = null;
        // onClose = null;
        // onMinimize = null;
        // onMaximize = null;
        // onBeforeDestroy = null;
        // onResizeOldNewWidthHeight = null;

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

    bool hide()
    {
        if (!isShowing)
        {
            return false;
        }

        if (const err = comWindow.hide)
        {
            logger.error(err.toString);
            return false;
        }

        isShowing = false;

        logger.tracef("Hide window '%s' with id %d", title, id);
        return true;
    }

    bool close()
    {
        if (isClosing)
        {
            //WARNING return
            return false;
        }

        isClosing = true;
        isShowing = false;

        logger.tracef("Close window '%s' with id %d", title, id);

        dispose;
        return true;
    }

    bool focusRequest()
    {
        if (const err = comWindow.focusRequest)
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool isMinimized()
    {
        bool value;
        if (const err = comWindow.getMinimized(value))
        {
            logger.error(err.toString);
        }
        return value;
    }

    bool minimize()
    {
        if (const err = comWindow.setMinimized)
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool isMaximized()
    {
        bool value;
        if (const err = comWindow.getMaximized(value))
        {
            logger.error(err.toString);
        }
        return value;
    }

    bool maximize()
    {
        if (const err = comWindow.setMaximized)
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool isFullScreen(bool value)
    {
        if (const err = comWindow.setFullScreen(value))
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool isFullScreen()
    {
        bool value;
        if (const err = comWindow.getFullScreen(value))
        {
            logger.error(err.toString);
        }
        return value;
    }

    bool restore()
    {
        if (const err = comWindow.restore)
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool isDecorated(bool isDecorated)
    {
        if (const err = comWindow.setDecorated(isDecorated))
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool isDecorated()
    {
        bool decorated;
        if (const err = comWindow.getDecorated(decorated))
        {
            logger.error(err.toString);
        }
        return decorated;
    }

    bool isResizable(bool isResizable)
    {
        if (const err = comWindow.setResizable(isResizable))
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool isResizable()
    {
        bool resizable;
        if (const err = comWindow.getResizable(resizable))
        {
            logger.error(err.toString);
        }
        return resizable;
    }

    bool resize(double newWidth, double newHeight)
    {
        if (const err = comWindow.setSize(cast(int) newWidth, cast(int) newHeight))
        {
            logger.errorf("Resizing window error, new width %s, height %s, current width %s, height %s: %s", newWidth, newHeight, width, height, err);
            return false;
        }
        lastChangedWidth = width;
        lastChangedHeight = height;
        return true;
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
        double factorHeight = isClose(lastChangedHeight, newHeight) ? 1 : newHeight / lastChangedHeight;

        lastChangedWidth = newWidth;
        lastChangedHeight = newHeight;

        currentScene.rescale(factorWidth, factorHeight);
    }

    Rect2d boundsInScreen()
    {
        const Vec2d winPos = pos;
        const Vec2d winSize = size;

        return Rect2d(winPos.x, winPos.y, winSize.x, winSize.y);
    }

    alias boundsRect = boundsLocal;

    Rect2d boundsLocal()
    {
        const Vec2d winSize = size;
        return Rect2d(0, 0, winSize.x, winSize.y);
    }

    Rect2d boundsSafe()
    {
        Rect2d bounds;
        if (const err = comWindow.getSafeBounds(bounds))
        {
            logger.error(err.toString);
        }
        return bounds;
    }

    double halfWidth() => width / 2;
    double halfHeight() => height / 2;

    double frameCount(double delayMsec)
    {
        import Math = api.math;

        if (frameRate == 0)
        {
            return 0;
        }

        return Math.round(delayMsec / (1000 / frameRate));
    }

    double width()
    {
        int width;
        if (const err = comWindow.getWidth(width))
        {
            logger.error(err.toString);
        }
        return width;
    }

    double height()
    {
        int height;
        if (const err = comWindow.getHeight(height))
        {
            logger.error(err.toString);
        }
        return height;
    }

    uint widthu() => cast(uint) width;
    uint heightu() => cast(uint) height;

    Vec2d size()
    {
        int width, height;
        if (const err = comWindow.getSize(width, height))
        {
            logger.error(err.toString);
        }
        return Vec2d(width, height);
    }

    Vec2d pos()
    {
        int x, y;
        if (const err = comWindow.getPos(x, y))
        {
            logger.trace(err.toString);
        }
        return Vec2d(x, y);
    }

    bool pos(Vec2d newPos)
    {
        return pos(newPos.x, newPos.y);
    }

    bool pos(double x, double y)
    {
        if (const err = comWindow.setPos(cast(int) x, cast(int) y))
        {
            logger.errorf("Window coordinate setting error, x: %s, y: %s. %s", x, y, err.toString);
            return false;
        }
        return true;
    }

    double x() => pos.x;
    double y() => pos.y;

    dstring title()
    {
        dstring winTitle;
        if (const err = comWindow.getTitle(winTitle))
        {
            logger.error(err.toString);
        }
        return winTitle;
    }

    bool title(dstring title)
    {
        import std.string : toStringz;
        import std.conv : to;

        //TODO dup\copy?
        if (const err = comWindow.setTitle(title))
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool setNormalWindow()
    {
        return isDecorated(true) && isResizable(true);
    }

    ComScreenId screenId()
    {
        ComScreenId id;
        if (const err = comWindow.getScreenId(id))
        {
            logger.error(err.toString);
            return 0;
        }
        return id;
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

    import api.math.geom2.vec2 : Vec2d;

    Vec2d dpiRatio()
    {
        const winSize = size;

        double winWidth = winSize.x;
        double winHeight = winSize.y;

        auto renderBounds = graphic.renderBounds;
        if (renderBounds.width == 0 || renderBounds.height == 0)
        {
            return Vec2d.init;
        }

        double hRatio = renderBounds.width / winWidth;
        double vRatio = renderBounds.height / winHeight;

        return Vec2d(hRatio, vRatio);
    }

    bool startTextInput()
    {
        if (const err = comWindow.startTextInput)
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool endTextInput()
    {
        if (const err = comWindow.endTextInput)
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool progress(float value) => comWindow.setProgress(value);

    float progress()
    {
        float value;
        if (!comWindow.getProgress(value))
        {
            return 0;
        }
        return value;
    }

    ComWindowProgressState progressState()
    {
        ComWindowProgressState state;
        if (!comWindow.getProgressState(state))
        {
            return ComWindowProgressState.none;
        }

        return state;
    }

    bool progressState(ComWindowProgressState state) => comWindow.setProgressState(state);

    bool nativePtr(out ComNativePtr ptr)
    {
        if (const err = comWindow.nativePtr(ptr))
        {
            logger.error("Native window pointer is invalid");
            return false;
        }
        return true;
    }

    void* rawPtr() => comWindow.rawPtr;
}
