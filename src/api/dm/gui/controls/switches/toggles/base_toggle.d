module api.dm.gui.controls.switches.toggles.base_toggle;

import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.sprites2d.shapes.rectangle : Rectangle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.kit.sprites.sprites2d.tweens.min_max_tween2d : MinMaxTween2d;
import api.dm.kit.sprites.sprites2d.tweens.tween2d : Tween2d;
import api.dm.kit.sprites.sprites2d.tweens.targets.value_tween2d : ValueTween2d;
import api.dm.kit.sprites.sprites2d.tweens.targets.props.opacity_tween2d : OpacityTween2d;
import api.dm.kit.sprites.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites.sprites2d.tweens.targets.target_tween2d : TargetTween2d;
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
        Sprite2d thumbContainer;
    }

    bool isCreateThumbContainer = true;
    Sprite2d delegate(Sprite2d) onThumbContainerCreate;
    void delegate(Sprite2d) onThumbContainerCreated;

    double thumbWidth = 0;
    double thumbHeight = 0;

    Sprite2d thumb;
    bool isCreateThumb = true;

    Sprite2d thumbEffect;
    bool isCreateThumbEffect = true;

    MinMaxTween2d!Vec2d thumbEffectAnimation;
    bool isCreateThumbEffectAnimation = true;

    bool isCreatePointerListeners = true;

    this(dstring label, double width, double height, string iconName = null, double graphicsGap = 5, bool isCreateLayout = true)
    {
        super(width, height, label, iconName, graphicsGap, isCreateLayout);
    }

    this(dstring label = "Toggle", string iconName = null, double graphicsGap = 5)
    {
        this(label, 0, 0, iconName, graphicsGap);
    }

    Vec2d thumbSize() => Vec2d(thumbWidth, thumbHeight);

    override void loadTheme()
    {
        super.loadTheme;
        loadToggleSwitchTheme;
    }

    void loadToggleSwitchTheme()
    {
        if (thumbWidth == 0)
        {
            thumbWidth = theme.toggleSwitchMarkerWidth;
        }

        if (thumbHeight == 0)
        {
            thumbHeight = theme.toggleSwitchMarkerHeight;
        }
    }

    override void create()
    {
        super.create;

        if (!thumbContainer && isCreateThumbContainer)
        {
            auto newContainer = newThumbContainer;
            thumbContainer = onThumbContainerCreate ? onThumbContainerCreate(newContainer)
                : newContainer;
            addCreate(thumbContainer);
            if (onThumbContainerCreated)
            {
                onThumbContainerCreated(thumbContainer);
            }
        }

        assert(thumbContainer);

        if (!thumb && isCreateThumb)
        {
            thumb = newThumb;
            thumbContainer.addCreate(thumb);
        }

        if (!thumbEffect && isCreateThumbEffect && thumb)
        {
            thumbEffect = newThumbEffect(thumb.width, thumb
                    .height);
            thumb.addCreate(thumbEffect);
        }

        if (!thumbEffectAnimation && isCreateThumbEffectAnimation)
        {
            thumbEffectAnimation = newThumbEffectAnimation;
            thumbContainer.addCreate(thumbEffectAnimation);
        }

        if(isCreatePointerListeners){
            onPointerRelease ~= (ref e) { toggle; };
        }

        invalidateListeners ~= () { setThumbEffectAnimation; };
        window.showingTasks ~= (double dt) {
            setThumbEffectAnimation;
            switchContentState(isOn, isOn);
        };
    }

    Sprite2d newThumb()
    {
        auto size = thumbSize;

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

    protected Sprite2d newThumbContainer()
    {
        import api.dm.gui.containers.container;
        import api.dm.kit.sprites.sprites2d.layouts.managed_layout : ManagedLayout;

        auto thumbContainer = new Container;

        auto size = thumbContainerSize;
        thumbContainer.resize(size.x, size.y);
        thumbContainer.isBorder = true;

        thumbContainer.layout = new ManagedLayout;
        return thumbContainer;

    }

    Vec2d thumbContainerSize() => Vec2d(thumbWidth * 2, thumbHeight);

    Sprite2d newThumbEffect(double w, double h)
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

    MinMaxTween2d!Vec2d newThumbEffectAnimation()
    {
        import api.dm.kit.sprites.sprites2d.tweens.targets.motions.linear_motion2d : LinearMotion2d;
        import api.dm.kit.tweens.curves.uni_interpolator : UniInterpolator;

        auto uniInterp = new UniInterpolator;
        uniInterp.interpolateMethod = &uniInterp.quadInOut;
        auto animation = new LinearMotion2d(Vec2d.zero, Vec2d.zero, 200, uniInterp);
        animation.addTarget(thumb);
        animation.onEnd ~= newOnEndThumbEffectAnimation;
        return animation;
    }

    void delegate() newOnEndThumbEffectAnimation()
    {
        return () {
            if(thumbEffectAnimation){
                thumbEffectAnimation.isReverse = false;
            }
        };
    }

    protected void setThumbEffectAnimation()
    {
        const minValue = thumbAnimationMinValue;
        const maxValue = thumbAnimationMaxValue;
        thumbEffectAnimation.minValue(minValue, isStop:
            false);
        thumbEffectAnimation.maxValue(maxValue, isStop:
            false);
    }

    abstract
    {
        Vec2d thumbAnimationMinValue();
        Vec2d thumbAnimationMaxValue();
    }

    override protected void switchContentState(bool oldState, bool newState)
    {
        super.switchContentState(oldState, newState);

        if(thumbEffect){
            thumbEffect.isVisible = newState;
        }

        if (thumbEffectAnimation)
        {
            if (thumbEffectAnimation.isRunning)
            {
                thumbEffectAnimation.stop;
            }

            if(!newState){
                thumbEffectAnimation.isReverse = true;
            }

            thumbEffectAnimation.run;
        }
    }
}
