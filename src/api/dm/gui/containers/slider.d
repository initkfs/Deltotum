module api.dm.gui.containers.slider;

import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.layouts.hlayout : HLayout;
import api.dm.kit.sprites.layouts.vlayout : VLayout;
import api.dm.gui.containers.stack_box : StackBox;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.transitions.objects.motions.linear_motion : LinearMotion;
import api.dm.kit.sprites.transitions.transition : Transition;
import api.math.vector2 : Vector2;

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

    this(SliderPos position = SliderPos.left)
    {
        layout = (position == SliderPos.left || position == SliderPos.right) ? new HLayout(0) : new VLayout(
            0);
        layout.isAutoResize = true;
        layout.isAlignX = true;
        layout.isAlignY = true;
        isDrawBounds = true;

        this.position = position;
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
        motionAnimation.addObject(this);

        if (position == SliderPos.left || position == SliderPos.top)
        {
            layout.isFillFromStartToEnd = false;
        }

        _handle.onPointerDown ~= (ref e) {
            if (motionAnimation && motionAnimation.isRunning)
            {
                return;
            }

            if (_expanded)
            {
                collapse;
            }
            else
            {
                expand;
            }
            _expanded = !_expanded;
        };
    }

    void toogle(bool isExpand = true)
    {
        //TODO remove switch?
        Vector2 endPoint;

        Vector2 offset = getMotionOffset;
        auto offsetX = offset.x;
        auto offsetY = offset.y;
        
        if(!isExpand){
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
        motionAnimation.minValue = Vector2(x, y);
        motionAnimation.maxValue = endPoint;
        motionAnimation.run;
    }

    void expand()
    {
        toogle(isExpand : true);
    }

    void collapse()
    {
        toogle(isExpand : false);
    }

    protected Vector2 getMotionOffset()
    {
        Vector2 sceneBoundsEx = checkSceneBoundsExceed;
        auto offsetX = _content.width;
        auto offsetY = _content.height;
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
        if (width > sceneBounds.width)
        {
            dx = width - sceneBounds.width;
        }
        if (height > sceneBounds.height)
        {
            dy = height - sceneBounds.height;
        }
        return Vector2(dx, dy);
    }

    void setInitialPos()
    {
        import api.math.rect2d : Rect2d;

        double newX = 0, newY = 0;
        const Rect2d sceneBounds = graphics.renderBounds;

        final switch (position) with (SliderPos)
        {
            case left:
                newX = sceneBounds.x - _content.width;
                newY = sceneBounds.y;
                break;
            case right:
                newX = sceneBounds.right - _handle.width;
                newY = sceneBounds.y;
                break;
            case top:
                newX = sceneBounds.x;
                newY = sceneBounds.y - _content.height;
                break;
            case bottom:
                newX = sceneBounds.x;
                newY = sceneBounds.bottom - _handle.height;
                break;

        }
        x = newX;
        y = newY;

        _expanded = false;
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
