module api.dm.gui.controls.viewers.webs.wbrowser_main_panel;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.switches.buttons.icon_button : IconButton;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.texts.text_field : TextField;

/**
 * Authors: initkfs
 */

class WBrowserMainPanel : Control
{
    TextField urlField;

    Button goButton;
    void delegate() onGo;

    Button prevButton;
    void delegate() onPrev;
    Button nextButton;
    void delegate() onNext;

    this()
    {
        setHLayout;
        layout.isAlignY = true;
    }

    override void create()
    {
        super.create;

        import Icons = api.dm.gui.themes.icons.pack_bootstrap;

        prevButton = new IconButton(Icons.arrow_left_circle_fill);
        addCreate(prevButton);
        prevButton.onAction ~= (ref e)
        {
            if (onPrev)
            {
                onPrev();
            }
        };

        nextButton = new IconButton(Icons.arrow_right_circle_fill);
        addCreate(nextButton);
        nextButton.onAction ~= (ref e)
        {
            if (onNext)
            {
                onNext();
            }
        };

        urlField = new TextField("https://google.com");
        addCreate(urlField);

        goButton = new IconButton(Icons.caret_right_fill);
        addCreate(goButton);
        goButton.onAction ~= (ref e) {
            if (onGo)
            {
                onGo();
            }
        };
    }

    string url()
    {
        if (!urlField)
        {
            throw new Exception("Url field not found");
        }

        import std.conv : to;

        return urlField.text.to!string;
    }
}
