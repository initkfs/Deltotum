module api.dm.gui.controls.control;

import api.dm.gui.components.gui_component : GuiComponent;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.kit.sprites.sprites2d.layouts.layout2d : Layout2d;
import api.math.insets : Insets;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.styles.default_style : DefaultStyle;
import api.dm.kit.graphics.styles.default_style;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.math.alignment : Alignment;
import api.math.insets : Insets;
import api.dm.gui.controls.popups.base_popup : BasePopup;
import api.dm.gui.themes.theme : Theme;

import api.dm.kit.sprites.sprites2d.tweens.tween2d : Tween2d;
import api.dm.kit.sprites.sprites2d.tweens.targets.props.opacity_tween2d : OpacityTween2d;

import std.typecons : Nullable;

enum ControlStyle : string
{
    background = "background",
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

    protected
    {
        Sprite2d _background;
        Sprite2d _hoverEffect;
        Tween2d _hoverEffectAnimation;

        Sprite2d _actionEffect;
        Tween2d _actionEffectAnimation;

        bool isTooltipDelay;
        bool isTooltipListeners;
        size_t tooltipDelayCounter;
    }

    bool isInitStyleFactory = true;

    GraphicStyle style;
    string styleId;
    GraphicStyle[string] styles;
    GraphicStyle delegate(string id) styleFactory;
    void delegate(string, ref GraphicStyle) onIdStyleCreated;
    bool isStyleUseParent;
    bool isStyleForChild;
    bool isStyleAppendForChild = true;

    bool isBackground;
    bool isBorder;
    bool isFocusable;
    bool isDisabled;

    bool isConsumeEventIfBackground = true;
    bool isConsumeEventAfterChildren;

    bool isThrowInvalidAnimationTime = true;

    Sprite2d delegate(Sprite2d) onBackgroundCreate;
    void delegate(Sprite2d) onBackgroundCreated;

    bool isProcessHover;
    bool isProcessAction;

    bool isCreateHoverEffect;
    Sprite2d delegate(Sprite2d) onHoverEffectCreate;
    void delegate(Sprite2d) onHoverEffectCreated;

    size_t hoverAnimationDelayMs;

    bool isCreateHoverEffectAnimation;
    Tween2d delegate(Tween2d) onHoverAnimationCreate;
    void delegate(Tween2d) onHoverAnimationCreated;

    void delegate() hoverEffectStartBehaviour;
    void delegate() hoverEffectEndBehaviour;

    bool isCreateActionEffect;
    Sprite2d delegate() actionEffectFactory;
    Sprite2d delegate(Sprite2d) onActionEffectCreate;
    void delegate(Sprite2d) onActionEffectCreated;

    void delegate(ref ActionEvent) actionEffectStartBehaviour;
    void delegate(ref ActionEvent) actionEffectEndBehaviour;

    size_t actionEffectAnimationDelayMs;

    bool isCreateActionEffectAnimation;
    Tween2d delegate(Sprite2d) actionEffectAnimationFactory;
    Tween2d delegate(Tween2d) onActionEffectAnimationCreate;
    void delegate(Tween2d) onActionEffectAnimationCreated;

    bool isCreateInteractiveListeners;

    void delegate() onPreControlContentCreated;
    void delegate() onPostControlContentCreated;

    bool isLayoutSpacingFromTheme = true;

