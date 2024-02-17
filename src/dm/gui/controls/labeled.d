module dm.gui.controls.labeled;

import dm.gui.controls.control : Control;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.sprites.layouts.layout : Layout;
import dm.kit.sprites.layouts.hlayout : HLayout;

/**
 * Authors: initkfs
 */
class Labeled : Control
{
    private
    {
        string _iconName;
        Sprite _icon;
    }

    this(string iconName = null, double graphicsGap, bool isCreateLayout = true)
    {
        this._iconName = iconName;

        if (isCreateLayout)
        {
            this.layout = new HLayout(graphicsGap);
            this.layout.isAutoResizeAndAlignOne = true;
            this.layout.isAlignY = true;
        }

        isBorder = true;
    }

    override void create()
    {
        super.create;
        if (_iconName && capGraphics.isIconPack)
        {
            _icon = createIcon(_iconName);
            add(icon);
            _iconName = null;
        }
    }

    inout(Sprite) icon() inout
    out (_icon; _icon !is null)
    {
        return _icon;
    }

    override void dispose()
    {
        super.dispose;
        if (_icon && !_icon.isDisposed)
        {
            _icon.dispose;
        }
        _icon = null;
    }

}
