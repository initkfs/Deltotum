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
        import deltotum.kit.sprites.layouts.hlayout : HLayout;

        layout = new HLayout(5);
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

        auto mustBePlugin = ext.findFirst("julia-console");
        if (!mustBePlugin.isNull)
        {
            import deltotum.kit.extensions.plugins.julia.julia_script_text_plugin : JuliaScriptTextPlugin;

            JuliaScriptTextPlugin p = cast(JuliaScriptTextPlugin) mustBePlugin.get;
            p.onCreateImage = (buff, buffLen) {
                import deltotum.kit.sprites.images.image: Image;
                debug writeln("Received image buffer");
                auto b = cast(string) buff[0..buffLen];
                auto im = new Image;
                build(im);
                im.loadRaw(b);
                addCreate(im);
            };
        }

        TextArea resultArea = new TextArea;
        resultArea.width = 300;
        resultArea.height = 300;
        addCreate(resultArea);

        import deltotum.com.inputs.keyboards.key_name : KeyName;

        auto prevDown = juliaScriptArea.onKeyDown;

        import deltotum.kit.sprites.images.image;

        juliaScriptArea.onKeyDown = (ref e) {
            prevDown(e);
            if(e.isConsumed){
                return;
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

                     debug writefln("Julia script result: %s", res.to!string);

                    resultArea.textView.text = res.to!string;
                }, (err) {
                    resultArea.textView.text = err;
                    logger.tracef("Julia error: %s", err);
                });

            }
        };

    }
}
