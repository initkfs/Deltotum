module dm.gui.controls.toggles.toggle_switch;

import dm.kit.sprites.sprite : Sprite;
import dm.gui.controls.labeled : Labeled;
import dm.gui.controls.control : Control;
import dm.kit.sprites.shapes.shape : Shape;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.kit.sprites.shapes.rectangle : Rectangle;
import dm.gui.events.action_event : ActionEvent;
import dm.kit.sprites.animations.transition : Transition;
import dm.kit.sprites.animations.object.value_transition : ValueTransition;
import dm.kit.sprites.animations.object.property.opacity_transition : OpacityTransition;
import dm.kit.sprites.textures.texture : Texture;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.sprites.animations.object.display_object_transition : DisplayObjectTransition;
import dm.math.vector2 : Vector2;
import dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class ToggleSwitch : Labeled
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
        Control switchContainer;
    }

    void delegate() onSwitchOn;
    void delegate() onSwitchOff;

    Sprite switchHandle;
    Sprite delegate() switchHandleFactory;

    Transition!Vector2 switchOnAnimation;
    Transition!Vector2 switchOffAnimation;

    Transition!Vector2 delegate() switchOnAnimationFactory;
    Transition!Vector2 delegate() switchOffAnimationFactory;

    //TODO factories, settings
    Sprite handleOnEffect;
    Sprite delegate(double, double) handleOnEffectFactory;

    this(dstring label = "Toggle", double width = 60, double height = 25, string iconName = null, double graphicsGap = 5)
    {
        super(iconName, graphicsGap, false);
        this.width = width;
        this.height = height;

        isCreateHoverFactory = false;
        isCreatePointerEffectFactory = false;
        isCreatePointerEffectAnimationFactory = false;
        isCreateTextFactory = true;

        import dm.kit.sprites.layouts.hlayout : HLayout;

        auto layout = new HLayout(5);
        layout.isAutoResize = true;
        layout.isAlignY = true;
        this.layout = layout;

        _labelText = label;

        isBorder = false;
    }

    override void initialize()
    {
        super.initialize;

        handleOnEffectFactory = (w, h) {

            auto currStyle = createDefaultStyle(w, h);
            if (!currStyle.isNested)
            {
                currStyle.lineColor = graphics.theme.colorAccent;
                currStyle.isFill = true;
                currStyle.fillColor = graphics.theme.colorAccent;
            }

            if (capGraphics.isVectorGraphics)
            {
                import dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

                return new VRegularPolygon(w, h, currStyle, graphics.theme.controlCornersBevel);
            }
            else
            {
                import dm.kit.sprites.shapes.regular_polygon : RegularPolygon;

                return new RegularPolygon(w, h, currStyle, graphics.theme.controlCornersBevel);
            }
        };

        switchHandleFactory = () {
            import dm.kit.sprites.shapes.regular_polygon : RegularPolygon;

            auto currStyle = createDefaultStyle(width, height);
            double w = width / 2;
            double h = height;

            if (capGraphics.isVectorGraphics)
            {
                import dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

                return new VRegularPolygon(w, h, currStyle, graphics.theme.controlCornersBevel);
            }
            else
            {
                import dm.kit.sprites.shapes.regular_polygon : RegularPolygon;

                return new RegularPolygon(w, h, currStyle, graphics
                        .theme.controlCornersBevel);
            }
        };

        switchOnAnimationFactory = () {
            import dm.math.vector2 : Vector2;
            import dm.kit.sprites.animations.object.motion.linear_motion_transition : LinearMotionTransition;
            import dm.kit.sprites.animations.interp.uni_interpolator : UniInterpolator;

            auto uniInterp = new UniInterpolator;
            uniInterp.interpolateMethod = &uniInterp.quadInOut;

            auto end = Vector2(bounds.right - switchHandle.width, bounds.y);
            auto animation = new LinearMotionTransition(switchHandle, Vector2(x, y), end, 200, uniInterp);
            animation.isCycle = false;
            return animation;
        };

        switchOffAnimationFactory = () {
            import dm.math.vector2 : Vector2;
            import dm.kit.sprites.animations.object.motion.linear_motion_transition : LinearMotionTransition;
            import dm.kit.sprites.animations.interp.uni_interpolator : UniInterpolator;

            auto start = Vector2(bounds.right - switchHandle.width, y);
            auto uniInterp = new UniInterpolator;
            uniInterp.interpolateMethod = &uniInterp.quadInOut;
            auto animation = new LinearMotionTransition(switchHandle, start, Vector2(x, y), 200, uniInterp);
            animation.isCycle = false;
            return animation;
        };

        if (_labelText.length == 0)
        {
            onPreTextCreate = () { createSwitchContainer; };
        }
        else
        {
            onPreIconCreate = () { createSwitchContainer; };
        }

    }

    void createSwitchContainer()
    {
        import dm.gui.containers.container;
        import dm.kit.sprites.layouts.managed_layout : ManagedLayout;

        switchContainer = new Container;

        switchContainer.layout = new ManagedLayout;
        import dm.math.insets : Insets;

        switchContainer.padding = Insets(5);
        switchContainer.layout.isAlignY = true;
        switchContainer.layout.isAutoResize = true;
        switchContainer.isBorder = true;

        addCreate(switchContainer);
    }

    override void create()
    {
        super.create;

        if (switchHandleFactory)
        {
            switchHandle = switchHandleFactory();

            import dm.kit.sprites.layouts.center_layout : CenterLayout;

            switchHandle.layout = new CenterLayout;
            switchContainer.addCreate(switchHandle);

            switchHandle.x = switchContainer.padding.left;

            const toHandleWidth = switchHandle.width * 2;
            if (toHandleWidth > switchContainer.width)
            {
                switchContainer.width = switchContainer.width + toHandleWidth;
            }

            if (handleOnEffectFactory)
            {
                handleOnEffect = handleOnEffectFactory(switchHandle.width, switchHandle
                        .height);
                handleOnEffect.isVisible = false;
                switchHandle.addCreate(handleOnEffect);
            }
        }

        if (switchOffAnimationFactory)
        {
            switchOffAnimation = switchOffAnimationFactory();
            switchContainer.addCreate(switchOffAnimation);
        }

        if (switchOnAnimationFactory)
        {
            switchOnAnimation = switchOnAnimationFactory();
            switchContainer.addCreate(switchOnAnimation);
        }

        onPointerDown ~= (ref e) {

            final switch (switchState) with (State)
            {
                case off:
                    setSwitchOn;
                    break;
                case on:
                    setSwitchOff;
                    break;
            }
        };

    }

    void setSwitchOn(bool isRunListeners = true)
    {
        if (switchState == State.on)
        {
            return;
        }

        switchState = State.on;

        if (onSwitchOn !is null && isRunListeners)
        {
            onSwitchOn();
        }

        if (switchOnAnimation && !switchOnAnimation.isRunning)
        {
            const b = switchContainer.bounds;
            const minValue = Vector2(b.x + switchContainer.padding.left, b
                    .y);
            const maxValue = Vector2(
                b.right - switchHandle.width - switchContainer.padding.right, b
                    .y);
            switchOnAnimation.minValue = minValue;
            switchOnAnimation.maxValue = maxValue;
            switchOnAnimation.run;
        }

        if (handleOnEffect)
        {
            handleOnEffect.isVisible = true;
        }
    }

    protected void setSwitchOff(bool isRunListeners = true)
    {
        if (switchState == State.off)
        {
            return;
        }

        switchState = State.off;

        if (onSwitchOff !is null && isRunListeners)
        {
            onSwitchOff();
        }

        if (switchOffAnimation !is null && !switchOffAnimation.isRunning)
        {
            const b = switchContainer.bounds;
            switchOffAnimation.minValue = Vector2(
                b.right - switchHandle.width - switchContainer.padding.right, b.y);
            switchOffAnimation.maxValue = Vector2(b.x + switchContainer.padding.left, b
                    .y);
            switchOffAnimation.run;
        }

        if (handleOnEffect)
        {
            handleOnEffect.isVisible = false;
        }
    }

    void toggle(bool isRunListeners = true)
    {
        if (switchState == State.on)
        {
            setSwitch(false, isRunListeners);
        }

        if (switchState == State.off)
        {
            setSwitch(false, isRunListeners);
        }
    }

    void setSwitch(bool value, bool isRunListeners = true)
    {
        if (window && window.isShowing)
        {
            if (value)
            {
                setSwitchOn(isRunListeners);
            }
            else
            {
                setSwitchOff(isRunListeners);
            }
        }
        else
        {
            window.showingTasks ~= (dt) {
                if (value)
                {
                    setSwitchOn(isRunListeners);
                }
                else
                {
                    setSwitchOff(isRunListeners);
                }
            };
        }

    }

}
