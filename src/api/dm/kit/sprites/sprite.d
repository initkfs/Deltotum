module api.dm.kit.sprites.sprite;

import api.dm.kit.events.event_kit_target : EventKitTarget;
import api.math.vector2 : Vector2;
import api.math.rect2d : Rect2d;
import api.math.alignment : Alignment;
import api.math.insets : Insets;
import api.dm.kit.sprites.layouts.layout : Layout;
import api.dm.kit.sprites.textures.rgba_texture : RgbaTexture;
import api.dm.kit.scenes.scaling.scale_mode : ScaleMode;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.core.apps.events.app_event : AppEvent;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.dm.kit.events.focus.focus_event : FocusEvent;
import api.dm.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import api.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.contexts.graphics_context : GraphicsContext;
import api.dm.kit.scenes.scene : Scene;

import std.container : DList;
import std.math.operations : isClose;
import std.stdio;
import std.math.algebraic : abs;
import std.typecons : Nullable;

import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.kit.graphics.colors.rgba : RGBA;

import Math = api.dm.math;

struct InvalidationState
{
    bool x, y, width, height, visible, managed, layout;

    void reset()
    {
        foreach (field, ref fieldValue; this.tupleof)
        {
            fieldValue = false;
        }
    }
}

/**
 * Authors: initkfs
 */
class Sprite : EventKitTarget
{
    enum debugFlag = "d_debug";

    string id;

    Sprite parent;

    protected
    {
        double _angle = 0;
    }

    double scale = 1;
    double mass = 1;
    double speed = 0;

    double _opacity = 1;
    double maxOpacity = double.max;
    bool isOpacityForChildren;

    bool isPhysicsEnabled;

    Vector2 velocity;
    Vector2 acceleration;

    Sprite isCollisionProcess;
    Sprite[] targetsForCollisions;

    bool delegate(Sprite, Sprite) onCollision;

    Rect2d clip;
    bool isMoveClip;
    bool isResizeClip;
    void delegate(Rect2d* clip) onClipResize;
    void delegate(Rect2d* clip) onClipMove;
    //TODO remove
    bool isClipped;

    bool inScreenBounds;
    bool delegate() onScreenBoundsIsStop;

    bool isDrawByParent = true;
    bool isRedraw = true;
    bool isRedrawChildren = true;
    bool isDrawAfterParent = true;
    bool _managed = true;
    bool isUpdatable = true;
    bool isResizable;
    bool isKeepAspectRatio;
    bool isForwardEventsToChildren = true;

    Layout layout;
    bool _layoutManaged = true;

    bool isResizeChildren;
    bool isResizeChildrenIfNoLayout = true;
    bool isResizeChildrenIfNotLManaged = true;
    bool isResizeChildrenIfNotResizable;
    bool isResizeChildrenAlways;

    bool isResizedByParent;

    bool isManagedByScene;

    Insets _padding;
    Insets _margin;
    bool isHGrow;
    bool isVGrow;

    Alignment alignment = Alignment.none;
    ScaleMode scaleMode = ScaleMode.none;

    bool isCreated;
    bool isFocus;
    bool isDraggable;
    bool isScalable;
    bool isDrawClip;

    bool isDrawBounds;
    RGBA boundsColor = RGBA.red;

    bool _visible = true;
    bool isReceiveEvents = true;

    //protected
    //{
    //TODO information about children
    Sprite[] children;
    //}

    bool delegate(double, double) onDragXY;

    InvalidationState invalidationState;
    void delegate()[] invalidateListeners;

    //old, new
    void delegate(double, double) onChangeWidthOldNew;
    void delegate(double, double) onChangeHeightOldNew;

    void delegate(double, double)[] onResize;

    double minWidth = 1.0;
    double minHeight = 1.0;

    Scene delegate() sceneProvider;

    version (SdlBackend)
    {
        //TODO correct max size
        double maxWidth = 16384;
        double maxHeight = 16384;
    }
    else
    {
        double maxWidth = double.max;
        double maxHeight = double.max;
    }

    void delegate(double, double) onChangeXOldNew;
    void delegate(double, double) onChangeYOldNew;

    bool isInvalidationProcess;
    bool isValidatableChildren = true;

    bool isValid = true;

    Object[string] userData;

    protected
    {
        RgbaTexture _cache;
        Sprite _hitbox;
        GraphicsContext _gContext;

        double _width = 0;
        double _height = 0;
    }

    private
    {
        double _x = 0;
        double _y = 0;

        double offsetX = 0;
        double offsetY = 0;

        bool _cached;
    }

    bool isDrag;

    enum double defaultTrashold = 0.01;

    double xChangeThreshold = defaultTrashold;
    double yChangeThreshold = defaultTrashold;
    double widthChangeThreshold = defaultTrashold;
    double heightChangeThreshold = defaultTrashold;

    bool isConstructed;

    this()
    {
        isConstructed = true;
    }

    void buildCreate(Sprite sprite)
    {
        assert(sprite);

        if (!sprite.isBuilt)
        {
            build(sprite);
            assert(sprite.isBuilt, "Sprite not built: " ~ sprite.className);

            sprite.initialize;
            assert(sprite.isInitialized, "Sprite not initialized: " ~ sprite.className);
        }

        if (!sprite.isCreated)
        {
            sprite.create;
            assert(sprite.isCreated, "Sprite not created: " ~ sprite.className);
        }
    }

    void onResume()
    {

    }

    override void run()
    {
        if (isPaused)
        {
            onResume;
        }

        super.run;
    }

