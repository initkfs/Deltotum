module api.dm.gui.controls.switches.toggles.base_toggle_switch;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.shapes.shape : Shape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.shapes.rectangle : Rectangle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.kit.sprites.tweens.min_max_tween : MinMaxTween;
import api.dm.kit.sprites.tweens.tween : Tween;
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

    Sprite handleEffect;
    bool isCreateHandleEffect = true;

    MinMaxTween!Vec2d handleEffectAnimation;
    bool isCreateHandleEffectAnimation = true;

    bool isCreatePointerListeners = true;

    this(dstring label, double width, double height, string iconName = null, double graphicsGap = 5, bool isCreateLayout = true)
    {
        super(width, height, label, iconName, graphicsGap, isCreateLayout);
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

        if (!handleEffect && isCreateHandleEffect && handle)
        {
            handleEffect = newHandleEffect(handle.width, handle
                    .height);
            handle.addCreate(handleEffect);
        }

        if (!handleEffectAnimation && isCreateHandleEffectAnimation)
        {
            handleEffectAnimation = newHandleEffectAnimation;
            handleContainer.addCreate(handleEffectAnimation);
        }

        if(isCreatePointerListeners){
            onPointerUp ~= (ref e) { toggle; };
        }

        invalidateListeners ~= () { setHandleEffectAnimation; };
        window.showingTasks ~= (double dt) {
            setHandleEffectAnimation;
            switchContentState(isOn, isOn);
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

    Sprite newHandleEffect(double w, double h)
    {
        auto currStyle = createStyle;
        if (!currStyle.isNested)
        {
            currStyle.isFill = true;
            currStyle.fillColor = theme.colorAccent;
        }

        auto shape = theme.shape(w, h, currStyle);
        shape.isVisible = false;
        return shape;
    }

    MinMaxTween!Vec2d newHandleEffectAnimation()
    {
        import api.dm.kit.sprites.tweens.targets.motions.linear_motion : LinearMotion;
        import api.dm.kit.sprites.tweens.curves.uni_interpolator : UniInterpolator;

        auto uniInterp = new UniInterpolator;
        uniInterp.interpolateMethod = &uniInterp.quadInOut;
        auto animation = new LinearMotion(Vec2d.zero, Vec2d.zero, 200, uniInterp);
        animation.addTarget(handle);
        animation.onEnd ~= newOnEndHandleEffectAnimation;
        return animation;
    }

    void delegate() newOnEndHandleEffectAnimation()
    {
        return () {
            if(handleEffectAnimation){
                handleEffectAnimation.isReverse = false;
            }
        };
    }

    protected void setHandleEffectAnimation()
    {
        const minValue = handleAnimationMinValue;
        const maxValue = handleAnimationMaxValue;
        handleEffectAnimation.minValue(minValue, isStop:
            false);
        handleEffectAnimation.maxValue(maxValue, isStop:
            false);
    }

    abstract
    {
        Vec2d handleAnimationMinValue();
        Vec2d handleAnimationMaxValue();
    }

    override protected void switchContentState(bool oldState, bool newState)
    {
        super.switchContentState(oldState, newState);

        if(handleEffect){
            handleEffect.isVisible = newState;
        }

        if (handleEffectAnimation)
        {
            if (handleEffectAnimation.isRunning)
            {
                handleEffectAnimation.stop;
            }

            if(!newState){
                handleEffectAnimation.isReverse = true;
            }

            handleEffectAnimation.run;
        }
    }
}
