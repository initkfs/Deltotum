module api.dm.kit.interacts.popups.popup_manager;

import api.dm.kit.sprites.sprite: Sprite;

/**
 * Authors: initkfs
 */
interface PopupManager
{
    void urgent(dstring text, bool delegate(Sprite) onPreShowPopupIsContinue = null);
    void notify(dstring text, bool delegate(Sprite) onPreShowPopupIsContinue = null);
}
