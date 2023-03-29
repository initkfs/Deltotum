module deltotum.ui.controls.texts.text_area;

import deltotum.ui.controls.texts.text_view : TextView;
import deltotum.ui.controls.scrollbars.vscrollbar: VScrollbar;
import deltotum.ui.containers.hbox: HBox;

import std.stdio;

/**
 * Authors: initkfs
 */
class TextArea : HBox
{
    TextView textView;
    VScrollbar scroll;

    this(){
        textView = new TextView;
        scroll = new VScrollbar;
    }

    override void create(){
        super.create;

        scroll.height = height;
        scroll.x = width - scroll.width;
        addCreated(scroll);

        scroll.onValue = (value){
            textView.scrollTo(value);
        };

        textView.height = height;
        textView.width = width - scroll.width;
        addCreated(textView);
    }
}
