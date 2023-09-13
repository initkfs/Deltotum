module deltotum.gui.controls.buttons.button;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.controls.control : Control;
import deltotum.kit.graphics.shapes.shape : Shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.graphics.shapes.rectangle : Rectangle;
import deltotum.gui.events.action_event : ActionEvent;
import deltotum.kit.sprites.animations.object.value_transition : ValueTransition;
import deltotum.kit.sprites.animations.object.property.opacity_transition : OpacityTransition;
import deltotum.gui.controls.texts.text;
import deltotum.kit.sprites.layouts.center_layout : CenterLayout;
import deltotum.kit.sprites.textures.texture : Texture;
import deltotum.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class Button : Control
{

    void delegate(ref ActionEvent) onAction;

    dstring _buttonText;

    Sprite delegate(double, double) hoverFactory;
    Sprite delegate() clickEffectFactory;
    Text delegate() textFactory;
    ValueTransition delegate() clickEffectAnimationFactory;

    //protected
    //{
        Sprite hover;
        Sprite clickEffect;
        ValueTransition clickEffectAnimation;
        Text _text;
        bool _selected;
    //}

    this(dstring text = "Button", double width = 80, double height = 40)
    {
        super();
        this.width = width;
        this.height = height;
        this._buttonText = text;

        this.layout = new CenterLayout;
        this.layout.isResizeParent = true;
        isBorder = true;
    }

    override void initialize()
    {
        super.initialize;

        enableInsets;

        backgroundFactory = (width, height) {

            import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;

            auto style = styleFromActionType;

            Shape object = new RegularPolygon(width, height, style, graphics
                    .theme.controlCornersBevel);
            object.isLayoutManaged = false;
            object.id = "btn_background";
            return object;
        };

        hoverFactory = (width, height) {

            import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;

            Shape hover = new RegularPolygon(width, height, GraphicStyle(1, graphics.theme.colorHover, true, graphics
                    .theme.colorHover), graphics.theme.controlCornersBevel);
            hover.id = "btn_hover";
            hover.isLayoutManaged = false;
            hover.isResizedByParent = true;
            hover.isVisible = false;
            hover.opacity = graphics.theme.opacityHover;
            return hover;
        };

        clickEffectFactory = () {

            import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;

            GraphicStyle clickStyle = GraphicStyle(1, graphics
                    .theme.colorAccent, true, graphics
                    .theme.colorAccent);

            Shape click = new RegularPolygon(width, height, clickStyle, graphics
                    .theme.controlCornersBevel);
            click.id = "btn_click";
            click.isLayoutManaged = false;
            click.isResizedByParent = true;
            click.isVisible = false;
            click.opacity = 0;

            return click;
        };

        textFactory = () {
            auto text = new Text();
            build(text);
            text.text = _buttonText;
            text.create;
            return text;
        };

        clickEffectAnimationFactory = () {
            auto clickEffectAnimation = new OpacityTransition(clickEffect, 50);
            clickEffectAnimation.isCycle = false;
            clickEffectAnimation.isInverse = true;
            clickEffectAnimation.onEnd = () {
                if (clickEffect !is null)
                {
                    clickEffect.isVisible = false;
                }
            };
            return clickEffectAnimation;
        };
    }

    override void create()
    {
        super.create;

        if (hoverFactory !is null)
        {
            hover = hoverFactory(width, height);
            addCreate(hover);
        }

        if (clickEffectFactory !is null)
        {
            clickEffect = clickEffectFactory();
            addCreate(clickEffect);
        }

        if (textFactory !is null)
        {
            _text = textFactory();
            addCreate(_text);
        }

        if (clickEffect !is null)
        {
            clickEffectAnimation = clickEffectAnimationFactory();
            addCreate(clickEffectAnimation);
        }

        //requestLayout;

        createListeners;
    }

    void createListeners()
    {
        onPointerEntered = (ref e) {

            if (_selected)
            {
                return;
            }

            if (hover !is null && !hover.isVisible)
            {
                hover.isVisible = true;
            }
        };

        onPointerExited = (ref e) {

            if (_selected)
            {
                return;
            }

            if (hover !is null && hover.isVisible)
            {
                hover.isVisible = false;
            }
        };

        onPointerUp = (ref e) {

            if (_selected)
            {
                return;
            }

            if (clickEffectAnimation !is null && !clickEffectAnimation.isRun)
            {
                clickEffect.isVisible = true;
                clickEffectAnimation.run;
            }

            if (onAction !is null)
            {
                auto ea = ActionEvent(e.ownerId, e.x, e.y, e.button);
                onAction(ea);
            }
        };
    }

    void text(dstring t)
    {
        if (!_text)
        {
            _buttonText = t;
            return;
        }

        _text.text = t;
    }

    dstring text()
    {
        if (_text)
        {
            return _text.text;
        }
        return _buttonText;
    }

    bool isSelected(){
        return _selected;
    }

    void isSelected(bool isSelected)
    {
        _selected = isSelected;
        if (hover)
        {
            hover.isVisible = isSelected;
            setInvalid;
        }
    }

}
