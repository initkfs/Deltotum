module api.dm.gui.controls.popups.gui_popup_manager;

import api.dm.kit.interacts.popups.popup_manager : PopupManager;
import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.controls.texts.text : Text;
import api.math.geom2.rect2 : Rect2d;
import api.dm.kit.sprites.sprites2d.tweens.targets.props.opacity_tween2d : OpacityTween2d;
import api.dm.kit.sprites.sprites2d.tweens.pause_tween2d : PauseTween2d;
import api.dm.kit.sprites.sprites2d.tweens.tween2d : Tween2d;

class Popup : VBox
{
    Text text;

    void delegate() onClose;

    Tween2d showAnimation;
    Tween2d hideAnimation;
    PauseTween2d hideDelayAnimation;

    bool isAutoClose;

    protected
    {
        size_t _autoCloseDelayMS = 2000;
    }

    bool isClosed;

    this()
    {
        isBackground = true;
        isBorder = true;
        isOpacityForChildren = true;
        isLayoutManaged = false;

        //_width = 200;
        //_height = 50;
    }

    override void create()
    {
        super.create;

        auto newShowAnimation = new OpacityTween2d(800);
        newShowAnimation.addTarget(this);
        addCreate(newShowAnimation);
        showAnimation = newShowAnimation;

        newShowAnimation.onEnd ~= () {
            if (isAutoClose && !hideDelayAnimation.isRunning)
            {
                hideDelayAnimation.run;
            }
        };

        auto newHideAnimation = new OpacityTween2d(800, isReverse:
            true);
        newHideAnimation.addTarget(this);
        addCreate(newHideAnimation);

        hideAnimation = newHideAnimation;

        //lazy
        assert(_autoCloseDelayMS > 0);
        hideDelayAnimation = new PauseTween2d(_autoCloseDelayMS);
        addCreate(hideDelayAnimation);

        hideDelayAnimation.onEnd ~= () { close; };

        enableInsets;

        text = new Text;
        text.isFocusable = false;
        addCreate(text);

        opacity = 0;

        //not onPointerPress, prevent accidental click on element under.
        onPointerRelease ~= (ref e) {

            if (showAnimation.isRunning)
            {
                return;
            }
            e.isConsumed = true;

            close;
        };

        isVisible = false;
    }

    void open()
    {
        if (showAnimation && !showAnimation.isRunning)
        {
            showAnimation.run;
        }
    }

    void close()
    {
        isVisible = false;
        isManaged = false;
        isLayoutManaged = false;
        if (onClose && !isClosed)
        {
            onClose();
        }

        isClosed = true;
    }

    void autoCloseDelayMS(size_t v)
    {
        assert(v > 0);
        _autoCloseDelayMS = v;
        if (hideDelayAnimation)
        {
            hideDelayAnimation.timeMs = _autoCloseDelayMS;
        }
    }

}

import api.dm.gui.containers.base.typed_container : TypedContainer;
import api.dm.kit.sprites.sprites2d.layouts.vlayout : VLayout;
import api.core.utils.arrays : drop;

import std.container.dlist : DList;

/**
 * Authors: initkfs
 */
class GuiPopupManager : Container, PopupManager
{
    Popup[] popupsPool;

    DList!Popup activeNotifyPopups;
    DList!Popup activeUrgentPopups;

    size_t popupSpacing = 5;

    bool isNewPopupShowFirst;

    bool isAutoCloseNotify = true;
    bool isAutoCloseUrgent = true;
    size_t autoCloseNotifyDelayMS = 3000;
    size_t autoCloseUrgentDelayMS = 5000;

    protected
    {
        size_t activeNotifyPopupsCount;
        size_t activeUrgentPopupsCount;
    }

    double spacing = 5;

    this(){
        isLayoutManaged = false;
    }

    override void create()
    {
        super.create;

    }

