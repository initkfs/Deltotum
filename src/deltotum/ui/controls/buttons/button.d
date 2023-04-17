module deltotum.ui.controls.buttons.button;

import deltotum.ui.controls.control : Control;
import deltotum.toolkit.graphics.shapes.shape : Shape;
import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.toolkit.graphics.shapes.rectangle : Rectangle;
import deltotum.ui.events.action_event : ActionEvent;
import deltotum.toolkit.display.animation.object.value_transition : ValueTransition;
import deltotum.toolkit.display.animation.object.property.opacity_transition : OpacityTransition;
import deltotum.ui.controls.texts.text;
import deltotum.toolkit.display.layouts.center_layout : CenterLayout;
import deltotum.toolkit.display.textures.texture : Texture;
import deltotum.toolkit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class Button : Control
{

    void delegate(ActionEvent) onAction;

    dstring _buttonText;

    Texture delegate(double, double) hoverFactory;
    Texture delegate() clickEffectFactory;
    Text delegate() textFactory;
    ValueTransition delegate() clickEffectAnimationFactory;

    protected
    {
        Texture hover;
        Texture clickEffect;
        ValueTransition clickEffectAnimation;
        Text text;
    }

    this(double width = 80, double height = 40, dstring text = "Button")
    {
        super();
        this.width = width;
        this.height = height;
        this._buttonText = text;

        this.layout = new CenterLayout;
    }

    override void initialize()
    {
        super.initialize;

        enum buttonCornerWidth = 8;

        backgroundFactory = (width, height) {

            import deltotum.toolkit.graphics.shapes.regular_polygon : RegularPolygon;

            Shape object = new RegularPolygon(width, height, GraphicStyle(1, graphics
                    .theme.colorAccent), graphics.theme.cornersBevel);
            object.isLayoutManaged = false;
            return object;
        };

        hoverFactory = (width, height) {

            import deltotum.toolkit.graphics.shapes.regular_polygon : RegularPolygon;

            Shape hover = new RegularPolygon(width, height, GraphicStyle(1, graphics.theme.colorHover, true, graphics
                    .theme.colorHover), graphics.theme.cornersBevel);
            hover.isLayoutManaged = false;
            hover.isVisible = false;
            hover.opacity = graphics.theme.controlHoverOpacity;
            return hover;
        };

        clickEffectFactory = () {
            double padding = style.lineWidth;

            import deltotum.toolkit.graphics.shapes.regular_polygon : RegularPolygon;

            GraphicStyle clickStyle = GraphicStyle(1, graphics
                    .theme.colorAccent, true, graphics
                    .theme.colorAccent);

            Shape click = new RegularPolygon(width, height, clickStyle, graphics.theme.cornersBevel);
            click.isLayoutManaged = false;
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
            addOrAddCreated(hover);
        }

        if (clickEffectFactory !is null)
        {
            clickEffect = clickEffectFactory();
            addOrAddCreated(clickEffect);
        }

        if (textFactory !is null)
        {
            text = textFactory();
            //FIXME
            text.focusEffectFactory = null;

            text.maxWidth = width - padding.width;
            text.maxHeight = height - padding.height;
            addOrAddCreated(text);
        }

        if (clickEffect !is null)
        {
            clickEffectAnimation = clickEffectAnimationFactory();
            addOrAddCreated(clickEffectAnimation);
        }

        requestLayout;

        createListeners;
    }

    void createListeners()
    {
        onMouseEntered = (e) {
            if (hover !is null && !hover.isVisible)
            {
                hover.isVisible = true;
            }
            return false;
        };

        onMouseExited = (e) {
            if (hover !is null && hover.isVisible)
            {
                hover.isVisible = false;
            }
            return false;
        };

        onMouseUp = (e) {

            if (clickEffectAnimation !is null && !clickEffectAnimation.isRun)
            {
                clickEffect.isVisible = true;
                clickEffectAnimation.run;
            }

            if (onAction !is null)
            {
                onAction(ActionEvent(e.ownerId, e.x, e.y, e.button));
            }
            return false;
        };
    }

}
