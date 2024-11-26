module api.dm.gui.controls.toggles.switches.base_toggle_switch;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.toggles.base_bitoggle : BaseBitoggle;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.shapes.shape : Shape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.shapes.rectangle : Rectangle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.kit.sprites.tweens.min_max_tween : MinMaxTween;
import api.dm.kit.sprites.tweens.targets.value_tween : ValueTween;
import api.dm.kit.sprites.tweens.targets.props.opacity_tween : OpacityTween;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites.tweens.targets.target_tween : TargetTween;
import api.math.geom2.vec2 : Vec2d;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.labeled : Labeled;

/**
 * Authors: initkfs
 */
class BaseToggleSwitch : BaseBitoggle
{
    protected
    {
        Sprite handleContainer;
    }

    bool isInitHandleContainerFactory = true;
    Sprite delegate() handleContainerFactory;
    Sprite delegate(Sprite) onHandleContainerCreate;
    void delegate(Sprite) onHandleContainerCreated;

    double handleWidth = 0;
    double handleHeight = 0;

    Sprite handle;
    bool isInitHandleFactory = true;
    Sprite delegate() handleFactory;

    Sprite handleOnEffect;
    bool isInitHandleOnEffectFactory = true;
    Sprite delegate(double, double) handleOnEffectFactory;
    Sprite handleOffEffect;
    bool isInitHandleOffEffectFactory;
    Sprite delegate(double, double) handleOffEffectFactory;

    MinMaxTween!Vec2d switchOnAnimation;
    MinMaxTween!Vec2d delegate() switchOnAnimationFactory;

    MinMaxTween!Vec2d switchOffAnimation;
    MinMaxTween!Vec2d delegate() switchOffAnimationFactory;

    this(dstring label, double width, double height, string iconName = null, double graphicsGap = 5, bool isCreateLayout = true)
    {
        super(width, height, iconName, graphicsGap, label, isCreateLayout);
    }

    this(dstring label = "Toggle", string iconName = null, double graphicsGap = 5)
    {
        this(label, 0, 0, iconName, graphicsGap);
    }

    override void initialize()
    {
        super.initialize;

        if (isInitHandleFactory)
        {
            handleFactory = () {

                auto size = handleSize;

                auto style = createStyle;
                if (!style.isNested && !style.isDefault)
                {
                    style.isFill = false;
                }

                auto shape = theme.shape(size.x, size.y, style);
                // import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

                // shape.layout = new CenterLayout;
                return shape;
            };
        }

        if (!handleOnEffectFactory && isInitHandleOnEffectFactory)
        {
            handleOnEffectFactory = (w, h) {

                auto currStyle = createStyle;
                if (!currStyle.isNested)
                {
                    currStyle.isFill = true;
                    currStyle.fillColor = theme.colorAccent;
                }

                return theme.shape(w, h, currStyle);
            };
        }

        switchOnAnimationFactory = () {
            import api.dm.kit.sprites.tweens.targets.motions.linear_motion : LinearMotion;
            import api.dm.kit.sprites.tweens.curves.uni_interpolator : UniInterpolator;

            auto uniInterp = new UniInterpolator;
            uniInterp.interpolateMethod = &uniInterp.quadInOut;
            auto animation = new LinearMotion(Vec2d.zero, Vec2d.zero, 200, uniInterp);
            animation.addTarget(handle);
            return animation;
        };

        if (!handleOffEffectFactory && isInitHandleOffEffectFactory)
        {
            handleOffEffectFactory = (w, h) {

                auto currStyle = createStyle;
                if (!currStyle.isNested)
                {
                    currStyle.isFill = false;
                }

                return theme.shape(w, h, currStyle);
            };

        }
        switchOffAnimationFactory = () {
            import api.dm.kit.sprites.tweens.targets.motions.linear_motion : LinearMotion;
            import api.dm.kit.sprites.tweens.curves.uni_interpolator : UniInterpolator;

            auto uniInterp = new UniInterpolator;
            uniInterp.interpolateMethod = &uniInterp.quadInOut;
            auto animation = new LinearMotion(Vec2d.zero, Vec2d.zero, 200, uniInterp);
            animation.addTarget(handle);
            return animation;
        };

        if (!handleContainerFactory && isInitHandleContainerFactory)
        {
            handleContainerFactory = newHandleContainerFactory;
        }
    }

    Vec2d handleSize() => Vec2d(handleWidth, handleHeight);

    override void loadTheme()
    {
        super.loadTheme;
        loadToggleSwitchTheme;
    }

    void loadToggleSwitchTheme()
    {
        if (handleWidth == 0)
        {
            handleWidth = theme.toggleSwitchMarkerWidth;
        }

        if (handleHeight == 0)
        {
            handleHeight = theme.toggleSwitchMarkerHeight;
        }
    }

