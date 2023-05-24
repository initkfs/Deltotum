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

        import deltotum.gui.supports.editors.controllers.layout_controller : LayoutController;

        auto layoutTab = new Tab("Layouts");
        layoutTab.content = new LayoutController;
        root.addCreate(layoutTab);

        import deltotum.gui.supports.editors.controllers.curves_controller : CurvesController;

        auto curvesTab = new Tab("Curves");
        curvesTab.content = new CurvesController;
        root.addCreate(curvesTab);

        root.changeTab(layoutTab);
    }

}
