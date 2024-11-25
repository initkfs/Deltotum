module api.dm.gui.controls.control;

import api.dm.gui.components.gui_component : GuiComponent;
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
import api.dm.gui.themes.theme : Theme;

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
class Control : GuiComponent
{
    enum
    {
        idBackground = "control_background",
        idHoverShape = "control_hover",
        idHoverAnimation = "control_hover_animation",
        idActionShape = "control_action",
        idActionAnimation = "control_action_animation"
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

    bool isCreateStyleFactory = true;
    bool isCreateBackgroundFactory = true;
    bool isCreateHoverEffectFactory;
    bool isCreateHoverAnimationFactory;
    bool isCreateActionEffectFactory;
    bool isCreateActionAnimationFactory;

    bool isConsumeEventIfBackground = true;

    Sprite delegate(double, double) backgroundFactory;
    Sprite delegate(Sprite) onBackgroundCreate;
    void delegate(Sprite) onBackgroundCreated;

    Sprite delegate(double, double) hoverEffectFactory;
    Sprite delegate(Sprite) onHoverEffectCreate;
    void delegate(Sprite) onHoverEffectCreated;

    Tween delegate() hoverAnimationFactory;
    Tween delegate(Tween) onHoverAnimationCreate;
    void delegate(Tween) onHoverAnimationCreated;

    void delegate() hoverEffectEnableBehaviour;
    void delegate() hoverEffectDisableBehaviour;

    size_t hoverAnimationDelayMs;

    Sprite delegate() actionEffectFactory;
    Sprite delegate(Sprite) onActionEffectCreate;
    void delegate(Sprite) onActionEffectCreated;

    void delegate() actionEffectBehaviour;

    size_t actionAnimationDelayMs;

    Tween delegate(Sprite) actionEffectAnimationFactory;
    Tween delegate(Tween) onActionEffectAnimationCreate;
    void delegate(Tween) onActionEffectAnimationCreated;

    bool isCreateInteractiveListeners;

    void delegate() onPreControlContentCreated;
    void delegate() onPostControlContentCreated;

    protected
    {
        bool _selected;

        Sprite _background;
        Sprite _hoverEffect;
        Tween _hoverEffectAnimation;

        Sprite _actionEffect;
        Tween _actionEffectAnimation;

        bool isTooltipDelay;
        bool isTooltipListeners;
        size_t tooltipDelayCounter;
    }

    BasePopup[] tooltips;
    size_t tooltipDelay;

    bool isSetNullWidthFromTheme = true;
    bool isSetNullHeightFromTheme = true;

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

        loadTheme;

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

        if (!hoverAnimationFactory && isCreateHoverAnimationFactory)
        {
            hoverAnimationFactory = createHoverAnimationFactory;
        }

        if (!actionEffectFactory && isCreateActionEffectFactory)
        {
            actionEffectFactory = createActionEffectFactory;
        }

        if (!actionEffectAnimationFactory && isCreateActionAnimationFactory)
        {
            actionEffectAnimationFactory = createActionEffectAnimationFactory;
        }

        if (!styleFactory && isCreateStyleFactory)
        {
            styleFactory = createStyleFactory;
        }

        if (tooltipDelay == 0)
        {
            tooltipDelay = theme.tooltipDelayMs;
        }

        if (actionAnimationDelayMs == 0)
        {
            actionAnimationDelayMs = theme.actionAnimationDelayMs;
        }

        if (hoverAnimationDelayMs == 0)
        {
            hoverAnimationDelayMs = theme.hoverAnimationDelayMs;
        }

        if (!hoverEffectEnableBehaviour)
        {
            hoverEffectEnableBehaviour = () {
                if (_hoverEffect && !_hoverEffect.isVisible)
                {
                    _hoverEffect.isVisible = true;

                    if (_hoverEffectAnimation && !_hoverEffectAnimation.isRunning)
                    {
                        _hoverEffectAnimation.isReverse = false;
                        //TODO from factory?
                        _hoverEffect.opacity = 0;
                        _hoverEffectAnimation.run;
                    }
                }
            };
        }

        if (!hoverEffectDisableBehaviour)
        {
            hoverEffectDisableBehaviour = () {
                if (_hoverEffect && _hoverEffect.isVisible)
                {
                    if (_hoverEffectAnimation)
                    {
                        if (_hoverEffectAnimation.isRunning && !_hoverEffectAnimation.isReverse)
                        {
                            _hoverEffectAnimation.stop;
                        }

                        if (!_hoverEffectAnimation.isRunning)
                        {
                            _hoverEffectAnimation.isReverse = true;
                            _hoverEffectAnimation.run;
                        }
                    }
                    else
                    {
                        _hoverEffect.isVisible = false;
                    }
                }
            };
        }

