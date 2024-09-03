module api.dm.gui.supports.editors.guieditor;

import api.dm.kit.scenes.scene : Scene;
import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class GuiEditor : Scene
{
    this()
    {
        name = "deltotum_gui_editor";
    }

    override void create()
    {
        super.create;
        import api.dm.gui.controls.tabs.tab : Tab;
        import api.dm.gui.controls.tabs.tabpane : TabPane;

        auto root = new TabPane;
        root.width = window.width;
        root.height = window.height;

        addCreate(root);

        import api.dm.gui.supports.editors.sections.controls : Controls;

        auto controlsTab = new Tab("Controls");
        controlsTab.content = new Controls;
        root.addCreate(controlsTab);

        version (DmAddon)
        {
            import api.dm.gui.supports.editors.sections.indicators : Indicators;

            auto indicatorsTab = new Tab("Indicators");
            indicatorsTab.content = new Indicators;
            root.addCreate(indicatorsTab);

        }

        import api.dm.gui.supports.editors.sections.layouts : Layouts;

        auto layoutTab = new Tab("Layouts");
        layoutTab.content = new Layouts;
        root.addCreate(layoutTab);

        import api.dm.gui.supports.editors.sections.graphics : Grahpics;

        auto graphicsTab = new Tab("Graphics");
        graphicsTab.content = new Grahpics;
        root.addCreate(graphicsTab);

        import api.dm.gui.supports.editors.sections.colors : Colors;

        auto colorsTab = new Tab("Colors");
        colorsTab.content = new Colors;
        root.addCreate(colorsTab);

        import api.dm.gui.supports.editors.sections.textures : Textures;

        auto texturesTab = new Tab("Textures");
        texturesTab.content = new Textures;
        root.addCreate(texturesTab);

        import api.dm.gui.supports.editors.sections.fonts : Fonts;

        auto fontsTab = new Tab("Fonts");
        fontsTab.content = new Fonts;
        root.addCreate(fontsTab);

        import api.dm.gui.supports.editors.sections.animations : Animations;

        auto animTab = new Tab("Animations");
        animTab.content = new Animations;
        root.addCreate(animTab);

        import api.dm.gui.supports.editors.sections.physics : Physics;

        auto physTab = new Tab("Physics");
        physTab.content = new Physics;
        root.addCreate(physTab);

        import api.dm.gui.supports.editors.sections.images : Images;

        auto imagesTab = new Tab("Images");
        imagesTab.content = new Images;
        root.addCreate(imagesTab);

        version (DmAddon)
        {
            import api.dm.gui.supports.editors.sections.procedural : Procedural;

            auto procTab = new Tab("Procedural");
            procTab.content = new Procedural;
            root.addCreate(procTab);

            import api.dm.gui.supports.editors.sections.curves : Curves;

            auto curvesTab = new Tab("Curves");
            curvesTab.content = new Curves;
            root.addCreate(curvesTab);

            import api.dm.gui.supports.editors.sections.fractals : Fractals;

            auto fractalsTab = new Tab("Fractals");
            fractalsTab.content = new Fractals;
            root.addCreate(fractalsTab);
        }

        root.changeTab(layoutTab);

        //import std;
        createDebugger;
    }

}