    override void create()
    {
        if (isCreated)
        {
            //logger.warning("Trying to create a sprite twice: ", className);
            return;
        }

        super.create;

        if (isCached)
        {
            recreateCache;
        }

        super.createHandlers;

        eventPointerHandlers ~= (ref e) {

            if (e.isConsumed)
            {
                return;
            }

            if (e.event == PointerEvent.Event.down)
            {
                if (isDraggable && bounds.contains(e.x, e.y))
                {
                    startDrag(e.x, e.y);
                }
            }
            else if (e.event == PointerEvent.Event.move)
            {
                if (isDrag)
                {
                    auto x = e.x + offsetX;
                    auto y = e.y + offsetY;
                    if (onDragXY is null || onDragXY(x, y))
                    {
                        this.x = x;
                        this.y = y;

                        debug
                        {
                            import std.format : format;

                            string dragInfo = format("Drag. x:%s, y:%s.", x, y);
                            if (parent !is null)
                            {
                                const xInParent = x - parent.x;
                                const yInParent = y - parent.y;
                                dragInfo ~= format("In parent x:%s, y:%s.", xInParent, yInParent);
                            }
                            writeln(dragInfo);
                        }
                    }
                }
            }
            else if (e.event == PointerEvent.Event.up)
            {
                if (isDraggable && isDrag)
                {
                    stopDrag;
                }

                foreach (Sprite child; children)
                {
                    if (child.isDraggable && child.isDrag)
                    {
                        child.stopDrag;
                    }
                }
            }
        };

        isCreated = true;
    }

    GraphicsContext newGraphicsContext()
    {
        import api.dm.kit.graphics.contexts.renderer_graphics_context : RendererGraphicsContext;

        return new RendererGraphicsContext(this.graphics);
    }

    bool hasGraphicsContext()
    {
        return _gContext !is null;
    }

    void createGraphicsContext()
    {
        // if (_gContext)
        // {
        //     throw new Exception("Graphics context already exists");
        // }
        _gContext = newGraphicsContext;
        assert(_gContext);
    }

    import api.dm.kit.events.event_kit_target : EventPhaseProcesor;

    mixin EventPhaseProcesor;

    void dispatchEvent(Event)(ref Event e)
    {
        if (!isVisible || !isReceiveEvents || e.isConsumed)
        {
            return;
        }

        import api.dm.kit.events.event_kit_target : EventKitPhase;

        onEventPhase(e, EventKitPhase.preDispatch);

        static if (__traits(compiles, e.target))
        {
            if (e.target !is null && e.target is this)
            {
                runEventHandlers(e);
                return;
            }
        }

        bool isNeedConsumed;

        static if (is(Event : PointerEvent))
        {
            //isClipped
            if ((clip.width > 0 || clip.height > 0) && !clip.contains(e.x, e.y))
            {
                //Forwarding to children can be dangerous. Children may not have clipping
                return;
            }

            if (containsPoint(e.x, e.y))
            {
                if (e.event == PointerEvent.Event.move)
                {
                    if (!isMouseOver)
                    {
                        isMouseOver = true;
                        if (onPointerEntered.length > 0 || eventPointerHandlers
                            .length > 0)
                        {
                            auto enteredEvent = PointerEvent(PointerEvent.Event.entered, e
                                    .ownerId, e
                                    .x, e.y, e
                                    .button, e.movementX, e.movementY);
                            enteredEvent.isSynthetic = true;
                            fireEvent(enteredEvent);
                        }

                    }

                    runEventHandlers(e);
                }
                else if (e.event == PointerEvent.Event.down)
                {
                    if (!isFocus)
                    {
                        isFocus = true;

                        if (onFocusIn.length > 0 || eventFocusHandlers.length > 0)
                        {
                            import api.dm.kit.events.focus.focus_event : FocusEvent;

                            auto focusEvent = FocusEvent(FocusEvent.Event.focusIn, e
                                    .ownerId, e.x, e.y);
                            focusEvent.isSynthetic = true;
                            fireEvent(focusEvent);
                        }
                    }

                    runEventHandlers(e);
                }
                else if (!e.isSynthetic)
                {
                    runEventHandlers(e);
                }
            }
            else
            {
                if (e.event == PointerEvent.Event.move)
                {
                    if (isMouseOver)
                    {
                        isMouseOver = false;
                        auto exitedEvent = PointerEvent(PointerEvent.Event.exited, e
                                .ownerId, e
                                .x, e.y, e
                                .button, e.movementX, e.movementY);
                        exitedEvent.isSynthetic = true;
                        fireEvent(exitedEvent);
                    }

                    runEventHandlers(e);
                }
                else if (e.event == PointerEvent.Event.down)
                {
                    if (isFocus && (onFocusOut.length > 0 || eventFocusHandlers.length > 0))
                    {
                        isFocus = false;
                        import api.dm.kit.events.focus.focus_event : FocusEvent;

                        auto focusEvent = FocusEvent(FocusEvent.Event.focusOut, e
                                .ownerId, e.x, e.y);
                        focusEvent.isSynthetic = true;
                        fireEvent(focusEvent);
                    }
                }
                else if (e.event == PointerEvent.Event.wheel)
                {
                    if (onPointerWheel.length > 0)
                    {
                        auto mousePos = input.systemCursor.getPos;
                        if (containsPoint(mousePos.x, mousePos.y))
                        {
                            runEventHandlers(e);
                        }
                    }
                }
                else if (isDrag && !e.isSynthetic)
                {
                    runEventHandlers(e);
                }
            }

            // if (e.event == PointerEvent.Event.move && (isDrag || bounds.contains(e.x, e
            //         .y)))
            // {
            //     runEventHandlers(e);
            // }
        }

        static if (is(Event : KeyEvent) || is(Event : TextInputEvent))
        {
            if (isFocus)
            {
                runEventHandlers(e);
            }
        }

        static if (is(Event : JoystickEvent))
        {
            runEventHandlers(e);
        }

        static if (is(Event : FocusEvent))
        {
            if ((clip.width > 0 || clip.height > 0) && !clip.contains(e.x, e.y))
            {
                return;
            }

            if (!e.isSynthetic)
            {
                if (containsPoint(e.x, e.y))
                {
                    if (!isFocus && e.event == FocusEvent.Event.focusIn)
                    {
                        //TODO move to parent
                        isFocus = true;
                        runEventHandlers(e);
                    }
                }
                else
                {
                    if (isFocus && e.event == FocusEvent
                        .Event.focusOut)
                    {
                        isFocus = false;
                        runEventHandlers(e);
                    }
                }

            }
        }

        if (isForwardEventsToChildren && children.length > 0)
        {
            onEventPhase(e, EventKitPhase.preDispatchChildren);
            foreach (Sprite child; children)
            {
                child.dispatchEvent(e);
                if (e.isConsumed)
                {
                    return;
                }
            }
            onEventPhase(e, EventKitPhase.postDispatchChildren);
        }

        onEventPhase(e, EventKitPhase.postDispatch);
    }

