module deltotum.kit.sprites.sprite;

import deltotum.kit.events.event_kit_target : EventKitTarget;
import deltotum.math.vector2d : Vector2d;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.geom.alignment : Alignment;
import deltotum.math.geom.insets : Insets;
import deltotum.kit.sprites.layouts.layout : Layout;
import deltotum.kit.sprites.canvases.texture_canvas : TextureCanvas;
import deltotum.kit.scenes.scaling.scale_mode : ScaleMode;
import deltotum.kit.inputs.pointers.events.pointer_event : PointerEvent;
import deltotum.core.apps.events.application_event : ApplicationEvent;
import deltotum.kit.inputs.keyboards.events.key_event : KeyEvent;
import deltotum.kit.sprites.events.focus.focus_event : FocusEvent;
import deltotum.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import deltotum.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.core.utils.tostring;

import std.container : DList;
import std.math.operations : isClose;
import std.stdio;
import std.math.algebraic : abs;
import std.typecons : Nullable;
import deltotum.core.utils.tostring : ToStringExclude;

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
    mixin ToString;

    enum debugFlag = "d_debug";

    string id;

    Sprite parent;

    double angle = 0;
    double opacity = 1;
    double scale = 1;
    double mass = 1;
    double speed = 0;

    bool isPhysicsEnabled;

    Vector2d velocity;
    Vector2d acceleration;

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

    GraphicStyle* style;
    bool isFindStyleInParent;

    bool inScreenBounds = true;
    bool delegate() onScreenBoundsIsStop;

    bool isRedraw = true;
    bool isRedrawChildren = true;
    bool isDrawAfterParent = true;
    bool _managed = true;
    bool isUpdatable = true;
    bool isResizable;
    bool isKeepAspectRatio;

    Layout layout;
    bool _layoutManaged = true;
    bool isResizeChildren;
    bool isResizedByParent;

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
    bool isDrawBounds;

    bool _visible = true;
    bool isReceiveEvents = true;

    //protected
    //{
    //TODO information about children
    @ToStringExclude Sprite[] children;
    //}

    bool delegate(double, double) onDrag;

    InvalidationState invalidationState;
    void delegate()[] invalidateListeners;

    //old, new
    void delegate(double, double) onChangeWidthOldNew;
    void delegate(double, double) onChangeHeightOldNew;

    double minWidth = 0;
    double minHeight = 0;

    double maxWidth = double.max;
    double maxHeight = double.max;

    void delegate(double, double) onChangeXOldNew;
    void delegate(double, double) onChangeYOldNew;

    Object[string] userData;

    bool isInvalidationProcess;
    bool isValidatableChildren = true;

    bool isValid = true;

    protected
    {
        TextureCanvas _cache;
        Sprite _hitbox;
    }

    private
    {
        double _x = 0;
        double _y = 0;

        double _width = 0;
        double _height = 0;

        double offsetX = 0;
        double offsetY = 0;
        bool isDrag;

        bool _cached;
    }

    this() pure @safe
    {

    }

    void buildCreate(Sprite sprite)
    {
        assert(sprite);

        if (!sprite.isBuilt)
        {
            build(sprite);
            assert(sprite.isBuilt, "Sprite not built: " ~ className);

            sprite.initialize;
            assert(sprite.isInitialized, "Sprite not initialized: " ~ className);
        }

        if (!sprite.isCreated)
        {
            sprite.create;
            assert(sprite.isCreated, "Sprite not created: " ~ className);
        }
    }

    override void create()
    {
        if (isCreated)
        {
            //TODO or error?
            return;
        }

        super.create;

        if (isCached)
        {
            recreateCache;
        }

        super.createHandlers;

        eventPointerHandlers ~= (ref e) {

            //runListeners(e);

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
                    if (onDrag is null || onDrag(x, y))
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
                            writefln(dragInfo);
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

    void dispatchEvent(Target : Sprite, Event)(Event e, ref DList!Target chain)
    {
        if (!isVisible || !isReceiveEvents)
        {
            return;
        }

        static if (__traits(compiles, e.target))
        {
            if (e.target !is null && e.target is this)
            {
                chain.insert(this);
                return;
            }
        }

        static if (is(Event : PointerEvent))
        {
            //isClipped
            if ((clip.width > 0 || clip.height > 0) && !clip.contains(e.x, e.y))
            {
                return;
            }

            if (bounds.contains(e.x, e.y))
            {
                if (e.event == PointerEvent.Event.move)
                {
                    if (!isMouseOver)
                    {
                        isMouseOver = true;
                        auto enteredEvent = PointerEvent(PointerEvent.Event.entered, e
                                .ownerId, e
                                .x, e.y, e
                                .button, e.movementX, e.movementY, false);
                        fireEvent(enteredEvent);
                    }

                    chain.insert(this);
                }
                else if (e.isChained)
                {
                    chain.insert(this);
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
                                .button, e.movementX, e.movementY, false);
                        fireEvent(exitedEvent);
                    }

                    chain.insert(this);
                }
                else if (isDrag && e.isChained)
                {
                    chain.insert(this);
                }
            }

            if (e.event == PointerEvent.Event.move && (isDrag || bounds.contains(e.x, e
                    .y)))
            {
                chain.insert(this);
            }
        }

        static if (is(Event : KeyEvent) || is(Event : TextInputEvent))
        {
            if (isFocus)
            {
                chain.insert(this);
            }
        }

        static if (is(Event : JoystickEvent))
        {
            chain.insert(this);
        }

        static if (is(Event : FocusEvent))
        {
            if (e.isChained)
            {
                if (bounds.contains(e.x, e.y))
                {
                    if (!isFocus && e.event == FocusEvent.Event.focusIn)
                    {
                        //TODO move to parent
                        isFocus = true;
                        chain.insert(this);
                    }
                }
                else
                {
                    if (isFocus && e.event == FocusEvent
                        .Event.focusOut)
                    {
                        isFocus = false;
                        chain.insert(this);
                    }
                }

            }
        }

        if (children.length > 0)
        {
            foreach (Sprite child; children)
            {
                child.dispatchEvent(e, chain);
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

        foreach (Sprite obj; children)
        {
            if (!obj.isDrawAfterParent && obj.isVisible)
            {
                if (!isValid)
                {
                    obj.draw;
                }
                else
                {
                    isRedraw = false;
                }
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
            if (obj.isDrawAfterParent && obj.isVisible)
            {
                if (!obj.isValid)
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

    import deltotum.kit.apps.comps.window_component : WindowComponent;

    alias build = WindowComponent.build;

    void build(Sprite sprite)
    {
        assert(!sprite.isBuilt);

        super.build(sprite);
        //TODO may be a harmful side effect
        applyStyle(sprite);
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
                throw new Exception("Sprite already added: " ~ sprite.toString);
            }
            return;
        }

        sprite.parent = this;
        applyStyle(sprite);

        if (index < 0 || children.length == 0)
        {
            children ~= sprite;
        }
        else
        {
            if (index >= children.length)
            {
                import std.format : format;

                throw new Exception(format("Child index must not be greater than %s, but received %s for child %s", children
                        .length, index, sprite.toString));
            }

            import std.array : insertInPlace;

            children.insertInPlace(cast(size_t) index, sprite);
        }
        setInvalid;
    }

    void applyStyle(Sprite sprite)
    {
        assert(sprite);
        if (style && !sprite.style)
        {
            sprite.style = style;
        }
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
            _cache = new TextureCanvas(width, height);
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

    void onAllChildren(scope void delegate(Sprite) onChild, Sprite root)
    {
        onChild(root);

        foreach (Sprite child; root.children)
        {
            onAllChildren(onChild, child);
        }
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

        // isInvalidationProcess = false;
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

        //isInvalidationProcess = true;
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
        //isInvalidationProcess = true;
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

                const screen = window.boundsLocal;
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

    bool intersect(Sprite other)
    {
        if (!hitbox && !other.hitbox)
        {
            return bounds.intersect(other.bounds);
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

    Vector2d position() @nogc @safe pure nothrow
    {
        return Vector2d(x, y);
    }

    void position(Vector2d pos)
    {
        x = pos.x;
        y = pos.y;
    }

    Vector2d center()
    {
        return Vector2d(x + (width / 2.0), y + (height / 2.0));
    }

    void xy(double newX, double newY)
    {
        x(newX);
        y(newY);
    }

    double x() @nogc @safe pure nothrow
    {
        return _x;
    }

    void x(double newX)
    {
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

    double y() @nogc @safe pure nothrow
    {
        return _y;
    }

    void y(double newY)
    {
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

    double width() @nogc @safe pure nothrow
    {
        return _width;
    }

    void width(double value)
    {
        if (
            value <= 0 ||
            value < minWidth ||
            value > maxWidth ||
            _width == value)
        {
            return;
        }

        if (isLayoutManaged && value > _width && !canExpandW(
                value - _width))
        {
            return;
        }

        immutable double oldWidth = _width;
        _width = value;

        //if (!isInvalidationProcess)
        //{
        setInvalid;
        invalidationState.width = true;
        //}

        if (!isCreated)
        {
            return;
        }

        if (onChangeWidthOldNew)
        {
            onChangeWidthOldNew(oldWidth, _width);
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

        //!isProcessLayout && !isProcessParentLayout && 
        if (isResizeChildren && children.length > 0)
        {
            immutable double dw = _width - oldWidth;
            foreach (child; children)
            {
                //TODO only isResizedByParent
                if (layout is null || (!child.isLayoutManaged && child.isResizedByParent))
                {
                    const newWidth = child.width + dw;
                    child.width(newWidth);
                }
            }
        }
    }

    double height() @nogc @safe pure nothrow
    {
        return _height;
    }

    void height(double value)
    {
        //(_width != 0 && !isResizable) || 
        if (value <= 0 ||
            _height == value)
        {
            return;
        }

        if (value < minHeight)
        {
            value = minHeight;
        }

        if (value > maxHeight)
        {
            value = maxHeight;
        }

        if (isLayoutManaged && value > _height && !canExpandH(value - _height))
        {
            return;
        }

        immutable double oldHeight = _height;
        _height = value;

        //if (!isInvalidationProcess)
        //{
        setInvalid;
        invalidationState.height = true;
        //}

        if (!isCreated)
        {
            return;
        }

        if (onChangeHeightOldNew)
        {
            onChangeHeightOldNew(oldHeight, _height);
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
                if (layout is null || (!child.isLayoutManaged && child.isResizedByParent))
                {
                    const newHeight = child.height + dh;
                    child.height(newHeight);
                }
            }
        }
    }

    bool resize(double newWidth, double newHeight)
    {
        width = newWidth;
        height = newHeight;
        return width == newWidth && height == newHeight;
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

    void setValid(bool value) @nogc @safe pure nothrow
    {
        isValid = value;
    }

    void setValidAll(bool value) @nogc @safe pure nothrow
    {
        isValid = value;
        foreach (ch; children)
        {
            ch.setValidAll(value);
        }
    }

    void setValidChildren(bool value) @nogc @safe pure nothrow
    {
        foreach (child; children)
        {
            child.isValid = value;
        }
    }

    void setInvalid() @nogc @safe pure nothrow
    {
        setValid(false);
    }

    string classnameShort()
    {
        string name;
        const string fullClassName = this.classinfo.name;

        import std.string : lastIndexOf;

        const lastDotPosIndex = fullClassName.lastIndexOf(".");
        if (lastDotPosIndex < 0)
        {
            return name;
        }
        name = fullClassName[lastDotPosIndex + 1 .. $];
        return name;
    }

    void drawBounds()
    {
        import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
        import deltotum.kit.graphics.colors.rgba : RGBA;

        if (width == 0 || height == 0)
        {
            return;
        }

        const debugColor = RGBA.red;

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

    void enableInsets()
    {
        enablePadding;
    }

    void enablePadding()
    {
        if (!hasGraphics || !graphics.theme)
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

    GraphicStyle* ownOrParentStyle()
    {
        if (style)
        {
            return style;
        }

        if (isFindStyleInParent)
        {
            Sprite currParent = parent;
            while (currParent)
            {
                if (currParent.style)
                {
                    return currParent.style;
                }
                currParent = currParent.parent;
            }
        }

        return parent ? parent.style : null;
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

    Insets margin()
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

    void margin(double top = 0, double right = 0, double bottom = 0, double left = 0)
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

    override void dispose()
    {
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

}
