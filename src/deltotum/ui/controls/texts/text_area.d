module deltotum.ui.controls.texts.text_area;

import deltotum.ui.controls.texts.text_view : TextView;
import deltotum.ui.controls.scrollbars.vscrollbar : VScrollbar;
import deltotum.ui.controls.control : Control;
import deltotum.toolkit.display.layouts.horizontal_layout : HorizontalLayout;

import std.stdio;

/**
 * Authors: initkfs
 */
class TextArea : Control
{
    TextView textView;
    VScrollbar scroll;

    override void create()
    {
        super.create;

        layout = new HorizontalLayout;

        scroll = new VScrollbar(0, 1.0, 20, height);

        textView = new TextView;
        textView.minHeight = height;
        textView.maxHeight = height;
        textView.minWidth = width - scroll.width;
        textView.maxWidth = textView.minWidth;
        addCreated(textView);

        addCreated(scroll);

        scroll.onValue = (value) { textView.scrollTo(value); };
    }
}
