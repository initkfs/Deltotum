module api.dm.gui.controls.popups.gui_popup_manager;

import api.dm.kit.interacts.popups.popup_manager : PopupManager;
import api.dm.gui.containers.container : Container;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.controls.texts.text : Text;
import api.math.rect2d : Rect2d;
import api.dm.kit.sprites.transitions.objects.props.opacity_transition: OpacityTransition;

class Popup : VBox
{

    Text text;

    this(){
        isBackground = true;
        isBorder = true;

        _width = 200;
        _height = 60;
    }

    override void create()
    {
        super.create;

        text = new Text;
        addCreate(text);

        onPointerDown ~= (ref e){
            isVisible = false;
            e.isConsumed = true;
        };

        isVisible = false;
    }

}

/**
 * Authors: initkfs
 */
class GuiPopupManager : Container, PopupManager
{
    Popup[] popupsPool;

    double spacing = 5;

    void popup(dstring message)
    {

        Popup freePopup;
        foreach (Popup p; popupsPool)
        {
            if (!p.isVisible)
            {
                freePopup = p;
            }
        }

        if (!freePopup)
        {
            auto newPopup = new Popup;
            newPopup.isLayoutManaged = false;
            newPopup.isVisible = false;
            addCreate(newPopup);
            popupsPool ~= newPopup;
            freePopup = newPopup;
            newPopup.isDrawByParent = false;
            window.scenes.currentScene.controlledSprites ~= newPopup;
        }

        freePopup.text.text = message;

        auto sceneBounds = window.bounds;
        auto px = sceneBounds.x;
        auto py = sceneBounds.y;

        freePopup.x = px;
        freePopup.y = py;

        freePopup.isVisible = true;
    }
}
