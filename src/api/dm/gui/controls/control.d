module api.dm.gui.controls.control;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.layouts.layout : Layout;
import api.math.insets : Insets;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.alignment : Alignment;
import api.math.insets : Insets;
import api.dm.gui.controls.tooltips.tooltip : Tooltip;

import api.dm.kit.sprites.transitions.min_max_transition : MinMaxTransition;
import api.dm.kit.sprites.transitions.objects.props.opacity_transition : OpacityTransition;

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

    enum ActionType : string
    {
        standard = "standard",
        success = "success",
        warning = "warning",
        danger = "danger"
    }

    string actionType = ActionType.standard;

    GraphicStyle* userStyle;
    bool isFindStyleInParent;

    bool isBackground;
    bool isBorder;
    bool isFocusable;
    bool isDisabled;

    bool isCreateBackgroundFactory = true;
    bool isCreateHoverFactory;
    bool isCreatePointerEffectFactory;
    bool isCreatePointerEffectAnimationFactory;

    Sprite delegate(double, double) backgroundFactory;
    Sprite delegate(Sprite) onBackgroundCreate;
    void delegate(Sprite) onBackgroundCreated;

    Sprite delegate(double, double) hoverFactory;
    Sprite delegate(Sprite) onHoverCreate;
    void delegate(Sprite) onHoverCreated;

    Sprite delegate() pointerEffectFactory;
    Sprite delegate(Sprite) onPointerEffectCreate;
    void delegate(Sprite) onPointerEffectCreated;

    MinMaxTransition!double delegate() pointerEffectAnimationFactory;
    MinMaxTransition!double delegate(MinMaxTransition!double) onPointerEffectAnimationCreate;
    void delegate(MinMaxTransition!double) onPointerEffectAnimationCreated;

    void delegate() onPreControlContentCreated;
    void delegate() onPostControlContentCreated;

    protected
    {
        bool _selected;

        Sprite _background;
        Sprite _hover;
        Sprite _pointerEffect;

        MinMaxTransition!double _pointerEffectAnimation;

        bool isTooltipDelay;
        bool isTooltipListeners;
        size_t tooltipDelayCounter;
    }

    Tooltip[] tooltips;
    size_t tooltipDelay = 20;

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
        return (w, h) { return createDefaultShape(w, h); };
    }

    Sprite delegate(double, double) createHoverFactory()
    {
        return (w, h) {
            assert(graphics.theme);

            GraphicStyle newStyle = createDefaultStyle;
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

            GraphicStyle newStyle = createDefaultStyle;
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

    MinMaxTransition!double delegate() createPointerEffectAnimationFactory()
    {
        return () {
            auto pointerEffectAnimation = new OpacityTransition(50);
            assert(_pointerEffect, "Pointer effect is null");
            //TODO move to create()
            pointerEffectAnimation.addObject(_pointerEffect);
            return pointerEffectAnimation;
        };
    }

    protected GraphicStyle createDefaultStyle()
    {
        GraphicStyle newStyle;
        if (auto parentPtr = ownOrParentStyle)
        {
            newStyle = *parentPtr;
            newStyle.isNested = true;
        }
        else
        {
            //The method can be used for internal controls
            //const lineThickness = isBorder ? graphics.theme.lineThickness : 0;
            newStyle = GraphicStyle(graphics.theme.lineThickness, graphics.theme.colorAccent, isBackground, graphics
                    .theme.colorControlBackground);
        }
        return newStyle;
    }

    protected Sprite createDefaultShape(double w, double h)
    {
        return createDefaultShape(w, h, createDefaultStyle);
    }

    protected Sprite createDefaultShape(double width, double height, GraphicStyle style = GraphicStyle
            .simple)
    {
        return graphics.theme.background(width, height, &style);
    }

    override void create()
    {
        super.create;

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
                _hover.opacity = graphics.theme.opacityHover;
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
                    _pointerEffectAnimation.isCycle = false;
                    _pointerEffectAnimation.isInverse = true;
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

        if (auto tooltip = sprite.castSafe!Tooltip)
        {
            tooltips ~= tooltip;
            if(!isTooltipListeners){
                initTooltipListeners;
            }
            assert(sceneProvider);
            sceneProvider().controlledSprites ~= tooltip;
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
        auto icon = new Image();
        build(icon);

        import std.conv : to;

        icon.loadRaw(iconData.to!(const(void[])), cast(int) iconSize, cast(int) iconSize);

        auto color = graphics.theme.colorAccent;
        if (userStyle)
        {
            color = userStyle.lineColor;
        }

        icon.color = color;
        icon.create;
        return icon;
    }

    void applyStyle(Control control)
    {
        assert(control);
        if (userStyle && !control.userStyle)
        {
            control.userStyle = userStyle;
        }
    }

    //TODO nullable, but it will become more difficult to use in if branches
    GraphicStyle* ownOrParentStyle()
    {
        if (userStyle)
        {
            return userStyle;
        }

        if (isFindStyleInParent)
        {
            import api.core.utils.types : castSafe;

            Control currParent = parent.castSafe!Control;
            while (currParent)
            {
                if (currParent.userStyle)
                {
                    return currParent.userStyle;
                }
                currParent = currParent.parent.castSafe!Control;
            }
        }

        return null;
    }

    GraphicStyle styleFromActionType()
    {
        import api.dm.kit.graphics.colors.rgba : RGBA;

        GraphicStyle style;
        if (auto parentStyle = ownOrParentStyle)
        {
            style = *parentStyle;
        }
        else
        {
            style = graphics.theme.defaultStyle;
        }

        if (actionType != ActionType.standard)
        {
            final switch (actionType) with (ActionType)
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

        _background.opacity = graphics.theme.opacityBackground;

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

    bool isSelected()
    {
        return _selected;
    }

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

    bool hasBackground()
    {
        return _background !is null;
    }

    Nullable!Sprite background()
    {
        if (!hasBackground)
        {
            return Nullable!Sprite.init;
        }
        return Nullable!Sprite(_background);
    }

    Sprite backgroundUnsafe()
    {
        return _background;
    }

    bool hasHover()
    {
        return _hover !is null;
    }

    Nullable!Sprite hover()
    {
        if (!hasHover)
        {
            return Nullable!Sprite.init;
        }
        return Nullable!Sprite(_hover);
    }

    bool hasPointerEffect()
    {
        return _pointerEffect !is null;
    }

    Nullable!Sprite pointerEffect()
    {
        if (!hasPointerEffect)
        {
            return Nullable!Sprite.init;
        }
        return Nullable!Sprite(_pointerEffect);
    }

    bool hasPointerEffectAnimation()
    {
        return _pointerEffectAnimation !is null;
    }

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

    override void dispose()
    {
        super.dispose;
    }

}
