module api.dm.gui.controls.toggles.toggle_switch;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.labeled : Labeled;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.shapes.shape : Shape;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites.shapes.rectangle : Rectangle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.kit.sprites.transitions.min_max_transition : MinMaxTransition;
import api.dm.kit.sprites.transitions.objects.value_transition : ValueTransition;
import api.dm.kit.sprites.transitions.objects.props.opacity_transition : OpacityTransition;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.sprites.transitions.objects.object_transition : ObjectTransition;
import api.math.vector2 : Vector2;
import api.dm.gui.controls.texts.text : Text;

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

    MinMaxTransition!Vector2 switchOnAnimation;
    MinMaxTransition!Vector2 switchOffAnimation;

    MinMaxTransition!Vector2 delegate() switchOnAnimationFactory;
    MinMaxTransition!Vector2 delegate() switchOffAnimationFactory;

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

        import api.dm.kit.sprites.layouts.hlayout : HLayout;

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

            auto currStyle = createDefaultStyle;
            if (!currStyle.isNested)
            {
                currStyle.lineColor = graphics.theme.colorAccent;
                currStyle.isFill = true;
                currStyle.fillColor = graphics.theme.colorAccent;
            }

            if (capGraphics.isVectorGraphics)
            {
                import api.dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

                return new VRegularPolygon(w, h, currStyle, graphics.theme.controlCornersBevel);
            }
            else
            {
                import api.dm.kit.sprites.shapes.regular_polygon : RegularPolygon;

                return new RegularPolygon(w, h, currStyle, graphics.theme.controlCornersBevel);
            }
        };

        switchHandleFactory = () {
            import api.dm.kit.sprites.shapes.regular_polygon : RegularPolygon;

            auto currStyle = createDefaultStyle;
            double w = width / 2;
            double h = height;

            if (capGraphics.isVectorGraphics)
            {
                import api.dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

                return new VRegularPolygon(w, h, currStyle, graphics.theme.controlCornersBevel);
            }
            else
            {
                import api.dm.kit.sprites.shapes.regular_polygon : RegularPolygon;

                return new RegularPolygon(w, h, currStyle, graphics
                        .theme.controlCornersBevel);
            }
        };

        switchOnAnimationFactory = () {
            import api.math.vector2 : Vector2;
            import api.dm.kit.sprites.transitions.objects.motions.linear_motion : LinearMotion;
            import api.math.interps.uni_interpolator : UniInterpolator;

            auto uniInterp = new UniInterpolator;
            uniInterp.interpolateMethod = &uniInterp.quadInOut;

            auto end = Vector2(bounds.right - switchHandle.width, bounds.y);
            auto animation = new LinearMotion(Vector2(x, y), end, 200, uniInterp);
            animation.addObject(switchHandle);
            animation.isCycle = false;
            return animation;
        };

        switchOffAnimationFactory = () {
            import api.math.vector2 : Vector2;
            import api.dm.kit.sprites.transitions.objects.motions.linear_motion : LinearMotion;
            import api.math.interps.uni_interpolator : UniInterpolator;

            auto start = Vector2(bounds.right - switchHandle.width, y);
            auto uniInterp = new UniInterpolator;
            uniInterp.interpolateMethod = &uniInterp.quadInOut;
            auto animation = new LinearMotion(start, Vector2(x, y), 200, uniInterp);
            animation.addObject(switchHandle);
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
        import api.dm.gui.containers.container;
        import api.dm.kit.sprites.layouts.managed_layout : ManagedLayout;

        switchContainer = new Container;

        switchContainer.layout = new ManagedLayout;
        import api.math.insets : Insets;

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

            import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

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
