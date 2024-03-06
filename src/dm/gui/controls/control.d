module dm.gui.controls.control;

import dm.kit.sprites.sprite : Sprite;
import dm.kit.sprites.layouts.layout : Layout;
import dm.math.insets : Insets;
import dm.kit.sprites.textures.texture : Texture;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.math.alignment : Alignment;

import dm.kit.sprites.transitions.min_max_transition : MinMaxTransition;
import dm.kit.sprites.transitions.objects.props.opacity_transition : OpacityTransition;

/**
 * Authors: initkfs
 */
class Control : Sprite
{
    enum ActionType : string
    {
        standard = "standard",
        success = "success",
        warning = "warning",
        danger = "danger"
    }

    string actionType = ActionType.standard;

    bool isCreateBackgroundFactory = true;
    Insets backgroundInsets;
    Sprite delegate(double, double) backgroundFactory;

    bool isBackground;
    bool isBorder;
    bool isFocusable;
    bool isDisabled;

    GraphicStyle* style;
    bool isFindStyleInParent;

    enum
    {
        idControlHover = "control_hover",
        idControlClick = "control_click"
    }

    bool isCreateHoverFactory;
    bool isCreatePointerEffectFactory;
    bool isCreatePointerEffectAnimationFactory;

    Sprite delegate(double, double) hoverFactory;
    Sprite delegate() pointerEffectFactory;
    MinMaxTransition!double delegate() pointerEffectAnimationFactory;

    void delegate() onPreControlContentCreated;
    void delegate() onPostControlContentCreated;

    //protected
    //{
    Sprite background;
    //}

    protected
    {
        Sprite hover;
        Sprite pointerEffect;
        MinMaxTransition!double pointerEffectAnimation;

        bool _selected;
    }

    this() pure @safe
    {
        isResizedByParent = true;
        isResizable = true;
        isLayoutManaged = true;
        isResizeChildren = true;
    }

