module api.dm.gui.controls.control;

import DisplayLayout = api.dm.gui.display_layout;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.layouts.layout : Layout;
import api.math.insets : Insets;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.styles.default_style: DefaultStyle;
import api.dm.kit.graphics.styles.default_style;
import api.math.alignment : Alignment;
import api.math.insets : Insets;
import api.dm.gui.controls.popups.base_popup : BasePopup;

import api.dm.kit.sprites.tweens.tween : Tween;
import api.dm.kit.sprites.tweens.targets.props.opacity_tween : OpacityTween;

import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class Control : Sprite
{
    enum
    {
        idControlBackground = "control_background",
        idControlHover = "control_hover",
        idControlPointerEffect = "control_pointer_effect"
    }

    GraphicStyle style;
    DefaultStyle defaultStyle;
    GraphicStyle delegate() styleFactory;
    GraphicStyle delegate(ref GraphicStyle) onStyleCreate;
    void delegate(ref GraphicStyle) onStyleCreated;
    bool isUseParentStyle;
    bool isStyleForChildren;

    bool isBackground;
    bool isBorder;
    bool isFocusable;
    bool isDisabled;

    bool isCreateBackgroundFactory = true;
    bool isCreateStyleFactory = true;
    bool isCreateHoverFactory;
    bool isCreatePointerEffectFactory;
    bool isCreatePointerEffectAnimationFactory;

    bool isConsumeEventIfBackground = true;

    Sprite delegate(double, double) backgroundFactory;
    Sprite delegate(Sprite) onBackgroundCreate;
    void delegate(Sprite) onBackgroundCreated;

    Sprite delegate(double, double) hoverFactory;
    Sprite delegate(Sprite) onHoverCreate;
    void delegate(Sprite) onHoverCreated;

    Sprite delegate() pointerEffectFactory;
    Sprite delegate(Sprite) onPointerEffectCreate;
    void delegate(Sprite) onPointerEffectCreated;

    Tween delegate() pointerEffectAnimationFactory;
    Tween delegate(Tween) onPointerEffectAnimationCreate;
    void delegate(Tween) onPointerEffectAnimationCreated;

    void delegate() onPreControlContentCreated;
    void delegate() onPostControlContentCreated;


    protected
    {
        bool _selected;

        Sprite _background;
        Sprite _hover;
        Sprite _pointerEffect;

        Tween _pointerEffectAnimation;

        bool isTooltipDelay;
        bool isTooltipListeners;
        size_t tooltipDelayCounter;
    }

    BasePopup[] tooltips;
    size_t tooltipDelay = DisplayLayout.displayTooltipDelayMs;

    this()
    {
        isResizedByParent = true;
        isResizable = true;
        isLayoutManaged = true;
        isResizeChildren = true;
    }

    override void initialize()
    {
        super.initialize;

        //TODO remove listener?
        invalidateListeners ~= () {
            if (!isCreated)
            {
                return;
            }

            adjustOrCreateBackground;
        };

        if (tooltips.length > 0)
        {
            initTooltipListeners;
        }

        if (!backgroundFactory && isCreateBackgroundFactory)
        {
            backgroundFactory = createBackgroundFactory;
        }

        if (!hoverFactory && isCreateHoverFactory)
        {
            hoverFactory = createHoverFactory;
        }

        if (!pointerEffectFactory && isCreatePointerEffectFactory)
        {
            pointerEffectFactory = createPointerEffectFactory;
        }

        if (!pointerEffectAnimationFactory && isCreatePointerEffectAnimationFactory)
        {
            pointerEffectAnimationFactory = createPointerEffectAnimationFactory;
        }

        if (!styleFactory && isCreateStyleFactory)
        {
            styleFactory = createStyleFactory;
        }
    }

    void initTooltipListeners()
    {
        if (isTooltipListeners)
        {
            return;
        }

        onPointerEntered ~= (ref e) {
            if (tooltips.length > 0)
            {
                isTooltipDelay = true;
            }
        };

        onPointerMove ~= (ref e) {
            if (isTooltipDelay && tooltipDelayCounter != 0)
            {
                tooltipDelayCounter = 0;
            }
        };

        onPointerExited ~= (ref e) {
            if (tooltips.length > 0)
            {
                isTooltipDelay = false;
                if (tooltips.length > 0)
                {
                    foreach (tooltip; tooltips)
                    {
                        tooltip.hide;
                    }
                }

            }
        };

        isTooltipListeners = true;
    }

    Sprite delegate(double, double) createBackgroundFactory()
    {
        return (w, h) => createShape(w, h);
    }

    Sprite delegate(double, double) createHoverFactory()
    {
        return (w, h) {
            assert(graphics.theme);

            GraphicStyle newStyle = createStyle;
            if (!newStyle.isNested)
            {
                newStyle.lineColor = graphics
                    .theme.colorHover;
                newStyle.fillColor = graphics.theme.colorHover;
                newStyle.isFill = true;
            }

            Sprite newHover = graphics.theme.background(w, h, &newStyle);
            return newHover;
        };
    }

    Sprite delegate() createPointerEffectFactory()
    {
        return () {
            assert(graphics.theme);

            GraphicStyle newStyle = createStyle;
            if (!newStyle.isNested)
            {
                newStyle.lineColor = graphics
                    .theme.colorAccent;
                newStyle.fillColor = graphics.theme.colorAccent;
                newStyle.isFill = true;
            }

            Sprite effect = graphics.theme.background(width, height, &newStyle);
            return effect;
        };
    }

    Tween delegate() createPointerEffectAnimationFactory()
    {
        return () {
            auto pointerEffectAnimation = new OpacityTween(DisplayLayout.displayPointerEffectAnimMs);
            assert(_pointerEffect, "Pointer effect must not be null");
            //TODO move to create()
            pointerEffectAnimation.addTarget(_pointerEffect);
            return pointerEffectAnimation;
        };
    }

    GraphicStyle delegate() createStyleFactory()
    {
        return () {
            assert(graphics.theme);

            return GraphicStyle(graphics.theme.lineThickness, graphics.theme.colorAccent, isBackground, graphics
                    .theme.colorControlBackground);
        };
    }

    protected GraphicStyle createStyle()
    {
        if (isUseParentStyle && parent)
        {
            import api.core.utils.types : castSafe;

            if (auto parentWidget = parent.castSafe!Control)
            {
                return parentWidget.style;
            }
        }
        return style;
    }

    protected Sprite createShape(double w, double h)
    {
        return createShape(w, h, createStyle);
    }

    protected Sprite createShape(double width, double height, GraphicStyle style = GraphicStyle
            .simple)
    {
        return graphics.theme.background(width, height, &style);
    }

    override void create()
    {
        super.create;

        if (style == GraphicStyle.init && styleFactory)
        {
            auto newStyle = styleFactory();
            style = onStyleCreate ? onStyleCreate(newStyle) : newStyle;
            if (onStyleCreated)
            {
                onStyleCreated(style);
            }
        }

        tryCreateBackground(width, height);

        if (onPreControlContentCreated)
        {
            onPreControlContentCreated();
        }

        if (hoverFactory)
        {
            auto newHover = hoverFactory(width, height);
            if (newHover)
            {
                _hover = onHoverCreate ? onHoverCreate(newHover) : newHover;
                _hover.id = idControlHover;
                _hover.isLayoutManaged = false;
                _hover.isResizedByParent = true;
                _hover.isVisible = false;

                addCreate(_hover);
                _hover.opacityLimit = graphics.theme.opacityHover;
                if (onHoverCreated)
                {
                    onHoverCreated(_hover);
                }
            }
            else
            {
                logger.error("Hover factory did not return the object");
            }
        }

        if (pointerEffectFactory)
        {
            auto newPointerEffect = pointerEffectFactory();
            if (newPointerEffect)
            {
                _pointerEffect = onPointerEffectCreate ? onPointerEffectCreate(newPointerEffect)
                    : newPointerEffect;
                _pointerEffect.id = idControlPointerEffect;
                _pointerEffect.isLayoutManaged = false;
                _pointerEffect.isResizedByParent = true;
                _pointerEffect.isVisible = false;

                addCreate(_pointerEffect);

                _pointerEffect.opacity = 0;

                if (onPointerEffectCreated)
                {
                    onPointerEffectCreated(_pointerEffect);
                }
            }
            else
            {
                logger.error("Pointer effect factory did not return the object");
            }
        }

        if (pointerEffectAnimationFactory)
        {
            auto newEffectAnimation = pointerEffectAnimationFactory();
            if (newEffectAnimation)
            {
                if (_pointerEffect)
                {
                    _pointerEffectAnimation = onPointerEffectAnimationCreate ? onPointerEffectAnimationCreate(
                        newEffectAnimation) : newEffectAnimation;
                    _pointerEffectAnimation.isLayoutManaged = false;
                    _pointerEffectAnimation.isInfinite = false;
                    _pointerEffectAnimation.isReverse = true;
                    _pointerEffectAnimation.onStop ~= () {
                        if (_pointerEffect)
                        {
                            _pointerEffect.isVisible = false;
                        }
                    };

                    addCreate(_pointerEffectAnimation);

                    if (onPointerEffectAnimationCreated)
                    {
                        onPointerEffectAnimationCreated(_pointerEffectAnimation);
                    }
                }
                else
                {
                    logger.error("Pointer effect is null for animation");
                }

            }
            else
            {
                logger.error("Pointer animation factory did not return the object or");
            }
        }

        if (onPostControlContentCreated)
        {
            onPostControlContentCreated();
        }

        createInteractiveListeners;
    }

    void createInteractiveListeners()
    {
        //TODO remove previous
        if (_hover)
        {
            onPointerEntered ~= (ref e) {

                if (isDisabled || _selected)
                {
                    return;
                }

                if (_hover && !_hover.isVisible)
                {
                    _hover.isVisible = true;
                }
            };

            onPointerExited ~= (ref e) {

                if (isDisabled || _selected)
                {
                    return;
                }

                if (_hover && _hover.isVisible)
                {
                    _hover.isVisible = false;
                }
            };
        }

        if (_pointerEffect || _pointerEffectAnimation)
        {
            onPointerUp ~= (ref e) {

                if (isDisabled || _selected)
                {
                    return;
                }

                if (_pointerEffect && !_pointerEffect.isVisible)
                {
                    _pointerEffect.isVisible = true;
                    if (_pointerEffectAnimation && !_pointerEffectAnimation.isRunning)
                    {
                        _pointerEffectAnimation.run;
                    }

                }
            };
        }

    }

    alias build = Sprite.build;

    override void build(Sprite sprite)
    {
        import api.core.utils.types : castSafe;

        assert(!sprite.isBuilt, "Sprite already built: " ~ sprite.className);

        super.build(sprite);
        //TODO may be a harmful side effect
        if (auto control = sprite.castSafe!Control)
        {
            applyStyle(control);
        }
    }

    alias add = Sprite.add;

    override void add(Sprite sprite, long index = -1)
    {
        import api.core.utils.types : castSafe;

        super.add(sprite, index);
        if (auto control = sprite.castSafe!Control)
        {
            applyStyle(control);
        }

        if (auto tooltip = sprite.castSafe!BasePopup)
        {
            tooltips ~= tooltip;
            if (!isTooltipListeners)
            {
                initTooltipListeners;
            }
            if (sceneProvider)
            {
                sceneProvider().controlledSprites ~= tooltip;
            }
        }
    }

    void addCreateIcon(string iconName)
    {
        auto icon = createIcon(iconName);
        addCreate(icon);
    }

    //TODO or move to scene factory?
    Sprite createIcon(string iconName)
    {
        assert(isCreated, "Sprite not created");

        import api.dm.kit.graphics.themes.icons.icon_name;
        import api.dm.kit.sprites.images.image : Image;

        import std.conv : to;

        const iconSize = graphics.theme.iconSize;

        const mustBeIconData = graphics.theme.iconData(iconName);
        if (mustBeIconData.isNull)
        {
            import api.dm.kit.sprites.shapes.rectangle : Rectangle;
            import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
            import api.dm.kit.graphics.colors.rgba : RGBA;

            auto placeholder = new Rectangle(iconSize, iconSize, GraphicStyle(1, RGBA.red, true, RGBA
                    .red));
            return placeholder;
        }

        const string iconData = mustBeIconData.get;

        auto icon = new Image;
        build(icon);

        import std.conv : to;

        icon.loadRaw(iconData.to!(const(void[])), cast(int) iconSize, cast(int) iconSize);

        auto color = graphics.theme.colorAccent;

        icon.color = color;
        icon.create;
        return icon;
    }

    void applyStyle(Control control)
    {
        assert(control);

        if (isStyleForChildren || control.isUseParentStyle)
        {
            control.style = style;
        }

        if (isStyleForChildren)
        {
            control.isStyleForChildren = isStyleForChildren;
        }
    }

    import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
    import api.dm.kit.events.event_kit_target : EventKitPhase;

    override void onEventPhase(ref PointerEvent e, EventKitPhase phase)
    {
        super.onEventPhase(e, phase);

        if (phase != EventKitPhase.postDispatch)
        {
            return;
        }

        if (isConsumeEventIfBackground && (isBackground || hasBackground))
        {
            if (containsPoint(e.x, e.y))
            {
                e.isConsumed = true;
            }
        }

    }

    protected bool tryCreateBackground(double width, double height)
    {
        if (
            _background ||
            width == 0 ||
            height == 0 ||
            (!isBackground && !isBorder)
            || !backgroundFactory)
        {
            return false;
        }

        auto newBackground = backgroundFactory(width, height);

        _background = onBackgroundCreate ? onBackgroundCreate(newBackground) : newBackground;
        _background.id = idControlBackground;
        _background.isResizedByParent = true;
        _background.isLayoutManaged = false;
        _background.isDrawAfterParent = false;

        addCreate(_background, 0);

        _background.opacityLimit = graphics.theme.opacityBackground;

        if (onBackgroundCreated)
        {
            onBackgroundCreated(_background);
        }

        return true;
    }

    void adjustOrCreateBackground()
    {
        if (_background)
        {
            _background.width = width;
            _background.height = height;
            return;
        }

        if (!_background && width > 0 && height > 0)
        {
            tryCreateBackground(width, height);
        }
    }

    bool isSelected() => _selected;

    void isSelected(bool value)
    {
        // if (isDisabled)
        // {
        //     return;
        // }
        _selected = value;
        if (_hover)
        {
            _hover.isVisible = value;
            setInvalid;
        }
    }

    bool hasBackground() => _background !is null;
    Sprite backgroundUnsafe() => _background;

    Nullable!Sprite background()
    {
        if (!hasBackground)
        {
            return Nullable!Sprite.init;
        }
        return Nullable!Sprite(_background);
    }

    bool hasHover() => _hover !is null;
    Sprite hoverUnsafe() => _hover;

    Nullable!Sprite hover()
    {
        if (!hasHover)
        {
            return Nullable!Sprite.init;
        }
        return Nullable!Sprite(_hover);
    }

    bool hasPointerEffect() => _pointerEffect !is null;
    Sprite pointerEffectUnsafe() => _pointerEffect;

    Nullable!Sprite pointerEffect()
    {
        if (!hasPointerEffect)
        {
            return Nullable!Sprite.init;
        }
        return Nullable!Sprite(_pointerEffect);
    }

    bool hasPointerEffectAnimation() => _pointerEffectAnimation !is null;
    Sprite pointerEffectAnimUnsafe() => _pointerEffectAnimation;

    Nullable!Sprite pointerEffectAnimation()
    {
        if (!hasPointerEffectAnimation)
        {
            return Nullable!Sprite.init;
        }
        return Nullable!Sprite(_pointerEffectAnimation);
    }

    override void update(double dt)
    {
        super.update(dt);

        if (isTooltipDelay)
        {
            if (tooltipDelayCounter >= tooltipDelay)
            {
                tooltipDelayCounter = 0;
                isTooltipDelay = false;
                foreach (t; tooltips)
                {
                    t.show;
                }
            }
            else
            {
                tooltipDelayCounter++;
            }
        }
    }

    GraphicStyle styleFromDefault()
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        GraphicStyle newStyle = style;

        if (defaultStyle != DefaultStyle.standard)
        {
            final switch (defaultStyle) with (DefaultStyle)
            {
                case standard:
                    break;
                case success:
                    style.lineColor = graphics.theme.colorSuccess;
                    break;
                case warning:
                    style.lineColor = graphics.theme.colorWarning;
                    break;
                case danger:
                    style.lineColor = graphics.theme.colorDanger;
                    break;
            }

            style.fillColor = style.lineColor;
        }
        style.isFill = isBackground;
        if (!isBorder)
        {
            style.lineWidth = 0;
        }
        return style;
    }

    override void dispose()
    {
        super.dispose;
    }

}
