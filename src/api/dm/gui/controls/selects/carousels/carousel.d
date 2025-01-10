module api.dm.gui.controls.selects.carousels.carousel;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.selects.base_selector : BaseSelector;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.switches.buttons.navigate_button : NavigateButton;
import api.dm.kit.sprites2d.layouts.hlayout : HLayout;
import api.dm.kit.sprites2d.layouts.vlayout : VLayout;
import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.sprites2d.tweens.tween2d : Tween2d;
import api.dm.kit.sprites2d.tweens.min_max_tween2d : MinMaxTween2d;
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
class Carousel : BaseSelector!Sprite2d
{
    size_t itemChangeDuration = 500;
    MinMaxTween2d!double itemChangeAnimation;
    bool isCreateItemChangeAnimation = true;
    MinMaxTween2d!double delegate(MinMaxTween2d!double) onNewItemChangeAnimation;
    void delegate(MinMaxTween2d!double) onCreatedItemChangeAnimation;

    Button prevButton;
    bool isCreatePrevButton = true;
    Button delegate(Button) onNewPrevButton;
    void delegate(Button) onCreatedPrevButton;

    Button nextButton;
    bool isCreateNextButton = true;
    Button delegate(Button) onNewNextButton;
    void delegate(Button) onCreatedNextButton;

    Container itemContainer;
    bool isCreateItemContainer = true;
    Container delegate(Container) onNewItemContainer;
    void delegate(Container) onCreatedItemContainer;

    double itemWidth = 0;
    double itemHeight = 0;

    bool isPreciseMove;

    protected
    {
        Sprite2d[] _items;
        Sprite2d _prev;

        size_t currentItemIndex;
        CarouselDirection direction = CarouselDirection.fromRight;
    }

    bool isInfinite = true;

    this(Sprite2d[] newItems)
    {
        this._items = newItems;

        layout = new HLayout;
        layout.isAlignY = true;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        if (!itemChangeAnimation && isCreateItemChangeAnimation)
        {
            auto newAnim = newItemChangeAnimation;
            itemChangeAnimation = !onNewItemChangeAnimation ? newAnim : onNewItemChangeAnimation(
                newAnim);

            itemChangeAnimation.onOldNewValue ~= (oldValue, newValue) {

                auto itemRoot = itemRootContainer;

                //auto dx = Math.abs(newValue - oldValue) * itemContainer.width;
                double dx = 0;
                if (direction == CarouselDirection.fromRight)
                {
                    dx = -((selected.x - itemRoot.x) * newValue);
                }
                else if (direction == CarouselDirection.fromLeft)
                {
                    dx = (itemRoot.x - selected.x) * newValue;
                }

                if (selected)
                {
                    selected.x = selected.x + dx;
                }

                if (_prev)
                {
                    _prev.x = _prev.x + dx;
                }
            };

            itemChangeAnimation.onEnd ~= () {

                auto itemRoot = itemRootContainer;

                if (_prev)
                {
                    _prev.isVisible = false;
                    _prev = null;
                }

                if (isPreciseMove && selected.x != itemRoot.x)
                {
                    selected.x = itemRoot.x;
                }
            };

            addCreate(itemChangeAnimation);
            if (onCreatedItemChangeAnimation)
            {
                onCreatedItemChangeAnimation(itemChangeAnimation);
            }
        }

        if (!prevButton && isCreatePrevButton)
        {
            auto newButton = newPrevButton;
            prevButton = !onNewPrevButton ? newButton : onNewPrevButton(newButton);

            prevButton.onAction ~= (ref e) {
                direction = CarouselDirection.fromLeft;
                showNextItem;
            };

            addCreate(prevButton);
            if (onCreatedPrevButton)
            {
                onCreatedPrevButton(prevButton);
            }
        }

        if (!itemContainer && isCreateItemContainer)
        {
            double maxItemWidth = itemWidth;
            double maxItemHeight = itemHeight;

            if (maxItemWidth == 0 || maxItemHeight == 0)
            {
                if (!prepareItems(maxItemWidth, maxItemHeight))
                {
                    logger.errorf(
                        "Error getting  displayed items size. Item width: %s, height: %s, calculated width %s, height: %s", itemWidth, itemHeight, maxItemWidth, maxItemHeight);
                }
            }

            assert(maxItemWidth > 0);
            assert(maxItemHeight > 0);

            auto newContainer = newItemContainer(maxItemWidth, maxItemHeight);
            itemContainer = !onNewItemContainer ? newContainer : onNewItemContainer(newContainer);

            itemContainer.isResizeChildrenIfNoLayout = false;
            itemContainer.isResizeChildrenIfNotLManaged = false;
            if (itemContainer.width != maxItemWidth)
            {
                auto isResize = (itemContainer.width = maxItemWidth);
                assert(isResize);
            }

            if (itemContainer.height != maxItemHeight)
            {
                auto isResize = itemContainer.height = maxItemHeight;
                assert(isResize);
            }

            itemContainer.setClipFromBounds;

            addCreate(itemContainer);
            if (onCreatedItemContainer)
            {
                onCreatedItemContainer(itemContainer);
            }
        }

        if (!nextButton && isCreateNextButton)
        {
            auto newButton = newNextButton;
            nextButton = !onNewNextButton ? newButton : onNewNextButton(newButton);

            nextButton.onAction ~= (ref e) {
                direction = CarouselDirection.fromRight;
                showNextItem;
            };

            addCreate(nextButton);
            if (onCreatedNextButton)
            {
                onCreatedNextButton(nextButton);
            }
        }

        if (itemContainer)
        {
            foreach (item; _items)
            {
                itemContainer.addCreate(item);
            }
        }

        enableInsets;

        showItem;
    }