    override void initialize()
    {
        super.initialize;

        invalidateListeners ~= () {
            if (!isCreated)
            {
                return;
            }

            checkBackground;
        };

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

    Sprite delegate(double, double) createBackgroundFactory()
    {
        return (w, h) { return createDefaultShape(w, h); };
    }

    Sprite delegate(double, double) createHoverFactory()
    {
        return (w, h) {
            assert(graphics.theme);

            GraphicStyle newStyle = createDefaultStyle(w, h);
            if (!newStyle.isNested)
            {
                newStyle.lineColor = graphics
                    .theme.colorHover;
                newStyle.fillColor = graphics.theme.colorHover;
                newStyle.isFill = true;
            }

            Sprite newHover = graphics.theme.background(w, h, &newStyle);
            newHover.id = idControlHover;
            newHover.isLayoutManaged = false;
            newHover.isResizedByParent = true;
            newHover.isVisible = false;
            return newHover;
        };
    }

    Sprite delegate() createPointerEffectFactory()
    {
        return () {
            assert(graphics.theme);

            GraphicStyle newStyle = createDefaultStyle(width, height);
            if (!newStyle.isNested)
            {
                newStyle.lineColor = graphics
                    .theme.colorAccent;
                newStyle.fillColor = graphics.theme.colorAccent;
                newStyle.isFill = true;
            }

            Sprite click = graphics.theme.background(width, height, &newStyle);
            click.id = idControlClick;
            click.isLayoutManaged = false;
            click.isResizedByParent = true;
            click.isVisible = false;

            return click;
        };
    }

    MinMaxTransition!double delegate() createPointerEffectAnimationFactory()
    {
        return () {

            if (!pointerEffect)
            {
                throw new Exception("Cannot create click effect animation, pointer effect is null");
            }

            auto pointerEffectAnimation = new OpacityTransition(50);
            pointerEffectAnimation.addObject(pointerEffect);
            pointerEffectAnimation.isLayoutManaged = false;
            pointerEffectAnimation.isCycle = false;
            pointerEffectAnimation.isInverse = true;
            pointerEffectAnimation.onEnd ~= () {
                if (pointerEffect !is null)
                {
                    pointerEffect.isVisible = false;
                }
            };
            return pointerEffectAnimation;
        };
    }

    protected GraphicStyle createDefaultStyle(double w, double h)
    {
        GraphicStyle newStyle;
        if (auto parentPtr = ownOrParentStyle)
        {
            newStyle = *parentPtr;
            newStyle.isNested = true;
        }
        else
        {
            newStyle = GraphicStyle(graphics.theme.lineThickness, graphics.theme.colorAccent, isBackground, graphics
                    .theme.colorControlBackground);
        }
        return newStyle;
    }

    protected Sprite createDefaultShape(double w, double h)
    {
        return createDefaultShape(w, h, createDefaultStyle(w, h));
    }

    protected Sprite createDefaultShape(double width, double height, GraphicStyle style)
    {
        return graphics.theme.background(width, height, &style);
    }

    override void create()
    {
        super.create;

        createBackground(width, height);

        if (onPreControlContentCreated)
        {
            onPreControlContentCreated();
        }

        if (hoverFactory)
        {
            hover = hoverFactory(width, height);
            if (hover)
            {
                addCreate(hover);
                hover.opacity = graphics.theme.opacityHover;
            }
            else
            {
                logger.error("Hover factory did not return the object");
            }
        }

        if (pointerEffect)
        {
            pointerEffectAnimation = pointerEffectAnimationFactory();
            if (pointerEffectAnimation)
            {
                addCreate(pointerEffectAnimation);
            }
            else
            {
                logger.error("Click effect animation factory did not return the object");
            }
        }

        if (pointerEffectFactory)
        {
            pointerEffect = pointerEffectFactory();
            if (pointerEffect)
            {
                addCreate(pointerEffect);
                pointerEffect.opacity = 0;
            }
            else
            {
                logger.error("Pointer effect factory did not return the object");
            }
        }

        if (pointerEffectAnimationFactory)
        {
            pointerEffectAnimation = pointerEffectAnimationFactory();
            if (pointerEffectAnimation)
            {
                addCreate(pointerEffectAnimation);
            }
            else
            {
                logger.error("Pointern animation factory did not return the object");
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
        if (hover)
        {
            onPointerEntered ~= (ref e) {

                if (isDisabled || _selected)
                {
                    return;
                }

                if (hover && !hover.isVisible)
                {
                    hover.isVisible = true;
                }
            };

            onPointerExited ~= (ref e) {

                if (isDisabled || _selected)
                {
                    return;
                }

                if (hover && hover.isVisible)
                {
                    hover.isVisible = false;
                }
            };
        }

        if (pointerEffect || pointerEffectAnimation)
        {
            onPointerUp ~= (ref e) {

                if (isDisabled || _selected)
                {
                    return;
                }

                if (pointerEffect && !pointerEffect.isVisible)
                {
                    pointerEffect.isVisible = true;
                    if (pointerEffectAnimation && !pointerEffectAnimation.isRunning)
                    {
                        pointerEffectAnimation.run;
                    }

                }
            };
        }

    }

    alias build = Sprite.build;

    override void build(Sprite sprite)
    {
        import dm.core.utils.type_util : castSafe;

        assert(!sprite.isBuilt);

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
        import dm.core.utils.type_util : castSafe;

        super.add(sprite, index);
        if (auto control = sprite.castSafe!Control)
        {
            applyStyle(control);
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
        assert(isCreated);

        import dm.kit.graphics.themes.icons.icon_name;
        import dm.kit.sprites.images.image : Image;

        import std.conv : to;

        const iconSize = graphics.theme.iconSize;

        const mustBeIconData = graphics.theme.iconData(iconName);
        if (mustBeIconData.isNull)
        {
            import dm.kit.sprites.shapes.rectangle : Rectangle;
            import dm.kit.graphics.styles.graphic_style : GraphicStyle;
            import dm.kit.graphics.colors.rgba : RGBA;

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
        if (style)
        {
            color = style.lineColor;
        }

        icon.color = color;
        icon.create;
        return icon;
    }

    void applyStyle(Control control)
    {
        assert(control);
        if (style && !control.style)
        {
            control.style = style;
        }
    }

    GraphicStyle* ownOrParentStyle()
    {
        if (style)
        {
            return style;
        }

        if (isFindStyleInParent)
        {
            import dm.core.utils.type_util : castSafe;

            Control currParent = parent.castSafe!Control;
            while (currParent)
            {
                if (currParent.style)
                {
                    return currParent.style;
                }
                currParent = currParent.parent.castSafe!Control;
            }
        }

        return null;
    }

    GraphicStyle styleFromActionType()
    {
        import dm.kit.graphics.colors.rgba : RGBA;

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

    protected bool createBackground(double width, double height)
    {
        if (
            background ||
            width == 0 ||
            height == 0 ||
            (!isBackground && !isBorder)
            || !backgroundFactory)
        {
            return false;
        }

        assert(backgroundInsets.width < width);
        assert(backgroundInsets.height < height);

        background = backgroundFactory(width - backgroundInsets.width, height - backgroundInsets
                .height);

        background.x = backgroundInsets.left;
        background.y = backgroundInsets.top;

        background.isResizedByParent = true;
        background.isLayoutManaged = false;

        addCreate(background, 0);

        background.id = "control_background";
        //if done in a factory, there may be an error on uncreated textures
        background.opacity = graphics.theme.opacityControls;

        return true;
    }

    void checkBackground()
    {
        if (background)
        {
            background.width = width;
            background.height = height;
            return;
        }

        if (!background && width > 0 && height > 0)
        {
            createBackground(width - backgroundInsets.width, height - backgroundInsets.height);
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
        if (hover)
        {
            hover.isVisible = value;
            setInvalid;
        }
    }

    override void dispose()
    {
        super.dispose;

        _selected = false;
    }

}
