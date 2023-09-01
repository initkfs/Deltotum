module deltotum.kit.sprites.sprite;

import deltotum.math.vector2d : Vector2d;
import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.kit.sprites.alignment : Alignment;
import deltotum.math.geom.insets : Insets;
import deltotum.kit.sprites.layouts.layout : Layout;
import deltotum.sys.sdl.sdl_texture : SdlTexture;
import deltotum.phys.physical_body : PhysicalBody;
import deltotum.kit.graphics.canvases.texture_canvas : TextureCanvas;
import deltotum.kit.scenes.scaling.scale_mode : ScaleMode;
import deltotum.kit.inputs.mouse.events.mouse_event : MouseEvent;
import deltotum.core.apps.events.application_event : ApplicationEvent;
import deltotum.kit.inputs.keyboards.events.key_event : KeyEvent;
import deltotum.kit.sprites.events.focus.focus_event : FocusEvent;
import deltotum.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import deltotum.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import deltotum.core.events.event_type : EventType;
import deltotum.core.utils.tostring;

import std.container : DList;
import std.math.operations : isClose;
import std.stdio;
import std.math.algebraic : abs;
import std.typecons : Nullable;
import deltotum.core.utils.tostring : ToStringExclude;

//TODO move to PhysBody
import deltotum.sys.chipmunk.chipm_body : ChipmBody;
import deltotum.sys.chipmunk.chipm_space : ChipmSpace;

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
class Sprite : PhysicalBody
{
    mixin ToString;

    string id;

    enum debugFlag = "d_debug";

    Sprite parent;

    double angle = 0;
    double opacity = 1;
    double scale = 1;

    Vector2d velocity;
    Vector2d acceleration;

    Rect2d clip;
    bool isMoveClip;
    bool isResizeClip;
    void delegate(Rect2d* clip) onClipResize;
    void delegate(Rect2d* clip) onClipMove;
    //TODO remove
    bool isClipped;

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

    ChipmBody physBody;
    ChipmSpace physSpace;

    //protected
    //{
    //TODO information about children
    @ToStringExclude Sprite[] children;
    //}

    protected
    {
        TextureCanvas _cache;
        Sprite _hitbox;
    }

    bool delegate(double, double) onDrag;

    InvalidationState invalidationState;
    void delegate()[] invalidateListeners;

    //old, new
    void delegate(double, double) onChangeWidthFromTo;
    void delegate(double, double) onChangeHeightFromTo;

    double minWidth = 0;
    double minHeight = 0;

    double maxWidth = double.max;
    double maxHeight = double.max;

    void delegate(double, double) onChangeXFromTo;
    void delegate(double, double) onChangeYFromTo;

    Object[string] userData;

    bool isInvalidationProcess;
    bool isValidatableChildren = true;

    bool isValid = true;

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

    void create()
    {
        if (isCreated)
        {
            return;
        }

        if (isCached && !_cache)
        {
            recreateCache;
        }

        super.createHandlers;
        eventMouseHandler = (ref e) {

            runListeners(e);

            if (e.isConsumed)
            {
                return;
            }

            if (e.event == MouseEvent.Event.mouseDown)
            {
                if (isDraggable && bounds.contains(e.x, e.y))
                {
                    startDrag(e.x, e.y);
                }
            }
            else if (e.event == MouseEvent.Event.mouseMove)
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
            else if (e.event == MouseEvent.Event.mouseUp)
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

    void recreate()
    {

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
            return;
        }

        sprite.parent = this;

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

            //TODO remove temp array
            children.insertInPlace(cast(size_t) index, [sprite]);
        }
        setInvalid;
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
            if (isDestroy)
            {
                ch.destroy;
            }
        }
        children = [];

