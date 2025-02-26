module api.dm.gui.controls.texts.text_area;

import api.dm.gui.controls.texts.text_view : TextView;
import api.dm.gui.controls.meters.scrolls.vscroll : VScroll;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d: Sprite2d;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

import std.stdio;

/**
 * Authors: initkfs
 */
class TextArea : HBox
{
    TextView textView;
    VScroll scroll;

    bool isShowScroll = true;

    void delegate() onCaret;

    this()
    {
        if (layout)
        {
            layout.isAlignY = false;
            layout.isAlignX = false;
        }
    }

    override void initialize()
    {
        super.initialize;

        import api.math.insets;

        padding = Insets(0);
        spacing = 0;
        isBackground = true;
    }

    override Sprite2d newBackground()
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.sprites2d.shapes.convex_polygon : ConvexPolygon;

        GraphicStyle backgroundStyle = GraphicStyle(1, theme.colorAccent, isBackground, theme
                .colorPrimary);
        auto background = super.newBackground(width, height, angle, backgroundStyle);
        return background;
    }

    override void create()
    {
        super.create;

        scroll = new VScroll(0, 1.0);

        textView = new TextView;
        textView.isEditable = true;

        textView.onPointerEnter ~= (ref e) {
            import api.dm.com.inputs.com_cursor : ComPlatformCursorType;

            input.systemCursor.change(ComPlatformCursorType.ibeam);
        };

        textView.onPointerExit ~= (ref e) { input.systemCursor.restore; };

        addCreate(textView);

        auto textViewWidth = width - padding.width - textView.margin.width - scroll.width - scroll.margin.width - spacing;

        textView.width = textViewWidth;
        textView.maxWidth = textView.width;

        textView.maxHeight = height;

        addCreate(scroll);

        scroll.onValue ~= (value) { textView.scrollTo(value); };

        //TODO isDisabled
        onTextInput ~= (ref key) {
            foreach (glyph; asset.fontBitmap.glyphs)
            {
                if (glyph.grapheme == key.firstLetter)
                {
                    textView.text = textView.text ~ glyph.grapheme;
                }
            }
        };

        onKeyPress ~= (ref key) {
            import api.dm.com.inputs.com_keyboard : ComKeyName;

            if (key.keyName == ComKeyName.backspace && textView.text.length > 0)
            {
                textView.text = textView.text[0 .. $ - 1];
                key.isConsumed = true;
                return;
            }

            if (key.keyName == ComKeyName.return_)
            {
                if (key.keyMod.isCtrl && onCaret !is null)
                {
                    onCaret();
                    key.isConsumed = true;
                    return;
                }

                textView.text = textView.text ~ '\n';
            }

            if (key.keyMod.isCtrl && key.keyName == ComKeyName.c)
            {
                import std.conv : to;

                if (textView.text.length > 0)
                {
                    input.clipboard.setText(textView.text.to!string);
                }
            }

            if (key.keyMod.isCtrl && key.keyName == ComKeyName.v)
            {
                import std.conv : to;

                if (input.clipboard.hasText)
                {
                    textView.text = input.clipboard.getText;
                }
            }
        };
    }
}
