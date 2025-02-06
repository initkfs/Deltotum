module api.dm.gui.supports.sceneview;

import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.center_box : CenterBox;
import api.dm.gui.controls.switches.toggles.toggle : Toggle;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.texts.textfield : TextField;
import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.texts.text_area : TextArea;
import api.dm.gui.controls.selects.tables.clipped.trees.tree_item : TreeItem;
import api.dm.gui.controls.selects.tables.clipped.trees.tree_list : TreeList, newTreeList;
import api.math.insets : Insets;
import api.dm.gui.controls.containers.scroll_box : ScrollBox;
import api.dm.gui.controls.containers.tabs.tab : Tab;
import api.dm.gui.controls.containers.tabs.tabbox : TabBox;
import api.dm.gui.controls.switches.checks.check : Check;

import IconNames = api.dm.gui.themes.icons.icon_name;

import std.conv : to;

private
{
    class DebugInfo : HBox
    {

        override void initialize()
        {
            super.initialize;
            isBackground = false;
        }

    }
}

/**
 * Authors: initkfs
 */
class SceneView : VBox
{
    Scene2d scene;

    void delegate() onEnableDebug;
    void delegate() onDisableDebug;

    const string debugUserDataKey = "debugData";

    TextArea output;

    TextField shortInfo;
    TextField xInfo;
    TextField yInfo;
    TextField xpInfo;
    TextField ypInfo;
    TextField wInfo;
    TextField hInfo;
    TextField rInfo;

    TextField paddingTop;
    TextField paddingRight;
    TextField paddingBottom;
    TextField paddingLeft;

    Text updateTimeMs;
    Text drawTimeMs;
    Text invalidNodesCount;

    Text gcUsedBytes;

    Check isDrag;

    private
    {
        //TODO remove templates
        import api.dm.gui.controls.selects.tables.clipped.trees.base_tree_table : BaseTreeTable;
        import api.dm.gui.controls.selects.tables.base_table_column : BaseTableColumn;
        import api.dm.gui.controls.selects.tables.base_table_row : BaseTableRow;
        import api.dm.gui.controls.selects.tables.clipped.trees.tree_item : TreeItem;
        import api.dm.gui.controls.selects.tables.clipped.trees.tree_row : TreeRow;

        TreeList!(Sprite2d, BaseTableColumn!Sprite2d, TreeRow!Sprite2d) controlStructure;
        
        Sprite2d objectOnDebug;
        size_t objectOnDebugSceneIndex;
        bool isDebug;
        TextArea objectFullInfo;
    }

    this(Scene2d scene)
    {
        super(5);
        this.scene = scene;
        isBorder = true;
        isBackground = true;
    }

