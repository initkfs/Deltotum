module api.dm.gui.supports.debuggers.additional_panel;

import api.dm.gui.supports.debuggers.base_debugger_panel: BaseDebuggerPanel;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.texts.text_field : TextField;
import api.dm.gui.scenes.gui_scene: GuiScene;

import api.dm.gui.controls.containers.tabs.tabbox : TabBox;
import api.dm.gui.controls.containers.tabs.tab : Tab;
import api.dm.gui.supports.debuggers.manages.sprite_manager: SpriteManager;
import api.dm.gui.controls.containers.splits.vsplit_box: VSplitBox;

/**
 * Authors: initkfs
 */
class AdditionalPanel : BaseDebuggerPanel
{
    VSplitBox mainContainer;

    SpriteManager spriteManager;

    this(GuiScene scene)
    {
        super(scene);
    }

    override void create()
    {
        super.create();

        spriteManager = new SpriteManager(targetScene);

        auto mainContainer = new VSplitBox;
        addCreate(mainContainer);
        resizeToParent(mainContainer);
        
        auto mainBox = new TabBox;
        buildInitCreate(mainBox);
        mainBox.enablePadding;
        if (width != 0)
        {
            mainBox.width = width;
        }

        mainBox.height = window.height / 2;

        auto sceneTab = mainBox.createTab(spriteManager, "Sprite");

        spriteManager.height = window.height / 2;
        buildInitCreate(spriteManager);
        mainBox.changeTab(sceneTab);

        import api.dm.gui.controls.containers.vbox: VBox;

        auto additionalContainer = new VBox;
        additionalContainer.width = width;
        additionalContainer.height = window.height / 2;
        buildInitCreate(additionalContainer);

        mainContainer.addContent([mainBox, additionalContainer]);

        
    }
}
