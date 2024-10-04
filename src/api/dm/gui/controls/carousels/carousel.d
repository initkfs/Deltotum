module api.dm.gui.controls.carousels.carousel;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.buttons.button : Button;
import api.dm.kit.sprites.layouts.hlayout : HLayout;
import api.dm.kit.sprites.layouts.vlayout : VLayout;
import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.transitions.transition : Transition;
import api.dm.kit.sprites.transitions.min_max_transition : MinMaxTransition;
import api.math.geom2.vec2 : Vec2d;

import std.conv : to;
import api.math.numericals.interp;
import Math = api.math;

enum CarouselDirection
{
    fromLeft,
    fromRight
}

/**
 * Authors: initkfs
 */
class Carousel : Control
{
    protected
    {
        Sprite[] _items;
        size_t currentItemIndex;
        Container itemContainer;

        MinMaxTransition!double animation;

        CarouselDirection direction = CarouselDirection.fromRight;

        Sprite current;
        Sprite prev;
    }

    bool isInfinite = true;

    this(Sprite[] newItems)
    {
        this._items = newItems;

        layout = new HLayout(5);
        layout.isAlignY = true;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        import api.dm.kit.sprites.transitions.curves.uni_interpolator : UniInterpolator;

        animation = new MinMaxTransition!double(0.0, 1.0, 500);
        animation.interpolator.interpolateMethod = &UniInterpolator.circIn;
        addCreate(animation);

        animation.onOldNewValue ~= (oldValue, newValue) {

            //auto dx = Math.abs(newValue - oldValue) * itemContainer.width;
            double dx = 0;
            if (direction == CarouselDirection.fromRight)
            {
                dx = -((current.x - itemContainer.x) * newValue);
            }
            else if (direction == CarouselDirection.fromLeft)
            {
                dx = (itemContainer.x - current.x) * newValue;
            }

            if (current)
            {
                current.x = current.x + dx;
            }

            if (prev)
            {
                prev.x = prev.x + dx;
            }
        };

        animation.onEnd ~= () {

            if (prev)
            {
                prev.isVisible = false;
                prev = null;
            }

            if (current.x != itemContainer.x)
            {
                current.x = itemContainer.x;
            }
        };

        Button prevButton = new Button("<");
        addCreate(prevButton);

        prevButton.onAction = (ref e) {
            direction = CarouselDirection.fromLeft;
            showNextItem;
        };

        double maxItemWidth = width;
        double maxItemHeight = height;
        if (_items.length > 0)
        {
            foreach (Sprite item; _items)
            {
                if (item.isLayoutManaged)
                {
                    item.isLayoutManaged = false;
                }

                //TODO correct resize after scene showing
                if (item.width > maxItemWidth)
                {
                    maxItemWidth = item.width;
                }

                if (item.height > maxItemHeight)
                {
                    maxItemHeight = item.width;
                }

                item.isVisible = false;
            }
        }

        assert(maxItemWidth > 0);
        assert(maxItemHeight > 0);

        itemContainer = new Container;
        itemContainer.isResizeChildrenIfNoLayout = false;
        itemContainer.isResizeChildrenIfNotLManaged = false;
        assert(itemContainer.width = maxItemWidth);
        assert(itemContainer.height = maxItemHeight);

        itemContainer.clipBounds;

        addCreate(itemContainer);

        foreach (item; _items)
        {
            itemContainer.addCreate(item);
        }

        Button nextButton = new Button(">");
        addCreate(nextButton);

        nextButton.onAction = (ref e) {
            direction = CarouselDirection.fromRight;
            showNextItem;
        };

        enableInsets;

        showItem;
    }

    protected void showItem(size_t index = 0)
    {

        assert(index < _items.length);

        currentItemIndex = index;

        current = _items[currentItemIndex];
        current.x = itemContainer.x;
        current.y = itemContainer.y;
        current.isVisible = true;

        prev = null;
    }

    protected void showNextItem()
    {
        if (animation.isRunning)
        {
            return;
        }

        if (current)
        {
            prev = current;
        }

        if (direction == CarouselDirection.fromLeft)
        {
            if (currentItemIndex == 0)
            {
                if(!isInfinite || _items.length <= 1){
                    return;
                }
                
                currentItemIndex = _items.length - 1;
            }

            currentItemIndex--;
            current = _items[currentItemIndex];
            current.x = itemContainer.x - current.bounds.width;
            current.y = itemContainer.y;
        }
        else if (direction == CarouselDirection.fromRight)
        {
            auto newIndex = currentItemIndex + 1;
            if (newIndex >= _items.length)
            {
                if(!isInfinite || _items.length <= 1){
                    return;
                }
                
                currentItemIndex = 0;
                newIndex = currentItemIndex;
            }

            currentItemIndex = newIndex;
            current = _items[currentItemIndex];

            current.x = itemContainer.bounds.right;
            current.y = itemContainer.y;
        }

        if (!current.isVisible)
        {
            current.isVisible = true;
        }

        animation.run;
    }

    Sprite currentItem()
    {
        assert(_items.length > 0);
        return _items[currentItemIndex];
    }
}
