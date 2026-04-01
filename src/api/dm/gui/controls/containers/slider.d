module api.dm.gui.controls.containers.slider;

import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.sprites2d.layouts.hlayout : HLayout;
import api.dm.kit.sprites2d.layouts.vlayout : VLayout;
import api.dm.gui.controls.containers.center_box : CenterBox;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.tweens.targets.motions.linear_motion : LinearMotion;
import api.dm.kit.sprites2d.tweens.tween2d : Tween2d;
import api.math.geom2.vec2 : Vec2f;
import Math = api.math;
import api.math.numericals.interp;

enum SliderPos
{
    left,
    top,
    bottom,
    right
}

/**
 * Authors: initkfs
 */
class Slider : Container
{
    protected
    {
        SliderPos position;
        Sprite2d _handle;
        CenterBox _content;
        LinearMotion motionAnimation;
        bool _expanded;
    }

    this(SliderPos position = SliderPos.left, bool expand = false)
    {
        if (position == SliderPos.left || position == SliderPos.right)
        {
            layout = new HLayout(0);
            layout.isAlignY = true;
        }
        else
        {
            layout = new VLayout(0);
            layout.isAlignX = true;
        }

        if (position == SliderPos.left || position == SliderPos.top)
        {
            layout.isFillStartToEnd = false;
        }

        layout.isAutoResize = true;

        this.position = position;

        _expanded = expand;
    }

    override void create()
    {
        super.create;

        padding = 0;

        import api.dm.kit.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        float handleWidth = 30;
        float handleHeight = 10;
        if (position == SliderPos.left || position == SliderPos.right)
        {
            import std.algorithm.mutation : swap;

            swap(handleWidth, handleHeight);
        }

        _handle = new VConvexPolygon(handleWidth, handleHeight, GraphicStyle(1, theme.colorAccent, true, theme
                .colorAccent), 3);
        addCreate(_handle);

        _content = new CenterBox;
        addCreate(_content);

        motionAnimation = new LinearMotion(Vec2f(0, 0), Vec2f(0, 0));
        addCreate(motionAnimation);
        motionAnimation.addTarget(this);

        _handle.onPointerPress ~= (ref e) {
            if (motionAnimation && motionAnimation.isRunning)
            {
                return;
            }
            toggle;
        };

        setWindowInitialPos;
        if (_expanded)
        {
            window.showingTasks ~= (dt) { switchStateForce(true); };
        }
    }

    void toggle()
    {
        switchState(!_expanded);
    }

    bool isAnimationRunning() => motionAnimation && motionAnimation.isRunning;
    bool canSwitchState() => !isAnimationRunning;

    bool switchState(bool expand)
    {
        if (_expanded == expand)
        {
            return false;
        }

        return switchStateForce(expand);
    }

    bool switchStateForce(bool expand)
    {
        if (isAnimationRunning)
        {
            motionAnimation.stop;
            if (!_expanded)
            {
                setStartPos;
            }
            else
            {
                Vec2f endPoint = getEndPointPanel(true);
                x = endPoint.x;
                y = endPoint.y;
            }
        }

        _expanded = expand;

        //TODO remove switch?
        Vec2f endPoint = getEndPointPanel(expand);
        motionAnimation.minValue = Vec2f(x, y);
        motionAnimation.maxValue = endPoint;
        motionAnimation.run;

        return true;
    }

    protected Vec2f getEndPointPanel(bool expand)
    {
        Vec2f endPoint;
        Vec2f offset = getMotionOffset;
        auto offsetX = offset.x;
        auto offsetY = offset.y;

        if (!expand)
        {
            offsetX = -offsetX;
            offsetY = -offsetY;
        }

        final switch (position) with (SliderPos)
        {
            case left:
                endPoint = Vec2f(x + offsetX, y);
                break;
            case top:
                endPoint = Vec2f(x, y + offsetY);
                break;
            case bottom:
                endPoint = Vec2f(x, y - offsetY);
                break;
            case right:
                endPoint = Vec2f(x - offsetX, y);
                break;
        }

        return endPoint;
    }

    bool isExpand() => _expanded;

    void expand()
    {
        switchState(expand : true);
    }

    void collapse()
    {
        switchState(expand : false);
    }

    protected Vec2f getMotionOffset()
    {
        Vec2f sceneBoundsEx = checkSceneBoundsExceed;
        auto offsetX = sliderWidth - handle.width;
        auto offsetY = sliderHeight - handle.height;
        if (sceneBoundsEx.x > 0 && sceneBoundsEx.x < offsetX)
        {
            offsetX -= sceneBoundsEx.x;
        }

        if (sceneBoundsEx.y > 0 && sceneBoundsEx.y < offsetY)
        {
            offsetY -= sceneBoundsEx.y;
        }
        return Vec2f(offsetX, offsetY);
    }

    protected Vec2f checkSceneBoundsExceed()
    {
        float dx = 0, dy = 0;
        const sceneBounds = graphic.renderBounds;
        if (sliderWidth > sceneBounds.width)
        {
            dx = width - sceneBounds.width;
        }
        if (sliderHeight > sceneBounds.height)
        {
            dy = height - sceneBounds.height;
        }
        return Vec2f(dx, dy);
    }

    protected float sliderWidth() => Math.max(_content.width, width);
    protected float sliderHeight() => Math.max(_content.height, height);

    void setWindowInitialPos()
    {
        window.showingTasks ~= (dt) { setStartPos; };
    }

    void setStartPos()
    {
        import api.math.geom2.rect2 : Rect2f;

        float newX = 0, newY = 0;
        const Rect2f sceneBounds = graphic.renderBounds;

        final switch (position) with (SliderPos)
        {
            case left:
                newX = sceneBounds.x - sliderWidth + _handle.width;
                newY = sceneBounds.y;
                break;
            case right:
                newX = sceneBounds.right - _handle.width;
                newY = sceneBounds.y;
                break;
            case top:
                newX = sceneBounds.x;
                newY = sceneBounds.y - sliderHeight + _handle.height;
                break;
            case bottom:
                newX = sceneBounds.x;
                newY = sceneBounds.bottom - _handle.height;
                break;

        }
        x = newX;
        y = newY;
    }

    void addContent(Sprite2d newContent)
    {
        assert(_content);
        //TODO replace?
        _content.addCreate(newContent);
    }

    Sprite2d content() => _content;
    Sprite2d handle() => _handle;
}
