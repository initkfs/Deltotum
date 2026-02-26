module api.dm.gui.controls.labels.hyperlinks.hyperlink;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.labels.label : Label;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.popups.tooltips.base_tooltip : BaseTooltip;
import api.dm.gui.controls.popups.tooltips.text_tooltip : TextTooltip;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Hyperlink : Control
{
    string url;

    bool isOpenBrowser;

    Label label;
    bool isCreateLabel = true;
    Label delegate(Label) onNewLabel;
    void delegate(Label) onConfiguredLabel;
    void delegate(Label) onCreatedLabel;

    Sprite2d underline;
    float underlineHeight = 0;

    bool isCreateUnderline = true;
    Sprite2d delegate(Sprite2d) onNewUnderline;
    void delegate(Sprite2d) onConfiguredUnderline;
    void delegate(Sprite2d) onCreatedUnderline;

    BaseTooltip urlTooltip;
    bool isCreateUrlTooltip = true;
    BaseTooltip delegate(BaseTooltip) onNewUrlTooltip;
    void delegate(BaseTooltip) onConfiguredUrlTooltip;
    void delegate(BaseTooltip) onCreatedUrlTooltip;

    float fromHoverOpacity = 0.5;
    float toHoverOpacity = 1.0;

    protected
    {
        dstring _text;
        dchar _iconName;
        float _graphicsGap = 0;
    }

    this(dstring text = "Hyperlink", dchar iconName = dchar.init, float graphicsGap = 0)
    {
        _text = text;
        _iconName = iconName;
        _graphicsGap = graphicsGap;

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout(0);
        layout.isAutoResize = true;
    }

    override void initialize()
    {
        super.initialize;

        onPointerEnter ~= (ref e) { linkOpacity(toHoverOpacity); };
        onPointerExit ~= (ref e) { linkOpacity(fromHoverOpacity); };

        onPointerPress ~= (ref e) {
            if (!isOpenBrowser || url.length == 0)
            {
                return;
            }
            platform.openURL(url);
        };
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadHyperlinkTheme;
    }

    void loadHyperlinkTheme()
    {
        if (underlineHeight == 0)
        {
            underlineHeight = theme.dividerSize / 2;
        }
    }

    override void create()
    {
        super.create;

        if (!label && isCreateLabel)
        {
            auto nl = newLabel;
            label = !onNewLabel ? nl : onNewLabel(nl);

            _text = null;
            _iconName = dchar.init;
            _graphicsGap = 0;
            label.isEnablePadding = false;

            if (onConfiguredLabel)
            {
                onConfiguredLabel(label);
            }

            addCreate(label);

            label.label.margin = 0;

            if (onCreatedLabel)
            {
                onCreatedLabel(label);
            }
        }

        if (!urlTooltip && isCreateUrlTooltip)
        {
            auto p = newUrlTooltip(url.to!dstring);
            urlTooltip = !onNewUrlTooltip ? p : onNewUrlTooltip(p);

            if (onConfiguredUrlTooltip)
            {
                onConfiguredUrlTooltip(urlTooltip);
            }

            addCreate(urlTooltip);

            installTooltip(urlTooltip);

            if (onCreatedUrlTooltip)
            {
                onCreatedUrlTooltip(urlTooltip);
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

            if (onConfiguredUnderline)
            {
                onConfiguredUnderline(underline);
            }

            addCreate(underline);

            underline.opacity = fromHoverOpacity;

            if (onCreatedUnderline)
            {
                onCreatedUnderline(underline);
            }
        }
    }

    void linkOpacity(float value)
    {
        if (underline && underline.isVisible)
        {
            underline.opacity = value;
        }
    }

    Label newLabel()
    {
        return new Label(_text, _iconName, _graphicsGap);
    }

    Sprite2d newUnderline()
    {
        auto shape = theme.rectShape(width, theme.dividerSize, angle, createFillStyle);
        return shape;
    }

    BaseTooltip newUrlTooltip(dstring text)
    {
        return new TextTooltip(text);
    }

}
