module dm.gui.supports.editors.guieditor;

import dm.kit.scenes.scene : Scene;
import dm.kit.graphics.colors.rgba : RGBA;

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
        import dm.gui.controls.tabs.tab : Tab;
        import dm.gui.controls.tabs.tabpane : TabPane;

        auto root = new TabPane;
        root.width = window.width;
        root.height = window.height;

        addCreate(root);

        import dm.gui.supports.editors.sections.controls : Controls;

        auto controlsTab = new Tab("Controls");
        controlsTab.content = new Controls;
        root.addCreate(controlsTab);

        import dm.gui.supports.editors.sections.layouts : Layouts;

        auto layoutTab = new Tab("Layouts");
        layoutTab.content = new Layouts;
        root.addCreate(layoutTab);

        import dm.gui.supports.editors.sections.graphics : Grahpics;

        auto graphicsTab = new Tab("Graphics");
        graphicsTab.content = new Grahpics;
        root.addCreate(graphicsTab);

        import dm.gui.supports.editors.sections.textures : Textures;

        auto texturesTab = new Tab("Textures");
        texturesTab.content = new Textures;
        root.addCreate(texturesTab);

        import dm.gui.supports.editors.sections.fonts : Fonts;

        auto fontsTab = new Tab("Fonts");
        fontsTab.content = new Fonts;
        root.addCreate(fontsTab);

        import dm.gui.supports.editors.sections.animations : Animations;

        auto animTab = new Tab("Animations");
        animTab.content = new Animations;
        root.addCreate(animTab);

        import dm.gui.supports.editors.sections.images : Images;

        auto imagesTab = new Tab("Images");
        imagesTab.content = new Images;
        root.addCreate(imagesTab);

        import dm.gui.supports.editors.sections.scripting : Scripting;

        auto scriptTab = new Tab("Scripting");
        scriptTab.content = new Scripting;
        root.addCreate(scriptTab);

        root.changeTab(controlsTab);

        createDebugger;
    }

}
