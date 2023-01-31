module deltotum.engine.ui.controls.button;

import deltotum.engine.ui.controls.control : Control;
import deltotum.engine.graphics.shapes.shape : Shape;
import deltotum.engine.graphics.styles.graphic_style : GraphicStyle;
import deltotum.engine.graphics.shapes.rectangle : Rectangle;
import deltotum.engine.ui.events.action_event : ActionEvent;
import deltotum.engine.display.animation.object.value_transition : ValueTransition;
import deltotum.engine.display.animation.object.property.opacity_transition : OpacityTransition;
import deltotum.engine.ui.controls.text;
import deltotum.engine.display.layouts.center_layout : CenterLayout;
import deltotum.engine.display.textures.texture : Texture;

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
        GraphicStyle hoverStyle;
        GraphicStyle clickEffectStyle;
    }

    this(double width = 80, double height = 40, string text = "Button")
    {
        super();
        this.width = width;
        this.height = height;
        this._buttonText = text;
        this.layout = new CenterLayout;

        hoverFactory = () {
            double padding = backgroundStyle.lineWidth;
            auto hover = new Rectangle(width - padding * 2, height - padding * 2, hoverStyle);
            hover.x = padding;
            hover.y = padding;
            hover.isVisible = false;
            hover.opacity = graphics.theme.controlOpacity;
            hover.isLayoutManaged = false;
            return hover;
        };

        clickEffectFactory = () {
            double padding = backgroundStyle.lineWidth;

            auto clickEffect = new Rectangle(width - padding * 2, height - padding * 2, clickEffectStyle);
            clickEffect.x = padding;
            clickEffect.y = padding;
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
            assert(clickEffect !is null);
            auto clickEffectAnimation = new OpacityTransition(clickEffect, 50);
            clickEffectAnimation.isCycle = false;
            clickEffectAnimation.isInverse = true;
            return clickEffectAnimation;
        };
    }

    override void create()
    {
        super.create;

        hoverStyle = GraphicStyle(0.0, graphics.theme.colorAccent, true, graphics.theme.colorAccent);
        clickEffectStyle = GraphicStyle(0.0, graphics.theme.colorAccent, true, graphics.theme.colorAccent);

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
            addOrAddCreated(text);
        }

        if (clickEffect !is null)
        {
            clickEffectAnimation = clickEffectAnimationFactory();
            addOrAddCreated(clickEffectAnimation);
        }

        layout.layout(this);

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
                clickEffectAnimation.run;
            }

            if (onAction !is null)
            {
                onAction(ActionEvent(e.windowId, e.x, e.y, e.button));
            }
            return false;
        };
    }

}
