module api.dm.gui.controls.control;

import api.dm.gui.components.gui_component : GuiComponent;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.kit.sprites2d.layouts.layout2d : Layout2d;
import api.math.pos2.insets : Insets;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.graphics.styles.default_style : DefaultStyle;
import api.dm.kit.graphics.styles.default_style;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.math.pos2.alignment : Alignment;
import api.math.pos2.insets : Insets;
import api.dm.gui.controls.popups.tooltips.base_tooltip : BaseTooltip;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.themes.theme : Theme;

import api.dm.kit.sprites2d.tweens.tween2d : Tween2d;
import api.dm.kit.sprites2d.tweens.targets.props.opacity_tween2d : OpacityTween2d;

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
        idActionAnimation = "control_action_animation",
        idFocus = "control_focus"
    }

    protected
    {
        Sprite2d _background;
        Sprite2d _hoverEffect;
        Tween2d _hoverEffectAnimation;

        Sprite2d _actionEffect;
        Tween2d _actionEffectAnimation;

        Sprite2d _focusEffect;

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

    bool isThrowInvalidAnimationTime = true;

    Sprite2d delegate(Sprite2d) onNewBackground;
    void delegate(Sprite2d) onCreatedBackground;

    bool isProcessHover;
    bool isProcessAction;

    bool isCreateHoverEffect;
    Sprite2d delegate(Sprite2d) onNewHoverEffect;
    void delegate(Sprite2d) onConfiguredHoverEffect;
    void delegate(Sprite2d) onCreatedHoverEffect;

    size_t hoverAnimationDelayMs;

    bool isCreateHoverEffectAnimation;
    Tween2d delegate(Tween2d) onNewHoverAnimation;
    void delegate(Sprite2d) onConfiguredHoverEffectAnimation;
    void delegate(Tween2d) onCreatedHoverAnimation;

    void delegate() hoverEffectStartBehaviour;
    void delegate() hoverEffectEndBehaviour;

    bool isCreateActionEffect;
    Sprite2d delegate() actionEffectFactory;
    Sprite2d delegate(Sprite2d) onNewActionEffect;
    void delegate(Sprite2d) onConfiguredActionEffect;
    void delegate(Sprite2d) onCreatedActionEffect;

    void delegate(ref ActionEvent) actionEffectStartBehaviour;
    void delegate(ref ActionEvent) actionEffectEndBehaviour;

    size_t actionEffectAnimationDelayMs;

    bool isCreateActionEffectAnimation;
    Tween2d delegate(Sprite2d) actionEffectAnimationFactory;
    Tween2d delegate(Tween2d) onNewActionEffectAnimation;
    void delegate(Sprite2d) onConfiguredActionEffectAnimation;
    void delegate(Tween2d) onCreatedActionEffectAnimation;

    bool isCreateFocusEffect;
    Sprite2d delegate(Sprite2d) onNewFocusEffect;
    void delegate(Sprite2d) onConfiguredFocusEffect;
    void delegate(Sprite2d) onCreatedFocusEffect;

    bool isCreateInteractiveListeners;

    void delegate() onPreControlContentCreated;
    void delegate() onPostControlContentCreated;

    bool isLayoutSpacingFromTheme = true;

    BaseTooltip[] tooltips;
    size_t tooltipDelay;

    bool isSetNullWidthFromTheme = true;
    bool isSetNullHeightFromTheme = true;

    this()
    {
        isLayoutManaged = true;

        isResizable = true;
        isResizeChildren = true;
        isScalable = true;
    }

    final void isCreateInteractions(bool value)
    {
        isCreateHoverEffect = value;
        isCreateHoverEffectAnimation = value;
        isCreateActionEffect = value;
        isCreateActionEffectAnimation = value;
        isCreateInteractiveListeners = true;
    }

    override void initialize()
    {
        super.initialize;

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

        initTheme;
        loadTheme;
    }

    //initTheme and loadTheme can be combined, but animation duration checks throw errors. It is very, very easy to make a mistake when overriding loadTheme() by a child
    void initTheme()
    {
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
            import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;

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
        if (tooltipDelay == 0)
        {
            assert(window);
            tooltipDelay = cast(size_t)(theme.popupDelayMs / (1000 / window.frameRate));
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

    void loadControlSizeTheme()
    {
        if (isSetNullWidthFromTheme && width == 0)
        {
            initWidth = theme.controlDefaultWidth;
        }

        if (isSetNullHeightFromTheme && height == 0)
        {
            initHeight = theme.controlDefaultHeight;
        }
    }

    void initTooltipListeners()
    {
        if (isTooltipListeners)
        {
            return;
        }

        if (platform.cap.isPointer)
        {
            onPointerEnter ~= (ref e) {
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

            onPointerExit ~= (ref e) {
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

        tryCreateBackground;

        createInteractiveEffects;

        if (isCreateInteractiveListeners)
        {
            createInteractiveListeners;
        }

        if (isFocusable)
        {
            createFocusEffect;
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

        tryCreateBackground;

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
            auto newHover = newHoverEffect;
            _hoverEffect = onNewHoverEffect ? onNewHoverEffect(newHover) : newHover;
            assert(_hoverEffect);

            _hoverEffect.id = idHoverShape;
            _hoverEffect.isLayoutManaged = false;
            _hoverEffect.isResizedByParent = true;
            _hoverEffect.isVisible = false;

            if (onConfiguredHoverEffect)
            {
                onConfiguredHoverEffect(_hoverEffect);
            }

            addCreate(_hoverEffect);

            assert(hasTheme);

            _hoverEffect.opacityLimit = theme.opacityHover;

            if (onCreatedHoverEffect)
            {
                onCreatedHoverEffect(_hoverEffect);
            }
        }

        if (!_hoverEffectAnimation && isCreateHoverEffectAnimation)
        {
            auto newHoverAnim = newHoverAnimation();
            assert(newHoverAnim);

            _hoverEffectAnimation = onNewHoverAnimation ? onNewHoverAnimation(
                newHoverAnim) : newHoverAnim;
            assert(_hoverEffectAnimation);

            if (onConfiguredHoverEffectAnimation)
            {
                onConfiguredHoverEffectAnimation(_hoverEffectAnimation);
            }

            addCreate(_hoverEffectAnimation);

            if (onCreatedHoverAnimation)
            {
                onCreatedHoverAnimation(_hoverEffectAnimation);
            }
        }

        if (!_actionEffect && isCreateActionEffect)
        {
            auto effect = newActionEffect();
            assert(effect);

            _actionEffect = onNewActionEffect ? onNewActionEffect(effect) : effect;
            assert(_actionEffect);

            _actionEffect.id = idActionShape;
            _actionEffect.isLayoutManaged = false;
            _actionEffect.isResizedByParent = true;
            _actionEffect.isVisible = false;

            if (onConfiguredActionEffect)
            {
                onConfiguredActionEffect(_actionEffect);
            }

            addCreate(_actionEffect);

            if (onCreatedActionEffect)
            {
                onCreatedActionEffect(_actionEffect);
            }
        }

        if (!_actionEffectAnimation && isCreateActionEffectAnimation)
        {
            auto newEffectAnimation = newActionEffectAnimation;
            assert(newEffectAnimation);

            _actionEffectAnimation = onNewActionEffectAnimation ? onNewActionEffectAnimation(
                newEffectAnimation) : newEffectAnimation;

            assert(_actionEffectAnimation);

            if (onConfiguredActionEffectAnimation)
            {
                onConfiguredActionEffectAnimation(_actionEffectAnimation);
            }

            addCreate(_actionEffectAnimation);

            if (onCreatedActionEffectAnimation)
            {
                onCreatedActionEffectAnimation(_actionEffectAnimation);
            }
        }
    }

    void createFocusEffect()
    {
        if (!_focusEffect && isCreateFocusEffect)
        {
            auto effect = newFocusEffect;
            assert(effect);

            _focusEffect = onNewFocusEffect ? onNewFocusEffect(effect) : effect;
            assert(_focusEffect);

            _focusEffect.id = idFocus;
            _focusEffect.isLayoutManaged = false;
            _focusEffect.isResizedByParent = true;
            _focusEffect.isVisible = false;

            if (onConfiguredFocusEffect)
            {
                onConfiguredFocusEffect(_focusEffect);
            }

            addCreate(_focusEffect);

            if (onCreatedFocusEffect)
            {
                onCreatedFocusEffect(_focusEffect);
            }
        }
    }

    void createInteractiveListeners()
    {
        //TODO remove previous
        if (hoverEffectStartBehaviour)
        {
            if (platform.cap.isPointer)
            {
                onPointerEnter ~= (ref e) {

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
            if (platform.cap.isPointer)
            {
                onPointerExit ~= (ref e) {

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
            if (platform.cap.isPointer)
            {
                onPointerPress ~= (ref e) {

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
            if (platform.cap.isPointer)
            {
                onPointerRelease ~= (ref e) {

                    if (isDisabled)
                    {
                        return;
                    }

                    auto ea = ActionEvent(e.ownerId, e.x, e.y, e.button);
                    endAction(ea);
                };

                onPointerOutBounds ~= (ref e) {
                    import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;

                    if (e.event != PointerEvent.Event.release)
                    {
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

    Sprite2d newBackground(double w, double h, double angle, GraphicStyle style)
    {
        Sprite2d shape;
        if (auto stylePtr = hasStyle(ControlStyle.background))
        {
            shape = createShape(w, h, angle, *stylePtr);
        }
        else
        {
            shape = createShape(w, h, angle, style);
        }
        assert(shape);
        return shape;
    }

    Sprite2d newBackground()
    {
        return newBackground(width, height, angle, createThisStyle);
    }

    Sprite2d newHoverEffectShape(double w, double h, double angle, GraphicStyle style)
    {
        return createShape(w, h, angle, style);
    }

    Sprite2d newHoverEffect(double w, double h, double angle, GraphicStyle style)
    {
        Sprite2d newHover = newHoverEffectShape(w, h, angle, style);
        return newHover;
    }

    Sprite2d newHoverEffect()
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

        return newHoverEffect(width, height, angle, newStyle);
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

    Sprite2d newActionEffectShape(double w, double h, double angle, GraphicStyle style)
    {
        return createShape(w, h, angle, style);
    }

    Sprite2d newActionEffect(double w, double h, double angle, GraphicStyle style)
    {
        Sprite2d effect = newActionEffectShape(w, h, angle, style);
        return effect;
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

        Sprite2d effect = newActionEffect(width, height, angle, newStyle);
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

    Sprite2d newFocusEffect()
    {
        GraphicStyle focusStyle = createDefaultStyle;
        if (!focusStyle.isNested && !focusStyle.isDefault)
        {
            focusStyle.lineColor = theme.colorFocus;
            focusStyle.fillColor = theme.colorFocus;
        }

        auto effect = theme.shape(width, height, angle, style);
        return effect;
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

    protected GraphicStyle createFillStyle(RGBA fillColor = RGBA.init)
    {
        assert(styleFactory);

        auto newStyle = createStyle;
        if (!newStyle.isPreset)
        {
            newStyle.isFill = true;
            newStyle.fillColor = fillColor != RGBA.init ? fillColor : theme.colorAccent;
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

    protected Sprite2d createThisShape(double w, double h)
    {
        return createShape(w, h, angle, createThisStyle);
    }

    protected Sprite2d createShape(double w, double h)
    {
        return createShape(w, h, angle, createStyle);
    }

    protected Sprite2d createShape(double w, double h, double angle, GraphicStyle style)
    {
        return theme.background(w, h, angle, &style);
    }

    alias build = GuiComponent.build;

    void build(Control control)
    {
        assert(control);
        applyStyle(control);
        super.build(control);
        //TODO from sprite?
        trySetParentProps(control);
    }

    alias build = GuiComponent.build;
    alias buildInit = GuiComponent.buildInit;
    alias buildInitCreate = GuiComponent.buildInitCreate;
    alias buildInitCreateRun = GuiComponent.buildInitCreateRun;

    void buildInit(Control component)
    {
        build(component);
        super.initialize(component);
    }

    void buildInitCreate(Control component)
    {
        buildInit(component);
        super.create(component);
    }

    void buildInitCreateRun(Control component)
    {
        buildInitCreate(component);
        super.run(component);
    }

    alias addCreate = GuiComponent.addCreate;

    void addCreate(Control control, long index = -1)
    {
        if (!control.isBuilt)
        {
            //FIXME TODO bug buildInitCreate
            build(control);
            assert(control.isBuilt);
            control.initialize;
            assert(control.isInitializing);
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
    }

    void installTooltip(BaseTooltip tooltip)
    {
        if (!tooltip.parent)
        {
            add(tooltip);
        }

        if (!tooltip.isBuilt)
        {
            buildInitCreate(tooltip);
        }

        tooltips ~= tooltip;
        if (!isTooltipListeners)
        {
            initTooltipListeners;
        }

        if (tooltipDelay == 0)
        {
            loadTooltipTheme;
        }

        if (sceneProvider)
        {
            sceneProvider().controlledSprites ~= tooltip;
        }
        else
        {
            assert(tooltip.isDrawByParent);
        }
    }

    override void onRemoveFromParent()
    {
        if (tooltips.length > 0 && sceneProvider)
        {
            auto scene = sceneProvider();
            foreach (tooltip; tooltips)
            {
                scene.removeControlled(tooltip);
            }
        }
    }

    void addCreateIcon(string iconName, long index = -1)
    {
        auto icon = createIcon(iconName);
        addCreate(icon, index);
    }

    import api.dm.kit.sprites2d.images.image : Image;

    //TODO or move to scene factory?
    Sprite2d createIcon(string iconName, double newIconSize = 0, RGBA delegate(int x, int y, RGBA color) onColor = null)
    {
        assert(isCreated, "Sprite2d not created");

        import api.dm.gui.themes.icons.icon_name;
        import api.dm.kit.sprites2d.images.image : Image;

        import std.conv : to;

        const iconSize = newIconSize == 0 ? theme.iconSize : newIconSize;
        assert(iconSize > 0);

        const mustBeIconData = theme.iconData(iconName);
        if (mustBeIconData.isNull)
        {
            import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
            import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
            import api.dm.kit.graphics.colors.rgba : RGBA;

            auto placeholder = new Rectangle(iconSize, iconSize, GraphicStyle(1, RGBA.red, true, RGBA
                    .red));
            return placeholder;
        }

        const string iconData = mustBeIconData.get;

        auto icon = new Image;
        build(icon);

        if (onColor)
        {
            icon.onColor = onColor;
        }

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

        if (isConsumeEventIfBackground && (isBackground || hasBackground) && containsPoint(
                e.x, e.y))
        {
            //TODO focus discharge
            //e.isConsumed = true;
            e.x = double.nan;
            e.y = double.nan;
        }
    }

    protected bool tryCreateBackground()
    {
        if (
            _background ||
            width == 0 ||
            height == 0 ||
            (!isBackground && !isBorder))
        {
            return false;
        }

        auto back = newBackground;

        back.id = idBackground;
        back.isResizedByParent = true;
        back.isLayoutManaged = false;
        back.isDrawAfterParent = false;

        _background = onNewBackground ? onNewBackground(back) : back;

        addCreate(_background, 0);

        _background.opacityLimit = theme.opacityBackground;

        if (onCreatedBackground)
        {
            onCreatedBackground(_background);
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
            tryCreateBackground;
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
                    t.showForPointer;
                }
            }
            else
            {
                tooltipDelayCounter++;
            }
        }
    }

    override bool canEnablePadding()
    {
        return hasTheme;
    }

    override void enablePadding()
    {
        debug
        {
            if (!canEnablePadding)
            {
                throw new Exception(
                    "Unable to enable paddings: graphic or theme is null. Perhaps the component is not built correctly");
            }
        }

        if (theme)
        {
            _padding = theme.controlPadding;
        }
    }

    override void dispose()
    {
        super.dispose;
    }

}
