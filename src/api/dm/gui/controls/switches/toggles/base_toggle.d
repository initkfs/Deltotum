module api.dm.gui.controls.switches.toggles.base_toggle;

import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.sprites2d.shapes.rectangle : Rectangle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.kit.sprites.sprites2d.tweens2.min_max_tween2d : MinMaxTween2d;
import api.dm.kit.sprites.sprites2d.tweens2.tween2d : Tween2d;
import api.dm.kit.sprites.sprites2d.tweens2.targets.value_tween : ValueTween;
import api.dm.kit.sprites.sprites2d.tweens2.targets.props.opacity_tween : OpacityTween;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites.sprites2d.tweens2.targets.target_tween : TargetTween;
import api.math.geom2.vec2 : Vec2d;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.labeled : Labeled;

/**
 * Authors: initkfs
 */
class BaseToggle : BaseBiswitch
{
    protected
    {
        Sprite2d handleContainer;
    }

    bool isCreateHandleContainer = true;
    Sprite2d delegate(Sprite2d) onHandleContainerCreate;
    void delegate(Sprite2d) onHandleContainerCreated;

    double handleWidth = 0;
    double handleHeight = 0;

    Sprite2d handle;
    bool isCreateHandle = true;

    Sprite2d handleEffect;
    bool isCreateHandleEffect = true;

    MinMaxTween2d!Vec2d handleEffectAnimation;
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

    Sprite2d newHandle()
    {
        auto size = handleSize;

        auto style = createStyle;
        if (!style.isNested && !style.isDefault)
        {
            style.isFill = false;
        }

        auto shape = theme.shape(size.x, size.y, angle, style);
        // import api.dm.kit.sprites.sprites2d.layouts.center_layout : CenterLayout;

        // shape.layout = new CenterLayout;
        return shape;
    }

    protected Sprite2d newHandleContainer()
    {
        import api.dm.gui.containers.container;
        import api.dm.kit.sprites.sprites2d.layouts.managed_layout : ManagedLayout;

        auto handleContainer = new Container;

        auto size = handleContainerSize;
        handleContainer.resize(size.x, size.y);
        handleContainer.isBorder = true;

        handleContainer.layout = new ManagedLayout;
        return handleContainer;

    }

    Vec2d handleContainerSize() => Vec2d(handleWidth * 2, handleHeight);

    Sprite2d newHandleEffect(double w, double h)
    {
        auto currStyle = createStyle;
        if (!currStyle.isNested)
        {
            currStyle.isFill = true;
            currStyle.fillColor = theme.colorAccent;
        }

        auto shape = theme.shape(w, h, angle, currStyle);
        shape.isVisible = false;
        return shape;
    }

    MinMaxTween2d!Vec2d newHandleEffectAnimation()
    {
        import api.dm.kit.sprites.sprites2d.tweens2.targets.motions.linear_motion : LinearMotion;
        import api.dm.kit.tweens.curves.uni_interpolator : UniInterpolator;

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
