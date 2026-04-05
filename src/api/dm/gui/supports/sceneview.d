module api.dm.gui.supports.sceneview;

import api.dm.gui.supports.debuggers.info_panel : InfoPanel;
import api.dm.gui.supports.debuggers.additional_panel : AdditionalPanel;
import api.dm.gui.supports.debuggers.main_panel : MainPanel;
import api.dm.gui.scenes.gui_scene: GuiScene;

import api.dm.gui.controls.containers.slider : Slider, SliderPos;
import api.dm.gui.controls.containers.container : Container;

import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.center_box : CenterBox;
import api.dm.gui.controls.switches.toggles.toggle : Toggle;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.texts.text_field : TextField;
import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.texts.text_area : TextArea;
import api.dm.gui.controls.selects.tables.clipped.trees.tree_item : TreeItem;
import api.dm.gui.controls.selects.tables.clipped.trees.tree_list : TreeList, newTreeList;
import api.math.pos2.insets : Insets;
import api.dm.gui.controls.containers.scroll_box : ScrollBox;
import api.dm.gui.controls.containers.tabs.tab : Tab;
import api.dm.gui.controls.containers.tabs.tabbox : TabBox;
import api.dm.gui.controls.switches.checks.check : Check;
import api.dm.kit.graphics.colors.rgba : RGBA;

import IconNames = api.dm.gui.themes.icons.pack_bootstrap;

import std.conv : to;

/**
 * Authors: initkfs
 */
class SceneView : Container
{
    GuiScene scene;

    MainPanel mainPanel;
    InfoPanel infoPanel;
    AdditionalPanel additionalPanel;

    this(GuiScene scene)
    {
        if (!scene)
        {
            throw new Exception("Scene must not be null");
        }
        this.scene = scene;
    }

    override void create()
    {
        super.create;

        enablePadding;

        mainPanel = new MainPanel(scene);
        applyMainPanel(mainPanel);

        auto mainSlider = new Slider(SliderPos.left, true);
        addCreate(mainSlider);
        mainSlider.addContent(mainPanel);

        additionalPanel = new AdditionalPanel(scene);
        applyMainPanel(additionalPanel);
        additionalPanel.width = 300;

        auto additionalSlider = new Slider(SliderPos.right, true);
        addCreate(additionalSlider);
        additionalSlider.addContent(additionalPanel);
        additionalSlider.setWindowInitialPos;

        auto infoStyle = theme.newDefaultStyle;
        infoStyle.lineColor = RGBA.hex("#DDCC66");
        infoStyle.fillColor = RGBA.hex("#ffb641");
        infoStyle.isFill = false;

        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        infoPanel = new InfoPanel;
        infoPanel.style = *infoStyle;
        infoPanel.isStyleForChild = true;
        infoPanel.isBorder = true;
        addCreate(infoPanel);

        mainPanel.sceneManager.sceneTree.onSelectedOldNewRow = (oldRow, newRow) {
            auto item = newRow.item;
            additionalPanel.spriteManager.currentSprite = item;
        };
    }

    void applyMainPanel(Container panel)
    {
        //panel.isLayoutManaged = false;
        panel.width = 250;
        panel.height = window.height;
        panel.isBorder = true;
        panel.isBackground = true;
    }

    override void applyLayout()
    {
        super.applyLayout;

        // mainPanel.x = 0;
        // mainPanel.y = 0;

        //additionalPanel.x = window.width - additionalPanel.width;
        //additionalPanel.y = 0;

        infoPanel.x = window.halfWidth - infoPanel.halfWidth;
        infoPanel.y = window.height - infoPanel.height - 100;
    }

    override void update(float delta)
    {
        super.update(delta);
    }
}
