module api.dm.gui.controls.labels.hyperlink;

import api.dm.gui.controls.labeled : Labeled;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.popups.base_popup: BasePopup;
import api.dm.gui.controls.popups.text_popup : TextPopup;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Hyperlink : Labeled
{
    string url;

    bool isOpenBrowser;

    Sprite2d underline;
    double underlineHeight = 0;

    bool isCreateUnderline = true;
    Sprite2d delegate(Sprite2d) onNewUnderline;
    void delegate(Sprite2d) onCreatedUnderline;

    BasePopup urlPopup;
    bool isCreateUrlPopup = true;
    BasePopup delegate(BasePopup) onNewUrlPopup;
    void delegate(BasePopup) onCreatedUrlPopup;

    this(dstring text = "Hyperlink", string iconName = null, double graphicsGap = 0, bool isCreateLayout = true)
    {
        super(text, iconName, graphicsGap, isCreateLayout);
        _labelText = text;

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout(0);
        layout.isAutoResize = true;
    }

    override void initialize()
    {
        super.initialize;

        onPointerEnter ~= (ref e) {
            if (underline && underline.isVisible)
            {
                underline.isVisible = false;
            }
        };

        onPointerExit ~= (ref e) {
            if (underline && !underline.isVisible)
            {
                underline.isVisible = true;
            }
        };

        onPointerPress ~= (ref e) {
            if (!isOpenBrowser || url.length == 0)
            {
                return;
            }
            platform.openURL(url);
        };
    }

    override void loadTheme(){
        super.loadTheme;
        loadHyperlinkTheme;
    }

    void loadHyperlinkTheme(){
        if(underlineHeight == 0){
            underlineHeight = theme.dividerSize / 2;
        }
    }

    override void create()
    {
        super.create;

        if (!urlPopup && isCreateUrlPopup)
        {
            auto p = newUrlPopup(url.to!dstring);
            urlPopup = !onNewUrlPopup ? p : onNewUrlPopup(p);
            addCreate(urlPopup);

            installPopup(urlPopup);

            if (onCreatedUrlPopup)
            {
                onCreatedUrlPopup(urlPopup);
            }
        }

        if (!underline && isCreateUnderline)
        {
            auto ul = newUnderline;
            underline = !onNewUnderline ? ul : onNewUnderline(ul);

            underline.isHGrow = true;
            underline.width = width > 0 ? width : theme.controlDefaultWidth / 2;

            assert(underlineHeight > 0);
            underline.height = underlineHeight;

            addCreate(underline);
            if (onCreatedUnderline)
            {
                onCreatedUnderline(underline);
            }
        }
    }

    Sprite2d newUnderline()
    {
        auto shape = theme.rectShape(width, theme.dividerSize, angle, createFillStyle);
        return shape;
    }

    BasePopup newUrlPopup(dstring text)
    {
        return new TextPopup(text);
    }

}
