module api.dm.gui.containers.slider;

import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.layouts.hlayout : HLayout;
import api.dm.kit.sprites.layouts.vlayout : VLayout;
import api.dm.gui.containers.stack_box : StackBox;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.transitions.targets.motions.linear_motion : LinearMotion;
import api.dm.kit.sprites.transitions.transition : Transition;
import api.math.vector2 : Vector2;
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
        Sprite _handle;
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

        import api.dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        double handleWidth = 30;
        double handleHeight = 10;
        if (position == SliderPos.left || position == SliderPos.right)
        {
            import std.algorithm.mutation : swap;

            swap(handleWidth, handleHeight);
        }

        _handle = new VRegularPolygon(handleWidth, handleHeight, GraphicStyle(1, graphics.theme.colorAccent, true, graphics
                .theme.colorAccent), 3);
        addCreate(_handle);

        _content = new StackBox;
        addCreate(_content);

        motionAnimation = new LinearMotion(Vector2(0, 0), Vector2(0, 0));
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
                Vector2 endPoint = getEndPointPanel(true);
                x = endPoint.x;
                y = endPoint.y;
            }
        }

        _expanded = expand;

        //TODO remove switch?
        Vector2 endPoint = getEndPointPanel(expand);
        motionAnimation.minValue = Vector2(x, y);
        motionAnimation.maxValue = endPoint;
        motionAnimation.run;
    }

    protected Vector2 getEndPointPanel(bool expand){
        Vector2 endPoint;
        Vector2 offset = getMotionOffset;
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
                endPoint = Vector2(x + offsetX, y);
                break;
            case top:
                endPoint = Vector2(x, y + offsetY);
                break;
            case bottom:
                endPoint = Vector2(x, y - offsetY);
                break;
            case right:
                endPoint = Vector2(x - offsetX, y);
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

    protected Vector2 getMotionOffset()
    {
        Vector2 sceneBoundsEx = checkSceneBoundsExceed;
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
        return Vector2(offsetX, offsetY);
    }

    protected Vector2 checkSceneBoundsExceed()
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
        return Vector2(dx, dy);
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
        import api.math.rect2d : Rect2d;

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

    void addContent(Sprite newContent)
    {
        assert(_content);
        //TODO replace?
        _content.addCreate(newContent);
    }

    Sprite content()
    {
        return _content;
    }

    Sprite handle()
    {
        return _handle;
    }
}
