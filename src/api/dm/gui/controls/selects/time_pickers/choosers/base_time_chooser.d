module api.dm.gui.controls.selects.time_pickers.choosers.base_time_chooser;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
abstract class BaseTimeChooser : Control
{
    void delegate(dstring) onStrValue;
    void delegate(int) onNumValue;

    double thumbSize = 0;
    double thumbOpacity = 0.8;

    Sprite2d thumb;
    bool isCreateThumb = true;
    Sprite2d delegate(Sprite2d) onNewThumb;
    void delegate(Sprite2d) onCreatedThumb;

    Text delegate(Text) onNewTextLabel;
    void delegate(Text) onCreatedTextLabel;

    this()
    {
        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        layout.isAutoResize = true;
        isResizedByParent = false;
    }

    abstract void value(int value);

    override void loadTheme()
    {
        super.loadTheme;
        loadBaseTimeChooserTheme;
    }

    void loadBaseTimeChooserTheme()
    {
        if (thumbSize == 0)
        {
            import Math = api.math;

            thumbSize = Math.max(theme.meterThumbWidth, theme.meterThumbHeight);
            assert(thumbSize > 0);
        }
    }

    override void create()
    {
        super.create;

        if (!thumb && isCreateThumb)
        {
            auto t = newThumb;
            thumb = !onNewThumb ? t : onNewThumb(t);

            thumb.isLayoutManaged = false;
            thumb.isResizedByParent = false;
            thumb.isVisible = false;

            addCreate(thumb);

            thumb.opacity = thumbOpacity;

            if (onCreatedThumb)
            {
                onCreatedThumb(thumb);
            }
        }
    }

    Sprite2d newThumb()
    {
        assert(thumbSize > 0);
        auto style = createStyle;
        if (!style.isPreset)
        {
            style.isFill = true;
        }
        auto shape = theme.roundShape(thumbSize, style);
        return shape;
    }

    Text newTextLabel(dstring text = null)
    {
        return new Text(text);
    }

    Text createNewTextLabel(dstring text = null, Sprite2d root = null)
    {
        assert(root);

        auto newButton = newTextLabel(text);
        auto label = !onNewTextLabel ? newButton : onNewTextLabel(newButton);

        label.isFocusable = false;
        label.isBorder = false;
        label.isBackground = false;

        label.onPointerPress ~= (ref e) {
            if (onStrValue)
            {
                onStrValue(label.text);
            }

            if (onNumValue)
            {
                import std.conv : to;

                onNumValue(label.text.to!int);
            }

            if (thumb)
            {
                thumb.xy(label.center.x - thumb.boundsRect.halfWidth, label.center.y - thumb
                        .boundsRect.halfHeight);
            }
        };

        auto labelRoot = root ? root : this;

        labelRoot.addCreate(label);

        if (onCreatedTextLabel)
        {
            onCreatedTextLabel(label);
        }

        return label;
    }

    override void drawContent()
    {
        super.drawContent;
        if (thumb && thumb.isVisible)
        {
            auto center = boundsRect.center;
            auto thumbCenter = thumb.boundsRect.center;
            auto color = theme.colorAccent;
            graphics.line(center.x, center.y, thumbCenter.x, thumbCenter.y, color);
        }
    }

    void hideThumb()
    {
        if (thumb && thumb.isVisible)
        {
            thumb.isVisible = false;
        }
    }

    void showThumb()
    {
        if (thumb)
        {
            thumb.isVisible = true;
        }
    }
}
