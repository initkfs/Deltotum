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

    string _buttonText;

    Texture delegate() hoverFactory;
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

    this(double width = 80, double height = 40, string text = "Button")
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

        hoverFactory = () {

            double padding = style.lineWidth;
            GraphicStyle hoverStyle = GraphicStyle(0, RGBA.transparent, true, graphics
                    .theme.colorHover);
            auto hover = new Rectangle(width - padding * 2, height - padding * 2, hoverStyle);
            hover.x = padding;
            hover.y = padding;
            hover.isVisible = false;
            hover.opacity = graphics.theme.controlHoverOpacity;
            hover.isLayoutManaged = false;
            return hover;
        };

        clickEffectFactory = () {
            double padding = style.lineWidth;

            GraphicStyle clickStyle = GraphicStyle(0, RGBA.transparent, true, graphics
                    .theme.colorAccent);

            auto clickEffect = new Rectangle(width - padding * 2, height - padding * 2, clickStyle);
            clickEffect.x = padding;
            clickEffect.y = padding;
            clickEffect.isVisible = false;
            clickEffect.opacity = 0;
            clickEffect.isLayoutManaged = false;

            return clickEffect;
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
            clickEffectAnimation.onEnd = ()
            {
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
            hover = hoverFactory();
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
