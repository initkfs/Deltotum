module api.dm.gui.supports.debuggers.manages.scene_manager;

import api.dm.gui.supports.debuggers.base_debugger_panel : BaseDebuggerPanel;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.selects.tables.clipped.trees.base_tree_table : BaseTreeTable;
import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
import api.dm.gui.controls.selects.tables.clipped.trees.tree_item : TreeItem;
import api.dm.gui.controls.selects.tables.clipped.trees.tree_row : TreeRow;
import api.dm.gui.controls.selects.tables.clipped.trees.tree_list : TreeList;
import api.dm.gui.scenes.gui_scene: GuiScene;

/**
 * Authors: initkfs
 */

class SceneManager : BaseDebuggerPanel
{
    TreeList!(Sprite2d, BaseTableColumn!Sprite2d, TreeRow!Sprite2d) sceneTree;

    this(GuiScene scene)
    {
        super(scene);
    }

    override void create()
    {
        super.create;

        sceneTree = new typeof(sceneTree);
        if (width != 0)
        {
            sceneTree.width = width;
        }
        addCreate(sceneTree);
        if (width != 0)
        {
            sceneTree.width = width;
        }

        if (height != 0)
        {
            sceneTree.height = height;
        }

        sceneTree.itemTextProvider = (item) {
            import std.conv : to;

            if (item.id.length != 0)
            {
                return item.id.to!dstring;
            }

            auto fullItem = item.toString;
            ptrdiff_t splitPos = -1;
            foreach (i, ch; fullItem)
            {
                if (ch == ' ')
                {
                    splitPos = i;
                    break;
                }
            }

            return splitPos >= 0 ? fullItem[0 .. splitPos].to!dstring : fullItem.to!dstring;
        };
    }

    void loadSceneTree()
    {
        auto roots = targetScene.activeSprites;
        foreach (root; roots)
        {
            if (root is this)
            {
                continue;
            }
            auto treeRootNode = buildSpriteTree(root);
            sceneTree.fill(treeRootNode);
            break;
        }

    }

    private TreeItem!Sprite2d buildSpriteTree(Sprite2d root)
    {

        auto node = new TreeItem!Sprite2d(root);

        foreach (ch; root.children)
        {
            auto childNode = buildSpriteTree(ch);
            node.childrenItems ~= childNode;
        }

        return node;
    }
}
