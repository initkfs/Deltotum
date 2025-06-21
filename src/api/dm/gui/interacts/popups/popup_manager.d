module api.dm.gui.interacts.popups.popup_manager;

import api.dm.kit.sprites2d.sprite2d: Sprite2d;

/**
 * Authors: initkfs
 */
interface PopupManager
{
    void urgent(dstring text, bool delegate(Sprite2d) onPreShowPopupIsContinue = null);
    void notify(dstring text, bool delegate(Sprite2d) onPreShowPopupIsContinue = null);
}