        if (!actionEffectBehaviour)
        {
            actionEffectBehaviour = () {
                if (_actionEffect)
                {
                    if (_actionEffectAnimation && _actionEffectAnimation.isRunning)
                    {
                        _actionEffectAnimation.stop;
                        _actionEffect.isVisible = false;
                    }

                    if (!_actionEffect.isVisible)
                    {
                        _actionEffect.isVisible = true;
                        if (_actionEffectAnimation)
                        {
                            _actionEffectAnimation.run;
                        }
                    }
                }
            };
        }
    }

    void loadTheme()
    {
        
    }

    void loadControlTheme()
    {
        if (isSetNullWidthFromTheme && _width == 0)
        {
            _width = theme.controlDefaultWidth;
        }

        if (isSetNullHeightFromTheme && _height == 0)
        {
            _height = theme.controlDefaultHeight;
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
                    if (!newStyle.isDefault)
                    {
                        newStyle.lineColor = theme.colorHover;
                        newStyle.fillColor = theme.colorHover;
                    }

                    newStyle.isFill = true;
                }
            }

            Sprite newHover = createShape(w, h, newStyle);
            newHover.id = idHoverShape;
            newHover.isLayoutManaged = false;
            newHover.isResizedByParent = true;
            newHover.isVisible = false;

