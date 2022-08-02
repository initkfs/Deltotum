module deltotum.ui.controls.button;

import deltotum.ui.controls.control : Control;
import deltotum.graphics.shape.shape : Shape;
import deltotum.graphics.shape.shape_style : ShapeStyle;
import deltotum.graphics.shape.rectangle : Rectangle;
import deltotum.ui.events.action_event : ActionEvent;
import deltotum.animation.object.property.opacity_transition : OpacityTransition;
import deltotum.ui.controls.text;
import deltotum.ui.theme.theme : Theme;
import deltotum.ui.layouts.center_layout : CenterLayout;

/**
 * Authors: initkfs
 */
class Button : Control
{

    @property void delegate(ActionEvent) onAction;
    @property string _buttonText;

    protected
    {
        Shape background;
        Shape hover;
        Shape clickEffect;
        OpacityTransition clickEffectAnimation;
        Text text;
    }

    this(Theme theme, double width = 80, double height = 40, string text = "Button")
    {
        super(theme);
        this.width = width;
        this.height = height;
        this._buttonText = text;
        this.layout = new CenterLayout;
    }

    override void create()
    {
        super.create;

        ShapeStyle* backgoundStyle = new ShapeStyle(1, theme.colorAccent, true, theme
                .colorSecondary);
        ShapeStyle* hoverStyle = new ShapeStyle(0.0, theme.colorAccent, true, theme.hoverColor);
        background = new Rectangle(width, height, backgoundStyle);
        hover = new Rectangle(width - backgoundStyle.lineWidth * 2, height - backgoundStyle.lineWidth * 2, hoverStyle);
        hover.x = backgoundStyle.lineWidth;
        hover.y = backgoundStyle.lineWidth;
        hover.isVisible = false;

        ShapeStyle* clickStyle = new ShapeStyle(0.0, theme.colorAccent, true, theme.colorAccent);
        clickEffect = new Rectangle(width - backgoundStyle.lineWidth * 2, height - backgoundStyle.lineWidth * 2, clickStyle);
        clickEffect.x = backgoundStyle.lineWidth;
        clickEffect.y = backgoundStyle.lineWidth;
        clickEffect.opacity = 0;

        clickEffectAnimation = new OpacityTransition(clickEffect, 50);
        build(clickEffectAnimation);
        clickEffectAnimation.isCycle = false;
        clickEffectAnimation.isInverse = true;

        build(background);
        build(hover);
        build(clickEffect);
        background.create;
        hover.create;
        clickEffect.create;

        add(clickEffectAnimation);

        add(background);
        add(hover);
        add(clickEffect);

        text = new Text(theme);
        build(text);
        text.text = _buttonText;
        text.create;

        add(text);

        layout.layout(this);

        createListeners;

    }

    void createListeners()
    {
        onMouseEntered = (e) {
            if (!hover.isVisible)
            {
                hover.isVisible = true;
            }
            return false;
        };

        onMouseExited = (e) {
            if (hover.isVisible)
            {
                hover.isVisible = false;
            }
            return false;
        };

        onMouseUp = (e) {

            if (!clickEffectAnimation.isRun)
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
