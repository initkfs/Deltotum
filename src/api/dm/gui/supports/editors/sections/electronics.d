module api.dm.gui.supports.editors.sections.electronics;

import api.dm.gui.controls.control : Control;
import api.math.geom2.rect2 : Rect2d;

import std.stdio;

/**
 * Authors: initkfs
 */
class Electronics : Control
{
    this()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;

        import api.sims.ele.simulator : Simulator;

        auto sim = new Simulator;
        addCreate(sim);

        // import api.dm.lib.libxml.svg_reader: SvgReader;

        // auto parser = new SvgReader;

        // auto userDir = context.app.userDir;
        // auto testFile = userDir ~ "/test.svg";

        // parser.load(testFile);

        
    }
}
