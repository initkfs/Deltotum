module app.dm.gui.supports.editors.sections.scripting;

import app.dm.gui.controls.control : Control;

import std.stdio;

/**
 * Authors: initkfs
 */
class Scripting : Control
{
    this()
    {
        import app.dm.kit.sprites.layouts.hlayout : HLayout;

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

        import app.dm.gui.controls.texts.text_area : TextArea;

        TextArea resultArea = new TextArea;
        resultArea.width = 300;
        resultArea.height = 300;
        addCreate(resultArea);
    }
}
