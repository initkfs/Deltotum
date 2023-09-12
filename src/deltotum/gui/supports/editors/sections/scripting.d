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

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    override void create()
    {
        super.create;

        import deltotum.gui.controls.texts.text_area : TextArea;

        TextArea resultArea = new TextArea;
        resultArea.width = 300;
        resultArea.height = 300;
        addCreate(resultArea);
    }
}
