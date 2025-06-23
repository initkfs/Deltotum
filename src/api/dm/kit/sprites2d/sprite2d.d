module api.dm.kit.sprites2d.sprite2d;

import api.dm.kit.events.event_kit_target : EventKitTarget;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.polygon2 : Quadrilateral2d;
import api.math.alignment : Alignment;
import api.math.insets : Insets;
import api.dm.kit.sprites2d.layouts.layout2d : Layout2d;
import api.dm.kit.sprites2d.textures.rgba_texture : RgbaTexture;
import api.dm.kit.scenes.scaling.scale_mode : ScaleMode;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.core.apps.events.app_event : AppEvent;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.dm.kit.events.focus.focus_event : FocusEvent;
import api.dm.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import api.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.kit.scenes.scene2d : Scene2d;

import std.container : DList;
import std.math.operations : isClose;
import std.stdio;
import std.math.algebraic : abs;
import std.typecons : Nullable;
import std.variant : Variant;

import api.dm.com.graphic.com_surface : ComSurface;
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
class Sprite2d : EventKitTarget
{
    enum debugFlag = "d_debug";

    string id;

    Sprite2d parent;

    protected
    {
        double _angle = 0;
    }

    bool isAngleForChildren = true;

    double scale = 1;
    double mass = 1;
    double speed = 0;

    double _opacity = 1;
    double maxOpacity = double.max;
    bool isOpacityForChildren;

    bool isPhysicsEnabled;

    Vec2d velocity;
    Vec2d acceleration;

    Sprite2d isCollisionProcess;
    Sprite2d[] targetsForCollisions;

    bool delegate(Sprite2d, Sprite2d) onCollision;

    Rect2d clip;
    bool isMoveClip;
    bool isResizeClip;
    void delegate(Rect2d* clip) onClipResize;
    void delegate(Rect2d* clip) onClipMove;
    bool isOutClipForwardEvents;

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

    Layout2d layout;
    bool _layoutManaged = true;
    bool _layoutMovable = true;

    bool isLayoutForChildren;

    bool isLayoutOnInvalid;
    bool isLayoutOnInvalidForChildren = true;

    bool isResizeChildren;
    bool isResizeChildrenIfNoLayout = true;
    bool isResizeChildrenIfNotLManaged = true;
    bool isResizeChildrenIfNotResizable;
    bool isResizeChildrenAlways;

    bool isResizedWidthByParent;
    bool isResizedHeightByParent;

    bool isManagedByScene = true;

    Insets _padding;
    Insets _margin;
    bool isHGrow;
    bool isVGrow;

    Alignment alignment = Alignment.none;
    ScaleMode scaleMode = ScaleMode.none;

    bool isLayoutInvertX;
    bool isLayoutInvertY;

    bool isDisableRecreate;

    bool isCreated;
    bool isFocus;
    bool isDraggable;
    bool isScalable;
    bool isDrawClip;

    bool isDrawBounds;
    bool isDrawCenterBounds;
    bool isDrawInvalidBounds;
    RGBA boundsColor = RGBA.red;
    RGBA boundsCenterColor = RGBA.yellow;
    RGBA boundsInvalidColor = RGBA.blue;

    bool _visible = true;
    bool isVisibilityForChildren;

    bool isReceiveEvents = true;
    bool isEventsFirstProcessChildren;
    bool isDispatchChildrenFromLast;

    //protected
    //{
    //TODO information about children
    Sprite2d[] children;
    //}

    bool delegate(double, double) onDragXY;
    void delegate() onStartDrag;
    void delegate() onStopDrag;

    InvalidationState invalidationState;
    bool isAllowInvalidate = true;
    void delegate()[] invalidateListeners;

    //old, new
    void delegate(double, double) onChangeWidthOldNew;
    void delegate(double, double) onChangeHeightOldNew;

    void delegate(double, double)[] onResize;

    double minWidth = 1.0;
    double minHeight = 1.0;

    double multiplyInitWidth = 1.0;
    double multiplyInitHeight = 1.0;

    Scene2d delegate() sceneProvider;

    void delegate(ref PointerEvent)[] onPointerInBounds;
    void delegate(ref PointerEvent)[] onPointerOutBounds;

    bool isRoundEvenX;
    bool isRoundEvenY;

    bool isRoundEvenChildX;
    bool isRoundEvenChildY;

    size_t clickCount;

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

    Variant[string] userData;

    protected
    {
        Sprite2d _hitbox;
        GraphicCanvas _gContext;

        double _width = 0;
        double _height = 0;

        double offsetX = 0;
        double offsetY = 0;

        double _x = 0;
        double _y = 0;

        ulong lastClickTimeMs;
    }

