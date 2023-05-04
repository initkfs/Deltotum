module deltotum.gui.controls.texts.text_area;

import deltotum.gui.controls.texts.text_view : TextView;
import deltotum.gui.controls.scrollbars.vscrollbar : VScrollbar;
import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.layouts.horizontal_layout : HorizontalLayout;

import std.stdio;

/**
 * Authors: initkfs
 */
class TextArea : Control
{
    TextView textView;
    VScrollbar scroll;

    void delegate() onCaret;

    override void initialize()
    {
        super.initialize;

        import deltotum.math.geometry.insets;

        padding = Insets(0);
    }

    override void create()
    {
        super.create;

        scroll = new VScrollbar(0, 1.0, 20, height);

        textView = new TextView;

        //FIXME invalid padding
        layout = new HorizontalLayout(0);

        textView.minHeight = height;
        textView.maxHeight = height;
        textView.minWidth = width - scroll.width;
        textView.maxWidth = textView.minWidth;
        addCreated(textView);

        addCreated(scroll);

        scroll.onValue = (value) { textView.scrollTo(value); };

        onTextInput = (key) {
            foreach (glyph; asset.defaultBitmapFont.glyphs)
            {
                if (glyph.grapheme == key.firstLetter)
                {
                    textView.text ~= glyph.grapheme;
                }
            }

            return false;
        };

        onKeyDown = (key) {
            import deltotum.com.inputs.keyboards.key_name : KeyName;

            if (key.keyName == KeyName.BACKSPACE && textView.text.length > 0)
            {
                textView.text = textView.text[0 .. $ - 1];
                return true;
            }

            if (key.keyName == KeyName.RETURN)
            {
                if (key.keyMod.isCtrl && onCaret !is null)
                {
                    onCaret();
                    return true;
                }

                textView.text ~= '\n';

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

            return false;
        };
    }
}
