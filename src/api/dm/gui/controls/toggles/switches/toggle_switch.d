module api.dm.gui.controls.toggles.switches.toggle_switch;

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
class ToggleSwitch : BaseBitoggle
{
    protected
    {
        Control handleContainer;
    }

    double handleWidth = 0;
    double handleHeight = 0;

    Sprite handle;
    bool isCreateHandleFactory = true;
    Sprite delegate() handleFactory;

    Sprite handleOnEffect;
    bool isCreateHandleOnEffectFactory = true;
    Sprite delegate(double, double) handleOnEffectFactory;
    Sprite handleOffEffect;
    bool isCreateHandleOffEffectFactory;
    Sprite delegate(double, double) handleOffEffectFactory;

    MinMaxTween!Vec2d switchOnAnimation;
    MinMaxTween!Vec2d delegate() switchOnAnimationFactory;

    MinMaxTween!Vec2d switchOffAnimation;
    MinMaxTween!Vec2d delegate() switchOffAnimationFactory;

    this(dstring label, double width, double height, string iconName = null, double graphicsGap = 5)
    {
        super(width, height, iconName, graphicsGap, label, isCreateLayout:
            true);
    }

    this(dstring label = "Toggle", string iconName = null, double graphicsGap = 5)
    {
        this(label, 0, 0, iconName, graphicsGap);
    }

    override void initialize()
    {
        super.initialize;

        if (isCreateHandleFactory)
        {
            handleFactory = () {

                assert(handleWidth > 0);
                assert(handleHeight > 0);

                auto style = createStyle;
                if (!style.isNested && !style.isDefault)
                {
                    style.isFill = false;
                }

                auto shape = theme.shape(handleWidth, handleHeight, style);
                // import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

                // shape.layout = new CenterLayout;
                return shape;
            };
        }

        if (!handleOnEffectFactory && isCreateHandleOnEffectFactory)
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

        if (!handleOffEffectFactory && isCreateHandleOffEffectFactory)
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

        if (_labelText.length == 0)
        {
            onPreIconTryCreate = () { createHandleContainer; };
        }
        else
        {
            onPreTextTryCreate = () { createHandleContainer; };
        }

    }

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

        if (handleFactory)
        {
            handle = handleFactory();
            handleContainer.addCreate(handle);

            const maxContainerWidth = handleWidth * 2;
            if (maxContainerWidth > handleContainer.width)
            {
                handleContainer.width = handleContainer.width + (
                    maxContainerWidth - handleContainer.width);
            }
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

    void createHandleContainer()
    {
        import api.dm.gui.containers.container;
        import api.dm.kit.sprites.layouts.managed_layout : ManagedLayout;

        handleContainer = new Container;

        auto hWidth = handleWidth * 2;
        auto hHeight = handleHeight;
        handleContainer.resize(hWidth, hHeight);
        handleContainer.isBorder = true;

        handleContainer.layout = new ManagedLayout;
        addCreate(handleContainer);
    }

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

        const b = handleContainer.bounds;
        const minValue = Vec2d(b.x + handleContainer.padding.left, b
                .y + handleContainer.padding.top);
        const maxValue = Vec2d(
            b.right - handle.width - handleContainer.padding.right, b
                .y + handleContainer.padding.top);
        //auto start = Vec2d(x, y);
        //auto end = Vec2d(bounds.right - handle.width, bounds.y);
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
        const b = handleContainer.bounds;
        const minValue = Vec2d(
            b.right - handle.width - handleContainer.padding.right, b.y + handleContainer
                .padding.top);
        const maxValue = Vec2d(b.x + handleContainer.padding.left, b
                .y + handleContainer.padding.top);
        //auto start = Vec2d(bounds.right - handle.width, y);
        //auto end = Vec2d(x, y);
        switchOffAnimation.minValue(minValue, isStop:
            false);
        switchOffAnimation.maxValue(maxValue, isStop:
            false);
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