    Container newItemContainer(double maxItemWidth, double maxItemHeight)
    {
        return new Container;
    }

    MinMaxTween2d!double newItemChangeAnimation()
    {
        auto animation = new MinMaxTween2d!double(0.0, 1.0, itemChangeDuration);

        import api.dm.kit.tweens.curves.uni_interpolator : UniInterpolator;

        animation.interpolator.interpolateMethod = &UniInterpolator.circIn;
        return animation;
    }

    Button newPrevButton()
    {
        return NavigateButton.newHPrevButton;
    }

    Button newNextButton()
    {
        return NavigateButton.newHNextButton;
    }

    protected bool prepareItems(out double maxWidth, out double maxHeight)
    {
        if (_items.length == 0)
        {
            maxWidth = width;
            maxHeight = height;
            return false;
        }

        double maxItemWidth = 0;
        double maxItemHeight = 0;

        foreach (Sprite2d item; _items)
        {
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

        bool isSuccess = true;

        if (maxItemWidth == 0)
        {
            maxItemWidth = width;
            isSuccess = false;
        }

        if (maxItemHeight == 0)
        {
            maxItemHeight = height;
            isSuccess = false;
        }

        maxWidth = maxItemWidth;
        maxHeight = maxItemHeight;

        return isSuccess;
    }

    protected void showItem(size_t index = 0)
    {
        assert(index < _items.length);

        currentItemIndex = index;

        auto itemRoot = itemRootContainer;

        auto newItem = _items[currentItemIndex];

        if (!select(newItem))
        {
            return;
        }

        selected.x = itemRoot.x;
        selected.y = itemRoot.y;
        selected.isVisible = true;

        _prev = null;
    }

    protected void showNextItem()
    {
        if (itemChangeAnimation.isRunning)
        {
            return;
        }

        if (selected)
        {
            _prev = selected;
        }

        auto itemRoot = itemRootContainer;

        if (direction == CarouselDirection.fromLeft)
        {
            if (currentItemIndex == 0)
            {
                if (!isInfinite || _items.length <= 1)
                {
                    return;
                }

                currentItemIndex = _items.length - 1;
            }

            currentItemIndex--;
            auto newItem = _items[currentItemIndex];
            if (select(newItem))
            {
                selected.x = itemRoot.x - selected.boundsRect.width;
                selected.y = itemRoot.y;
            }
        }
        else if (direction == CarouselDirection.fromRight)
        {
            auto newIndex = currentItemIndex + 1;
            if (newIndex >= _items.length)
            {
                if (!isInfinite || _items.length <= 1)
                {
                    return;
                }

                currentItemIndex = 0;
                newIndex = currentItemIndex;
            }

            currentItemIndex = newIndex;
            auto newItem = _items[currentItemIndex];
            if (select(newItem))
            {
                selected.x = itemRoot.boundsRect.right;
                selected.y = itemRoot.y;
            }
        }

        if (selected && !selected.isVisible)
        {
            selected.isVisible = true;
        }

        itemChangeAnimation.run;
    }

    Sprite2d itemRootContainer() => itemContainer ? itemContainer : this;

    Sprite2d currentItem()
    {
        assert(_items.length > 0);
        auto item = _items[currentItemIndex];
        assert(item == selected);
        return item;
    }
}
