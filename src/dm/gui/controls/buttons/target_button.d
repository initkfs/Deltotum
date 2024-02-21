module dm.gui.controls.buttons.target_button;

import dm.gui.controls.buttons.button_base : ButtonBase;
import dm.gui.controls.buttons.button : Button;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.gui.controls.texts.text : Text;
import dm.gui.controls.control : Control;
import dm.kit.sprites.animations.transition : Transition;
import dm.kit.sprites.layouts.center_layout : CenterLayout;

/**
 * Authors: initkfs
 */
class TargetButton : ButtonBase
{
    this(dstring text = "Button", string iconName)
    {
        super(text, iconName);
    }

    enum stickPadding = 2;

    this(
        dstring text = "Button",
        double size = defaultWidth,
        double graphicsGap = defaultGraphicsGap,
        string iconName = null
    )
    {
        super(text, size, size, graphicsGap, iconName);
        isCreateHoverFactory = false;
        isCreateBackgroundFactory = false;
        isCreatePointerEffectFactory = false;
        isCreatePointerEffectAnimationFactory = false;
        isCreateTextFactory = false;

        this.layout = new CenterLayout;
        this.layout.isAutoResizeAndAlignOne = true;
    }

    protected
    {
        Sprite leftStick;
        Sprite topStick;
        Sprite rightStick;
        Sprite bottomStick;

        Transition!double stickAnimation;

        Button innerButton;
    }

    protected Sprite createStick(double width, double height)
    {
        GraphicStyle style = createDefaultStyle(width, height);
        if (!style.isNested)
        {
            style.isFill = true;
            style.fillColor = graphics.theme.colorAccent;
        }
        Sprite stick;
        if (capGraphics.isVectorGraphics)
        {
            import dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

            stick = new VRegularPolygon(width, height, style, 0);
        }
        else
        {
            import dm.kit.sprites.shapes.rectangle : Rectangle;

            style.lineWidth = 1.0;

            stick = new Rectangle(width, height, style);
        }
        stick.isLayoutManaged = false;
        return stick;
    }

    void layoutSticks()
    {
        leftStick.xy(x + stickPadding, y + height / 2 - leftStick.height / 2);
        rightStick.xy(x + width - stickPadding - rightStick.width, y + height / 2 - rightStick.height / 2);
        topStick.xy(x + width / 2 - topStick.width / 2, y + stickPadding);
        bottomStick.xy(x + width / 2 - bottomStick.width / 2, y + height - stickPadding - bottomStick
                .height);
    }

    override void create()
    {
        super.create;

        innerButton = new Button(_buttonText);
        innerButton.onAction = this.onAction;
        //TODO best size;
        innerButton.isBackground = false;
        innerButton.isBorder = false;
        addCreate(innerButton);

        enum sticckTopBottomWidth = 5;
        enum sticckTopBottomHeight = 10;
        enum stickLeftRightWidht = 10;
        enum stickLeftRightHeight = 5;

        leftStick = createStick(stickLeftRightWidht, stickLeftRightHeight);
        rightStick = createStick(stickLeftRightWidht, stickLeftRightHeight);

        topStick = createStick(sticckTopBottomWidth, sticckTopBottomHeight);
        bottomStick = createStick(sticckTopBottomWidth, sticckTopBottomHeight);

        addCreate([leftStick, topStick, rightStick, bottomStick]);

        layoutSticks;

        //TODO infinite?
        stickAnimation = new Transition!double(0, 10, 10000);
        addCreate(stickAnimation);
        enum dt = 10;
        stickAnimation.onValue = (v) {

            if (stickAnimation.isInverse)
            {
                leftStick.x = leftStick.x - dt;
                rightStick.x = rightStick.x + dt;
                topStick.y = topStick.y - dt;
                bottomStick.y = bottomStick.y + dt;

                bool isLeftStop = leftStick.x <= x + stickPadding;
                bool isRightStop = rightStick.bounds.right >= x + width - stickPadding;
                bool isTopStop = topStick.bounds.y <= y + stickPadding;
                bool isBottomStop = bottomStick.bounds.bottom >= y + height - stickPadding;

                if (isLeftStop || isRightStop || isTopStop || isBottomStop)
                {
                    stickAnimation.isInverse = false;
                    stickAnimation.stop;
                }
            }
            else
            {
                leftStick.x = leftStick.x + dt;
                rightStick.x = rightStick.x - dt;
                topStick.y = topStick.y + dt;
                bottomStick.y = bottomStick.y - dt;

                bool isLeftStop = leftStick.bounds.right > x + width / 2;
                bool isRightStop = rightStick.bounds.x < x + width / 2;
                bool isTopStop = topStick.bounds.bottom > y + height / 2;
                bool isBottomStop = bottomStick.bounds.y < y + height / 2;

                if (isLeftStop || isRightStop || isTopStop || isBottomStop)
                {
                    leftStick.isVisible = false;
                    rightStick.isVisible = false;
                    topStick.isVisible = false;
                    bottomStick.isVisible = false;
                    stickAnimation.stop;
                }
            }

        };
    }

    override void createListeners()
    {
        onPointerEntered ~= (ref e) {

            if (isDisabled || _selected)
            {
                return;
            }

            if (stickAnimation.isRunning)
            {
                return;
            }

            stickAnimation.run;
        };

        onPointerExited ~= (ref e) {
            if (isDisabled || _selected)
            {
                return;
            }

            if (stickAnimation.isRunning)
            {
                return;
            }

            stickAnimation.isInverse = true;
            leftStick.isVisible = true;
            rightStick.isVisible = true;
            topStick.isVisible = true;
            bottomStick.isVisible = true;
            stickAnimation.run;

            //layoutSticks;
        };

        onPointerUp ~= (ref e) {

            if (isDisabled || _selected)
            {
                return;
            }

            // if (onAction)
            // {
            //     auto ea = ActionEvent(e.ownerId, e.x, e.y, e.button);
            //     onAction(ea);
            // }
        };
    }

}
