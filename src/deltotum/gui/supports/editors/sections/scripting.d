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
        juliaScriptArea.width = 200;
        juliaScriptArea.height = 400;
        addCreate(juliaScriptArea);

        TextArea resultArea = new TextArea;
        resultArea.width = 200;
        resultArea.height = 200;
        addCreate(resultArea);

        import deltotum.gui.controls.buttons.button : Button;

        auto juliaRunButton = new Button("Run");
        juliaRunButton.onAction = (e) {
            import std.variant : Variant;
            import std.conv: to;

            auto text = juliaScriptArea.textView.text;
            ext.call("julia-console", [text.to!string], (res) {
                import std.conv: to;
                import std.variant: Variant;
                resultArea.textView.text = res.to!string;
            }, (err) {
                resultArea.textView.text = err;
                logger.trace("Julia error: %s", err);
            });

        };
        addCreate(juliaRunButton);

    }
}
