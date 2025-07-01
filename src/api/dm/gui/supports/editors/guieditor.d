module api.dm.gui.supports.editors.guieditor;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.scenes.gui_scene : GuiScene;

/**
 * Authors: initkfs
 */
class GuiEditor : GuiScene
{
    this()
    {
        name = "deltotum_gui_editor";
    }

    override void create()
    {
        super.create;
        import api.dm.gui.controls.containers.tabs.tab : Tab;
        import api.dm.gui.controls.containers.tabs.tabbox : TabBox;

        auto root = new TabBox;
        root.width = window.width;
        root.height = window.height;

        addCreate(root);

        import api.dm.gui.supports.editors.sections.controls : Controls;

        auto controlsTab = new Tab("Controls");
        controlsTab.content = new Controls;
        root.addCreate(controlsTab);

        import api.dm.gui.supports.editors.sections.containers : Containers;

        auto containerTab = new Tab("Containers");
        containerTab.content = new Containers;
        root.addCreate(containerTab);

        import api.dm.gui.supports.editors.sections.graphic : Grahpics;

        auto graphicsTab = new Tab("Graphics");
        graphicsTab.content = new Grahpics;
        root.addCreate(graphicsTab);

        version (DmAddon)
        {
            import api.dm.gui.supports.editors.sections.audio : Audio;

            auto audioTab = new Tab("Audio");
            audioTab.content = new Audio;
            root.addCreate(audioTab);
        }

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

        root.changeTab(controlsTab);

        //import std;
        // createDebugger;
    }

}
