module api.dm.kit.windows.window;

import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.kit.scenes.scene3d : Scene3d;
import api.dm.com.graphics.com_screen : ComScreenId;
import api.dm.kit.factories.factory_kit : FactoryKit;
import api.dm.kit.components.graphic_component : GraphicComponent;
import api.dm.com.ptrs.com_native_ptr : ComNativePtr;
import api.dm.com.graphics.com_window : ComWindowId, ComWindow, ComWindowProgressState;
import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.vec2 : Vec2f, Vec2i;
import api.dm.kit.apps.loops.counters.fps_update_counter : FpsUpdateCounter;
import api.dm.kit.apps.loops.counters.fps_update_counter : FpsUpdateCounter;
import api.dm.kit.apps.loops.counters.fps_fixed_counter : FpsFixedCounter;

import api.dm.kit.events.kit_event_manager : KitEventManager;

//TODO extract COM interfaces
import api.dm.back.sdl3.gpu.sdl_gpu_device : SdlGPUDevice;

import api.dm.kit.screens.single_screen : SingleScreen;

import api.core.loggers.logging : Logging;

import api.dm.com.graphics.com_renderer : ComRenderer;

import std.stdio : File;

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

        ComWindow _comWindow;

        bool isClosing;

        float lastChangedWidth = 0;
        float lastChangedHeight = 0;

        size_t lastShowingTick = 0;
    }

    KitEventManager events;

    FpsUpdateCounter updateCounter;
    FpsFixedCounter fixedCounter;
    float timeDrawSceneMs = 0;
    float timeUpdateSceneMs = 0;

    Window parent;
    SingleScreen screen;
    FactoryKit factory;
    ComRenderer renderer;

    SdlGPUDevice gpuDevice;

    Window delegate(dstring, int, int, int, int, Window) childWindowProvider;
    void delegate(float, float, float, float)[] onResizeOldNewWidthHeight;

    void delegate(float)[] showingTasks;
    size_t showingTaskDelayTicks = 5;

    void delegate(float)[] drawingSceneTasks;

    void delegate()[] onShow;
    void delegate()[] onHide;

    //Some delegates can be called by the event manager
    void delegate()[] onCreate;
    void delegate()[] onDisappear;
    void delegate()[] onMinimize;
    void delegate()[] onMaximize;
    void delegate()[] onClose;
    void delegate()[] onBeforeDestroy;
    void delegate()[] onAfterDestroy;

    float frameRate = 0;

    bool isDestroyScenes = true;
    bool isDestroyRenderer = true;

    bool isFocus;
    bool isShowing;
    bool isDisposed;

    //TODO remove
    File* fpsLog;

    this(ComWindow window, KitEventManager eventManager)
    {
        if (!window)
        {
            throw new Exception("Window must not be null");
        }
        this._comWindow = window;

        if (!eventManager)
        {
            throw new Exception("Event manager must not be null");
        }
        this.events = eventManager;

        //TODO di
        updateCounter = new FpsUpdateCounter;
        fixedCounter = new FpsFixedCounter;
    }

    override void create()
    {
        super.create;

        if (const err = _comWindow.create)
        {
            throw new Exception(err.toString);
        }

        version (EnableTrace)
        {
            logger.tracef("Create window '%s' with id %d", title, id);
        }

        if (onCreate.length > 0)
        {
            foreach (dg; onCreate)
            {
                dg();
            }
        }
    }

    void createWithRenderer()
    {
        super.create;

        if (const err = _comWindow.createWithRenderer)
        {
            throw new Exception(err.toString);
        }

        version (EnableTrace)
        {
            logger.tracef("Create with renderer window '%s' with id %d", title, id);
        }

        if (onCreate.length > 0)
        {
            foreach (dg; onCreate)
            {
                dg();
            }
        }
    }

    void fireForAll(E)(ref E e)
    {
        events.dispatchEvent(e);
    }

    Scene2d currentScene() @safe pure nothrow
    out (_currentScene; _currentScene !is null)
    {
        return _currentScene;
    }

    void currentScene(Scene2d scene) @safe pure
    {
        if (!scene)
        {
            throw new Exception("Scene must not be null");
        }

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
        if (!scene)
        {
            throw new Exception("Scene must not be null");
        }

        if (!scene.isBuilt)
        {
            build(scene);
            assert(scene.isBuilt);
        }

        if (!scene.isInitializing)
        {
            initialize(scene);
        }

        if (!scene.isCreating)
        {
            super.create(scene);
        }

        if (platform.cap.isGPU)
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
        if (!scene)
        {
            throw new Exception("Scene must not be null");
        }

        foreach (sc; _scenes)
        {
            if (sc is scene)
            {
                return false;
            }
        }
        _scenes ~= scene;

        if (scene.isAutoSizeToWindow)
        {
            scene.width = width;
            scene.height = height;
        }

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
        if (const err = _comWindow.getId(winId))
        {
            throw new Exception(err.toString);
        }
        return winId;
    }

    bool isShown()
    {
        bool value;
        if (const err = _comWindow.isShown(value))
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

        if (const err = _comWindow.show)
        {
            throw new Exception(err.toString);
        }

        isShowing = true;
        //TODO from config
        focusRequest;

        version (EnableTrace)
        {
            logger.tracef("Show window '%s' with id %d", title, id);
        }
        return true;
    }

    bool isHidden()
    {
        bool value;
        if (const err = _comWindow.isHidden(value))
        {
            logger.error(err.toString);
        }
        return value;
    }

    bool draw(float alpha)
    {
        if (!_currentScene)
        {
            return false;
        }

        float startTimeMs = platform.timer.ticksMs;

        _currentScene.drawAll(alpha);

        if (drawingSceneTasks.length > 0)
        {
            foreach (dg; drawingSceneTasks)
            {
                dg(alpha);
            }
            drawingSceneTasks = null;
        }

        timeDrawSceneMs = platform.timer.ticksMs - startTimeMs;

        return true;
    }

    override void dispose()
    {
        assert(!isDisposed);

        const windowId = id;
        version (EnableTrace)
        {
            logger.tracef("Start dispose window '%s' with id %d", title, windowId);
        }

        if (fpsLog && fpsLog.isOpen)
        {
            fpsLog.close;
            version (EnableTrace)
            {
                logger.infof("Close fps log for window id %d: %s", windowId, fpsLog.name);
            }
        }

        //TODO close child windows
        if (onBeforeDestroy.length > 0)
        {
            foreach (dg; onBeforeDestroy)
            {
                dg();
            }
        }

        if (const err = _comWindow.close)
        {
            logger.error("Window closing error: " ~ err.toString);
            //WARNING return
            return;
        }

        super.dispose;

        if (renderer && isDestroyRenderer)
        {
            renderer.dispose;
        }

        if (gpuDevice && _comWindow && !_comWindow.isDisposed)
        {
            if (const err = gpuDevice.removeFromWindow(_comWindow))
            {
                logger.warning(err.toString);
            }

            version (EnableTrace)
            {
                logger.trace("Release window from GPU device");
            }
        }

        if (isDestroyScenes)
        {
            foreach (Scene2d scene; _scenes)
            {
                const sceneName = scene.name;
                if (scene.isComponentCreated)
                {
                    if (scene.isRunning)
                    {
                        scene.stop;
                        assert(scene.isStopping);
                    }

                    scene.dispose;
                    version (EnableTrace)
                    {
                        logger.trace("Dispose created scene in window with name: " ~ sceneName);
                    }
                }
            }
        }

        //after window
        _comWindow.dispose;
        version (EnableTrace)
        {
            logger.tracef("Dispose native window with id: %d", windowId);
        }

        //TODO all fields
        // onCreate = null;
        // onShow = null;
        // onDisappear = null;
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

        if (const err = _comWindow.hide)
        {
            logger.error(err.toString);
            return false;
        }

        isShowing = false;

        version (EnableTrace)
        {
            logger.tracef("Hide window '%s' with id %d", title, id);
        }
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
        version (EnableTrace)
        {
            logger.tracef("Close window '%s' with id %d", title, id);
        }
        dispose;
        return true;
    }

    bool focusRequest()
    {
        if (const err = _comWindow.focusRequest)
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool isMinimized()
    {
        bool value;
        if (const err = _comWindow.getMinimized(value))
        {
            logger.error(err.toString);
        }
        return value;
    }

    bool minimize()
    {
        if (const err = _comWindow.setMinimized)
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool isMaximized()
    {
        bool value;
        if (const err = _comWindow.getMaximized(value))
        {
            logger.error(err.toString);
        }
        return value;
    }

    bool maximize()
    {
        if (const err = _comWindow.setMaximized)
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool isFullScreen(bool value)
    {
        if (const err = _comWindow.setFullScreen(value))
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool isFullScreen()
    {
        bool value;
        if (const err = _comWindow.getFullScreen(value))
        {
            logger.error(err.toString);
        }
        return value;
    }

    bool restore()
    {
        if (const err = _comWindow.restore)
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool isDecorated(bool isDecorated)
    {
        if (const err = _comWindow.setDecorated(isDecorated))
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool isDecorated()
    {
        bool decorated;
        if (const err = _comWindow.getDecorated(decorated))
        {
            logger.error(err.toString);
        }
        return decorated;
    }

    bool isResizable(bool isResizable)
    {
        if (const err = _comWindow.setResizable(isResizable))
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool isResizable()
    {
        bool resizable;
        if (const err = _comWindow.getResizable(resizable))
        {
            logger.error(err.toString);
        }
        return resizable;
    }

    bool resize(float newWidth, float newHeight)
    {
        if (const err = _comWindow.setSize(cast(int) newWidth, cast(int) newHeight))
        {
            logger.errorf("Resizing window error, new width %s, height %s, current width %s, height %s: %s", newWidth, newHeight, width, height, err);
            return false;
        }
        lastChangedWidth = width;
        lastChangedHeight = height;

        foreach (sc; _scenes)
        {
            if (sc.isAutoSizeToWindow)
            {
                sc.width = newWidth;
                sc.height = newHeight;
            }
        }

        return true;
    }

    void confirmResize(float newWidth, float newHeight)
    {
        if (onResizeOldNewWidthHeight.length > 0)
        {
            foreach (dg; onResizeOldNewWidthHeight)
            {
                dg(lastChangedWidth, lastChangedHeight, newWidth, newHeight);
            }
        }

        import std.math.operations : isClose;

        float factorWidth = isClose(lastChangedWidth, newWidth) ? 1 : newWidth / lastChangedWidth;
        float factorHeight = isClose(lastChangedHeight, newHeight) ? 1 : newHeight / lastChangedHeight;

        lastChangedWidth = newWidth;
        lastChangedHeight = newHeight;

        currentScene.rescale(factorWidth, factorHeight);
    }

    Rect2f boundsInScreen()
    {
        const Vec2f winPos = pos;
        const Vec2f winSize = size;

        return Rect2f(winPos.x, winPos.y, winSize.x, winSize.y);
    }

    alias boundsRect = boundsLocal;

    Rect2f boundsLocal()
    {
        const Vec2f winSize = size;
        return Rect2f(0, 0, winSize.x, winSize.y);
    }

    Rect2f boundsSafe()
    {
        Rect2f bounds;
        if (const err = _comWindow.getSafeBounds(bounds))
        {
            logger.error(err.toString);
        }
        return bounds;
    }

    float halfWidth() => width / 2;
    float halfHeight() => height / 2;

    float frameCount(float delayMsec)
    {
        import Math = api.math;

        if (frameRate == 0)
        {
            return 0;
        }

        return Math.round(delayMsec / (1000 / frameRate));
    }

    float width()
    {
        int width;
        if (const err = _comWindow.getWidth(width))
        {
            logger.error(err.toString);
        }

        return width;
    }

    float height()
    {
        int height;
        if (const err = _comWindow.getHeight(height))
        {
            logger.error(err.toString);
        }
        return height;
    }

    uint widthu() => cast(uint) width;
    uint heightu() => cast(uint) height;

    Vec2f size()
    {
        int width, height;
        if (const err = _comWindow.getSize(width, height))
        {
            logger.error(err.toString);
        }
        return Vec2f(width, height);
    }

    Vec2f pos()
    {
        int x, y;
        if (const err = _comWindow.getPos(x, y))
        {
            logger.error(err.toString);
        }
        return Vec2f(x, y);
    }

    bool pos(Vec2f newPos)
    {
        return pos(newPos.x, newPos.y);
    }

    bool pos(float x, float y)
    {
        if (const err = _comWindow.setPos(cast(int) x, cast(int) y))
        {
            logger.errorf("Window coordinate setting error, x: %s, y: %s. %s", x, y, err.toString);
            return false;
        }
        return true;
    }

    float x() => pos.x;
    float y() => pos.y;

    dstring title()
    {
        dstring winTitle;
        if (const err = _comWindow.getTitle(winTitle))
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
        if (const err = _comWindow.setTitle(title))
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
        if (const err = _comWindow.getScreenId(id))
        {
            logger.error(err.toString);
            return 0;
        }
        return id;
    }

    void updateFrameStat(float startMs, float deltaMs, size_t physUpdateCount)
    {
        updateCounter.update(deltaMs);
        fixedCounter.update(deltaMs, physUpdateCount);

        if (fpsLog && fpsLog.isOpen)
        {
            try
            {
                fpsLog.writefln("%f %f", updateCounter.fps, fixedCounter.fps);
            }
            catch (Exception e)
            {
                logger.error(e.toString);
            }
        }
    }

    void update(float startMs, float deltaMs, float fixedDeltaSec)
    {

        float startTimeMs = platform.timer.ticksMs;

        if (_currentScene)
        {
            _currentScene.update(fixedDeltaSec);
        }

        if (isShowing && showingTasks.length > 0)
        {
            lastShowingTick++;
            if (lastShowingTick >= showingTaskDelayTicks)
            {
                lastShowingTick = 0;
                foreach (task; showingTasks)
                {
                    task(fixedDeltaSec);
                }
                showingTasks = null;
            }
        }

        timeUpdateSceneMs = platform.timer.ticksMs - startTimeMs;
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

    import api.math.geom2.vec2 : Vec2f;

    Vec2f dpiRatio()
    {
        const winSize = size;

        float winWidth = winSize.x;
        float winHeight = winSize.y;

        auto renderBounds = graphic.renderBounds;
        if (renderBounds.width == 0 || renderBounds.height == 0)
        {
            return Vec2f.init;
        }

        float hRatio = renderBounds.width / winWidth;
        float vRatio = renderBounds.height / winHeight;

        return Vec2f(hRatio, vRatio);
    }

    bool startTextInput()
    {
        if (const err = _comWindow.startTextInput)
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool endTextInput()
    {
        if (const err = _comWindow.endTextInput)
        {
            logger.error(err.toString);
            return false;
        }
        return true;
    }

    bool progress(float value) => _comWindow.setProgress(value);

    float progress()
    {
        float value;
        if (!_comWindow.getProgress(value))
        {
            return 0;
        }
        return value;
    }

    ComWindowProgressState progressState()
    {
        ComWindowProgressState state;
        if (!_comWindow.getProgressState(state))
        {
            return ComWindowProgressState.none;
        }

        return state;
    }

    bool progressState(ComWindowProgressState state) => _comWindow.setProgressState(state);

    float pixelDensity()
    {
        float density;
        if (const err = _comWindow.getPixelDensity(density))
        {
            logger.error(err.toString);
        }
        return density;
    }

    ComWindow comWindow() => _comWindow;
    ComNativePtr nativePtr() => _comWindow.nativePtr;
    void* rawPtr() => _comWindow.rawPtr;
}