    void drawContent()
    {

    }

    bool draw()
    {
        if (!isVisible)
        {
            return false;
        }

        bool redraw;

        if (clip.width > 0 || clip.height > 0)
        {
            enableClipping;
        }

        foreach (Sprite obj; children)
        {
            if (!obj.isDrawByParent)
            {
                continue;
            }

            if (!obj.isDrawAfterParent && obj.isVisible)
            {
                //if (!isValid)
                //{
                obj.draw;
                //}
                //else
                //{
                //  isRedraw = false;
                //}
                checkClip(obj);
            }
        }

        if (isRedraw)
        {
            if (isCached && _cache)
            {
                _cache.draw;
            }
            else
            {
                drawContent;
                redraw = true;
            }
        }

        foreach (Sprite obj; children)
        {
            if (!obj.isDrawByParent)
            {
                continue;
            }

            if (obj.isDrawAfterParent && obj.isVisible)
            {
                //if (!obj.isValid)
                {
                    obj.draw;
                }
                checkClip(obj);
            }
        }

        if (isClipped)
        {
            disableClipping;
        }

        if (isDrawBounds)
        {
            drawBounds;
        }

        if (isDrawClip)
        {
            drawClip;
        }

        //TODO remove duplication
        if (clip.width > 0 || clip.height > 0)
        {
            enableClipping;
        }

        return redraw;
    }

    void recreate()
    {

    }

    import api.dm.kit.components.window_component : WindowComponent;

    alias build = WindowComponent.build;

    void build(Sprite sprite)
    {
        assert(!sprite.isBuilt);
        super.build(sprite);

        //sprite can access parent properties before being added
        trySetParentProps(sprite);
    }

    protected bool trySetParentProps(Sprite sprite)
    {
        assert(sprite);

        bool isSet;
        if (!sprite.parent)
        {
            sprite.parent = this;
            isSet = true;
        }

        if (sceneProvider && !sprite.sceneProvider)
        {
            sprite.sceneProvider = sceneProvider;
            isSet |= true;
        }

        return isSet;
    }

    void addCreate(Sprite[] sprites)
    {
        foreach (sprite; sprites)
        {
            addCreate(sprite);
        }
    }

    void addCreate(Sprite sprite, long index = -1)
    {
        if (sprite is null)
        {
            //TODO logging
            throw new Exception("Cannot add null sprite");
        }

        if (sprite is this)
        {
            throw new Exception("Cannot add this");
        }

        if (sprite.isManaged)
        {
            sprite.x = x + sprite.x;
            sprite.y = y + sprite.y;
        }

        buildCreate(sprite);
        add(sprite, index);
    }

    void add(Sprite[] sprites)
    {
        foreach (s; sprites)
        {
            add(s);
        }
    }

    void add(Sprite sprite, long index = -1)
    {
        if (hasDirect(sprite))
        {
            debug
            {
                import std.format: format;
                throw new Exception(format("Sprite %s already added: %s. Parent %s: %s", typeid(sprite), sprite.toString, typeid(this), toString));
            }
            return;
        }

        trySetParentProps(sprite);

        if (index < 0 || index == children.length)
        {
            children ~= sprite;
        }
        else
        {
            if (index >= children.length)
            {
                import std.format : format;

                throw new Exception(format("Child index must not be greater than %s, but received %s for child %s with children length %s", children
                        .length, index, sprite.toString, sprite.children.length));
            }

            import std.array : insertInPlace;

            children.insertInPlace(cast(size_t) index, sprite);
        }
        setInvalid;
    }

    Nullable!Sprite hasDirectSprite(Sprite obj)
    {
        if (obj is null)
        {
            throw new Exception("Unable to check for child existence: object is null");
        }

        foreach (Sprite child; children)
        {
            if (obj is child)
            {
                return Nullable!Sprite(obj);
            }
        }
        return Nullable!Sprite.init;
    }

    bool hasDirect(Sprite obj)
    {
        if (obj is null)
        {
            throw new Exception("Unable to check for child existence: object is null");
        }

        foreach (Sprite child; children)
        {
            if (obj is child)
            {
                return true;
            }
        }
        return false;
    }

    bool removeAll(bool isDestroy = true)
    {
        if (children.length == 0)
        {
            return false;
        }

        foreach (ch; children)
        {
            if (isDestroy && !ch.isDisposed)
            {
                ch.dispose;
            }
        }
        children = null;
        setInvalid;

        return true;
    }

