module api.dm.gui.controls.control;

import DisplayLayout = api.dm.gui.display_layout;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.layouts.layout : Layout;
import api.math.insets : Insets;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.styles.default_style : DefaultStyle;
import api.dm.kit.graphics.styles.default_style;
import api.math.alignment : Alignment;
import api.math.insets : Insets;
import api.dm.gui.controls.popups.base_popup : BasePopup;
import api.dm.kit.graphics.themes.theme : Theme;

import api.dm.kit.sprites.tweens.tween : Tween;
import api.dm.kit.sprites.tweens.targets.props.opacity_tween : OpacityTween;

import std.typecons : Nullable;

enum ControlStyle : string
{
    background = "backgroundStyle",
    hoverEffect = "hoverEffect",
    actionEffect = "actionEffect"
}

/**
 * Authors: initkfs
 */
class Control : Sprite
{
    enum
    {
        idBackground = "control_background",
        idHoverShape = "control_hoverEffect",
        idActionShape = "control_action"
    }

    GraphicStyle style;
    GraphicStyle[string] styles;
    string styleId;
    GraphicStyle delegate(string id) styleFactory;
    void delegate(string, ref GraphicStyle) onStyleIdCreated;
    bool isUseParentStyle;
    bool isStyleForChildren;
    bool isAppendStylesForChildren = true;

    bool isBackground;
    bool isBorder;
    bool isFocusable;
    bool isDisabled;

    bool isCreateBackgroundFactory = true;
    bool isCreateStyleFactory = true;
    bool isCreateHoverEffectFactory;
    bool isCreateActionEffectFactory;
    bool isCreateActionEffectAnimationFactory;

    bool isConsumeEventIfBackground = true;

    Sprite delegate(double, double) backgroundFactory;
    Sprite delegate(Sprite) onBackgroundCreate;
    void delegate(Sprite) onBackgroundCreated;

    Sprite delegate(double, double) hoverEffectFactory;
    Sprite delegate(Sprite) onHoverEffectCreate;
    void delegate(Sprite) onHoverEffectCreated;

    Sprite delegate() actionEffectFactory;
    Sprite delegate(Sprite) onActionEffectCreate;
    void delegate(Sprite) onActionEffectCreated;

    Tween delegate() actionEffectAnimationFactory;
    Tween delegate(Tween) onActionEffectAnimationCreate;
    void delegate(Tween) onActionEffectAnimationCreated;

    void delegate() onPreControlContentCreated;
    void delegate() onPostControlContentCreated;

    Theme theme;

