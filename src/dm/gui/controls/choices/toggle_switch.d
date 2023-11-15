module dm.gui.controls.choices.toggle_switch;

import dm.kit.sprites.sprite : Sprite;
import dm.gui.controls.control : Control;
import dm.gui.containers.container: Container;
import dm.kit.sprites.shapes.shape : Shape;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.kit.sprites.shapes.rectangle : Rectangle;
import dm.gui.events.action_event : ActionEvent;
import dm.kit.sprites.animations.object.value_transition : ValueTransition;
import dm.kit.sprites.animations.object.property.opacity_transition : OpacityTransition;
import dm.gui.controls.texts.text;
import dm.kit.sprites.layouts.hlayout : HLayout;
import dm.kit.sprites.textures.texture : Texture;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.sprites.animations.object.display_object_transition : DisplayObjectTransition;
import dm.math.vector2d : Vector2d;
import dm.gui.controls.texts.text : Text;

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

    Container switchContainer;

    Sprite switchHandle;
    Sprite delegate() switchHandleFactory;

    DisplayObjectTransition!Vector2d clickSwitchOnAnimation;
    DisplayObjectTransition!Vector2d clickSwitchOffAnimation;

    DisplayObjectTransition!Vector2d delegate() clickSwitchOnAnimationFactory;
    DisplayObjectTransition!Vector2d delegate() clickSwitchOffAnimationFactory;

    //TODO factories, settings
    Sprite effectHandleSwitchOn;
    Sprite delegate(double, double) effectHandleSwitchOnFactory;

    Text label;

    this(double width = 60, double height = 25)
    {
        this.width = width;
        this.height = height;

        import dm.kit.sprites.layouts.center_layout : CenterLayout;

        auto layout = new HLayout(5);
        layout.isAutoResize = true;
        layout.isAlignY = true;
        this.layout = layout;
    }

    override void initialize()
    {
        super.initialize;

        effectHandleSwitchOnFactory = (width, height) {
            import dm.kit.graphics.styles.graphic_style : GraphicStyle;
            import dm.kit.sprites.shapes.regular_polygon : RegularPolygon;

            auto currStyle = ownOrParentStyle;

            GraphicStyle style = currStyle ? *currStyle : GraphicStyle(1, graphics.theme.colorAccent, true, graphics
                    .theme.colorAccent);
            style.isFill = true;

            auto control = new RegularPolygon(width - 5, height - 5, style, graphics
                    .theme.controlCornersBevel);
            return control;
        };

        switchHandleFactory = () {

            import dm.kit.graphics.styles.graphic_style : GraphicStyle;
            import dm.kit.sprites.shapes.regular_polygon : RegularPolygon;

            auto currStyle = ownOrParentStyle;

            GraphicStyle clickStyle = currStyle ? *currStyle : GraphicStyle(1, graphics.theme.colorAccent);

            auto control = new RegularPolygon(width / 2, height, clickStyle, graphics
                    .theme.controlCornersBevel);
            return control;
        };

        clickSwitchOnAnimationFactory = () {
            import dm.math.vector2d : Vector2d;
            import dm.kit.sprites.animations.object.motion.linear_motion_transition : LinearMotionTransition;
            import dm.kit.sprites.animations.interp.uni_interpolator : UniInterpolator;

            auto uniInterp = new UniInterpolator;
            uniInterp.interpolateMethod = &uniInterp.quadInOut;

            auto end = Vector2d(bounds.right - switchHandle.width, bounds.y);
            auto animation = new LinearMotionTransition(switchHandle, Vector2d(x, y), end, 200, uniInterp);
            animation.isCycle = false;
            return animation;
        };

        clickSwitchOffAnimationFactory = () {
            import dm.math.vector2d : Vector2d;
            import dm.kit.sprites.animations.object.motion.linear_motion_transition : LinearMotionTransition;
            import dm.kit.sprites.animations.interp.uni_interpolator : UniInterpolator;

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

        import dm.gui.containers.container;
        import dm.kit.sprites.layouts.managed_layout: ManagedLayout;

        switchContainer = new Container;
        
        switchContainer.layout = new ManagedLayout;
        import dm.math.geom.insets: Insets;
        switchContainer.padding = Insets(5);
        switchContainer.layout.isAlignY = true;
        switchContainer.layout.isAutoResize = true;
        
        switchContainer.isBorder = true;
        
        addCreate(switchContainer);

        if (switchHandleFactory)
        {
            switchHandle = switchHandleFactory();

            import dm.kit.sprites.layouts.center_layout : CenterLayout;

            switchHandle.layout = new CenterLayout;
            switchContainer.addCreate(switchHandle);

            switchHandle.x = switchContainer.padding.left;

            const toHandleWidth = switchHandle.width * 2;
            if(toHandleWidth > switchContainer.width){
                switchContainer.width = switchContainer.width + toHandleWidth;
            }

            if (effectHandleSwitchOnFactory)
            {
                effectHandleSwitchOn = effectHandleSwitchOnFactory(switchHandle.width, switchHandle
                        .height);
                effectHandleSwitchOn.isVisible = false;
                switchHandle.addCreate(effectHandleSwitchOn);
            }
        }

        if (clickSwitchOffAnimationFactory !is null)
        {
            clickSwitchOffAnimation = clickSwitchOffAnimationFactory();
            switchContainer.addCreate(clickSwitchOffAnimation);
        }

        if (clickSwitchOnAnimationFactory !is null)
        {
            clickSwitchOnAnimation = clickSwitchOnAnimationFactory();
            switchContainer.addCreate(clickSwitchOnAnimation);
        }

        label = new Text("Switch");
        label.isFocusable = false;
        addCreate(label);

        onPointerDown ~= (ref e) {

            final switch (switchState) with (State)
            {
            case off:
                switchState = State.on;

                if (onSwitchOn !is null)
                {
                    onSwitchOn();
                }

                if (clickSwitchOnAnimation !is null && !clickSwitchOnAnimation.isRunning)
                {
                    const b = switchContainer.bounds;
                    clickSwitchOnAnimation.minValue = Vector2d(b.x + switchContainer.padding.left, b.y);
                    clickSwitchOnAnimation.maxValue = Vector2d(b.right - switchHandle.width - switchContainer.padding.right, b.y);
                    clickSwitchOnAnimation.run;
                }

                if (effectHandleSwitchOn)
                {
                    effectHandleSwitchOn.isVisible = true;
                }

                break;
            case on:
                switchState = State.off;
                if (onSwitchOff !is null)
                {
                    onSwitchOff();
                }

                if (clickSwitchOffAnimation !is null && !clickSwitchOffAnimation.isRunning)
                {
                    const b = switchContainer.bounds;
                    clickSwitchOffAnimation.minValue = Vector2d(b.right - switchHandle.width - switchContainer.padding.right, b.y);
                    clickSwitchOffAnimation.maxValue = Vector2d(b.x + switchContainer.padding.left, b.y);
                    clickSwitchOffAnimation.run;
                }

                if (effectHandleSwitchOn)
                {
                    effectHandleSwitchOn.isVisible = false;
                }

                break;
            }
        };

    }

}
