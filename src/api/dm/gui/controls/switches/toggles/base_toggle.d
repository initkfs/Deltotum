module api.dm.gui.controls.switches.toggles.base_toggle;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.kit.sprites2d.tweens.min_max_tween : MinMaxTween;
import api.dm.kit.sprites2d.tweens.tween2d : Tween2d;
import api.dm.kit.sprites2d.tweens.targets.value_tween : ValueTween;
import api.dm.kit.sprites2d.tweens.targets.props.opacity_tween : OpacityTween;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites2d.tweens.targets.target_tween : TargetTween;
import api.math.geom2.vec2 : Vec2f;
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
    Sprite2d delegate(Sprite2d) onNewThumbContainer;
    void delegate(Sprite2d) onCongifuredThumbContainer;
    void delegate(Sprite2d) onCreatedThumbContainer;

    float thumbWidth = 0;
    float thumbHeight = 0;

    Sprite2d thumb;
    bool isCreateThumb = true;

    Sprite2d thumbEffect;
    bool isCreateThumbEffect = true;

    MinMaxTween!Vec2f thumbEffectAnimation;
    bool isCreateThumbEffectAnimation = true;

    bool isCreatePointerListeners = true;

    this(dstring label, float width, float height, string iconName = null, float graphicsGap = 5, bool isCreateLayout = true)
    {
        super(label, iconName, graphicsGap, isCreateLayout);
        initSize(width, height);
    }

    this(dstring label = "Toggle", string iconName = null, float graphicsGap = 5)
    {
        this(label, 0, 0, iconName, graphicsGap);
    }

    Vec2f thumbSize() => Vec2f(thumbWidth, thumbHeight);

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
            thumbContainer = onNewThumbContainer ? onNewThumbContainer(newContainer) : newContainer;

            if (onCongifuredThumbContainer)
            {
                onCongifuredThumbContainer(thumbContainer);
            }

            addCreate(thumbContainer);

            if (onCreatedThumbContainer)
            {
                onCreatedThumbContainer(thumbContainer);
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

        if (isCreatePointerListeners)
        {
            onPointerRelease ~= (ref e) { toggle; };
        }

        invalidateListeners ~= () { setThumbEffectAnimation; };
        window.showingTasks ~= (float dt) {
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
        // import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        // shape.layout = new CenterLayout;
        return shape;
    }

    protected Sprite2d newThumbContainer()
    {
        import api.dm.gui.controls.containers.container;
        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        auto thumbContainer = new Container;

        auto size = thumbContainerSize;
        thumbContainer.resize(size.x, size.y);
        thumbContainer.isBorder = true;

        thumbContainer.layout = new ManagedLayout;
        return thumbContainer;

    }

    Vec2f thumbContainerSize() => Vec2f(thumbWidth * 2, thumbHeight);

    Sprite2d newThumbEffect(float w, float h)
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

    MinMaxTween!Vec2f newThumbEffectAnimation()
    {
        import api.dm.kit.sprites2d.tweens.targets.motions.linear_motion : LinearMotion;
        import api.dm.kit.sprites2d.tweens.curves.uni_interpolator : UniInterpolator;

        auto uniInterp = new UniInterpolator;
        uniInterp.interpolateMethod = &uniInterp.quadInOut;
        auto animation = new LinearMotion(Vec2f.zero, Vec2f.zero, 200, uniInterp);
        animation.addTarget(thumb);
        animation.onEnd ~= newOnEndThumbEffectAnimation;
        return animation;
    }

    void delegate() newOnEndThumbEffectAnimation()
    {
        return () {
            if (thumbEffectAnimation)
            {
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
        Vec2f thumbAnimationMinValue();
        Vec2f thumbAnimationMaxValue();
    }

    override protected void switchContentState(bool oldState, bool newState)
    {
        super.switchContentState(oldState, newState);

        if (thumbEffect)
        {
            thumbEffect.isVisible = newState;
        }

        if (thumbEffectAnimation)
        {
            if (thumbEffectAnimation.isRunning)
            {
                thumbEffectAnimation.stop;
            }

            if (!newState)
            {
                thumbEffectAnimation.isReverse = true;
            }

            thumbEffectAnimation.run;
        }
    }
}
