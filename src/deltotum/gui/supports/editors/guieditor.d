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

        import deltotum.gui.supports.editors.sections.graphics : Grahpics;

        auto graphicsTab = new Tab("Graphics");
        graphicsTab.content = new Grahpics;
        root.addCreate(graphicsTab);

        import deltotum.gui.supports.editors.sections.textures : Textures;

        auto texturesTab = new Tab("Textures");
        texturesTab.content = new Textures;
        root.addCreate(texturesTab);

        import deltotum.gui.supports.editors.sections.animations : Animations;

        auto animTab = new Tab("Animations");
        animTab.content = new Animations;
        root.addCreate(animTab);

        import deltotum.gui.supports.editors.sections.images : Images;

        auto imagesTab = new Tab("Images");
        imagesTab.content = new Images;
        root.addCreate(imagesTab);

        import deltotum.gui.supports.editors.sections.scripting : Scripting;

        auto scriptTab = new Tab("Scripting");
        scriptTab.content = new Scripting;
        root.addCreate(scriptTab);

        root.changeTab(imagesTab);

        createDebugger;
    }

}
