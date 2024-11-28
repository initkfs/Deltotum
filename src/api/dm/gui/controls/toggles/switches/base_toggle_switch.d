module api.dm.gui.controls.toggles.switches.base_toggle_switch;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.shapes.shape : Shape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.shapes.rectangle : Rectangle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.kit.sprites.tweens.min_max_tween : MinMaxTween;
import api.dm.kit.sprites.tweens.tween: Tween;
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
class BaseToggleSwitch : BaseBiswitch
{
    protected
    {
        Sprite handleContainer;
    }

    bool isCreateHandleContainer = true;
    Sprite delegate(Sprite) onHandleContainerCreate;
    void delegate(Sprite) onHandleContainerCreated;

    double handleWidth = 0;
    double handleHeight = 0;

    Sprite handle;
    bool isCreateHandle = true;

    Sprite handleOnEffect;
    bool isCreateHandleOnEffect = true;

    Sprite handleOffEffect;
    bool isCreateHandleOffEffect;
    Sprite delegate(double, double) handleOffEffectFactory;

    MinMaxTween!Vec2d handleOnAnimation;
    bool isCreateHandleOnAnimation = true;

    MinMaxTween!Vec2d handleOffAnimation;
    bool isCreateHandleOffAnimation = true;

    this(dstring label, double width, double height, string iconName = null, double graphicsGap = 5, bool isCreateLayout = true)
    {
        super(width, height, iconName, graphicsGap, label, isCreateLayout);
    }

    this(dstring label = "Toggle", string iconName = null, double graphicsGap = 5)
    {
        this(label, 0, 0, iconName, graphicsGap);
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

        if (!handleContainer && isCreateHandleContainer)
        {
            auto newContainer = newHandleContainer;
            handleContainer = onHandleContainerCreate ? onHandleContainerCreate(newContainer)
                : newContainer;
            addCreate(handleContainer);
            if (onHandleContainerCreated)
            {
                onHandleContainerCreated(handleContainer);
            }
        }

        assert(handleContainer);

        if (!handle && isCreateHandle)
        {
            handle = newHandle;
            handleContainer.addCreate(handle);
        }

        if (!handleOffEffect && isCreateHandleOffEffect && handle)
        {
            handleOffEffect = newHandleOffEffect(handle.width, handle
                    .height);
            handleOffEffect.isVisible = false;
            handleContainer.addCreate(handleOffEffect);
        }

        if (!handleOnEffect && isCreateHandleOnEffect && handle)
        {
            handleOnEffect = newHandleOnEffect(handle.width, handle
                    .height);
            handleOnEffect.isVisible = false;
            handle.addCreate(handleOnEffect);
        }

        if (!handleOnAnimation && isCreateHandleOnAnimation)
        {
            handleOnAnimation = newHandleOnAnimation;
            handleContainer.addCreate(handleOnAnimation);
        }

        if (!handleOffAnimation && isCreateHandleOffAnimation)
        {
            handleOffAnimation = newHandleOffAnimation;
            handleContainer.addCreate(handleOffAnimation);
        }

        onPointerUp ~= (ref e) { toggle; };

        invalidateListeners ~= () { setSwitchAnimation; };
        window.showingTasks ~= (double dt) {
            setSwitchAnimation;
            changeToggleState(isOn);
        };
    }

    Sprite newHandle()
    {
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
    }

    protected Sprite newHandleContainer()
    {
        import api.dm.gui.containers.container;
        import api.dm.kit.sprites.layouts.managed_layout : ManagedLayout;

        auto handleContainer = new Container;

        auto size = handleContainerSize;
        handleContainer.resize(size.x, size.y);
        handleContainer.isBorder = true;

        handleContainer.layout = new ManagedLayout;
        return handleContainer;

    }

    Vec2d handleContainerSize() => Vec2d(handleWidth * 2, handleHeight);

    Sprite newHandleOnEffect(double w, double h)
    {
        auto currStyle = createStyle;
        if (!currStyle.isNested)
        {
            currStyle.isFill = true;
            currStyle.fillColor = theme.colorAccent;
        }

        return theme.shape(w, h, currStyle);
    }

    MinMaxTween!Vec2d newHandleOnAnimation()
    {
        import api.dm.kit.sprites.tweens.targets.motions.linear_motion : LinearMotion;
        import api.dm.kit.sprites.tweens.curves.uni_interpolator : UniInterpolator;

        auto uniInterp = new UniInterpolator;
        uniInterp.interpolateMethod = &uniInterp.quadInOut;
        auto animation = new LinearMotion(Vec2d.zero, Vec2d.zero, 200, uniInterp);
        animation.addTarget(handle);
        return animation;
    }

    Sprite newHandleOffEffect(double w, double h)
    {
        auto currStyle = createStyle;
        if (!currStyle.isNested)
        {
            currStyle.isFill = false;
        }

        return theme.shape(w, h, currStyle);
    }

    MinMaxTween!Vec2d newHandleOffAnimation()
    {
        import api.dm.kit.sprites.tweens.targets.motions.linear_motion : LinearMotion;
        import api.dm.kit.sprites.tweens.curves.uni_interpolator : UniInterpolator;

        auto uniInterp = new UniInterpolator;
        uniInterp.interpolateMethod = &uniInterp.quadInOut;
        auto animation = new LinearMotion(Vec2d.zero, Vec2d.zero, 200, uniInterp);
        animation.addTarget(handle);
        return animation;
    }

    protected void setSwitchAnimation()
    {
        setSwitchOnAnimation;
        setSwitchOffAnimation;
    }

    protected void setSwitchOnAnimation()
    {
        if (!handleOnAnimation || !handle)
        {
            return;
        }

        const minValue = handleOnAnimationMinValue;
        const maxValue = handleOnAnimationMaxValue;
        handleOnAnimation.minValue(minValue, isStop:
            false);
        handleOnAnimation.maxValue(maxValue, isStop:
            false);
    }

    protected void setSwitchOffAnimation()
    {
        if (!handleOffAnimation || !handle)
        {
            return;
        }
        const minValue = handleOffAnimationMinValue;
        const maxValue = handleOffAnimationMaxValue;
        handleOffAnimation.minValue(minValue, isStop:
            false);
        handleOffAnimation.maxValue(maxValue, isStop:
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
            if (handleOffAnimation && handleOffAnimation.isRunning)
            {
                handleOffAnimation.stop;
            }

            if (handleOnAnimation && !handleOnAnimation.isRunning)
            {
                handleOnAnimation.run;
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
            if (handleOnAnimation && handleOnAnimation.isRunning)
            {
                handleOnAnimation.stop;
            }

            if (handleOffAnimation && !handleOffAnimation.isRunning)
            {
                handleOffAnimation.run;
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