    bool isCreateTooltip;
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
        isScalable = true;
    }

    override void initialize()
    {
        super.initialize;

        initTheme;
        loadTheme;

        if (isBackground || isBorder)
        {
            invalidateListeners ~= () {
                if (!isCreated)
                {
                    return;
                }

                adjustOrCreateBackground;
            };
        }

        if (isCreateTooltip)
        {
            initTooltipListeners;
        }

        if (!styleFactory && isInitStyleFactory)
        {
            styleFactory = newStyleFactory;
        }

        if (!hoverEffectStartBehaviour)
        {
            auto newBehaviour = newHoverEffectStartBehaviour;
            if (newBehaviour)
            {
                hoverEffectStartBehaviour = newBehaviour;
            }
        }

        if (!hoverEffectEndBehaviour)
        {
            auto newBehaviour = newHoverEffectEndBehaviour;
            if (newBehaviour)
            {
                hoverEffectEndBehaviour = newBehaviour;
            }
        }

        if (!actionEffectStartBehaviour)
        {
            auto newBehaviour = newActionEffectStartBehaviour;
            if (newBehaviour)
            {
                actionEffectStartBehaviour = newBehaviour;
            }
        }

        if (!actionEffectEndBehaviour)
        {
            auto newBehaviour = newActionEffectEndBehaviour;
            if (newBehaviour)
            {
                actionEffectEndBehaviour = newBehaviour;
            }
        }
    }

    //initTheme and loadTheme can be combined, but animation duration checks throw errors. It is very, very easy to make a mistake when overriding loadTheme() by a child
    void initTheme()
    {
        loadTooltipTheme;
        loadAnimationTheme;
    }

    void loadTheme()
    {
        loadLayoutTheme;
    }

    void loadLayoutTheme()
    {
        if (layout)
        {
            import api.dm.kit.sprites.sprites2d.layouts.spaceable_layout : SpaceableLayout;

            if (auto slayout = cast(SpaceableLayout) layout)
            {
                if (slayout.spacing == SpaceableLayout.DefaultSpacing)
                {
                    slayout.spacing = theme.layoutIndent;
                }
            }
        }
    }

    void loadTooltipTheme()
    {
        if (isCreateTooltip && tooltipDelay == 0)
        {
            tooltipDelay = theme.tooltipDelayMs;
        }
    }

    void loadAnimationTheme()
    {
        if (actionEffectAnimationDelayMs == 0)
        {
            actionEffectAnimationDelayMs = theme.actionEffectAnimationDelayMs;
        }

        if (hoverAnimationDelayMs == 0)
        {
            hoverAnimationDelayMs = theme.hoverAnimationDelayMs;
        }
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
        if (!isCreateTooltip || isTooltipListeners)
        {
            return;
        }

        if (capGraphics.isPointer)
        {
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

        if (isCreateInteractiveListeners)
        {
            createInteractiveListeners;
        }

        if (onPostControlContentCreated)
        {
            onPostControlContentCreated();
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

        return isSuperRecreated;
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
        if (!_hoverEffect && isCreateHoverEffect)
        {
            auto newHover = newHoverEffect(width, height);
            assert(newHover);

            _hoverEffect = onHoverEffectCreate ? onHoverEffectCreate(newHover) : newHover;
            assert(_hoverEffect);
            addCreate(_hoverEffect);

            assert(hasTheme);

            _hoverEffect.opacityLimit = theme.opacityHover;

            if (onHoverEffectCreated)
            {
                onHoverEffectCreated(_hoverEffect);
            }
        }

        if (!_hoverEffectAnimation && isCreateHoverEffectAnimation)
        {
            auto newHoverAnim = newHoverAnimation();
            assert(newHoverAnim);

            _hoverEffectAnimation = onHoverAnimationCreate ? onHoverAnimationCreate(
                newHoverAnim) : newHoverAnim;
            assert(_hoverEffectAnimation);

            addCreate(_hoverEffectAnimation);

            if (onHoverAnimationCreated)
            {
                onHoverAnimationCreated(_hoverEffectAnimation);
            }
        }

        if (!_actionEffect && isCreateActionEffect)
        {
            auto effect = newActionEffect();
            assert(effect);

            _actionEffect = onActionEffectCreate ? onActionEffectCreate(effect) : effect;
            assert(_actionEffect);
            addCreate(_actionEffect);

            if (onActionEffectCreated)
            {
                onActionEffectCreated(_actionEffect);
            }
        }

        if (!_actionEffectAnimation && isCreateActionEffectAnimation)
        {
            auto newEffectAnimation = newActionEffectAnimation;
            assert(newEffectAnimation);

            _actionEffectAnimation = onActionEffectAnimationCreate ? onActionEffectAnimationCreate(
                newEffectAnimation) : newEffectAnimation;

            assert(_actionEffectAnimation);
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
        if (hoverEffectStartBehaviour)
        {
            if (capGraphics.isPointer)
            {
                onPointerEntered ~= (ref e) {

                    if (isDisabled)
                    {
                        return;
                    }

                    startHover;
                };
            }
        }

        if (hoverEffectEndBehaviour)
        {
            if (capGraphics.isPointer)
            {
                onPointerExited ~= (ref e) {

                    if (isDisabled)
                    {
                        return;
                    }
                    endHover;
                };
            }
        }

        if (actionEffectStartBehaviour)
        {
            if (capGraphics.isPointer)
            {
                onPointerDown ~= (ref e) {

                    if (isDisabled)
                    {
                        return;
                    }

                    auto ea = ActionEvent(e.ownerId, e.x, e.y, e.button);
                    startAction(ea);
                };
            }
        }

        if (actionEffectEndBehaviour)
        {
            if (capGraphics.isPointer)
            {
                onPointerUp ~= (ref e) {

                    if (isDisabled)
                    {
                        return;
                    }

                    auto ea = ActionEvent(e.ownerId, e.x, e.y, e.button);
                    endAction(ea);
                };

                onPointerOutBounds ~= (ref e) {
                    import api.dm.kit.inputs.pointers.events.pointer_event: PointerEvent;

                    if(e.event != PointerEvent.Event.up){
                        return;
                    }

                    if (isProcessAction)
                    {
                        auto ea = ActionEvent(e.ownerId, e.x, e.y, e.button);
                        ea.isInBounds = false;
                        endAction(ea);
                    }
                };
            }
        }

    }

    void startHover()
    {
        //if(isProcessHover)?
        isProcessHover = true;

        if (hoverEffectStartBehaviour)
        {
            hoverEffectStartBehaviour();
        }
    }

    void endHover()
    {
        isProcessHover = false;
        if (hoverEffectEndBehaviour)
        {
            hoverEffectEndBehaviour();
        }
    }

    void startAction(ref ActionEvent e)
    {
        isProcessAction = true;
        if (actionEffectStartBehaviour)
        {
            actionEffectStartBehaviour(e);
        }
    }

    void endAction(ref ActionEvent e)
    {
        isProcessAction = false;
        if (actionEffectEndBehaviour)
        {
            actionEffectEndBehaviour(e);
        }
    }

    Sprite2d newBackground(double w, double h)
    {
        Sprite2d shape;
        if (auto stylePtr = hasStyle(ControlStyle.background))
        {
            shape = createShape(w, h, angle, *stylePtr);
        }
        else
        {
            shape = createShape(w, h, angle, createThisStyle);
        }
        assert(shape);
        return shape;
    }

    Sprite2d newHoverEffect(double w, double h)
    {
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

        Sprite2d newHover = createShape(w, h, angle, newStyle);
        newHover.id = idHoverShape;
        newHover.isLayoutManaged = false;
        newHover.isResizedByParent = true;
        newHover.isVisible = false;

        return newHover;
    }

    Tween2d newHoverAnimation()
    {
        import std.conv : to;

        assert(_hoverEffect, "Hover effect is null");

        auto anim = new OpacityTween2d(hoverAnimationDelayMs.to!int);
        anim.isThrowInvalidTime = isThrowInvalidAnimationTime;
        anim.id = idHoverAnimation;
        anim.addTarget(_hoverEffect);
        anim.isLayoutManaged = false;

        auto newOnEnd = newOnStopHoverAnimation;
        if (newOnEnd)
        {
            anim.onStop ~= newOnEnd;
        }
        return anim;
    }

    void delegate() newOnStopHoverAnimation()
    {
        return () {
            if (_hoverEffect && _hoverEffectAnimation)
            {
                if (_hoverEffectAnimation.isReverse)
                {
                    _hoverEffect.isVisible = false;
                }
            }
        };
    }

    void delegate() newHoverEffectStartBehaviour()
    {
        return () {
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

    void delegate() newHoverEffectEndBehaviour()
    {
        return () {
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

    Sprite2d newActionEffect()
    {
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

        Sprite2d effect = createShape(width, height, angle, newStyle);
        effect.id = idActionShape;
        effect.isLayoutManaged = false;
        effect.isResizedByParent = true;
        effect.isVisible = false;

        return effect;
    }

    Tween2d newActionEffectAnimation()
    {
        import std.conv : to;

        auto actionEffectAnimation = new OpacityTween2d(actionEffectAnimationDelayMs.to!int);
        actionEffectAnimation.id = idActionAnimation;

        actionEffectAnimation.isThrowInvalidTime = isThrowInvalidAnimationTime;

        assert(_actionEffect, "Action effect must not be null");
        actionEffectAnimation.addTarget(_actionEffect);

        actionEffectAnimation.isLayoutManaged = false;
        actionEffectAnimation.isInfinite = false;
        actionEffectAnimation.isOneShort = true;

        auto newOnEnd = newOnStopActionEffectAnimation;
        if (newOnEnd)
        {
            actionEffectAnimation.onStop ~= newOnEnd;
        }

        return actionEffectAnimation;
    }

    void delegate() newOnStopActionEffectAnimation()
    {
        return () {
            if (_actionEffect)
            {
                _actionEffect.isVisible = false;
            }
        };
    }

    void delegate(ref ActionEvent) newActionEffectStartBehaviour()
    {
        return (ref e) {
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

    void delegate(ref ActionEvent) newActionEffectEndBehaviour()
    {
        return null;
    }

    GraphicStyle delegate(string id) newStyleFactory()
    {
        return (id) {
            assert(theme);

            if (style != GraphicStyle.init)
            {
                return style;
            }

            if (id.length > 0)
            {
                if (auto stylePtr = hasStyle(id))
                {
                    return *stylePtr;
                }
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
        if (onIdStyleCreated)
        {
            onIdStyleCreated(styleId, newStyle);
        }
        return newStyle;
    }

    protected GraphicStyle createThisStyle()
    {
        auto newStyle = createStyle;

        newStyle.isFill = isBackground;
        if (!isBorder)
        {
            newStyle.lineWidth = 0;
        }

        return newStyle;
    }

    protected Sprite2d createShape(double w, double h, double angle = 0)
    {
        return createShape(w, h, angle, createStyle);
    }

    protected Sprite2d createShape(double width, double height, double angle = 0, GraphicStyle style = GraphicStyle
            .simple)
    {
        return theme.background(width, height, angle, &style);
    }

    alias build = GuiComponent.build;

    void build(Control control)
    {
        assert(control);
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

    override void addCreate(Sprite2d sprite, long index = -1)
    {
        if (auto control = cast(Control) sprite)
        {
            addCreate(control, index);
            return;
        }
        super.addCreate(sprite, index);
    }

    override void addCreate(Sprite2d[] sprites)
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

    void addCreateIcon(string iconName, long index = -1)
    {
        auto icon = createIcon(iconName);
        addCreate(icon, index);
    }

    //TODO or move to scene factory?
    Sprite2d createIcon(string iconName)
    {
        assert(isCreated, "Sprite2d not created");

        import api.dm.gui.themes.icons.icon_name;
        import api.dm.kit.sprites.sprites2d.images.image : Image;

        import std.conv : to;

        const iconSize = theme.iconSize;

        const mustBeIconData = theme.iconData(iconName);
        if (mustBeIconData.isNull)
        {
            import api.dm.kit.sprites.sprites2d.shapes.rectangle : Rectangle;
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

        if (isStyleForChild || control.isStyleUseParent)
        {
            control.styleFactory = styleFactory;
            if (!isStyleAppendForChild)
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

        if (isStyleForChild)
        {
            control.isStyleForChild = isStyleForChild;
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

        if (isConsumeEventAfterChildren &&
            (isConsumeEventIfBackground && (isBackground || hasBackground) && containsPoint(
                e.x, e.y)))
        {
            e.isConsumed = true;
        }
    }

    protected bool tryCreateBackground(double width, double height)
    {
        if (
            _background ||
            width == 0 ||
            height == 0 ||
            (!isBackground && !isBorder))
        {
            return false;
        }

        auto newBackground = newBackground(width, height);

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

    bool hasBackground() => _background !is null;
    Sprite2d backgroundUnsafe() => _background;

    Nullable!Sprite2d background()
    {
        if (!hasBackground)
        {
            return Nullable!Sprite2d.init;
        }
        return Nullable!Sprite2d(_background);
    }

    bool hasHoverEffect() => _hoverEffect !is null;
    Sprite2d hoverEffectUnsafe() => _hoverEffect;

    Nullable!Sprite2d hoverEffect()
    {
        if (!hasHoverEffect)
        {
            return Nullable!Sprite2d.init;
        }
        return Nullable!Sprite2d(_hoverEffect);
    }

    bool hasActionEffect() => _actionEffect !is null;
    Sprite2d actionEffectUnsafe() => _actionEffect;

    Nullable!Sprite2d actionEffect()
    {
        if (!hasActionEffect)
        {
            return Nullable!Sprite2d.init;
        }
        return Nullable!Sprite2d(_actionEffect);
    }

    bool hasActionEffectAnimation() => _actionEffectAnimation !is null;
    Sprite2d actionEffectAnimUnsafe() => _actionEffectAnimation;

    Nullable!Sprite2d actionEffectAnimation()
    {
        if (!hasActionEffectAnimation)
        {
            return Nullable!Sprite2d.init;
        }
        return Nullable!Sprite2d(_actionEffectAnimation);
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
        super.dispose;
    }

}
