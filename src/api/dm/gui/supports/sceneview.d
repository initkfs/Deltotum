module api.dm.gui.supports.sceneview;

import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.containers.stack_box : StackBox;
import api.dm.gui.controls.toggles.toggle_switch : ToggleSwitch;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.texts.textfield : TextField;
import api.dm.kit.scenes.scene : Scene;
import api.dm.gui.controls.buttons.button : Button;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.containers.container : Container;
import api.dm.gui.controls.texts.text_area : TextArea;
import api.dm.gui.controls.trees.tree_item : TreeItem;
import api.dm.gui.controls.trees.tree_list_view : TreeListView;
import api.dm.math.insets : Insets;
import api.dm.gui.containers.scroll_box : ScrollBox;
import api.dm.gui.controls.tabs.tab : Tab;
import api.dm.gui.controls.tabs.tabpane : TabPane;
import api.dm.gui.controls.checks.checkbox : CheckBox;

import IconNames = api.dm.kit.graphics.themes.icons.icon_name;

import std.conv : to;

private
{
    class DebugInfo : HBox
    {

        override void initialize()
        {
            super.initialize;
            backgroundFactory = null;
        }

    }
}

/**
 * Authors: initkfs
 */
class SceneView : VBox
{
    Scene scene;

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

    CheckBox isDrag;

    private
    {
        TreeListView!Sprite controlStructure;
        Sprite objectOnDebug;
        size_t objectOnDebugSceneIndex;
        bool isDebug;
        TextArea objectFullInfo;
    }

    this(Scene scene)
    {
        super(5);
        this.scene = scene;
        isBorder = true;
    }

    override void create()
    {
        super.create;

        enableInsets;

        isLayoutManaged = false;

        //TODO autosize
        width = 300;
        height = scene.window.height;

        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        userStyle = graphics.theme.newDefaultStyle;
        userStyle.lineColor = RGBA.web("#DDCC66");
        userStyle.fillColor = RGBA.web("#ffb641");
        userStyle.isFill = false;

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

        auto tb = new ToggleSwitch;
        btnContainer.addCreate(tb);

        tb.onSwitchOn = () {
            if (onEnableDebug !is null)
            {
                onEnableDebug();
            }
            isDebug = true;
        };
        tb.onSwitchOff = () {
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
        };

        tb.addCreateIcon(IconNames.locate_outline);
        tb.text = "";

        auto fillStruct = new Button("");
        fillStruct.onAction = (ref e) { fillStructure; };
        btnContainer.addCreate(fillStruct);
        fillStruct.addCreateIcon(IconNames.enter_outline);

        auto fillScene = new Button("Scene");
        fillScene.onAction = (ref e) { fillFullScene; };
        btnContainer.addCreate(fillScene);

        controlStructure = new TreeListView!Sprite;
        controlStructure.width = width - padding.width;
        controlStructure.height = 200;
        addCreate(controlStructure);

        auto controlSettings = new TabPane;
        addCreate(controlSettings);

        import IconNames = api.dm.kit.graphics.themes.icons.icon_name;

        auto controlTab = new Tab("");
        controlTab.content = createControlTab;
        controlSettings.addCreate(controlTab);
        controlTab.label.addCreateIcon(IconNames.options_outline);

        auto layoutTab = new Tab("");
        layoutTab.content = createLayoutTab;
        controlSettings.addCreate(layoutTab);
        layoutTab.label.addCreateIcon(IconNames.grid_outline);

        auto dumpTab = new Tab("");
        dumpTab.content = createDumpTab;
        controlSettings.addCreate(dumpTab);
        dumpTab.label.addCreateIcon(IconNames.construct_outline);

        controlSettings.changeTab(controlTab);

        controlStructure.onSelectedOldNew = (oldSprite, newSprite) {
            import std;

            if (newSprite is objectOnDebug)
            {
                return;
            }

            if (objectOnDebug)
            {
                removeDebugInfo(objectOnDebug);
            }

            objectOnDebug = newSprite;
            setDebugInfo(objectOnDebug);
        };

        x = scene.window.width - width;

        debugScene;
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
            onObjectDebug((object) => object.width = wInfo.text.to!double);
        };
        wInfo.width = textWidth;

        hInfo = new TextField("0");
        hInfo.onEnter = (ref e) {
            onObjectDebug((object) => object.height = hInfo.text.to!double);
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
        invalidBtn.onAction = (ref e) {
            if (objectOnDebug)
            {
                objectOnDebug.setInvalid;
            }
        };
        controlInfo.addCreate(invalidBtn);
        invalidBtn.addCreateIcon(IconNames.copy_outline);

        auto updateBtn = new Button("Update");
        updateBtn.onAction = (ref e) {
            if (objectOnDebug)
            {
                fillDebugInfo(objectOnDebug);
            }
        };
        controlInfo.addCreate(updateBtn);

        isDrag = new CheckBox("IsDrag");
        isDrag.onToggleOldNewValue = (old, newValue) {
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

    void onObjectDebug(scope void delegate(Sprite) onObject)
    {
        if (objectOnDebug)
        {
            onObject(objectOnDebug);
        }
    }

    void debugScene()
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

            obj.onPointerDown ~= (ref e) {
                if (!isDebug || e.button != 3)
                {
                    return;
                }

                Sprite nextForDebug = objectOnDebug;

                size_t inBoundsChildCount = 0;
                obj.onChildrenRec((child) {

                    if (cast(DebugInfo) child)
                    {
                        return true;
                    }

                    if (child.bounds.contains(e.x, e.y) && child !is nextForDebug)
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

    private DebugInfo createDebugInfo(Sprite obj)
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
        import api.dm.kit.sprites.shapes.rectangle : Rectangle;
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

        // auto sizeInfo = new TextField(format("%s, p: %s", obj.bounds, obj.padding));

        // container.addCreate(sizeInfo);

        return container;
    }

    private void setDebugInfo(Sprite obj)
    {
        if (obj is null)
        {
            return;
        }

        if (auto debugData = cast(DebugInfo) obj.userData.get(debugUserDataKey, null))
        {
            return;
        }

        obj.userData[debugUserDataKey] = createDebugInfo(obj);
        fillDebugInfo(obj);
    }

    private void fillDebugInfo(Sprite obj)
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

        auto parentBounds = obj.boundsInParent;

        xpInfo.text = Math.trunc(parentBounds.x).to!string;
        ypInfo.text = Math.trunc(parentBounds.y).to!string;

        wInfo.text = obj.width.to!string;
        hInfo.text = obj.height.to!string;
        rInfo.text = obj.angle.to!string;

        paddingTop.text = obj.padding.top.to!string;
        paddingRight.text = obj.padding.right.to!string;
        paddingBottom.text = obj.padding.bottom.to!string;
        paddingLeft.text = obj.padding.left.to!string;

        isDrag.isCheck = obj.isDraggable;

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

    private TreeItem!Sprite buildSpriteTree(Sprite root)
    {

        auto node = new TreeItem!Sprite(root);

        foreach (ch; root.children)
        {
            auto childNode = buildSpriteTree(ch);
            node.children ~= childNode;
        }

        return node;
    }

    private void removeDebugInfo(Sprite obj)
    {
        if (obj is null)
        {
            return;
        }

        if (auto debugData = cast(DebugInfo) obj.userData.get(debugUserDataKey, null))
        {
            obj.remove(debugData);
            obj.userData = null;
        }
    }

    override void update(double delta)
    {
        super.update(delta);
    }
}
