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

        class ButtonBorder : Shape
        {
            this(double width, double height, GraphicStyle style)
            {
                super(width, height, style);
            }

            override void createTextureContent()
            {
                auto mainLineColor = style.lineColor;
                enum cornerPadding = buttonCornerWidth;
                enum lineWidth = 1;

                const topLineStartX = cornerPadding;
                const topLineStartY = 0;
                const topLineEndX = width - cornerPadding - lineWidth;
                const topLineEndY = 0;
                graphics.drawLine(topLineStartX, topLineStartY, topLineEndX, topLineEndY, mainLineColor);

                const topRightCornerStartX = topLineEndX;
                const topRightCornerStartY = topLineEndY;
                const topRightCornerEndX = width - lineWidth;
                const topRightCornerEndY = cornerPadding;
                graphics.drawLine(topRightCornerStartX, topRightCornerStartY, topRightCornerEndX, topRightCornerEndY, mainLineColor);

                const rightLineStartX = topRightCornerEndX;
                const rightLineStartY = topRightCornerEndY;
                const rightLineEndX = width - lineWidth;
                const rightLineEndY = height - cornerPadding - lineWidth;
                graphics.drawLine(rightLineStartX, rightLineStartY, rightLineEndX, rightLineEndY, mainLineColor);

                const bottomRightCornerStartX = rightLineEndX;
                const bottomRightCornerStartY = rightLineEndY;
                const bottomRightCornerEndX = width - cornerPadding - lineWidth;
                const bottomRightCornerEndY = height - lineWidth;
                graphics.drawLine(bottomRightCornerStartX, bottomRightCornerStartY, bottomRightCornerEndX, bottomRightCornerEndY, mainLineColor);

                const bottomLineStartX = bottomRightCornerEndX;
                const bottomLineStartY = bottomRightCornerEndY;
                const bottomLineEndX = cornerPadding;
                const bottomLineEndY = height - lineWidth;
                graphics.drawLine(bottomLineStartX, bottomLineStartY, bottomLineEndX, bottomLineEndY, mainLineColor);

                const bottomLeftCornerStartX = bottomLineEndX;
                const bottomLeftCornerStartY = bottomLineEndY;
                const bottomLeftCornerEndX = 0;
                const bottomLeftCornerEndY = height - cornerPadding - lineWidth;
                graphics.drawLine(bottomLeftCornerStartX, bottomLeftCornerStartY, bottomLeftCornerEndX, bottomLeftCornerEndY, mainLineColor);

                const leftLineStartX = bottomLeftCornerEndX;
                const leftLineStartY = bottomLeftCornerEndY;
                const leftLineEndX = 0;
                const leftLineEndY = cornerPadding;
                graphics.drawLine(leftLineStartX, leftLineStartY, leftLineEndX, leftLineEndY, mainLineColor);

                const topLeftCornerStartX = leftLineEndX;
                const topLeftCornerStartY = leftLineEndY;
                const topLeftCornerEndX = topLineStartX;
                const topLeftCornerEndY = topLineStartY;
                graphics.drawLine(topLeftCornerStartX, topLeftCornerStartY, topLeftCornerEndX, topLeftCornerEndY, mainLineColor);
            }
        }

        backgroundFactory = (width, height) {

            double padding = style.lineWidth;

            import deltotum.toolkit.graphics.shapes.shape : Shape;

            Shape object = new ButtonBorder(width, height, GraphicStyle(1, graphics.theme.colorAccent));
            object.isLayoutManaged = false;
            return object;
        };

        hoverFactory = () {

            double padding = style.lineWidth;
            Shape hover = new ButtonBorder(width, height, GraphicStyle(1, graphics.theme.colorHover));
            hover.isLayoutManaged = false;
            hover.isVisible = false;
            return hover;
        };

        clickEffectFactory = () {
            double padding = style.lineWidth;

            GraphicStyle clickStyle = GraphicStyle(0, RGBA.transparent, true, graphics
                    .theme.colorAccent);

            auto clickEffect = new Rectangle(width - buttonCornerWidth * 2, height, clickStyle);
            clickEffect.x = width / 2 - clickEffect.width / 2;
            clickEffect.y = height / 2 - clickEffect.height / 2;
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
