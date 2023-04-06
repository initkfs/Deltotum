module deltotum.ui.controls.buttons.toggle_switch;

import deltotum.ui.controls.control : Control;
import deltotum.toolkit.graphics.shapes.shape : Shape;
import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.toolkit.graphics.shapes.rectangle : Rectangle;
import deltotum.ui.events.action_event : ActionEvent;
import deltotum.toolkit.display.animation.object.value_transition : ValueTransition;
import deltotum.toolkit.display.animation.object.property.opacity_transition : OpacityTransition;
import deltotum.ui.controls.texts.text;
import deltotum.toolkit.display.layouts.horizontal_layout : HorizontalLayout;
import deltotum.toolkit.display.textures.texture : Texture;
import deltotum.toolkit.display.display_object : DisplayObject;
import deltotum.toolkit.graphics.colors.rgba : RGBA;
import deltotum.toolkit.display.animation.object.display_object_transition : DisplayObjectTransition;
import deltotum.maths.vector2d : Vector2d;

/**
 * Authors: initkfs
 */
class ToggleSwitch : Control
{
    private
    {
        enum State
        {
            off,
            on
        }
    }

    protected
    {
        State switchState = State.off;
    }

    void delegate() onSwitchOn;
    void delegate() onSwitchOff;

    Texture switchOffArea;
    Texture delegate() switchOffAreaFactory;

    Texture switchOnArea;
    Texture delegate() switchOnAreaFactory;

    Texture switchHandle;
    Texture delegate() switchHandleFactory;

    DisplayObjectTransition!Vector2d clickSwitchOnAnimation;
    DisplayObjectTransition!Vector2d clickSwitchOffAnimation;

    DisplayObjectTransition!Vector2d delegate() clickSwitchOnAnimationFactory;
    DisplayObjectTransition!Vector2d delegate() clickSwitchOffAnimationFactory;

    //TODO factories, settings
    DisplayObject effectSwitchOn;
    DisplayObject effectSwitchOff;

    this(double width = 60, double height = 25)
    {
        this.width = width;
        this.height = height;

        this.layout = new HorizontalLayout;
    }

    override void initialize()
    {
        super.initialize;

        import deltotum.maths.geometry.insets : Insets;

        padding = Insets(0);

        switchOffAreaFactory = () {

            import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;

            GraphicStyle clickStyle = GraphicStyle(1, graphics.theme.colorAccent);

            auto control = new Rectangle(width / 2, height, clickStyle);

            return control;
        };

        switchOnAreaFactory = () {

            import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;

            GraphicStyle clickStyle = GraphicStyle(1, graphics.theme.colorAccent, true, graphics
                    .theme.colorAccent);

            auto control = new Rectangle(width / 2, height, clickStyle);
            return control;
        };

        switchHandleFactory = () {

            import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;

            GraphicStyle clickStyle = GraphicStyle(1, graphics.theme.colorAccent, true, graphics
                    .theme.colorSecondary);

            auto control = new Rectangle(width / 2, height, clickStyle);
            return control;
        };

        clickSwitchOnAnimationFactory = () {
            import deltotum.maths.vector2d : Vector2d;
            import deltotum.toolkit.display.animation.object.motion.linear_motion_transition : LinearMotionTransition;
            import deltotum.toolkit.display.animation.interp.uni_interpolator : UniInterpolator;

            auto uniInterp = new UniInterpolator;
            uniInterp.interpolateMethod = &uniInterp.quadInOut;

            auto end = Vector2d(bounds.right - switchHandle.width, bounds.y);
            auto animation = new LinearMotionTransition(switchHandle, Vector2d(x, y), end, 200, uniInterp);
            animation.isCycle = false;
            return animation;
        };

        clickSwitchOffAnimationFactory = () {
            import deltotum.maths.vector2d : Vector2d;
            import deltotum.toolkit.display.animation.object.motion.linear_motion_transition : LinearMotionTransition;
            import deltotum.toolkit.display.animation.interp.uni_interpolator : UniInterpolator;

            auto start = Vector2d(bounds.right - switchHandle.width, y);
            auto uniInterp = new UniInterpolator;
            uniInterp.interpolateMethod = &uniInterp.quadInOut;
            auto animation = new LinearMotionTransition(switchHandle, start, Vector2d(x, y), 200, uniInterp);
            animation.isCycle = false;
            return animation;
        };

    }

    override void create()
    {
        super.create;

        switchOnArea = switchOnAreaFactory();
        addCreated(switchOnArea);

        switchOffArea = switchOffAreaFactory();
        addCreated(switchOffArea);

        switchHandle = switchHandleFactory();
        switchHandle.isLayoutManaged = false;

        import deltotum.toolkit.display.layouts.center_layout : CenterLayout;

        switchHandle.layout = new CenterLayout;
        addCreated(switchHandle);

        import deltotum.toolkit.graphics.shapes.circle : Circle;

        effectSwitchOn = new Circle(10, GraphicStyle(1, graphics.theme.colorAccent, true, graphics.theme.colorAccent));
        switchHandle.addCreated(effectSwitchOn);
        effectSwitchOn.isVisible = false;

        effectSwitchOff = new Circle(10, GraphicStyle(1, graphics.theme.colorAccent));
        switchHandle.addCreated(effectSwitchOff);

        if (clickSwitchOffAnimationFactory !is null)
        {
            clickSwitchOffAnimation = clickSwitchOffAnimationFactory();
            addCreated(clickSwitchOffAnimation);
        }

        if (clickSwitchOnAnimationFactory !is null)
        {
            clickSwitchOnAnimation = clickSwitchOnAnimationFactory();
            addCreated(clickSwitchOnAnimation);
        }

        onMouseDown = (e) {

            final switch (switchState) with (State)
            {
            case off:
                switchState = State.on;

                if (onSwitchOn !is null)
                {
                    onSwitchOn();
                }

                if (clickSwitchOnAnimation !is null && !clickSwitchOnAnimation.isRun)
                {
                    const b = bounds;
                    clickSwitchOnAnimation.minValue = Vector2d(b.x, b.y);
                    clickSwitchOnAnimation.maxValue = Vector2d(b.right - switchHandle.width, b.y);
                    clickSwitchOnAnimation.run;
                }

                effectSwitchOn.isVisible = true;

                break;
            case on:
                switchState = State.off;
                if (onSwitchOff !is null)
                {
                    onSwitchOff();
                }

                if (clickSwitchOffAnimation !is null && !clickSwitchOffAnimation.isRun)
                {
                    const b = bounds;
                    clickSwitchOffAnimation.minValue = Vector2d(b.right - switchHandle.width, b.y);
                    clickSwitchOffAnimation.maxValue = Vector2d(b.x, b.y);
                    clickSwitchOffAnimation.run;
                }

                effectSwitchOn.isVisible = false;

                break;
            }

            return false;
        };

    }

}
