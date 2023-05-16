module deltotum.gui.controls.texts.text_area;

import deltotum.gui.controls.texts.text_view : TextView;
import deltotum.gui.controls.scrollbars.vscrollbar : VScrollbar;
import deltotum.gui.controls.control : Control;
import deltotum.gui.containers.hbox: HBox;
import deltotum.kit.sprites.layouts.horizontal_layout : HorizontalLayout;

import std.stdio;

/**
 * Authors: initkfs
 */
class TextArea : HBox
{
    TextView textView;
    VScrollbar scroll;

    void delegate() onCaret;

    override void initialize()
    {
        super.initialize;

        import deltotum.math.geometry.insets;
        padding = Insets(0);
        spacing = 0;
        isBackground = true;
    }

    override void create()
    {
        super.create;

        scroll = new VScrollbar(0, 1.0, 20, height);

        textView = new TextView;

        textView.minHeight = height;
        textView.maxHeight = height;
        //FIXME hack
        textView.minWidth = width - scroll.width - scroll.width / 2;
        textView.maxWidth = textView.minWidth;
        addCreate(textView);

        addCreate(scroll);

        scroll.onValue = (value) { textView.scrollTo(value); };

        //TODO isDisabled
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

        onMouseEntered = (e){
            import deltotum.com.inputs.cursors.com_system_cursor_type: ComSystemCursorType;
            input.systemCursor.change(ComSystemCursorType.ibeam);
            return false;
        };

        onMouseExited = (e){
            input.systemCursor.restore;
            return false;
        };
    }
}