    bool changeIndex(Sprite sprite, size_t index)
    {
        //TODO check exists, etc
        remove(sprite, false);
        if (index >= children.length)
        {
            //TODO bool
            add(sprite);
        }
        else
        {
            add(sprite, index);
        }

        return true;
    }

    bool changeIndexToLast(Sprite sprite)
    {
        remove(sprite, false);
        add(sprite);
        return true;
    }

    bool remove(Sprite[] sprites, bool isDestroy = true)
    {
        if (isDestroy)
        {
            foreach (sprite; sprites)
            {
                if (!sprite.isDisposed)
                {
                    sprite.dispose;
                }
            }
        }

        import std.algorithm.mutation : remove;
        import std.algorithm.searching : canFind;

        children = children.remove!(s => sprites.canFind(s));
        setInvalid;
        return true;
    }

    bool remove(Sprite obj, bool isDestroy = true)
    {
        import std.algorithm.searching : countUntil;
        import std.algorithm.mutation : remove;

        auto mustBeIndex = children.countUntil(obj);
        if (mustBeIndex < 0)
        {
            return false;
        }

        auto sprite = children[mustBeIndex];

        if (isDestroy && !sprite.isDisposed)
        {
            sprite.dispose;
        }

        children = children.remove(mustBeIndex);
        setInvalid;
        return true;
    }