            return newHover;
        };
    }

    Tween delegate() createHoverAnimationFactory()
    {
        return () {
            import std.conv : to;

            assert(_hoverEffect, "Hover effect is null");

            auto anim = new OpacityTween(hoverAnimationDelayMs.to!int);
            anim.id = idHoverAnimation;
            anim.addTarget(_hoverEffect);
            anim.isLayoutManaged = false;
            anim.onStop ~= () {
                if (_hoverEffect)
                {
                    if (anim.isReverse)
                    {
                        _hoverEffect.isVisible = false;
                    }
                }
            };
            return anim;
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
                    if (!newStyle.isDefault)
                    {
                        newStyle.lineColor = theme.colorAccent;
                        newStyle.fillColor = theme.colorAccent;
                    }

                    newStyle.isFill = true;
                }
            }

            Sprite effect = createShape(width, height, newStyle);
            effect.id = idActionShape;
            effect.isLayoutManaged = false;
            effect.isResizedByParent = true;
            return effect;
        };
    }

    Tween delegate(Sprite) createActionEffectAnimationFactory()
    {
        return (Sprite actionEffect) {
            import std.conv : to;

            auto actionEffectAnimation = new OpacityTween(actionAnimationDelayMs.to!int);
            actionEffectAnimation.id = idActionAnimation;

            assert(_actionEffect, "Action effect must not be null");
            actionEffectAnimation.addTarget(_actionEffect);

            actionEffectAnimation.isLayoutManaged = false;
            actionEffectAnimation.isInfinite = false;
            actionEffectAnimation.isOneShort = true;
            actionEffectAnimation.onStop ~= () {
                if (_actionEffect)
                {
                    _actionEffect.isVisible = false;
                }
            };
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
                        newStyle.fillColor = newStyle.lineColor;
                        newStyle.isDefault = true;
                        break;
                    case warning:
                        newStyle.lineColor = theme.colorWarning;
                        newStyle.fillColor = newStyle.lineColor;
                        newStyle.isDefault = true;
                        break;
                    case danger:
                        newStyle.lineColor = theme.colorDanger;
                        newStyle.fillColor = newStyle.lineColor;
                        newStyle.isDefault = true;
                        break;
                    default:
                        break;
                }
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
        return GraphicStyle(theme.lineThickness, theme.colorAccent, isBackground, theme
                .colorControlBackground);
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

        if (onPreControlContentCreated)
        {
            onPreControlContentCreated();
        }

        tryCreateBackground(width, height);

        createInteractiveEffects;

        if (onPostControlContentCreated)
        {
            onPostControlContentCreated();
        }

        if (isCreateInteractiveListeners)
        {
            createInteractiveListeners;
        }
    }

    override bool recreate()
    {

        const isSuperRecreated = super.recreate;
        if (!isSuperRecreated)
        {
            return isSuperRecreated;
        }

        if (!isCreated)
        {
            create;
            return true;
        }

        return true;
    }

    void recreateContent()
    {
        if (_background)
        {
            bool isRemoved = remove(_background);
            assert(isRemoved);
            _background = null;
        }

        tryCreateBackground(width, height);

        if (_hoverEffect)
        {
            bool isRemoved = remove(_hoverEffect);
            assert(isRemoved);
            _hoverEffect = null;
        }

        if (_hoverEffectAnimation)
        {
            bool isRemoved = remove(_hoverEffectAnimation);
            assert(isRemoved);
            _hoverEffectAnimation = null;
        }

        if (_actionEffect)
        {
            bool isRemoved = remove(_actionEffect);
            assert(isRemoved);
            _actionEffect = null;
        }

        if (_actionEffectAnimation)
        {
            bool isRemoved = remove(_actionEffectAnimation);
            assert(isRemoved);
            _actionEffectAnimation = null;
        }

        createInteractiveEffects;
    }

    void createInteractiveEffects()
    {
        if (hoverEffectFactory)
        {
            auto newHover = hoverEffectFactory(width, height);
            if (newHover)
            {
                _hoverEffect = onHoverEffectCreate ? onHoverEffectCreate(newHover) : newHover;
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

        if (hoverAnimationFactory)
        {
            auto newHoverAniimation = hoverAnimationFactory();
            _hoverEffectAnimation = onHoverAnimationCreate ? onHoverAnimationCreate(
                newHoverAniimation) : newHoverAniimation;
            assert(_hoverEffectAnimation);

            addCreate(_hoverEffectAnimation);

            if (onHoverAnimationCreated)
            {
                onHoverAnimationCreated(_hoverEffectAnimation);
            }
        }

        if (actionEffectFactory)
        {
            auto newActionEffect = actionEffectFactory();
            assert(newActionEffect);

            _actionEffect = onActionEffectCreate ? onActionEffectCreate(newActionEffect)
                : newActionEffect;

            addCreate(_actionEffect);

            _actionEffect.isVisible = false;

            if (onActionEffectCreated)
            {
                onActionEffectCreated(_actionEffect);
            }
        }

        if (actionEffectAnimationFactory)
        {
            auto newEffectAnimation = actionEffectAnimationFactory(_actionEffect);
            _actionEffectAnimation = onActionEffectAnimationCreate ? onActionEffectAnimationCreate(
                newEffectAnimation) : newEffectAnimation;

            addCreate(_actionEffectAnimation);

            if (onActionEffectAnimationCreated)
            {
                onActionEffectAnimationCreated(_actionEffectAnimation);
            }
        }
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

                if (hoverEffectEnableBehaviour)
                {
                    hoverEffectEnableBehaviour();
                }
            };

            onPointerExited ~= (ref e) {

                if (isDisabled || _selected)
                {
                    return;
                }
                if (hoverEffectDisableBehaviour)
                {
                    hoverEffectDisableBehaviour();
                }
            };
        }

        onPointerUp ~= (ref e) {

            if (isDisabled || _selected)
            {
                return;
            }

            if (actionEffectBehaviour)
            {
                actionEffectBehaviour();
            }
        };

    }

    alias build = GuiComponent.build;

    void build(Control control)
    {
        applyStyle(control);
        super.build(control);
    }

    alias addCreate = GuiComponent.addCreate;

    void addCreate(Control control, long index = -1)
    {
        if (!control.isBuilt)
        {
            build(control);
            assert(control.isBuilt);
            control.initialize;
            assert(control.isInitialized);
        }
        super.addCreate(control, index);
    }

    override void addCreate(Sprite sprite, long index = -1)
    {
        if (auto control = cast(Control) sprite)
        {
            addCreate(control, index);
            return;
        }
        super.addCreate(sprite, index);
    }

    override void addCreate(Sprite[] sprites)
    {
        foreach (s; sprites)
        {
            if (auto control = cast(Control) s)
            {
                addCreate(control);
                continue;
            }

            super.addCreate(s);
        }
    }

    alias add = GuiComponent.add;

    void add(Control control, long index = -1)
    {
        super.add(control, index);

        applyStyle(control);

        //TODO overload
        if (auto tooltip = cast(BasePopup) control)
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

        import api.dm.gui.themes.icons.icon_name;
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

        auto style = createStyle;
        auto color = style.lineColor;

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
        return hasTheme;
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