    uint maxClickTimeMs = 300;

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

    void onResume()
    {

    }

    alias initialize = EventKitTarget.initialize;
    alias create = EventKitTarget.create;
    alias run = EventKitTarget.run;
    alias stop = EventKitTarget.stop;

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

        super.createHandlers;

        eventPointerHandlers ~= (ref e) {

            if (e.isConsumed)
            {
                return;
            }

            if (e.event == PointerEvent.Event.press)
            {
                if (isDraggable && boundsRect.contains(e.x, e.y))
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
            else if (e.event == PointerEvent.Event.release)
            {
                if (isDraggable && isDrag)
                {
                    stopDrag;
                }

                foreach (Sprite2d child; children)
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

    GraphicCanvas newGraphicsContext()
    {
        import api.dm.kit.graphics.canvases.renderer_canvas : RendererCanvas;

        return new RendererCanvas(this.graphic);
    }

    bool hasGraphicsContext()
    {
        return _gContext !is null;
    }

    void createGraphicsContext()
    {
        // if (_gContext)
        // {
        //     throw new Exception("Graphic context already exists");
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

        if (isEventsFirstProcessChildren)
        {
            dispatchEventToChildren(e);
        }

        onEventPhase(e, EventKitPhase.preDispatch);

        static if (__traits(compiles, e.target))
        {
            if (e.target && e.target is this)
            {
                runEventHandlers(e);
                return;
            }
        }

        static if (is(Event : PointerEvent))
        {
            bool inCurClipBounds = inClipBounds(e.x, e.y);

            if (inCurClipBounds && containsPoint(e.x, e.y))
            {
                if (onPointerInBounds.length > 0)
                {
                    foreach (dg; onPointerInBounds)
                    {
                        dg(e);
                    }
                }

                if (e.event == PointerEvent.Event.move)
                {
                    if (clickCount != 0)
                    {
                        clickCount = 0;
                    }

                    if (!isMouseOver)
                    {
                        isMouseOver = true;
                        if (onPointerEnter.length > 0 || eventPointerHandlers
                            .length > 0)
                        {
                            auto enterEvent = PointerEvent(PointerEvent.Event.enter, e
                                    .ownerId, e
                                    .x, e.y, e
                                    .button, e.movementX, e.movementY);
                            enterEvent.isSynthetic = true;
                            fireEvent(enterEvent);
                        }

                    }

                    runEventHandlers(e);
                }
                else if (e.event == PointerEvent.Event.press)
                {
                    if (!isFocus)
                    {
                        focus(e.ownerId);
                    }

                    //TODO from config
                    enum primaryButton = 1;
                    if (e.button == primaryButton)
                    {
                        if (platform.timer.ticksMs - lastClickTimeMs < maxClickTimeMs)
                        {
                            clickCount++;
                            if (clickCount == 1)
                            {
                                auto clickEvent = PointerEvent(PointerEvent.Event.click, e
                                        .ownerId, e
                                        .x, e.y, e
                                        .button, e.movementX, e.movementY);
                                clickEvent.isSynthetic = true;
                                fireEvent(clickEvent);
                                clickCount = 0;

                                if (clickEvent.isConsumed)
                                {
                                    return;
                                }
                            }
                        }
                        else
                        {
                            clickCount = 0;
                        }
                        lastClickTimeMs = platform.timer.ticksMs;
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
                if (clickCount != 0)
                {
                    clickCount = 0;
                }

                if (onPointerOutBounds.length > 0)
                {
                    foreach (dg; onPointerOutBounds)
                    {
                        dg(e);
                    }
                }

                if (e.event == PointerEvent.Event.move)
                {
                    if (isMouseOver)
                    {
                        isMouseOver = false;
                        auto exitEvent = PointerEvent(PointerEvent.Event.exit, e
                                .ownerId, e
                                .x, e.y, e
                                .button, e.movementX, e.movementY);
                        exitEvent.isSynthetic = true;
                        fireEvent(exitEvent);
                    }

                    runEventHandlers(e);
                }
                else if (e.event == PointerEvent.Event.press)
                {
                    if (isFocus && (onFocusExit.length > 0 || eventFocusHandlers.length > 0))
                    {
                        unfocus(e.ownerId);
                    }
                }
                else if (e.event == PointerEvent.Event.wheel)
                {
                    if (onPointerWheel.length > 0)
                    {
                        auto pointerPos = input.systemCursor.getPos;
                        if (containsPoint(pointerPos.x, pointerPos.y))
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
        }

        static if (is(Event : FocusEvent))
        {
            if (!e.isSynthetic)
            {
                if (inClipBounds(e.x, e.y) && containsPoint(e.x, e.y))
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

        static if (is(Event : KeyEvent) || is(Event : TextInputEvent))
        {
            if (isFocus)
            {
                runEventHandlers(e);
            }
        }

        static if (is(Event : JoystickEvent))
        {
            if (isFocus)
            {
                runEventHandlers(e);
            }
        }

        if (!isEventsFirstProcessChildren)
        {
            dispatchEventToChildren(e);
        }

        onEventPhase(e, EventKitPhase.postDispatch);
    }

    void dispatchEventToChildren(E)(ref E e)
    {
        if (isForwardEventsToChildren && children.length > 0)
        {
            onEventPhase(e, EventKitPhase.preDispatchChildren);

            if (!isDispatchChildrenFromLast)
            {
                foreach (Sprite2d child; children)
                {
                    dispatchEventToChild(e, child);

                    if (e.isConsumed)
                    {
                        break;
                    }
                }
            }
            else
            {
                foreach_reverse (Sprite2d child; children)
                {
                    dispatchEventToChild(e, child);

                    if (e.isConsumed)
                    {
                        break;
                    }
                }
            }

            onEventPhase(e, EventKitPhase.postDispatchChildren);
        }
    }

    void dispatchEventToChild(E)(ref E e, Sprite2d child)
    {
        if (!isClipped)
        {
            child.dispatchEvent(e);
        }
        else
        {
            if (isOutClipForwardEvents)
            {
                child.dispatchEvent(e);
            }
            else
            {
                //TODO specify the events being forwarded
                static if (__traits(compiles, (e.x == e.y)))
                {
                    if (clip.contains(e.x, e.y))
                    {
                        child.dispatchEvent(e);
                    }
                    else
                    {
                        static if (is(Event : PointerEvent))
                        {
                            if (e.event == PointerEvent.Event.move)
                            {
                                child.dispatchEvent(e);
                            }
                        }
                    }
                }
                else
                {
                    child.dispatchEvent(e);
                }
            }
        }
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

        foreach (Sprite2d obj; children)
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
            drawContent;
            redraw = true;
        }

        foreach (Sprite2d obj; children)
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

        if (!isValid && isDrawInvalidBounds)
        {
            drawBounds(boundsInvalidColor);
        }

        if (isDrawCenterBounds)
        {
            drawCenterBounds;
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

    bool recreate()
    {
        return true;
    }

    import api.dm.kit.components.graphic_component : GraphicComponent;

    alias build = GraphicComponent.build;

    void build(Sprite2d sprite)
    {
        assert(!sprite.isBuilt);
        super.build(sprite);

        //sprite can access parent properties before being added
        trySetParentProps(sprite);
    }

    protected bool trySetParentProps(Sprite2d sprite)
    {
        assert(sprite);

        bool isSet;
        if (!sprite.parent)
        {
            sprite.parent = this;
            isSet = true;
        }

        if (!sprite.sceneProvider)
        {
            // if (!sceneProvider)
            // {
            //     import std.format : format;

            //     throw new Exception(format("Scene provider not installed on %s, parent: %s with scene provider: %s", classInfo, parent, (parent ? parent.sceneProvider : null)));
            // }

            sprite.sceneProvider = sceneProvider;
            isSet |= true;
        }

        if (isLayoutOnInvalidForChildren)
        {
            sprite.isLayoutOnInvalid = isLayoutOnInvalid;
        }

        if (layout && isLayoutForChildren)
        {
            sprite.layout = layout;
        }

        return isSet;
    }

    void addCreate(Sprite2d[] sprites)
    {
        foreach (sprite; sprites)
        {
            addCreate(sprite);
        }
    }

    void addCreate(Sprite2d sprite, long index = -1)
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

        if (!sprite.isBuilt)
        {
            buildInit(sprite);
        }

        if (!sprite.isCreated)
        {
            if (!sprite.isInitialized)
            {
                initialize(sprite);
            }

            sprite.create;
            if (!sprite.isCreated)
            {
                throw new Exception("Sprite2d not created: " ~ sprite.className);
            }
        }

        add(sprite, index);
    }

    void add(Sprite2d[] sprites)
    {
        foreach (s; sprites)
        {
            add(s);
        }
    }

    void add(Sprite2d sprite, long index = -1)
    {
        if (hasDirect(sprite))
        {
            debug
            {
                import std.format : format;

                throw new Exception(format("Sprite2d %s already added: %s. Parent %s: %s", typeid(
                        sprite), sprite.toString, typeid(this), toString));
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

                throw new Exception(format(
                        "Child index must not be greater than %s, but received %s for child %s with children length %s", children
                        .length, index, sprite.toString, sprite.children.length));
            }

            import std.array : insertInPlace;

            children.insertInPlace(cast(size_t) index, sprite);
        }
        setInvalid;
    }

    Nullable!Sprite2d hasDirectSprite(Sprite2d obj)
    {
        if (obj is null)
        {
            throw new Exception("Unable to check for child existence: object is null");
        }

        foreach (Sprite2d child; children)
        {
            if (obj is child)
            {
                return Nullable!Sprite2d(obj);
            }
        }
        return Nullable!Sprite2d.init;
    }

    bool hasDirect(Sprite2d obj)
    {
        if (obj is null)
        {
            throw new Exception("Unable to check for child existence: object is null");
        }

        foreach (Sprite2d child; children)
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
            ch.onRemoveFromParent;

            if (isDestroy && !ch.isDisposed)
            {
                stopDisposeSafe(ch);
            }
        }

        children = null;
        setInvalid;

        return true;
    }

    bool changeIndex(Sprite2d sprite, size_t index)
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

    bool changeIndexToLast(Sprite2d sprite)
    {
        remove(sprite, false);
        add(sprite);
        return true;
    }

    bool remove(Sprite2d[] sprites, bool isDestroy = true)
    {
        bool isAnyRemove;
        foreach (sprite; sprites)
        {
            isAnyRemove |= remove(sprite, isDestroy);
        }
        return isAnyRemove;
    }

    void onRemoveFromParent()
    {

    }

    bool remove(Sprite2d obj, bool isDestroy = true)
    {
        import api.core.utils.arrays : drop;

        if (!hasDirect(obj))
        {
            return false;
        }

        obj.onRemoveFromParent;

        if (isDestroy && !obj.isDisposed)
        {
            if (obj.isRunning)
            {
                obj.stop;
            }
            obj.dispose;
        }

        auto isRemove = drop(children, obj);
        if (!isRemove)
        {
            import std.format : format;

            throw new Exception(format("The child %s has not been removed from %s", obj, this));
        }

        setInvalid;

        return isRemove;
    }

    void startDrag(double x, double y)
    {
        //TODO parent coordinates
        offsetX = _x - x;
        offsetY = _y - y;
        this.isDrag = true;

        if (onStartDrag)
        {
            onStartDrag();
        }
    }

    void stopDrag()
    {
        offsetX = 0;
        offsetY = 0;
        this.isDrag = false;

        if (onStopDrag)
        {
            onStopDrag();
        }
    }

    //TODO remove root from children
    void onAllChildren(scope void delegate(Sprite2d) onChild, Sprite2d root, bool isForRoot = true)
    {
        if (isForRoot)
        {
            onChild(root);
        }

        foreach (Sprite2d child; root.children)
        {
            onAllChildren(onChild, child);
        }
    }

    void onAllChildren(scope void delegate(Sprite2d) onChild, bool isForRoot = true)
    {
        onAllChildren(onChild, this, isForRoot);
    }

    protected void checkClip(Sprite2d obj)
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

    bool inClipBounds(double x, double y)
    {
        if (!isClipped)
        {
            return true;
        }
        return clip.contains(x, y);
    }

    void setClipFromBounds()
    {
        clip = Rect2d(x, y, width, height);
        isMoveClip = true;
        isResizeClip = true;
    }

    void enableClipping()
    {
        graphic.clip(clip);
    }

    void disableClipping()
    {
        graphic.clearClip;
    }

    bool isClipped() => clip.width > 0 || clip.height > 0;

    void applyLayout()
    {
        if (layout)
        {
            if (isLayoutOnInvalid && isValid)
            {
                return;
            }

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

    void validate(scope void delegate(Sprite2d) onInvalid = null)
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

            if (isAllowInvalidate)
            {
                //listeners can expect to call layout manager
                foreach (invListener; invalidateListeners)
                {
                    invListener();
                }
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

    void applyAllContainers()
    {
        foreach (ch; children)
        {
            ch.applyAllContainers;
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
                auto thisBounds = boundsRect;
                thisBounds.x = _x + dx;
                thisBounds.y = _y + dy;

                const screen = graphic.renderBounds;
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

        foreach (Sprite2d child; children)
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

    bool isInScreenBounds()
    {
        assert(graphic);
        return graphic.renderBounds.contains(boundsRect);
    }

    bool isClipSet() => clip.width > 0 || clip.height > 0;

    bool containsPoint(double x, double y)
    {
        return boundsRect.contains(x, y);
    }

    bool intersectBounds(Sprite2d other)
    {
        return boundsRect.intersect(other.boundsRect);
    }

    bool intersect(Sprite2d other)
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

    Rect2d boundsRect() => Rect2d(x, y, _width, _height);
    Rect2d boundsLocal() => Rect2d(0, 0, _width, _height);

    Rect2d boundsRectInParent()
    {
        if (!parent)
        {
            return boundsRect;
        }

        const Rect2d pBounds = {x - parent.x, y - parent.y, _width, _height};
        return pBounds;
    }

    Quadrilateral2d boundsPoly()
    {
        Quadrilateral2d bounds = Quadrilateral2d(x, y, _width, _height);
        if (_angle == 0)
        {
            return bounds;
        }

        rotateBounds(bounds, _angle);

        return bounds;
    }

    Quadrilateral2d boundsPolyInParent()
    {
        if (!parent)
        {
            return boundsPoly;
        }

        Quadrilateral2d bounds = Quadrilateral2d(x - parent.x, y - parent.y, _width, _height);
        if (_angle == 0)
        {
            return bounds;
        }

        rotateBounds(bounds, _angle);

        return bounds;
    }

    void rotateBounds(ref Quadrilateral2d bounds, double angle)
    {
        import api.math.matrices.matrix : Matrix2x2, Matrix2x1, toVec2d, fromVec2d;

        import Math = api.math;

        //TODO affine 2d
        Matrix2x2 rotM;
        rotM[0][0] = Math.cosDeg(angle);
        rotM[0][1] = -Math.sinDeg(angle);
        rotM[1][0] = Math.sinDeg(angle);
        rotM[1][1] = Math.cosDeg(angle);

        Matrix2x1 vecm;

        Vec2d pivot = bounds.center;

        fromVec2d(vecm, bounds.leftTop.subtract(pivot));
        bounds.leftTop = rotM.multiply(vecm).toVec2d.add(pivot);

        fromVec2d(vecm, bounds.rightTop.subtract(pivot));
        bounds.rightTop = rotM.multiply(vecm).toVec2d.add(pivot);

        fromVec2d(vecm, bounds.rightBottom.subtract(pivot));
        bounds.rightBottom = rotM.multiply(vecm).toVec2d.add(pivot);

        fromVec2d(vecm, bounds.leftBottom.subtract(pivot));
        bounds.leftBottom = rotM.multiply(vecm).toVec2d.add(pivot);
    }

    Rect2d boundsRectPadding()
    {
        const b = boundsRect;
        const pBounds = Rect2d(b.x + padding.left, b.y + padding.top, b.width - padding.width, b.height - padding
                .height);
        return pBounds;
    }

    Rect2d boundsRectLayout()
    {
        Rect2d bounds = Rect2d(
            x - margin.left,
            y - margin.top,
            _width + margin.width,
            _height + margin.height
        );
        return bounds;
    }

    Rect2d boundsRectGeom()
    {
        const Rect2d bounds = {0, 0, _width, _height};
        return bounds;
    }

    alias move = pos;

    bool toCenter(bool isUseParent = false)
    {
        bool isMove;
        isMove |= toCenterX(isUseParent);
        isMove |= toCenterY(isUseParent);
        return isMove;
    }

    bool toCenterX(bool isUseParent = false)
    {
        Rect2d bounds = (isUseParent && parent) ? parent.boundsRect : graphic.renderBounds;
        if (bounds.width == 0)
        {
            return false;
        }

        auto middleX = bounds.middleX;

        if (_width > 0)
        {
            auto newX = middleX - _width / 2;
            return (x = newX);
        }

        return x = middleX;
    }

    bool toCenterY(bool isUseParent = false)
    {
        Rect2d bounds = (isUseParent && parent) ? parent.boundsRect : graphic.renderBounds;
        if (bounds.height == 0)
        {
            return false;
        }

        auto middleY = bounds.middleY;

        if (_height > 0)
        {
            auto newY = middleY - _height / 2;
            return (y = newY);
        }

        return (y = middleY);
    }

    Vec2d pos() @safe pure nothrow
    {
        return Vec2d(x, y);
    }

    bool pos(Vec2d newPos) => pos(newPos.x, newPos.y);

    bool pos(double newX, double newY)
    {
        bool isChangePos;
        isChangePos |= (x = newX);
        isChangePos |= (y = newY);
        return isChangePos;
    }

    Vec2d center()
    {
        return Vec2d(x + (width / 2.0), y + (height / 2.0));
    }

    void centering(Sprite2d child)
    {
        assert(child);
        auto childPos = center.subtract(Vec2d(child.halfWidth, child.halfHeight));
        child.xy(childPos);
    }

    Vec2d xy() => Vec2d(x, y);

    bool xy(Vec2d newXY) => xy(newXY.x, newXY.y);

    bool xy(double newX, double newY)
    {
        bool isChangeXY;
        isChangeXY |= x(newX);
        isChangeXY |= y(newY);
        return isChangeXY;
    }

    double x() @safe pure nothrow
    {
        return _x;
    }

    bool x(double newX)
    {
        if (isRoundEvenX)
        {
            newX = Math.roundEven(newX);
        }

        if (!Math.greater(_x, newX, xChangeThreshold))
        {
            return false;
        }

        foreach (Sprite2d child; children)
        {
            if (child.isManaged)
            {
                double dx = newX - _x;
                double newChildX = child.x + dx;
                child.x = !isRoundEvenChildX ? newChildX : Math.roundEven(newChildX);
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

        if (!isInvalidationProcess)
        {
            setInvalid;
            invalidationState.x = true;
        }

        return true;
    }

    double y() @safe pure nothrow
    {
        return _y;
    }

    bool y(double newY)
    {
        if (isRoundEvenY)
        {
            newY = Math.roundEven(newY);
        }

        if (!Math.greater(_y, newY, yChangeThreshold))
        {
            return false;
        }

        foreach (Sprite2d child; children)
        {
            if (child.isManaged)
            {
                double dy = newY - _y;
                double newChildY = child.y + dy;
                child.y = !isRoundEvenChildY ? newChildY : Math.roundEven(newChildY);
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

        if (!isInvalidationProcess)
        {
            setInvalid;
            invalidationState.y = true;
        }

        return true;
    }

    void isRoundEvenXY(bool isRound)
    {
        isRoundEvenX = isRound;
        isRoundEvenY = isRound;
    }

    void isRoundEvenChildXY(bool isRound)
    {
        isRoundEvenChildX = isRound;
        isRoundEvenChildY = isRound;
    }

    bool initWidth(double newWidth) => width = newWidth * multiplyInitWidth;
    bool initHeight(double newHeight) => height = newHeight * multiplyInitHeight;
    void initWidthForce(double newWidth)
    {
        _width = newWidth * multiplyInitWidth;
    }

    void initHeightForce(double newHeight)
    {
        _height = newHeight * multiplyInitHeight;
    }

    protected bool initSize(double newWidth, double newHeight)
    {
        bool isWidth = initWidth(newWidth);
        bool isHeight = initHeight(newHeight);
        return isWidth || isHeight;
    }

    protected void initSizeForce(double newWidth, double newHeight)
    {
        initWidthForce(newWidth);
        initHeightForce(newHeight);
    }

    double width() @safe pure nothrow
    {
        return _width;
    }

    double halfWidth() @safe pure nothrow => width / 2;

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

    void forceWidth(double value)
    {
        _width = value;
    }

    void forceHeight(double value)
    {
        _height = value;
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
                if (isResizeChildrenAlways)
                {
                    incChildWidth(child, dw);
                    continue;
                }

                if (!child.isResizedWidthByParent)
                {
                    if (isResizeChildrenIfNotResizable)
                    {
                        incChildWidth(child, dw);
                    }

                    continue;
                }

                if ((isResizeChildrenIfNoLayout && !layout) || (isResizeChildrenIfNotLManaged && !child
                        .isLayoutManaged))
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

    protected void incChildWidth(Sprite2d child, double dw)
    {
        const newWidth = child.width + dw;
        child.width = newWidth;
    }

    protected void incChildHeight(Sprite2d child, double dh)
    {
        const newHeight = child.height + dh;
        child.height = newHeight;
    }

    double height() @safe pure nothrow
    {
        return _height;
    }

    double halfHeight() @safe pure nothrow => height / 2;

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

    bool setHeight(double value)
    {
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
                if (isResizeChildrenAlways)
                {
                    incChildHeight(child, dh);
                    continue;
                }

                if (!child.isResizedHeightByParent)
                {
                    if (isResizeChildrenIfNotResizable)
                    {
                        incChildHeight(child, dh);
                    }

                    continue;
                }

                if ((isResizeChildrenIfNoLayout && !layout) || (isResizeChildrenIfNotLManaged && !child
                        .isLayoutManaged))
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
        if (isForce)
        {
            isResized |= setWidth(newWidth);
            isResized |= setHeight(newHeight);
            return isResized;
        }

        isResized |= (width = newWidth);
        isResized |= (height = newHeight);
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

    bool rescale(double factor) => rescale(factor, factor);
    bool rescale2() => rescale(2, 2);
    bool rescale05() => rescale(0.5, 0.5);

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
        drawBounds(boundsColor);
    }

    void drawBounds(RGBA color)
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        if (width == 0 || height == 0)
        {
            return;
        }

        graphic.color(color);

        const b = boundsRect;
        //graphic.rect(b.x, b.y, b.width, b.height, GraphicStyle(1, RGBA.red));
        const double leftTopX = b.x, leftTopY = b.y;

        const double rightTopX = leftTopX + b.width, rightTopY = leftTopY;
        graphic.line(leftTopX, leftTopY, rightTopX, rightTopY);

        const double rightBottomX = rightTopX, rightBottomY = rightTopY + b.height;
        graphic.line(rightTopX, rightTopY, rightBottomX, rightBottomY);

        const double leftBottomX = leftTopX, leftBottomY = leftTopY + b.height;
        graphic.line(rightBottomX, rightBottomY, leftBottomX, leftBottomY);

        graphic.line(leftBottomX, leftBottomY, leftTopX, leftTopY);

        graphic.restoreColor;
    }

    void drawCenterBounds()
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        if (width == 0 || height == 0)
        {
            return;
        }

        graphic.color(boundsCenterColor);
        scope (exit)
        {
            graphic.restoreColor;
        }

        const thisBounds = boundsRect;
        graphic.line(thisBounds.middleX, thisBounds.y, thisBounds.middleX, thisBounds.bottom);
        graphic.line(thisBounds.x, thisBounds.middleY, thisBounds.right, thisBounds.middleY);
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

        graphic.color(color);

        import api.math.geom2.vec2 : Vec2d;

        graphic.rect(Vec2d(clip.x, clip.y), clip.width, clip.height);

        graphic.restoreColor;
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

    void onChildrenRec(bool delegate(Sprite2d) onSpriteIsContinue)
    {
        onChildrenRec(this, onSpriteIsContinue);
    }

    void onChildrenRec(Sprite2d root, bool delegate(Sprite2d) onSpriteIsContinue)
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

    Nullable!Sprite2d findChildRec(string id)
    {
        Sprite2d mustBeChild;
        onChildrenRec((child) {
            if (child.id == id)
            {
                mustBeChild = child;
                return false;
            }
            return true;
        });
        return mustBeChild is null ? Nullable!Sprite2d.init : Nullable!Sprite2d(mustBeChild);
    }

    Nullable!Sprite2d findChildRec(Sprite2d child)
    {
        if (child is null)
        {
            debug throw new Exception("Child must not be null");
            return Nullable!Sprite2d.init;
        }
        Sprite2d mustBeChild;
        onChildrenRec((currentChild) {
            if (child is currentChild)
            {
                mustBeChild = child;
                return false;
            }
            return true;
        });

        return mustBeChild is null ? Nullable!Sprite2d.init : Nullable!Sprite2d(mustBeChild);
    }

    int findChildIndex(Sprite2d child)
    {
        import std.conv : to;

        foreach (i, Sprite2d ch; children)
        {
            if (ch is child)
            {
                return i.to!int;
            }
        }
        return -1;
    }

    bool isLastIndex(Sprite2d child)
    {
        if (children.length == 0)
        {
            return false;
        }
        const index = findChildIndex(child);
        return index == children.length - 1;
    }

    Sprite2d findChildUnsafe(Sprite2d child)
    {
        foreach (Sprite2d ch; children)
        {
            if (ch is child)
            {
                return ch;
            }
        }
        return null;
    }

    Nullable!Sprite2d findChild(Sprite2d child)
    {
        foreach (Sprite2d ch; children)
        {
            if (ch is child)
            {
                return Nullable!Sprite2d(ch);
            }
        }
        return Nullable!Sprite2d.init;
    }

    Nullable!Sprite2d findChild(string id)
    {
        foreach (Sprite2d ch; children)
        {
            if (ch.id == id)
            {
                return Nullable!Sprite2d(ch);
            }
        }
        return Nullable!Sprite2d.init;
    }

    import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

    Texture2d toTexture(double scaleX = 1, double scaleY = 1, Texture2d delegate() newTextureProvider = null)
    {
        assert(width > 0);
        assert(height > 0);

        auto tW = width * scaleX;
        auto tH = height * scaleY;

        auto texture = newTextureProvider ? newTextureProvider() : new Texture2d(tW, tH);
        if (!texture.isCreated)
        {
            buildInitCreate(texture);
            texture.createTargetRGBA32;
        }

        toTexture(texture);
        return texture;
    }

    void toTexture(Texture2d dest)
    {
        assert(dest);

        dest.setRendererTarget;
        scope (exit)
        {
            dest.restoreRendererTarget;
        }

        graphic.clearTransparent;

        bool isVisibleTemp = isVisible;
        if (!isVisibleTemp)
        {
            isVisible = true;
        }

        draw;

        isVisible = isVisibleTemp;
    }

    ComSurface snapshot()
    {
        assert(width > 0 && height > 0);
        import api.math.geom2.rect2 : Rect2d;

        auto bounds = Rect2d(
            0, 0, width, height
        );
        auto surf = graphic.comSurfaceProvider.getNew();
        auto err = surf.createRGBA32(cast(int) width, cast(int) height);
        if (err)
        {
            throw new Exception(err.toString);
        }
        graphic.readPixels(bounds, surf);
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

        import api.dm.kit.sprites2d.images.image : Image;

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

    bool canEnablePadding()
    {
        return false;
    }

    void enablePadding()
    {

    }

    void disableInsets()
    {
        padding(0);
    }

    ref Insets padding()
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

    double marginTop() => _margin.top;
    double marginTop(double value) => _margin.top = value;

    double marginBottom() => _margin.bottom;
    double marginBottom(double value) => _margin.bottom = value;

    double marginRight() => _margin.right;
    double marginRight(double value) => _margin.right = value;

    double marginLeft() => _margin.left;
    double marginLeft(double value) => _margin.left = value;

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

    void setUserData(T)(string key, T data)
    {
        //TODO remove qualifiers from value types
        Variant v = data;
        userData[key] = v;
    }

    T getUserData(T)(string key)
    {
        if (auto keyPtr = key in userData)
        {
            Variant v = *keyPtr;
            return v.get!T;
        }

        throw new Exception("Not found user data for key " ~ key);
    }

    override void dispose()
    {
        if (isRunning)
        {
            stop;
        }

        super.dispose;

        if (_hitbox)
        {
            _hitbox.dispose;
        }

        foreach (Sprite2d child; children)
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

    bool canExpandW(double value)
    {
        Sprite2d curParent = parent;
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
        Sprite2d curParent = parent;
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

    void hitbox(Sprite2d sprite)
    {
        addCreate(sprite);
        sprite.isLayoutManaged = false;
        //sprite.isVisible = false;
        _hitbox = sprite;
    }

    Sprite2d hitbox()
    {
        return _hitbox;
    }

    Rect2d boundingBox() => boundingBox(angle);

    Rect2d boundingBox(double angleDeg)
    {
        import Math = api.math;

        Rect2d box = boundsRect.boundingBox(angleDeg);
        box.x = x;
        box.y = y;
        return box;
    }

    Rect2d boundingBoxMax() => boundsRect.boundingBoxMax;

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

        if (isVisibilityForChildren)
        {
            foreach (ch; children)
            {
                ch.isVisible = value;
            }
        }
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

    bool isLayoutMovable() pure @safe
    {
        return _layoutMovable;
    }

    void isLayoutMovable(bool value) pure @safe
    {
        if (_layoutMovable != value)
        {
            setInvalid;
            invalidationState.layout = true;
        }

        _layoutMovable = value;
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

    void focus(int eventOwnerId = 0)
    {
        if (isFocus)
        {
            return;
        }

        isFocus = true;

        if (onFocusEnter.length > 0 || eventFocusHandlers.length > 0)
        {
            import api.dm.kit.events.focus.focus_event : FocusEvent;

            auto focusEvent = FocusEvent(FocusEvent.Event.enter, eventOwnerId);
            focusEvent.isSynthetic = true;
            fireEvent(focusEvent);
        }
    }

    void unfocus(int eventOwnerId = 0)
    {
        if (!isFocus)
        {
            return;
        }

        isFocus = false;

        if (onFocusExit.length > 0 || eventFocusHandlers.length > 0)
        {
            import api.dm.kit.events.focus.focus_event : FocusEvent;

            auto focusEvent = FocusEvent(FocusEvent.Event.exit, eventOwnerId);
            focusEvent.isSynthetic = true;
            fireEvent(focusEvent);
        }
    }

    void opacityLimit(double v)
    {
        maxOpacity = v;
        opacity = v;
    }

    GraphicCanvas canvas()

    out (_gContext; _gContext !is null)
    {
        return _gContext;
    }

    void canvas(GraphicCanvas context)
    in (context !is null)
    {
        _gContext = context;
    }

    void angle(double value)
    {
        if (_angle == value)
        {
            return;
        }

        _angle = value;

        if (isAngleForChildren)
        {
            foreach (ch; children)
            {
                ch.angle = angle;
            }
        }

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

    void isResizedByParent(bool v)
    {
        isResizedWidthByParent = v;
        isResizedHeightByParent = v;
    }

    bool isResizedByParent() => isResizedWidthByParent || isResizedHeightByParent;

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

    string classInfo()
    {
        if (id.length > 0)
        {
            return id;
        }
        return className;
    }

    override string toString()
    {
        import std.format : format;

        return format("id: %s, parent: %s, x: %f, y: %f, width: %f, height: %f", id, parent, x, y, width, height);
    }

}