    protected void recreateCache()
    {
        if (!_cache)
        {
            _cache = new RgbaTexture(width, height);
            buildCreate(_cache);
        }
        else
        {
            _cache.width = width;
            _cache.height = height;
        }

        //TODO remove hack;
        double oldX = x, oldY = y;
        x = 0;
        y = 0;
        _cache.captureRenderer(() { drawContent; });
        x = oldX;
        y = oldY;

        _cache.x = x;
        _cache.y = y;
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

    //TODO remove root from children
    void onAllChildren(scope void delegate(Sprite) onChild, Sprite root, bool isForRoot = true)
    {
        if (isForRoot)
        {
            onChild(root);
        }

        foreach (Sprite child; root.children)
        {
            onAllChildren(onChild, child);
        }
    }

    void onAllChildren(scope void delegate(Sprite) onChild, bool isForRoot = true)
    {
        onAllChildren(onChild, this, isForRoot);
    }

    protected void checkClip(Sprite obj)
    {
        if (obj.isClipped)
        {
            obj.disableClipping;
            if (isClipped)
            {
                enableClipping;
            }
        }
    }

    void clipBounds(){
        clip = Rect2d(x, y, width, height);
        isMoveClip = true;
        isResizeClip = true;
    }

    void enableClipping()
    {
        graphics.setClip(clip);
        isClipped = true;
    }

    void disableClipping()
    {
        graphics.removeClip;
        isClipped = false;
    }

    void applyLayout()
    {
        if (layout !is null)
        {
            layout.applyLayout(this);
        }
    }

    void unvalidate()
    {
        if (isValidatableChildren)
        {
            foreach (ch; children)
            {
                ch.unvalidate;
            }
        }

        setValid(true);
        invalidationState.reset;
    }

    void validate(scope void delegate(Sprite) onInvalid = null)
    {
        bool isChildInvalid;
        if (isValidatableChildren)
        {
            foreach (ch; children)
            {
                ch.validate(onInvalid);
                if (!ch.isValid)
                {
                    setInvalid;
                    if (!isChildInvalid)
                    {
                        isChildInvalid = true;
                    }
                }
            }
        }

        applyLayout;

        if (!isValid)
        {
            if (onInvalid)
            {
                onInvalid(this);
            }
            //listeners can expect to call layout manager
            foreach (invListener; invalidateListeners)
            {
                invListener();
            }
        }
    }

    void setInvalidationProcessAll(bool value)
    {
        isInvalidationProcess = value;
        foreach (ch; children)
        {
            ch.setInvalidationProcessAll(value);
        }
    }

    void applyAllLayouts()
    {
        foreach (ch; children)
        {
            ch.applyAllLayouts;
        }

        applyLayout;
    }

    void update(double delta)
    {
        double dx = 0;
        double dy = 0;

        checkCollisions;

        if (isUpdatable && isPhysicsEnabled)
        {
            //TODO check velocity is 0 || acceleration is 0
            const double accelerationDx = acceleration.x * invMass * delta;
            const double accelerationDy = acceleration.y * invMass * delta;

            double newVelocityX = velocity.x + accelerationDx;
            double newVelocityY = velocity.y + accelerationDy;

            dx = newVelocityX * delta;
            dy = newVelocityY * delta;

            if (inScreenBounds)
            {
                auto thisBounds = bounds;
                thisBounds.x = _x + dx;
                thisBounds.y = _y + dy;

                const screen = graphics.renderBounds;
                if (!screen.contains(thisBounds))
                {
                    if (!onScreenBoundsIsStop || onScreenBoundsIsStop())
                    {
                        newVelocityX = 0;
                        newVelocityY = 0;

                        acceleration.x = 0;
                        acceleration.y = 0;
                    }
                    else
                    {
                        newVelocityX = velocity.x;
                        newVelocityY = velocity.y;
                    }

                    dx = 0;
                    dy = 0;
                }
            }

            _x += dx;
            _y += dy;

            velocity.x = newVelocityX;
            velocity.y = newVelocityY;
        }

        foreach (Sprite child; children)
        {
            if (!child.isUpdatable)
            {
                continue;
            }

            if (layout is null || (child.isManaged && !child.isLayoutManaged))
            {
                //child.velocity.x = velocity.x;
                //child.velocity.y = velocity.y;

                if (dx != 0 || dy != 0)
                {
                    child.x = child.x + dx;
                    child.y = child.y + dy;
                }
            }

            child.update(delta);
        }
    }

    bool containsPoint(double x, double y)
    {
        return bounds.contains(x, y);
    }

    bool intersectBounds(Sprite other)
    {
        return bounds.intersect(other.bounds);
    }

    bool intersect(Sprite other)
    {
        if (!hitbox && !other.hitbox)
        {
            return intersectBounds(other);
        }

        return hitbox.intersect(other.hitbox);
    }

    void checkCollisions()
    {
        if (!onCollision)
        {
            return;
        }

        foreach (i, firstSprite; targetsForCollisions)
        {
            foreach (secondSprite; targetsForCollisions[i + 1 .. $])
            {
                if (firstSprite is secondSprite)
                {
                    continue;
                }
                if (firstSprite.intersect(secondSprite))
                {
                    if (!firstSprite.isCollisionProcess && !secondSprite.isCollisionProcess)
                    {
                        onCollision(firstSprite, secondSprite);
                    }
                }
                else
                {
                    if (firstSprite.isCollisionProcess is secondSprite)
                    {
                        firstSprite.isCollisionProcess = null;
                    }

                    if (secondSprite.isCollisionProcess is firstSprite)
                    {
                        secondSprite.isCollisionProcess = null;
                    }
                }
            }
        }
    }

    Rect2d bounds()
    {
        const Rect2d bounds = {x, y, _width, _height};
        return bounds;
    }

    Rect2d boundsInParent()
    {
        if (!parent)
        {
            return bounds;
        }
        const Rect2d pBounds = {x - parent.x, y - parent.y, _width, _height};
        return pBounds;
    }

    Rect2d paddingBounds()
    {
        const b = bounds;
        const pBounds = Rect2d(b.x + padding.left, b.y + padding.top, b.width - padding.width, b.height - padding
                .height);
        return pBounds;
    }

    Rect2d layoutBounds()
    {
        Rect2d bounds = Rect2d(
            x - margin.left,
            y - margin.top,
            _width + margin.width,
            _height + margin.height
        );
        return bounds;
    }

    Rect2d geometryBounds()
    {
        const Rect2d bounds = {0, 0, _width, _height};
        return bounds;
    }

    void positionCenter()
    {
        positionCenterX;
        positionCenterY;
    }

    void positionCenterX()
    {
        if (_width > 0 && window.width > 0 && _width < window.width)
        {
            x = window.width / 2 - _width / 2;
        }
    }

    void positionCenterY()
    {
        if (_height > 0 && window.height > 0 && _height < window.height)
        {
            y = window.height / 2 - _height / 2;
        }
    }

    Vector2 position() @safe pure nothrow
    {
        return Vector2(x, y);
    }

    void position(Vector2 pos)
    {
        x = pos.x;
        y = pos.y;
    }

    Vector2 center()
    {
        return Vector2(x + (width / 2.0), y + (height / 2.0));
    }

    void xy(double newX, double newY)
    {
        x(newX);
        y(newY);
    }

    double x() @safe pure nothrow
    {
        return _x;
    }

    void x(double newX)
    {
        if (!Math.greater(_x, newX, xChangeThreshold))
        {
            return;
        }

        foreach (Sprite child; children)
        {
            if (child.isManaged)
            {
                double dx = newX - _x;
                child.x = child.x + dx;
            }
        }

        if (isCreated && onChangeXOldNew !is null)
        {
            onChangeXOldNew(_x, newX);
        }

        if (isMoveClip && (clip.width > 0 || clip.height > 0))
        {
            clip.x = clip.x + (newX - _x);
            if (onClipMove)
            {
                onClipMove(&clip);
            }
        }

        _x = newX;

        if (_cache)
        {
            _cache.x = _x;
        }

        if (!isInvalidationProcess)
        {
            setInvalid;
            invalidationState.x = true;
        }
    }

    double y() @safe pure nothrow
    {
        return _y;
    }

    void y(double newY)
    {
        if (!Math.greater(_y, newY, yChangeThreshold))
        {
            return;
        }

        foreach (Sprite child; children)
        {
            if (child.isManaged)
            {
                double dy = newY - _y;
                child.y = child.y + dy;
            }
        }

        if (isCreated && onChangeYOldNew !is null)
        {
            onChangeYOldNew(_y, newY);
        }

        if (isMoveClip && (clip.width > 0 || clip.height > 0))
        {
            clip.y = clip.y + (newY - _y);
            if (onClipMove)
            {
                onClipMove(&clip);
            }
        }

        _y = newY;

        if (_cache)
        {
            _cache.y = _y;
        }

        if (!isInvalidationProcess)
        {
            setInvalid;
            invalidationState.y = true;
        }
    }

    double width() @safe pure nothrow
    {
        return _width;
    }

    bool canChangeWidth(double value)
    {
        if (value < minWidth || value > maxWidth)
        {
            return false;
        }

        if (
            value <= 0 ||
            !Math.greater(_width, value, widthChangeThreshold))
        {
            return false;
        }

        if (isLayoutManaged && value > _width && !canExpandW(
                value - _width))
        {
            return false;
        }

        return true;
    }

    bool tryWidth(double value)
    {
        if (!canChangeWidth(value))
        {
            return false;
        }

        return setWidth(value);
    }

    bool setWidth(double value)
    {
        immutable double oldWidth = _width;
        _width = value;

        bool isResized = true;

        //if (!isInvalidationProcess)
        //{
        setInvalid;
        invalidationState.width = true;
        //}

        if (onChangeWidthOldNew)
        {
            onChangeWidthOldNew(oldWidth, _width);
        }

        if (!isCreated)
        {
            return isResized;
        }

        if (_cache)
        {
            recreateCache;
        }

        if (isResizeClip && (clip.width > 0 || clip.height > 0))
        {
            clip.width = clip.width + (_width - oldWidth);
            if (onClipResize)
            {
                onClipResize(&clip);
            }
        }

        if (isResizeChildren && children.length > 0)
        {
            immutable double dw = _width - oldWidth;

            //Branch expanded for easier debugging
            foreach (child; children)
            {
                if (isResizeChildrenIfNoLayout && !layout)
                {
                    incChildWidth(child, dw);
                }
                else if (isResizeChildrenIfNotLManaged && !child.isLayoutManaged && child
                    .isResizedByParent)
                {
                    incChildWidth(child, dw);
                }
                else if (isResizeChildrenAlways && child.isResizedByParent)
                {
                    incChildWidth(child, dw);
                }
                else if (isResizeChildrenIfNotResizable)
                {
                    incChildWidth(child, dw);
                }
            }
        }

        return isResized;
    }

    bool width(double value)
    {
        return tryWidth(value);
    }

    protected void incChildWidth(Sprite child, double dw)
    {
        const newWidth = child.width + dw;
        child.width = newWidth;
    }

    protected void incChildHeight(Sprite child, double dh)
    {
        const newHeight = child.height + dh;
        child.height = newHeight;
    }

    double height() @safe pure nothrow
    {
        return _height;
    }

    bool canChangeHeight(double value)
    {
        if (value < minHeight || value > maxHeight)
        {
            return false;
        }

        if (
            value <= 0 ||
            !Math.greater(_height, value, heightChangeThreshold))
        {
            return false;
        }

        if (isLayoutManaged && value > _height && !canExpandH(value - _height))
        {
            return false;
        }

        return true;
    }

    bool tryHeight(double value)
    {
        if (!canChangeHeight(value))
        {
            return false;
        }

        return setHeight(value);
    }

    bool setHeight(double value){
        immutable double oldHeight = _height;
        _height = value;

        bool isResized = true;

        //if (!isInvalidationProcess)
        //{
        setInvalid;
        invalidationState.height = true;
        //}

        if (onChangeHeightOldNew)
        {
            onChangeHeightOldNew(oldHeight, _height);
        }

        if (!isCreated)
        {
            return isResized;
        }

        if (_cache)
        {
            recreateCache;
        }

        if (isResizeClip && (clip.width > 0 || clip.height > 0))
        {
            clip.height = clip.height + (_height - oldHeight);
            if (onClipResize)
            {
                onClipResize(&clip);
            }
        }

        //!isProcessLayout && !isProcessParentLayout && 
        if (isResizeChildren && children.length > 0)
        {
            const dh = _height - oldHeight;
            foreach (child; children)
            {
                //Branch expanded for easier debugging
                if (isResizeChildrenIfNoLayout && !layout)
                {
                    incChildHeight(child, dh);
                }
                else if (isResizeChildrenIfNotLManaged && !child.isLayoutManaged && child
                    .isResizedByParent)
                {
                    incChildHeight(child, dh);
                }
                else if (isResizeChildrenAlways && child.isResizedByParent)
                {
                    incChildHeight(child, dh);
                }
                else if (isResizeChildrenIfNotResizable)
                {
                    incChildHeight(child, dh);
                }
            }
        }

        return isResized;
    }

    bool height(double value)
    {
        return tryHeight(value);
    }

    bool resize(double newWidth, double newHeight, bool isForce = false)
    {
        bool isResized;
        if(isForce){
            isResized |= setWidth(newWidth);
            isResized |= setHeight(newHeight);
            return isResized;
        }

        isResized |= width = newWidth;
        isResized |= height = newHeight;
        //TODO newWidth == oldWidth, etc
        return isResized;
    }

    bool rescale(double factorWidth, double factorHeight)
    {
        if (!isScalable)
        {
            return false;
        }
        auto newWidth = width * factorWidth;
        auto newHeight = height * factorHeight;

        if (!isKeepAspectRatio)
        {
            return resize(newWidth, newHeight);
        }

        double scaleFactorWidth = 1, scaleFactorHeight = 1;
        if (width >= height)
        {
            scaleFactorWidth = newWidth / width;
            scaleFactorHeight = scaleFactorWidth;
        }
        else
        {
            scaleFactorHeight = newHeight / height;
            scaleFactorWidth = scaleFactorHeight;
        }

        import std.math.rounding : round;

        auto newW = round(width * scaleFactorWidth);
        auto newH = round(height * scaleFactorHeight);
        return resize(newW, newH);
    }

    void setValid(bool value) @safe pure nothrow
    {
        isValid = value;
    }

    void setValidAll(bool value) @safe pure nothrow
    {
        isValid = value;
        foreach (ch; children)
        {
            ch.setValidAll(value);
        }
    }

    void setValidChildren(bool value) @safe pure nothrow
    {
        foreach (child; children)
        {
            child.isValid = value;
        }
    }

    void setInvalid() @safe pure nothrow
    {
        setValid(false);
    }

    void drawBounds()
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        if (width == 0 || height == 0)
        {
            return;
        }

        const debugColor = boundsColor;

        graphics.changeColor(debugColor);

        const b = bounds;
        //graphics.rect(b.x, b.y, b.width, b.height, GraphicStyle(1, RGBA.red));
        const double leftTopX = b.x, leftTopY = b.y;

        const double rightTopX = leftTopX + b.width, rightTopY = leftTopY;
        graphics.line(leftTopX, leftTopY, rightTopX, rightTopY);

        const double rightBottomX = rightTopX, rightBottomY = rightTopY + b.height;
        graphics.line(rightTopX, rightTopY, rightBottomX, rightBottomY);

        const double leftBottomX = leftTopX, leftBottomY = leftTopY + b.height;
        graphics.line(rightBottomX, rightBottomY, leftBottomX, leftBottomY);

        graphics.line(leftBottomX, leftBottomY, leftTopX, leftTopY);

        graphics.restoreColor;
    }

