module deltotum.gui.supports.editors.guieditor;

import deltotum.kit.scenes.scene : Scene;
import deltotum.kit.graphics.colors.rgba : RGBA;

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
        import deltotum.gui.controls.tabs.tab : Tab;
        import deltotum.gui.controls.tabs.tabpane : TabPane;

        auto root = new TabPane;
        root.width = window.width;
        root.height = window.height;

        addCreate(root);

        import deltotum.gui.supports.editors.sections.controls : Controls;

        auto controlsTab = new Tab("Controls");
        controlsTab.content = new Controls;
        root.addCreate(controlsTab);

        import deltotum.gui.supports.editors.sections.layouts : Layouts;

        auto layoutTab = new Tab("Layouts");
        layoutTab.content = new Layouts;
        root.addCreate(layoutTab);

        import deltotum.gui.supports.editors.sections.curves : Curves;

        auto curvesTab = new Tab("Curves");
        curvesTab.content = new Curves;
        root.addCreate(curvesTab);

        import deltotum.gui.supports.editors.sections.fractals : Fractals;

        auto fractalsTab = new Tab("Fractals");
        fractalsTab.content = new Fractals;
        root.addCreate(fractalsTab);

        import deltotum.gui.supports.editors.sections.images : Images;

        auto imagesTab = new Tab("Images");
        imagesTab.content = new Images;
        root.addCreate(imagesTab);

        import deltotum.gui.supports.editors.sections.particles : Particles;

        auto particlesTab = new Tab("Particles");
        particlesTab.content = new Particles;
        root.addCreate(particlesTab);

        import deltotum.gui.supports.editors.sections.scripting : Scripting;

        auto scriptTab = new Tab("Scripting");
        scriptTab.content = new Scripting;
        root.addCreate(scriptTab);

        root.changeTab(controlsTab);

        createDebugger;
    }

}
