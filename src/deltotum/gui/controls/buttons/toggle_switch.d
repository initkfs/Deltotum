module deltotum.gui.controls.buttons.toggle_switch;

import deltotum.gui.controls.control : Control;
import deltotum.kit.graphics.shapes.shape : Shape;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.graphics.shapes.rectangle : Rectangle;
import deltotum.gui.events.action_event : ActionEvent;
import deltotum.kit.display.animation.object.value_transition : ValueTransition;
import deltotum.kit.display.animation.object.property.opacity_transition : OpacityTransition;
import deltotum.gui.controls.texts.text;
import deltotum.kit.display.layouts.horizontal_layout : HorizontalLayout;
import deltotum.kit.display.textures.texture : Texture;
import deltotum.kit.display.display_object : DisplayObject;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.display.animation.object.display_object_transition : DisplayObjectTransition;
import deltotum.math.vector2d : Vector2d;

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

    Texture switchHandle;
    Texture delegate() switchHandleFactory;

    DisplayObjectTransition!Vector2d clickSwitchOnAnimation;
    DisplayObjectTransition!Vector2d clickSwitchOffAnimation;

    DisplayObjectTransition!Vector2d delegate() clickSwitchOnAnimationFactory;
    DisplayObjectTransition!Vector2d delegate() clickSwitchOffAnimationFactory;

    //TODO factories, settings
    DisplayObject effectHandleSwitchOn;
    Texture delegate(double, double) effectHandleSwitchOnFactory;
    DisplayObject effectBackgroundSwitchOn;
    Texture delegate() effectBackgroundSwitchOnFactory;

    this(double width = 60, double height = 25)
    {
        this.width = width;
        this.height = height;

        import deltotum.kit.display.layouts.center_layout: CenterLayout;

        //FIXME center + isLManaged = false + align y not working
        this.layout = new HorizontalLayout;
    }

    override void initialize()
    {
        super.initialize;

        import deltotum.math.geometry.insets : Insets;

        padding = Insets(0);

        effectHandleSwitchOnFactory = (width, height) {
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
            import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;

            GraphicStyle style = GraphicStyle(1, graphics.theme.colorAccent, true, graphics.theme.colorAccent);

            auto control = new RegularPolygon(width - 5, height - 5, style, graphics
                    .theme.controlCornersBevel);
            return control;
        };

        effectBackgroundSwitchOnFactory = () {
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
            import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;
            import deltotum.kit.graphics.shapes.rectangle: Rectangle;

            GraphicStyle style = GraphicStyle(1, graphics.theme.colorAccent, true, graphics
                    .theme.colorAccent);

            auto control = new Rectangle(width / 2, height - graphics.theme.controlCornersBevel * 2, style);
            return control;
        };

        switchHandleFactory = () {

            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
            import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;

            GraphicStyle clickStyle = GraphicStyle(1, graphics.theme.colorAccent);

            auto control = new RegularPolygon(width / 2, height, clickStyle, graphics
                    .theme.controlCornersBevel);
            return control;
        };

        clickSwitchOnAnimationFactory = () {
            import deltotum.math.vector2d : Vector2d;
            import deltotum.kit.display.animation.object.motion.linear_motion_transition : LinearMotionTransition;
            import deltotum.kit.display.animation.interp.uni_interpolator : UniInterpolator;

            auto uniInterp = new UniInterpolator;
            uniInterp.interpolateMethod = &uniInterp.quadInOut;

            auto end = Vector2d(bounds.right - switchHandle.width, bounds.y);
            auto animation = new LinearMotionTransition(switchHandle, Vector2d(x, y), end, 200, uniInterp);
            animation.isCycle = false;
            return animation;
        };

        clickSwitchOffAnimationFactory = () {
            import deltotum.math.vector2d : Vector2d;
            import deltotum.kit.display.animation.object.motion.linear_motion_transition : LinearMotionTransition;
            import deltotum.kit.display.animation.interp.uni_interpolator : UniInterpolator;

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

        if (effectBackgroundSwitchOnFactory)
        {
            effectBackgroundSwitchOn = effectBackgroundSwitchOnFactory();
            //effectBackgroundSwitchOn.isLayoutManaged = false;
            import deltotum.kit.display.alignment : Alignment;
            effectBackgroundSwitchOn.alignment = Alignment.y;
            effectBackgroundSwitchOn.isVisible = false;
            addCreated(effectBackgroundSwitchOn);
        }

        if (switchHandleFactory)
        {
            switchHandle = switchHandleFactory();
            switchHandle.isLayoutManaged = false;

            import deltotum.kit.display.layouts.center_layout : CenterLayout;

            switchHandle.layout = new CenterLayout;
            addCreated(switchHandle);

            if (effectHandleSwitchOnFactory)
            {
                effectHandleSwitchOn = effectHandleSwitchOnFactory(switchHandle.width, switchHandle.height);
                effectHandleSwitchOn.isVisible = false;
                switchHandle.addCreated(effectHandleSwitchOn);
            }
        }

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

                if (effectHandleSwitchOn)
                {
                    effectHandleSwitchOn.isVisible = true;
                }

                if(effectBackgroundSwitchOn){
                    effectBackgroundSwitchOn.isVisible = true;
                }

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

                if (effectHandleSwitchOn)
                {
                    effectHandleSwitchOn.isVisible = false;
                }

                 if(effectBackgroundSwitchOn){
                    effectBackgroundSwitchOn.isVisible = false;
                }

                break;
            }

            return false;
        };

    }

}