    override void create()
    {
        super.create;

        if (handleContainerFactory)
        {
            auto newContainer = handleContainerFactory();
            handleContainer = onHandleContainerCreate ? onHandleContainerCreate(newContainer)
                : newContainer;
            addCreate(handleContainer);
            if (onHandleContainerCreated)
            {
                onHandleContainerCreated(handleContainer);
            }
        }

        assert(handleContainer);

        if (handleFactory)
        {
            handle = handleFactory();
            handleContainer.addCreate(handle);
        }

        if (handleOffEffectFactory && handle)
        {
            handleOffEffect = handleOffEffectFactory(handle.width, handle
                    .height);
            handleOffEffect.isVisible = false;
            handleContainer.addCreate(handleOffEffect);
        }

        if (handleOnEffectFactory && handle)
        {
            handleOnEffect = handleOnEffectFactory(handle.width, handle
                    .height);
            handleOnEffect.isVisible = false;
            handle.addCreate(handleOnEffect);
        }

        if (switchOnAnimationFactory)
        {
            switchOnAnimation = switchOnAnimationFactory();
            handleContainer.addCreate(switchOnAnimation);
        }

        if (switchOffAnimationFactory)
        {
            switchOffAnimation = switchOffAnimationFactory();
            handleContainer.addCreate(switchOffAnimation);
        }

        onPointerUp ~= (ref e) { toggle; };

        invalidateListeners ~= () { setSwitchAnimation; };
        window.showingTasks ~= (double dt) {
            setSwitchAnimation;
            if (isOn)
            {
                changeToggleState(isOn);
            }
        };
    }

    protected Sprite delegate() newHandleContainerFactory()
    {
        return () {
            import api.dm.gui.containers.container;
            import api.dm.kit.sprites.layouts.managed_layout : ManagedLayout;

            auto handleContainer = new Container;

            auto size = handleContainerSize;
            handleContainer.resize(size.x, size.y);
            handleContainer.isBorder = true;

            handleContainer.layout = new ManagedLayout;
            return handleContainer;
        };
    }

    Vec2d handleContainerSize() => Vec2d(handleWidth * 2, handleHeight);

    protected void setSwitchAnimation()
    {
        setSwitchOnAnimation;
        setSwitchOffAnimation;
    }

    protected void setSwitchOnAnimation()
    {
        if (!switchOnAnimation || !handle)
        {
            return;
        }

        const minValue = handleOnAnimationMinValue;
        const maxValue = handleOnAnimationMaxValue;
        switchOnAnimation.minValue(minValue, isStop:
            false);
        switchOnAnimation.maxValue(maxValue, isStop:
            false);
    }

    protected void setSwitchOffAnimation()
    {
        if (!switchOffAnimation || !handle)
        {
            return;
        }
        const minValue = handleOffAnimationMinValue;
        const maxValue = handleOffAnimationMaxValue;
        switchOffAnimation.minValue(minValue, isStop:
            false);
        switchOffAnimation.maxValue(maxValue, isStop:
            false);
    }

    abstract
    {
        Vec2d handleOnAnimationMinValue();
        Vec2d handleOnAnimationMaxValue();
        Vec2d handleOffAnimationMinValue();
        Vec2d handleOffAnimationMaxValue();
    }

    override bool isOn() => super.isOn;

    override bool isOn(bool value, bool isRunListeners = true)
    {
        if (!super.isOn(value, isRunListeners))
        {
            return false;
        }

        if (!isCreated)
        {
            return false;
        }

        changeToggleState(_state);

        return true;
    }

    protected void changeToggleState(bool stateValue)
    {
        if (stateValue)
        {
            //Switch on
            if (switchOffAnimation && switchOffAnimation.isRunning)
            {
                switchOffAnimation.stop;
            }

            if (switchOnAnimation && !switchOnAnimation.isRunning)
            {
                switchOnAnimation.run;
            }

            if (handleOnEffect)
            {
                handleOnEffect.isVisible = true;
            }

            if (handleOffEffect)
            {
                handleOffEffect.isVisible = false;
            }
        }
        else
        {
            //Switch off
            if (switchOnAnimation && switchOnAnimation.isRunning)
            {
                switchOnAnimation.stop;
            }

            if (switchOffAnimation && !switchOffAnimation.isRunning)
            {
                switchOffAnimation.run;
            }

            if (handleOnEffect)
            {
                handleOnEffect.isVisible = false;
            }

            if (handleOffEffect)
            {
                handleOffEffect.isVisible = true;
            }
        }
    }
}