    override void applyLayout()
    {
        super.applyLayout;
        if (activeNotifyPopupsCount > 0)
        {
            double nextX = 0, nextY = 0;
            foreach (Popup popup; activeNotifyPopups[])
            {
                popup.x = nextX;
                popup.y = nextY;

                nextY += popup.height;
                nextY += popupSpacing;
            }
        }

        if (activeUrgentPopupsCount > 0)
        {
            auto middleBounds = graphics.renderBounds;
            double nextX = middleBounds.middleX;
            double nextY = middleBounds.middleY;
            foreach (Popup popup; activeUrgentPopups[])
            {
                popup.x = nextX - popup.boundsRect.halfWidth;
                popup.y = nextY - popup.boundsRect.halfHeight;

                nextY += popup.height;
                nextY += popupSpacing;
            }
        }

    }

    protected Popup freeOrNewPopup()
    {
        Popup freePopup;
        foreach (Popup popup; popupsPool)
        {
            if (!popup.isVisible)
            {
                freePopup = popup;
                break;
            }
        }

        if (!freePopup)
        {
            auto newPopup = new Popup;
            newPopup.isLayoutManaged = false;
            newPopup.isVisible = false;
            newPopup.isDrawByParent = false;
            addCreate(newPopup);
            popupsPool ~= newPopup;
            window.currentScene.controlledSprites ~= newPopup;
            freePopup = newPopup;
        }

        freePopup.isClosed = false;

        return freePopup;
    }

    protected Popup freeOrNewNotifyPopup()
    {
        auto popup = freeOrNewPopup;

        if (isAutoCloseNotify)
        {
            popup.isAutoClose = true;
            popup.autoCloseDelayMS = autoCloseNotifyDelayMS;
        }
        else
        {
            popup.isAutoClose = false;
        }

        popup.onClose = () {
            bool isRemoved = activeNotifyPopups.linearRemoveElement(popup);
            if (isRemoved)
            {
                assert(activeNotifyPopupsCount > 0);
                activeNotifyPopupsCount--;
            }

        };
        return popup;
    }

    protected Popup freeOrNewUrgentPopup()
    {
        auto popup = freeOrNewPopup;

        if (isAutoCloseUrgent)
        {
            popup.isAutoClose = true;
            popup.autoCloseDelayMS = autoCloseUrgentDelayMS;
        }
        else
        {
            popup.isAutoClose = false;
        }

        popup.onClose = () {
            bool isRemoved = activeUrgentPopups.linearRemoveElement(popup);
            if (isRemoved)
            {
                assert(activeUrgentPopupsCount > 0);
                activeUrgentPopupsCount--;
            }
        };
        return popup;
    }

    void showPopup(Popup popup)
    {
        popup.isVisible = true;
        popup.opacity = 0;
        popup.showAnimation.run;
    }

    void urgent(dstring message, bool delegate(Sprite2d) onPreShowPopupIsContinue = null)
    {
        auto popup = freeOrNewUrgentPopup;

        popup.text.text = message;

        if (!onPreShowPopupIsContinue || onPreShowPopupIsContinue(popup))
        {
            addUrgentPopup(popup);
        }

        showPopup(popup);
    }

    void notify(dstring message, bool delegate(Sprite2d) onPreShowPopupIsContinue = null)
    {
        auto popup = freeOrNewNotifyPopup;

        popup.text.text = message;

        if (!onPreShowPopupIsContinue || onPreShowPopupIsContinue(popup))
        {
            addNotifyPopup(popup);
        }

        showPopup(popup);
    }

    protected void addNotifyPopup(Popup popup)
    {
        if (isNewPopupShowFirst)
        {
            activeNotifyPopups.insertFront(popup);
        }
        else
        {
            activeNotifyPopups.insertBack(popup);
        }
        activeNotifyPopupsCount++;
    }

    protected void addUrgentPopup(Popup popup)
    {
        if (isNewPopupShowFirst)
        {
            activeUrgentPopups.insertFront(popup);
        }
        else
        {
            activeUrgentPopups.insertBack(popup);
        }
        activeUrgentPopupsCount++;
    }
}
