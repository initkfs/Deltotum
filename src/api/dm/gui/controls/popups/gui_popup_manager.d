module api.dm.gui.controls.popups.gui_popup_manager;

import api.dm.kit.interacts.popups.popup_manager : PopupManager;
import api.dm.gui.containers.container : Container;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.controls.texts.text : Text;
import api.math.rect2d : Rect2d;
import api.dm.kit.sprites.transitions.objects.props.opacity_transition : OpacityTransition;

class Popup : VBox
{

    Text text;
    void delegate() onClose;
    OpacityTransition animation;

    this()
    {
        isBackground = true;
        isBorder = true;
        isOpacityForChildren = true;

        _width = 200;
        _height = 50;
    }

    override void create()
    {
        super.create;

        animation = new OpacityTransition(800);
        animation.addObject(this);
        addCreate(animation);

        enableInsets;

        text = new Text;
        text.isFocusable = false;
        addCreate(text);

        opacity = 0;

        //not onPointerDown, prevent accidental click on element under.
        onPointerUp ~= (ref e) {

            if(animation.isRunning){
                return;
            }

            isVisible = false;
            isManaged = false;
            isLayoutManaged = false;
            e.isConsumed = true;

            if(onClose){
                onClose();
            }
        };

        isVisible = false;
    }

}

import api.dm.gui.containers.base.typed_container : TypedContainer;
import api.dm.kit.sprites.layouts.vlayout : VLayout;
import api.core.utils.arrays : drop;

import std.container.dlist : DList;

/**
 * Authors: initkfs
 */
class GuiPopupManager : Container, PopupManager
{
    Popup[] popupsPool;
    DList!Popup activePopups;
    DList!dstring messageQueue;

    size_t popupSpacing = 5;

    bool isNewPopupShowFirst;

    protected {
        size_t activePopupsCount;
    }

    double spacing = 5;

    override void create()
    {
        super.create;

    }

    override void applyLayout()
    {
        super.applyLayout;
        if(activePopupsCount == 0){
            return;
        }

        double nextX = 0, nextY = 0;
        foreach (Popup popup; activePopups[])
        {
            popup.x = nextX;
            popup.y = nextY;

            nextY += popup.height;
            nextY += popupSpacing;
        }
    }

    void popup(dstring message)
    {
        messageQueue.insertBack(message);

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
            window.scenes.currentScene.controlledSprites ~= newPopup;

            newPopup.onClose = (){
                bool isRemoved = activePopups.linearRemoveElement(newPopup);
                assert(isRemoved);
                assert(activePopupsCount > 0);
                activePopupsCount--;
            };

            freePopup = newPopup;
        }

        freePopup.text.text = message;
        if(isNewPopupShowFirst){
            activePopups.insertFront(freePopup);
        }else {
            activePopups.insertBack(freePopup);
        }
        
        freePopup.isVisible = true;
        freePopup.opacity = 0;
        freePopup.animation.run;
        activePopupsCount++;
    }
}