    void drawClip()
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        if (clip.width == 0 || clip.height == 0)
        {
            return;
        }

        const color = RGBA.blueviolet;

        graphics.changeColor(color);

        import api.math.vector2 : Vector2;

        graphics.rect(Vector2(clip.x, clip.y), clip.width, clip.height);

        graphics.restoreColor;
    }

    void drawAllBounds(bool isDraw)
    {
        onChildrenRec((ch) {
            if (debugFlag in ch.userData)
            {
                return true;
            }

            ch.isDrawBounds = isDraw;
            return true;
        });
    }

    void onChildrenRec(bool delegate(Sprite) onSpriteIsContinue)
    {
        onChildrenRec(this, onSpriteIsContinue);
    }

    void onChildrenRec(Sprite root, bool delegate(Sprite) onSpriteIsContinue)
    {
        if (root is null)
        {
            return;
        }

        if (!onSpriteIsContinue(root))
        {
            return;
        }

        foreach (child; root.children)
        {
            onChildrenRec(child, onSpriteIsContinue);
        }
    }

    Nullable!Sprite findChildRec(string id)
    {
        Sprite mustBeChild;
        onChildrenRec((child) {
            if (child.id == id)
            {
                mustBeChild = child;
                return false;
            }
            return true;
        });
        return mustBeChild is null ? Nullable!Sprite.init : Nullable!Sprite(mustBeChild);
    }

    Nullable!Sprite findChildRec(Sprite child)
    {
        if (child is null)
        {
            debug throw new Exception("Child must not be null");
            return Nullable!Sprite.init;
        }
        Sprite mustBeChild;
        onChildrenRec((currentChild) {
            if (child is currentChild)
            {
                mustBeChild = child;
                return false;
            }
            return true;
        });

        return mustBeChild is null ? Nullable!Sprite.init : Nullable!Sprite(mustBeChild);
    }

    int findChildIndex(Sprite child)
    {
        import std.conv : to;

        foreach (i, Sprite ch; children)
        {
            if (ch is child)
            {
                return i.to!int;
            }
        }
        return -1;
    }

    bool isLastIndex(Sprite child)
    {
        if (children.length == 0)
        {
            return false;
        }
        const index = findChildIndex(child);
        return index == children.length - 1;
    }

    Nullable!Sprite findChild(Sprite child)
    {
        foreach (Sprite ch; children)
        {
            if (ch is child)
            {
                return Nullable!Sprite(ch);
            }
        }
        return Nullable!Sprite.init;
    }

    Nullable!Sprite findChild(string id)
    {
        foreach (Sprite ch; children)
        {
            if (ch.id == id)
            {
                return Nullable!Sprite(ch);
            }
        }
        return Nullable!Sprite.init;
    }

    ComSurface snapshot()
    {
        assert(width > 0 && height > 0);
        import api.math.rect2d : Rect2d;

        auto bounds = Rect2d(
            0, 0, width, height
        );
        auto surf = graphics.comSurfaceProvider.getNew();
        auto err = surf.createRGB(cast(int) width, cast(int) height);
        if (err)
        {
            throw new Exception(err.toString);
        }
        graphics.readPixels(bounds, surf);
        return surf;
    }

    void snapshot(string path)
    {
        //TODO unification with scene
        auto surf = snapshot;
        scope (exit)
        {
            surf.dispose;
        }

        import api.dm.kit.sprites.images.image : Image;

        auto im = new Image;
        build(im);
        im.initialize;
        im.create;
        scope (exit)
        {
            im.dispose;
        }

        im.savePNG(surf, path);
    }

    bool isCanEnableInsets()
    {
        return hasGraphics && graphics.theme;
    }

    void enableInsets()
    {
        enablePadding;
    }

    void enablePadding()
    {
        if (!isCanEnableInsets)
        {
            throw new Exception(
                "Unable to enable paddings: graphic or theme is null. Perhaps the component is not built correctly");
        }
        _padding = graphics.theme.controlPadding;
    }

    void disablePadding()
    {
        padding(0);
    }

    Insets padding()
    {
        return _padding;
    }

    void padding(Insets value)
    {
        _padding = value;
    }

    void padding(double value)
    {
        _padding = Insets(value);
    }

    void padding(double top = 0, double right = 0, double bottom = 0, double left = 0)
    {
        _padding = Insets(top, right, bottom, left);
    }

    void paddingTop(double value)
    {
        _padding.top = value;
    }

    void paddingRight(double value)
    {
        _padding.right = value;
    }

    void paddingLeft(double value)
    {
        _padding.left = value;
    }

    void paddingBottom(double value)
    {
        _padding.bottom = value;
    }

    ref Insets margin()
    {
        return _margin;
    }

    void margin(Insets value)
    {
        _margin = value;
    }

    void margin(double value)
    {
        _margin = Insets(value);
    }

    void margin(double top, double right, double bottom, double left)
    {
        _margin = Insets(top, right, bottom, left);
    }

    void marginTop(double value)
    {
        _margin.top = value;
    }

    void marginBottom(double value)
    {
        _margin.bottom = value;
    }

    void marginRight(double value)
    {
        _margin.right = value;
    }

    void marginLeft(double value)
    {
        _margin.left = value;
    }

    void onScenePause()
    {
        if (isManagedByScene && isRunning)
        {
            pause;
        }

        onAllChildren((child) { child.onScenePause; }, isForRoot:
            false);
    }

    void onSceneResume()
    {
        if (isManagedByScene && isPaused)
        {
            run;
        }

        onAllChildren((child) { child.onSceneResume; }, isForRoot:
            false);
    }

    override void dispose()
    {
        if (isRunning)
        {
            stop;
        }

        super.dispose;

        if (_cache)
        {
            _cache.dispose;
        }

        if (_hitbox)
        {
            _hitbox.dispose;
        }

        foreach (Sprite child; children)
        {
            child.parent = null;

            if (child.isRunning)
            {
                child.stop;
            }

            child.dispose;
        }

        invalidateListeners = null;
    }

    bool isCached()
    {
        return _cached;
    }

    void isCached(bool value)
    {
        _cached = value;
    }

    bool canExpandW(double value)
    {
        Sprite curParent = parent;
        if (!curParent || !curParent.layout)
        {
            return true;
        }

        while (curParent)
        {
            if (curParent.layout)
            {
                auto freeMaxWidth = curParent.layout.freeMaxWidth(curParent);
                if (freeMaxWidth < value)
                {
                    return false;
                }
            }

            curParent = curParent.parent;
        }

        return true;
    }

    bool canExpandH(double value)
    {
        Sprite curParent = parent;
        while (curParent)
        {
            if (curParent.layout)
            {
                const freeMaxHeight = curParent.layout.freeMaxHeight(curParent);
                if (freeMaxHeight < value)
                {
                    return false;
                }
            }
            curParent = curParent.parent;
        }

        return true;
    }

    void hitbox(Sprite sprite)
    {
        addCreate(sprite);
        sprite.isLayoutManaged = false;
        //sprite.isVisible = false;
        _hitbox = sprite;
    }

    Sprite hitbox()
    {
        return _hitbox;
    }

    void setGrow(bool isGrow = true)
    {
        isHGrow = isGrow;
        isVGrow = isGrow;
    }

    bool isVisible() pure @safe
    {
        return _visible;
    }

    void isVisible(bool value) pure @safe
    {
        if (_visible != value)
        {
            setInvalid;
            invalidationState.visible = true;
        }
        _visible = value;
    }

    bool isManaged() pure @safe
    {
        return _managed;
    }

    void isManaged(bool value) pure @safe
    {
        if (_managed != value)
        {
            setInvalid;
            invalidationState.managed = true;
        }
        _managed = value;
    }

    bool isLayoutManaged() pure @safe
    {
        return _layoutManaged;
    }

    void isLayoutManaged(bool value) pure @safe
    {
        if (_layoutManaged != value)
        {
            setInvalid;
            invalidationState.layout = true;
        }

        _layoutManaged = value;
    }

    double invMass() pure @safe nothrow
    {
        return 1.0 / mass;
    }

    double opacity()
    {
        return _opacity;
    }

    bool canSetOpacity(double value) => value >= 0 && value <= maxOpacity;

    bool opacity(double value)
    {
        if (!canSetOpacity(value))
        {
            if (value > maxOpacity)
            {
                _opacity = maxOpacity;
            }

            return false;
        }

        _opacity = value;

        if (isOpacityForChildren)
        {
            onChildrenRec((child) {
                if (child is this)
                {
                    return true;
                }
                child.opacity = value;
                return true;
            });
        }

        return true;
    }

    void opacityLimit(double v)
    {
        maxOpacity = v;
        opacity = v;
    }

    GraphicsContext gContext()

    out (_gContext; _gContext !is null)
    {
        return _gContext;
    }

    void gContext(GraphicsContext context)
    in (context !is null)
    {
        _gContext = context;
    }

    void angle(double value)
    {
        _angle = value;
        setInvalid;
    }

    double angle()
    {
        return _angle;
    }

    void show()
    {
        isVisible = true;
    }

    void showForLayout()
    {
        show;
        if (!isLayoutManaged)
        {
            isLayoutManaged = true;
        }
    }

    void hide()
    {
        isVisible = false;
    }

    void hideForLayout()
    {
        hide;
        if (isLayoutManaged)
        {
            isLayoutManaged = false;
        }
    }

    void isGrow(bool value)
    {
        isHGrow = value;
        isVGrow = value;
    }

    bool isGrow()
    {
        return isHGrow && isVGrow;
    }

    RGBA[][] surfaceToBuffer(ComSurface surf)
    {
        assert(surf);
        int w, h;
        if (const err = surf.getWidth(w))
        {
            throw new Exception(err.toString);
        }

        if (const err = surf.getHeight(h))
        {
            throw new Exception(err.toString);
        }

        assert(w > 0 && h > 0);
        RGBA[][] buff = new RGBA[][](h, w);
        surfaceToBuffer(surf, buff);
        return buff;
    }

    void surfaceToBuffer(ComSurface surf, RGBA[][] buff)
    {
        assert(surf);

        int surfWidth, surfHeight;
        if (const err = surf.getWidth(surfWidth))
        {
            throw new Exception(err.toString);
        }

        if (const err = surf.getHeight(surfHeight))
        {
            throw new Exception(err.toString);
        }

        assert(surfWidth > 0 && surfHeight > 0);
        assert(buff.length >= surfHeight);

        import std.algorithm.searching : all;

        assert(buff.all!(b => b.length >= surfWidth));

        auto pixErr = surf.getPixels((x, y, r, g, b, a) {
            buff[y][x] = RGBA(r, g, b, RGBA.fromAByte(a));
            return true;
        });
        if (pixErr)
        {
            logger.error(pixErr.toString);
        }
    }

    bool removeInvListener(void delegate() dg)
    {
        import api.core.utils.arrays : drop;

        return drop(invalidateListeners, dg);
    }

    override string toString()
    {
        import std.format : format;

        return format("id: %s, parent: %s, x: %f, y: %f, width: %f, height: %f", id, parent, x, y, width, height);
    }

}