    override void create()
    {
        super.create;

        enableInsets;

        //TODO autosize
        width = 300;
        height = scene.window.height;

        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        // userStyle = theme.newDefaultStyle;
        // userStyle.lineColor = RGBA.web("#DDCC66");
        // userStyle.fillColor = RGBA.web("#ffb641");
        // userStyle.isFill = false;

        auto infoContainer = new HBox;
        infoContainer.layout.isAlignY = true;
        addCreate(infoContainer);
        infoContainer.enableInsets;

        updateTimeMs = new Text("");
        infoContainer.addCreate([new Text("Ums:"), updateTimeMs]);

        drawTimeMs = new Text("");
        infoContainer.addCreate([new Text("Dms:"), drawTimeMs]);

        invalidNodesCount = new Text("");
        infoContainer.addCreate([new Text("Inv:"), invalidNodesCount]);

        auto infoContainer2 = new HBox;
        infoContainer2.layout.isAlignY = true;
        addCreate(infoContainer2);
        infoContainer2.enableInsets;

        gcUsedBytes = new Text("");
        infoContainer2.addCreate([new Text("GCu(KB):"), gcUsedBytes]);

        auto btnContainer = new HBox;
        btnContainer.layout.isAlignY = true;
        addCreate(btnContainer);

        auto tb = new Toggle;
        btnContainer.addCreate(tb);

        tb.onOldNewValue ~= (oldValue, newValue) {
            if (newValue)
            {
                if (onEnableDebug !is null)
                {
                    onEnableDebug();
                }
                isDebug = true;
            }
            else
            {
                if (onDisableDebug !is null)
                {
                    onDisableDebug();
                }

                isDebug = false;
                if (objectOnDebug)
                {
                    removeDebugInfo(objectOnDebug);
                    objectOnDebug = null;
                }
            }

        };

        tb.addCreateIcon(IconNames.locate_outline);
        tb.text = "";

        auto fillStruct = new Button("");
        fillStruct.onAction ~= (ref e) { fillStructure; };
        btnContainer.addCreate(fillStruct);
        fillStruct.addCreateIcon(IconNames.enter_outline);

        auto fillScene = new Button("Scene2d");
        fillScene.onAction ~= (ref e) { fillFullScene; };
        btnContainer.addCreate(fillScene);

        controlStructure = newTreeList!Sprite2d;
        controlStructure.itemTextProvider = (Sprite2d item){
            if(!item){
                return "null"d;
            }
            import std.conv: to;
            return (item.id.length) > 0 ? item.id.to!dstring : item.classNameShort.to!dstring;
        };
        controlStructure.width = width - padding.width;
        controlStructure.height = 200;
        addCreate(controlStructure);

        auto controlSettings = new TabBox;
        addCreate(controlSettings);

        import IconNames = api.dm.gui.themes.icons.icon_name;

        auto controlTab = new Tab("", IconNames.options_outline);
        controlTab.content = createControlTab;
        controlSettings.addCreate(controlTab);

        auto layoutTab = new Tab("", IconNames.grid_outline);
        layoutTab.content = createLayoutTab;
        controlSettings.addCreate(layoutTab);

        auto dumpTab = new Tab("", IconNames.construct_outline);
        dumpTab.content = createDumpTab;
        controlSettings.addCreate(dumpTab);

        controlSettings.changeTab(controlTab);

        // controlStructure.onChangeOldNew = (oldSprite, newSprite) {
        //     import std;

        //     if (newSprite is objectOnDebug)
        //     {
        //         return;
        //     }

        //     if (objectOnDebug)
        //     {
        //         removeDebugInfo(objectOnDebug);
        //     }

        //     objectOnDebug = newSprite;
        //     setDebugInfo(objectOnDebug);
        // };

        sceneIsDebug;
    }

    Container createLayoutTab()
    {
        auto box = new HBox;
        build(box);
        box.create;
        return box;
    }

    Container createDumpTab()
    {
        objectFullInfo = new TextArea();
        objectFullInfo.width = width - padding.width;
        objectFullInfo.height = 400;
        build(objectFullInfo);
        return objectFullInfo;
    }

