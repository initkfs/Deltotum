module deltotum.gui.supports.editors.sections.scripting;

import deltotum.gui.controls.control : Control;

import std.stdio;

/**
 * Authors: initkfs
 */
class Scripting : Control
{

    this()
    {
        import deltotum.kit.sprites.layouts.horizontal_layout : HorizontalLayout;

        layout = new HorizontalLayout(5);
        layout.isAutoResize = true;
        isBackground = false;
        layout.isAlignY = false;
    }

    override void create()
    {
        super.create;

        import deltotum.gui.controls.texts.text_area : TextArea;

        TextArea juliaScriptArea = new TextArea;
        juliaScriptArea.width = 300;
        juliaScriptArea.height = 300;
        addCreate(juliaScriptArea);

        TextArea resultArea = new TextArea;
        resultArea.width = 300;
        resultArea.height = 300;
        addCreate(resultArea);

        import deltotum.com.inputs.keyboards.key_name : KeyName;

        auto prevDown = juliaScriptArea.onKeyDown;

        juliaScriptArea.onKeyDown = (e) {
            if (prevDown(e))
            {
                return true;
            }

            if (e.keyMod.isCtrl && e.keyName == KeyName.RETURN)
            {
                import std.variant : Variant;
                import std.conv : to;

                resultArea.textView.text = "";

                auto text = juliaScriptArea.textView.text;
                ext.call("julia-console", [text.to!string], (res) {
                    import std.conv : to;
                    import std.variant : Variant;

                    resultArea.textView.text = res.to!string;
                }, (err) {
                    resultArea.textView.text = err;
                    logger.tracef("Julia error: %s", err);
                });

            }

            return false;
        };

    }
}
