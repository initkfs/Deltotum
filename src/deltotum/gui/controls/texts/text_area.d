module deltotum.gui.controls.texts.text_area;

import deltotum.gui.controls.texts.text_view : TextView;
import deltotum.gui.controls.sliders.vslider : VSlider;
import deltotum.gui.controls.control : Control;
import deltotum.gui.containers.hbox : HBox;
import deltotum.kit.sprites.layouts.hlayout : HLayout;

import std.stdio;

/**
 * Authors: initkfs
 */
class TextArea : HBox
{
    TextView textView;
    VSlider scroll;

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

        import deltotum.math.geom.insets;

        padding = Insets(0);
        spacing = 0;
        isBackground = true;

        backgroundFactory = (width, height) {
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
            import deltotum.kit.sprites.shapes.regular_polygon : RegularPolygon;

            auto style = ownOrParentStyle;

            GraphicStyle backgroundStyle = style ? *style : GraphicStyle(1, graphics.theme.colorAccent, isBackground, graphics
                    .theme.colorPrimary);
            auto background = new RegularPolygon(width, height, backgroundStyle, graphics
                    .theme.controlCornersBevel);
            return background;
        };
    }

    override void create()
    {
        super.create;

        scroll = new VSlider(0, 1.0, 20, height);

        textView = new TextView;
        textView.isEditable = true;

        textView.onPointerEntered ~= (ref e) {
            import deltotum.com.inputs.cursors.com_system_cursor_type : ComSystemCursorType;

            input.systemCursor.change(ComSystemCursorType.ibeam);
        };

        textView.onPointerExited ~= (ref e) { input.systemCursor.restore; };

        addCreate(textView);

        auto textViewWidth = width - padding.width - textView.margin.width - scroll.width - scroll.margin.width - spacing;

        textView.width = textViewWidth;
        textView.maxWidth = textView.width;

        textView.maxHeight = height;

        addCreate(scroll);

        scroll.onValue = (value) { textView.scrollTo(value); };

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

        onKeyDown ~= (ref key) {
            import deltotum.com.inputs.keyboards.key_name : KeyName;

            if (key.keyName == KeyName.BACKSPACE && textView.text.length > 0)
            {
                textView.text = textView.text[0 .. $ - 1];
                key.isConsumed = true;
                return;
            }

            if (key.keyName == KeyName.RETURN)
            {
                if (key.keyMod.isCtrl && onCaret !is null)
                {
                    onCaret();
                    key.isConsumed = true;
                    return;
                }

                textView.text = textView.text ~ '\n';
            }

            if (key.keyMod.isCtrl && key.keyName == KeyName.c)
            {
                import std.conv : to;

                if (textView.text.length > 0)
                {
                    input.clipboard.setText(textView.text.to!string);
                }
            }

            if (key.keyMod.isCtrl && key.keyName == KeyName.v)
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