    Container createControlTab()
    {
        VBox controlInfoContainer = new VBox;
        controlInfoContainer.isHGrow = true;
        controlInfoContainer.isVGrow = true;
        build(controlInfoContainer);
        controlInfoContainer.create;

        VBox controlInfo = new VBox;
        controlInfo.isHGrow = true;
        controlInfoContainer.addCreate(controlInfo);
        controlInfo.enableInsets;

        shortInfo = new TextField("");
        controlInfo.addCreate(shortInfo);

        enum textWidth = 50;

        HBox h1 = new HBox();
        h1.layout.isAlignY = true;
        controlInfo.addCreate(h1);
        h1.enableInsets;
        wInfo = new TextField("0");
        wInfo.onEnter = (ref e) {
            onObjectDebug((object) { object.width = wInfo.text.to!double; });
        };
        wInfo.width = textWidth;

        hInfo = new TextField("0");
        hInfo.onEnter = (ref e) {
            onObjectDebug((object) { object.height = hInfo.text.to!double; });
        };
        hInfo.width = textWidth;

        rInfo = new TextField("0");
        rInfo.onEnter = (ref e) {
            onObjectDebug((object) { object.angle = rInfo.text.to!double; });
        };
        rInfo.width = textWidth;

        h1.addCreate([
            new Text("w:"), wInfo, new Text("h:"), hInfo, new Text("r:"), rInfo
        ]);

        HBox h2 = new HBox();
        h2.layout.isAlignY = true;
        controlInfo.addCreate(h2);
        h2.enableInsets;
        xInfo = new TextField("0");
        xInfo.onEnter = (ref e) {
            if (objectOnDebug)
            {
                import std.conv : to;

                objectOnDebug.x = xInfo.text.to!double;
            }
        };
        xInfo.width = textWidth;
        yInfo = new TextField("0");
        yInfo.onEnter = (ref e) {
            if (objectOnDebug)
            {
                import std.conv : to;

                objectOnDebug.y = yInfo.text.to!double;
            }
        };
        yInfo.width = textWidth;
        h2.addCreate([new Text("x:"), xInfo, new Text("y:"), yInfo]);

        HBox coordsParent = new HBox();
        coordsParent.layout.isAlignY = true;
        controlInfo.addCreate(coordsParent);
        coordsParent.enableInsets;
        xpInfo = new TextField("0");
        xpInfo.width = textWidth;
        ypInfo = new TextField("0");
        ypInfo.width = textWidth;
        coordsParent.addCreate([new Text("xp:"), xpInfo, new Text("yp:"), ypInfo]);

        auto paddingContainer = new HBox;
        paddingContainer.layout.isAlignY = true;
        controlInfo.addCreate(paddingContainer);
        paddingContainer.enableInsets;

        paddingContainer.addCreate(new Text("p:"));

        paddingTop = new TextField("0");
        paddingContainer.addCreate(paddingTop);
        paddingTop.onEnter = (ref e) {
            if (objectOnDebug)
            {
                objectOnDebug.padding.top = paddingTop.textTo!double;
            }
        };
        paddingRight = new TextField("0");
        paddingContainer.addCreate(paddingRight);
        paddingRight.onEnter = (ref e) {
            if (objectOnDebug)
            {
                objectOnDebug.padding.right = paddingRight.textTo!double;
            }
        };
        paddingBottom = new TextField("0");
        paddingContainer.addCreate(paddingBottom);
        paddingBottom.onEnter = (ref e) {
            if (objectOnDebug)
            {
                objectOnDebug.padding.bottom = paddingBottom.textTo!double;
            }
        };
        paddingLeft = new TextField("0");
        paddingContainer.addCreate(paddingLeft);
        paddingLeft.onEnter = (ref e) {
            if (objectOnDebug)
            {
                objectOnDebug.padding.left = paddingLeft.textTo!double;
            }
        };

        import api.core.utils.types : castSafe;

        foreach (ch; paddingContainer.children)
        {
            if (auto tf = ch.castSafe!TextField)
            {
                tf.width = 50;
            }
        }

        auto invalidBtn = new Button("");
        invalidBtn.onAction ~= (ref e) {
            if (objectOnDebug)
            {
                objectOnDebug.setInvalid;
            }
        };
        controlInfo.addCreate(invalidBtn);
        invalidBtn.addCreateIcon(IconNames.copy_outline);

        auto updateBtn = new Button("Update");
        updateBtn.onAction ~= (ref e) {
            if (objectOnDebug)
            {
                fillDebugInfo(objectOnDebug);
            }
        };
        controlInfo.addCreate(updateBtn);

        isDrag = new Check("IsDrag");
        isDrag.onOldNewValue ~= (old, newValue) {
            onObjectDebug((object) { object.isDraggable = newValue; });
        };
        controlInfo.addCreate(isDrag);

        output = new TextArea();
        output.width = width - padding.width;
        output.height = 150;
        output.isVisible = false;
        controlInfo.addCreate(output);

        return controlInfoContainer;
    }

    void onObjectDebug(scope void delegate(Sprite2d) onObject)
    {
        if (objectOnDebug)
        {
            onObject(objectOnDebug);
        }
    }

