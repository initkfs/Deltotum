module api.dm.gui.containers.slider;

import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.sprites2d.layouts.hlayout : HLayout;
import api.dm.kit.sprites.sprites2d.layouts.vlayout : VLayout;
import api.dm.gui.containers.stack_box : StackBox;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites.sprites2d.tweens2.targets.motions.linear_motion : LinearMotion;
import api.dm.kit.sprites.sprites2d.tweens2.tween2d : Tween2d;
import api.math.geom2.vec2 : Vec2d;
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
        StackBox _content;
        LinearMotion motionAnimation;
        bool _expanded;
    }

    this(SliderPos position = SliderPos.left, bool expand = false)
    {
        layout = (position == SliderPos.left || position == SliderPos.right) ? new HLayout(0) : new VLayout(
            0);
        layout.isAutoResize = true;
        layout.isAlignX = true;
        layout.isAlignY = true;

        this.position = position;

        _expanded = expand;
    }

    override void create()
    {
        super.create;

        padding = 0;

        import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        double handleWidth = 30;
        double handleHeight = 10;
        if (position == SliderPos.left || position == SliderPos.right)
        {
            import std.algorithm.mutation : swap;

            swap(handleWidth, handleHeight);
        }

        _handle = new VConvexPolygon(handleWidth, handleHeight, GraphicStyle(1, theme.colorAccent, true, theme.colorAccent), 3);
        addCreate(_handle);

        _content = new StackBox;
        addCreate(_content);

        motionAnimation = new LinearMotion(Vec2d(0, 0), Vec2d(0, 0));
        addCreate(motionAnimation);
        motionAnimation.addTarget(this);

        if (position == SliderPos.left || position == SliderPos.top)
        {
            layout.isFillFromStartToEnd = false;
        }

        _handle.onPointerDown ~= (ref e) {
            if (motionAnimation && motionAnimation.isRunning)
            {
               return;
            }
            toggle;
        };

        setWindowInitialPos;
        if (_expanded)
        {
            window.showingTasks ~= (dt) { expand; };
        }
    }

    void toggle()
    {
        switchState(!_expanded);
    }

    bool isAnimationRunning() => motionAnimation && motionAnimation.isRunning;

    bool canSwitchState() => !isAnimationRunning; 

    void switchState(bool expand)
    {
        if (_expanded == expand)
        {
            return;
        }

        if (isAnimationRunning)
        {
            motionAnimation.stop;
            if(!_expanded){
                setInitialPos;
            }else {
                Vec2d endPoint = getEndPointPanel(true);
                x = endPoint.x;
                y = endPoint.y;
            }
        }

        _expanded = expand;

        //TODO remove switch?
        Vec2d endPoint = getEndPointPanel(expand);
        motionAnimation.minValue = Vec2d(x, y);
        motionAnimation.maxValue = endPoint;
        motionAnimation.run;
    }

    protected Vec2d getEndPointPanel(bool expand){
        Vec2d endPoint;
        Vec2d offset = getMotionOffset;
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
                endPoint = Vec2d(x + offsetX, y);
                break;
            case top:
                endPoint = Vec2d(x, y + offsetY);
                break;
            case bottom:
                endPoint = Vec2d(x, y - offsetY);
                break;
            case right:
                endPoint = Vec2d(x - offsetX, y);
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

    protected Vec2d getMotionOffset()
    {
        Vec2d sceneBoundsEx = checkSceneBoundsExceed;
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
        return Vec2d(offsetX, offsetY);
    }

    protected Vec2d checkSceneBoundsExceed()
    {
        double dx = 0, dy = 0;
        const sceneBounds = graphics.renderBounds;
        if (sliderWidth > sceneBounds.width)
        {
            dx = width - sceneBounds.width;
        }
        if (sliderHeight > sceneBounds.height)
        {
            dy = height - sceneBounds.height;
        }
        return Vec2d(dx, dy);
    }

    protected double sliderWidth()
    {
        return Math.max(_content.width, width);
    }

    protected double sliderHeight()
    {
        return Math.max(_content.height, height);
    }

    void setWindowInitialPos()
    {
        assert(window);
        window.showingTasks ~= (dt) { setInitialPos; };
    }

    void setInitialPos()
    {
        import api.math.geom2.rect2 : Rect2d;

        double newX = 0, newY = 0;
        const Rect2d sceneBounds = graphics.renderBounds;

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

    Sprite2d content()
    {
        return _content;
    }

    Sprite2d handle()
    {
        return _handle;
    }
}