        return true;
    }

    bool remove(Sprite[] sprites, bool isDestroy = true)
    {
        if (isDestroy)
        {
            foreach (sprite; sprites)
            {
                sprite.destroy;
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

        if (isDestroy)
        {
            children[mustBeIndex].destroy;
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

        static if (is(Event : MouseEvent))
        {
            //isClipped
            if ((clip.width > 0 || clip.height > 0) && !clip.contains(e.x, e.y))
            {
                return;
            }

            if (bounds.contains(e.x, e.y))
            {
                if (e.event == MouseEvent.Event.mouseMove)
                {
                    if (!isMouseOver)
                    {
                        isMouseOver = true;
                        auto enteredEvent = MouseEvent(EventType.mouse, MouseEvent.Event.mouseEntered, e
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
                if (e.event == MouseEvent.Event.mouseMove)
                {
                    if (isMouseOver)
                    {
                        isMouseOver = false;
                        auto exitedEvent = MouseEvent(EventType.mouse, MouseEvent.Event.mouseExited, e
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

            if (e.event == MouseEvent.Event.mouseMove && (isDrag || bounds.contains(e.x, e
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

    void onAllChildren(scope void delegate(Sprite) onChild, Sprite root)
    {
        onChild(root);

        foreach (Sprite child; root.children)
        {
            onAllChildren(onChild, child);
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
                obj.draw;
                checkClip(obj);
            }
        }

        if (isRedraw)
        {
            if (isCached)
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
                obj.draw;
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

        isInvalidationProcess = false;
        setValid(true);
        invalidationState.reset;
    }

    void validate()
    {
        if (isValidatableChildren)
        {
            foreach (ch; children)
            {
                ch.validate;
                if (!ch.isValid)
                {
                    setInvalid;
                }
            }
        }

        applyLayout;

        if (!isValid)
        {
            //listeners can expect to call layout manager
            foreach (invListener; invalidateListeners)
            {
                invListener();
            }
        }

        isInvalidationProcess = true;
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
        isInvalidationProcess = true;
    }

    void update(double delta)
    {
        double dx = 0;
        double dy = 0;

        checkCollisions;

        if (physBody)
        {
            Vector2d physVelocity = physBody.getVelocity;
            Vector2d physPosition = physBody.getPosition;
            double angleDeg = physBody.angleDeg;

            this.angle = angleDeg;
            if (width > 0 || height > 0)
            {
                //TODO offset in phys body
                _x = physPosition.x - width / 2.0;
                _y = physPosition.y - height / 2.0;
            }
            else
            {
                _x = physPosition.x;
                _y = physPosition.y;
            }

            velocity = physVelocity;
        }

        if (isUpdatable && isPhysicsEnabled)
        {
            //TODO check velocity is 0 || acceleration is 0
            const double accelerationDx = acceleration.x * invMass * delta;
            const double accelerationDy = acceleration.y * invMass * delta;

            double newVelocityX = velocity.x + accelerationDx;
            double newVelocityY = velocity.y + accelerationDy;

            if (gravity.x != 0 || gravity.y != 0)
            {
                //Vector2d forces = gravity.inc(invMass).scale(delta);
                Vector2d forces = gravity.scale(delta);

                newVelocityX += forces.x;
                newVelocityY += forces.y;
            }

            dx = newVelocityX * delta;
            dy = newVelocityY * delta;

            if (externalForce.x != 0)
            {
                externalForce.x = 0;
            }

            if (externalForce.y != 0)
            {
                externalForce.y = 0;
            }

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

        if (physSpace)
        {
            physSpace.step(delta);
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

    Rect2d bounds()
    {
        const Rect2d bounds = {x, y, _width, _height};
        return bounds;
    }

    Rect2d paddingBounds()
    {
        const b = bounds;
        const pBounds = Rect2d(b.x + padding.left, b.y + padding.top, b.width - padding.right, b.height - padding
                .bottom);
        return pBounds;
    }

    Rect2d layoutBounds()
    {
        const Rect2d bounds = {
            x - margin.left, y - margin.top, _width + margin.width, _height + margin.height};
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

            if (isCreated && onChangeXFromTo !is null)
            {
                onChangeXFromTo(_x, newX);
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

            if (isCreated && onChangeYFromTo !is null)
            {
                onChangeYFromTo(_y, newY);
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

            if (!isInvalidationProcess)
            {
                setInvalid;
                invalidationState.width = true;
            }

            if (!isCreated)
            {
                return;
            }

            if (onChangeWidthFromTo)
            {
                onChangeWidthFromTo(oldWidth, _width);
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

            if (!isInvalidationProcess)
            {
                setInvalid;
                invalidationState.height = true;
            }

            if (!isCreated)
            {
                return;
            }

            if (onChangeHeightFromTo)
            {
                onChangeHeightFromTo(oldHeight, _height);
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

        bool setScale(double factorWidth, double factorHeight)
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

            const prevColor = graphics.adjustRender(debugColor);

            const b = bounds;
            //graphics.drawRect(b.x, b.y, b.width, b.height, GraphicStyle(1, RGBA.red));
            const double leftTopX = b.x, leftTopY = b.y;

            const double rightTopX = leftTopX + b.width, rightTopY = leftTopY;
            graphics.drawLine(leftTopX, leftTopY, rightTopX, rightTopY, debugColor);

            const double rightBottomX = rightTopX, rightBottomY = rightTopY + b.height;
            graphics.drawLine(rightTopX, rightTopY, rightBottomX, rightBottomY, debugColor);

            const double leftBottomX = leftTopX, leftBottomY = leftTopY + b.height;
            graphics.drawLine(rightBottomX, rightBottomY, leftBottomX, leftBottomY, debugColor);

            graphics.drawLine(leftBottomX, leftBottomY, leftTopX, leftTopY, debugColor);

            graphics.adjustRender(prevColor);
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

        override void destroy()
        {
            super.destroy;

            if (_cache)
            {
                _cache.destroy;
            }

            if (_hitbox)
            {
                _hitbox.destroy;
            }

            if (physBody)
            {
                if (physSpace)
                {
                    if (physBody.shape)
                    {
                        physSpace.removeShape(physBody.shape.getObject);
                    }
                    physSpace.removeBody(physBody.getObject);
                }

                if (physBody.shape)
                {
                    physBody.shape.destroy;
                }

                physBody.destroy;
            }

            foreach (Sprite child; children)
            {
                child.parent = null;
                child.destroy;
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
    }
