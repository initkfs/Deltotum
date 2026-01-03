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
import api.dm.kit.sprites2d.tweens.min_max_tween : MinMaxTween;
import api.math.geom2.vec2 : Vec2f;

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
    MinMaxTween!float itemChangeAnimation;
    bool isCreateItemChangeAnimation = true;
    MinMaxTween!float delegate(MinMaxTween!float) onNewItemChangeAnimation;
    void delegate(MinMaxTween!float) onConfiguredItemChangeAnimation;
    void delegate(MinMaxTween!float) onCreatedItemChangeAnimation;

    Button prevButton;
    bool isCreatePrevButton = true;
    Button delegate(Button) onNewPrevButton;
    void delegate(Button) onConfiguredPrevButton;
    void delegate(Button) onCreatedPrevButton;

    Button nextButton;
    bool isCreateNextButton = true;
    Button delegate(Button) onNewNextButton;
    void delegate(Button) onConfiguredNextButton;
    void delegate(Button) onCreatedNextButton;

    Container itemContainer;
    bool isCreateItemContainer = true;
    Container delegate(Container) onNewItemContainer;
    void delegate(Container) onConfiguredItemContainer;
    void delegate(Container) onCreatedItemContainer;

    float itemWidth = 0;
    float itemHeight = 0;

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
                float dx = 0;
                if (direction == CarouselDirection.fromRight)
                {
                    dx = -((current.x - itemRoot.x) * newValue);
                }
                else if (direction == CarouselDirection.fromLeft)
                {
                    dx = (itemRoot.x - current.x) * newValue;
                }

                if (current)
                {
                    current.x = current.x + dx;
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

                if (isPreciseMove && current.x != itemRoot.x)
                {
                    current.x = itemRoot.x;
                }
            };

            if (onConfiguredItemChangeAnimation)
            {
                onConfiguredItemChangeAnimation(itemChangeAnimation);
            }

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

            if (onConfiguredPrevButton)
            {
                onConfiguredPrevButton(prevButton);
            }

            addCreate(prevButton);
            if (onCreatedPrevButton)
            {
                onCreatedPrevButton(prevButton);
            }
        }

        if (!itemContainer && isCreateItemContainer)
        {
            float maxItemWidth = itemWidth;
            float maxItemHeight = itemHeight;

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

            itemContainer.isResizeChildIfNoLayout = false;
            itemContainer.isResizeChildIfNotManaged = false;
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

            if (onConfiguredItemContainer)
            {
                onConfiguredItemContainer(itemContainer);
            }

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

            if (onConfiguredNextButton)
            {
                onConfiguredNextButton(nextButton);
            }

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

        enablePadding;

        showItem;
    }

    Container newItemContainer(float maxItemWidth, float maxItemHeight)
    {
        return new Container;
    }

    MinMaxTween!float newItemChangeAnimation()
    {
        auto animation = new MinMaxTween!float(0.0, 1.0, itemChangeDuration);

        import api.dm.kit.sprites2d.tweens.curves.uni_interpolator : UniInterpolator;

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

    protected bool prepareItems(out float maxWidth, out float maxHeight)
    {
        if (_items.length == 0)
        {
            maxWidth = width;
            maxHeight = height;
            return false;
        }

        float maxItemWidth = 0;
        float maxItemHeight = 0;

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

        if (!current(newItem))
        {
            return;
        }

        current.x = itemRoot.x;
        current.y = itemRoot.y;
        current.isVisible = true;

        _prev = null;
    }

    protected void showNextItem()
    {
        if (itemChangeAnimation.isRunning)
        {
            return;
        }

        if (current)
        {
            _prev = current;
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
            if (current(newItem))
            {
                current.x = itemRoot.x - current.boundsRect.width;
                current.y = itemRoot.y;
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
            if (current(newItem))
            {
                current.x = itemRoot.boundsRect.right;
                current.y = itemRoot.y;
            }
        }

        if (current && !current.isVisible)
        {
            current.isVisible = true;
        }

        itemChangeAnimation.run;
    }

    Sprite2d itemRootContainer() => itemContainer ? itemContainer : this;

    Sprite2d currentItem()
    {
        assert(_items.length > 0);
        auto item = _items[currentItemIndex];
        assert(item == current);
        return item;
    }
}