    void sceneIsDebug()
    {
        if (!scene)
        {
            return;
        }

        foreach (obj; scene.activeSprites)
        {
            if (obj is this)
            {
                continue;
            }

            obj.onPointerPress ~= (ref e) {
                if (!isDebug || e.button != 3)
                {
                    return;
                }

                Sprite2d nextForDebug = objectOnDebug;

                size_t inBoundsChildCount = 0;
                obj.onChildrenRec((child) {

                    if (cast(DebugInfo) child)
                    {
                        return true;
                    }

                    if (child.boundsRect.contains(e.x, e.y) && child !is nextForDebug)
                    {
                        if (inBoundsChildCount > objectOnDebugSceneIndex || !nextForDebug)
                        {
                            objectOnDebugSceneIndex = inBoundsChildCount + 1;
                            nextForDebug = child;
                            return false;
                        }

                        inBoundsChildCount++;
                    }

                    return true;
                });

                if (!nextForDebug || nextForDebug is objectOnDebug)
                {
                    objectOnDebugSceneIndex = 0;
                }

                if (nextForDebug !is null)
                {
                    if (objectOnDebug)
                    {
                        removeDebugInfo(objectOnDebug);
                    }

                    objectOnDebug = nextForDebug;
                    setDebugInfo(objectOnDebug);
                }
            };
        }
    }

    private DebugInfo createDebugInfo(Sprite2d obj)
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        auto container = new DebugInfo;
        container.width = obj.width;
        container.height = obj.height;
        container.isLayoutManaged = false;

        auto borderStyle = GraphicStyle(1, RGBA.red);

        if (container.width == 0 || container.height == 0)
        {
            borderStyle = GraphicStyle(1, RGBA.green);
            container.width = 10;
            container.height = 10;
        }

        obj.addCreate(container);

        //Random color?
        auto border = new Rectangle(container.width, container.height, borderStyle);
        border.isLayoutManaged = false;

        container.addCreate(border);

        import api.dm.gui.controls.texts.text : Text;
        import std.format : format;

        // auto sizeInfo = new TextField(format("%s, p: %s", obj.boundsRect, obj.padding));

        // container.addCreate(sizeInfo);

        return container;
    }

    private void setDebugInfo(Sprite2d obj)
    {
        if (obj is null)
        {
            return;
        }

        // if (auto debugData = cast(DebugInfo) obj.userData.get(debugUserDataKey, null))
        // {
        //     return;
        // }

        // obj.userData[debugUserDataKey] = createDebugInfo(obj);
        fillDebugInfo(obj);
    }

    private void fillDebugInfo(Sprite2d obj)
    {
        if (objectFullInfo is null)
        {
            return;
        }

        import Math = api.dm.math;
        import std.conv : to;
        import std.format : format;

        shortInfo.text = format("%s(%s)", obj.classNameShort, obj.id.length > 0 ? obj.id : "id");

        xInfo.text = Math.trunc(obj.x).to!string;
        yInfo.text = Math.trunc(obj.y).to!string;

        auto parentBounds = obj.boundsRectInParent;

        xpInfo.text = Math.trunc(parentBounds.x).to!string;
        ypInfo.text = Math.trunc(parentBounds.y).to!string;

        wInfo.text = obj.width.to!string;
        hInfo.text = obj.height.to!string;
        rInfo.text = obj.angle.to!string;

        paddingTop.text = obj.padding.top.to!string;
        paddingRight.text = obj.padding.right.to!string;
        paddingBottom.text = obj.padding.bottom.to!string;
        paddingLeft.text = obj.padding.left.to!string;

        isDrag.isOn = obj.isDraggable;

        if (objectFullInfo && objectFullInfo.isCreated)
        {
            objectFullInfo.textView.text = obj.toString;
        }
    }

    private void fillFullScene()
    {
        if (!isDebug)
        {
            return;
        }
        auto roots = scene.activeSprites;
        foreach (root; roots)
        {
            if (root is this)
            {
                continue;
            }
            auto treeRootNode = buildSpriteTree(root);
            controlStructure.fill(treeRootNode);
            break;
        }

    }

    private void fillStructure()
    {
        if (!objectOnDebug)
        {
            return;
        }
        auto treeRootNode = buildSpriteTree(objectOnDebug);
        controlStructure.fill(treeRootNode);
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

    private void removeDebugInfo(Sprite2d obj)
    {
        if (obj is null)
        {
            return;
        }

        // if (auto debugData = cast(DebugInfo) obj.userData.get(debugUserDataKey, null))
        // {
        //     obj.remove(debugData);
        //     obj.userData = null;
        // }
    }

    override void update(double delta)
    {
        super.update(delta);
    }
}