    protected
    {
        bool _selected;

        Sprite _background;
        Sprite _hoverEffect;

        Sprite _actionEffect;
        Tween _actionEffectAnimation;

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

        if (!theme)
        {
            theme = loadTheme;
            assert(theme, "Theme must not be null");
        }

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

        if (!hoverEffectFactory && isCreateHoverEffectFactory)
        {
            hoverEffectFactory = createHoverEffectFactory;
        }

        if (!actionEffectFactory && isCreateActionEffectFactory)
        {
            actionEffectFactory = createActionEffectFactory;
        }

        if (!actionEffectAnimationFactory && isCreateActionEffectAnimationFactory)
        {
            actionEffectAnimationFactory = createActionEffectAnimationFactory;
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
        if (auto stylePtr = hasStyle(ControlStyle.background))
        {
            return (w, h) => createShape(w, h, *stylePtr);
        }
        return (w, h) => createShape(w, h);
    }

    Sprite delegate(double, double) createHoverEffectFactory()
    {
        return (w, h) {
            assert(theme);

            GraphicStyle newStyle;
            if (auto stylePtr = hasStyle(ControlStyle.hoverEffect))
            {
                newStyle = *stylePtr;
            }
            else
            {
                newStyle = createStyle;
                if (!newStyle.isNested)
                {
                    newStyle.lineColor = theme.colorHover;
                    newStyle.fillColor = theme.colorHover;
                    newStyle.isFill = true;
                }
            }

            Sprite newHover = theme.background(w, h, &newStyle);
            return newHover;
        };
    }

    Sprite delegate() createActionEffectFactory()
    {
        return () {
            assert(theme);

            GraphicStyle newStyle;
            if (auto stylePtr = hasStyle(ControlStyle.actionEffect))
            {
                newStyle = *stylePtr;
            }
            else
            {
                newStyle = createStyle;
                if (!newStyle.isNested)
                {
                    newStyle.lineColor = theme.colorAccent;
                    newStyle.fillColor = theme.colorAccent;
                    newStyle.isFill = true;
                }
            }

            Sprite effect = theme.background(width, height, &newStyle);
            return effect;
        };
    }

    Tween delegate() createActionEffectAnimationFactory()
    {
        return () {
            auto actionEffectAnimation = new OpacityTween(DisplayLayout.displayActionEffectAnimMs);
            assert(_actionEffect, "Pointer effect must not be null");
            //TODO move to create()
            actionEffectAnimation.addTarget(_actionEffect);
            return actionEffectAnimation;
        };
    }

    GraphicStyle delegate(string id) createStyleFactory()
    {
        return (id) {
            assert(theme);

            if (id.length == 0)
            {
                if (style != GraphicStyle.init)
                {
                    return style;
                }

                return createDefaultStyle;
            }

            if (auto stylePtr = hasStyle(id))
            {
                return *stylePtr;
            }

            GraphicStyle newStyle = createDefaultStyle;

            if (styleId)
            {
                switch (styleId) with (DefaultStyle)
                {
                    case standard:
                        break;
                    case success:
                        newStyle.lineColor = theme.colorSuccess;
                        break;
                    case warning:
                        newStyle.lineColor = theme.colorWarning;
                        break;
                    case danger:
                        newStyle.lineColor = theme.colorDanger;
                        break;
                    default:
                        break;
                }

                newStyle.fillColor = newStyle.lineColor;
            }

            newStyle.isFill = isBackground;
            if (!isBorder)
            {
                newStyle.lineWidth = 0;
            }

            return newStyle;
        };
    }

    GraphicStyle createDefaultStyle()
    {
        return GraphicStyle(theme.lineThickness, theme.colorAccent, isBackground, theme.colorControlBackground);
    }

    protected GraphicStyle createStyle()
    {
        assert(styleFactory);

        auto newStyle = styleFactory(styleId);
        if (onStyleIdCreated)
        {
            onStyleIdCreated(styleId, newStyle);
        }
        return newStyle;
    }

    protected Sprite createShape(double w, double h)
    {
        return createShape(w, h, createStyle);
    }

    protected Sprite createShape(double width, double height, GraphicStyle style = GraphicStyle
            .simple)
    {
        return theme.background(width, height, &style);
    }

    override void create()
    {
        super.create;

        if (!theme)
        {
            theme = loadTheme;
            assert(theme, "Theme must not be null");
        }

        tryCreateBackground(width, height);

        if (onPreControlContentCreated)
        {
            onPreControlContentCreated();
        }

        if (hoverEffectFactory)
        {
            auto newHover = hoverEffectFactory(width, height);
            if (newHover)
            {
                _hoverEffect = onHoverEffectCreate ? onHoverEffectCreate(newHover) : newHover;
                _hoverEffect.id = idHoverShape;
                _hoverEffect.isLayoutManaged = false;
                _hoverEffect.isResizedByParent = true;
                _hoverEffect.isVisible = false;

                addCreate(_hoverEffect);
                _hoverEffect.opacityLimit = theme.opacityHover;
                if (onHoverEffectCreated)
                {
                    onHoverEffectCreated(_hoverEffect);
                }
            }
            else
            {
                logger.error("Hover factory did not return the object");
            }
        }

        if (actionEffectFactory)
        {
            auto newActionEffect = actionEffectFactory();
            if (newActionEffect)
            {
                _actionEffect = onActionEffectCreate ? onActionEffectCreate(newActionEffect)
                    : newActionEffect;
                _actionEffect.id = idActionShape;
                _actionEffect.isLayoutManaged = false;
                _actionEffect.isResizedByParent = true;
                _actionEffect.isVisible = false;

                addCreate(_actionEffect);

                _actionEffect.opacity = 0;

                if (onActionEffectCreated)
                {
                    onActionEffectCreated(_actionEffect);
                }
            }
            else
            {
                logger.error("Pointer effect factory did not return the object");
            }
        }

        if (actionEffectAnimationFactory)
        {
            auto newEffectAnimation = actionEffectAnimationFactory();
            if (newEffectAnimation)
            {
                if (_actionEffect)
                {
                    _actionEffectAnimation = onActionEffectAnimationCreate ? onActionEffectAnimationCreate(
                        newEffectAnimation) : newEffectAnimation;
                    _actionEffectAnimation.isLayoutManaged = false;
                    _actionEffectAnimation.isInfinite = false;
                    _actionEffectAnimation.isReverse = true;
                    _actionEffectAnimation.onStop ~= () {
                        if (_actionEffect)
                        {
                            _actionEffect.isVisible = false;
                        }
                    };

                    addCreate(_actionEffectAnimation);

                    if (onActionEffectAnimationCreated)
                    {
                        onActionEffectAnimationCreated(_actionEffectAnimation);
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

    Theme loadTheme()
    {
        import LocatorKeys = api.dm.gui.locator_keys;

        auto newTheme = cast(Theme) locator.getObject(LocatorKeys.mainTheme);
        if (!newTheme)
        {
            throw new Exception("Not found service from locator");
        }
        return newTheme;
    }

    void createInteractiveListeners()
    {
        //TODO remove previous
        if (_hoverEffect)
        {
            onPointerEntered ~= (ref e) {

                if (isDisabled || _selected)
                {
                    return;
                }

                if (_hoverEffect && !_hoverEffect.isVisible)
                {
                    _hoverEffect.isVisible = true;
                }
            };

            onPointerExited ~= (ref e) {

                if (isDisabled || _selected)
                {
                    return;
                }

                if (_hoverEffect && _hoverEffect.isVisible)
                {
                    _hoverEffect.isVisible = false;
                }
            };
        }

        if (_actionEffect || _actionEffectAnimation)
        {
            onPointerUp ~= (ref e) {

                if (isDisabled || _selected)
                {
                    return;
                }

                if (_actionEffect && !_actionEffect.isVisible)
                {
                    _actionEffect.isVisible = true;
                    if (_actionEffectAnimation && !_actionEffectAnimation.isRunning)
                    {
                        _actionEffectAnimation.run;
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

        const iconSize = theme.iconSize;

        const mustBeIconData = theme.iconData(iconName);
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

        auto color = theme.colorAccent;

        icon.color = color;
        icon.create;
        return icon;
    }

    void applyStyle(Control control)
    {
        assert(control);

        if (isStyleForChildren || control.isUseParentStyle)
        {
            control.styleFactory = styleFactory;
            if (!isAppendStylesForChildren)
            {
                control.styles = styles;
            }
            else
            {
                foreach (styleId, style; styles)
                {
                    if (!control.hasStyle(styleId))
                    {
                        control.styles[styleId] = style;
                    }
                }
            }

            if (control.style == GraphicStyle.init)
            {
                control.style = style;
            }
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
        _background.id = idBackground;
        _background.isResizedByParent = true;
        _background.isLayoutManaged = false;
        _background.isDrawAfterParent = false;

        addCreate(_background, 0);

        _background.opacityLimit = theme.opacityBackground;

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
        if (_hoverEffect)
        {
            _hoverEffect.isVisible = value;
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

    bool hasHoverEffect() => _hoverEffect !is null;
    Sprite hoverEffectUnsafe() => _hoverEffect;

    Nullable!Sprite hoverEffect()
    {
        if (!hasHoverEffect)
        {
            return Nullable!Sprite.init;
        }
        return Nullable!Sprite(_hoverEffect);
    }

    bool hasActionEffect() => _actionEffect !is null;
    Sprite actionEffectUnsafe() => _actionEffect;

    Nullable!Sprite actionEffect()
    {
        if (!hasActionEffect)
        {
            return Nullable!Sprite.init;
        }
        return Nullable!Sprite(_actionEffect);
    }

    bool hasActionEffectAnimation() => _actionEffectAnimation !is null;
    Sprite actionEffectAnimUnsafe() => _actionEffectAnimation;

    Nullable!Sprite actionEffectAnimation()
    {
        if (!hasActionEffectAnimation)
        {
            return Nullable!Sprite.init;
        }
        return Nullable!Sprite(_actionEffectAnimation);
    }

    GraphicStyle* hasStyle(string id)
    {
        assert(id.length > 0);
        return id in styles;
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

    override bool isCanEnableInsets()
    {
        return theme !is null;
    }

    override void enablePadding()
    {
        if (!isCanEnableInsets)
        {
            throw new Exception(
                "Unable to enable paddings: graphic or theme is null. Perhaps the component is not built correctly");
        }
        _padding = theme.controlPadding;
    }

    override void dispose()
    {
        styles = null;
        super.dispose;
    }

}
