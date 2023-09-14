module deltotum.gui.supports.sceneview;

import deltotum.gui.containers.vbox : VBox;
import deltotum.gui.containers.hbox : HBox;
import deltotum.gui.containers.stack_box : StackBox;
import deltotum.gui.controls.choices.toggle_switch : ToggleSwitch;
import deltotum.gui.controls.texts.text : Text;
import deltotum.gui.controls.texts.textfield : TextField;
import deltotum.kit.scenes.scene : Scene;
import deltotum.gui.controls.buttons.button : Button;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.containers.container : Container;
import deltotum.gui.controls.texts.text_area : TextArea;
import deltotum.gui.controls.data.tree_table_view : TreeItem, TreeTableView;
import deltotum.math.geom.insets : Insets;
import deltotum.gui.containers.scroll_box : ScrollBox;
import deltotum.gui.controls.tabs.tab : Tab;
import deltotum.gui.controls.tabs.tabpane : TabPane;

import IconNames = deltotum.gui.themes.icons.icon_name;

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
    TextField wInfo;
    TextField hInfo;

    TextField paddingTop;
    TextField paddingRight;
    TextField paddingBottom;
    TextField paddingLeft;

    Text updateTimeMs;
    Text drawTimeMs;
    Text invalidNodesCount;

    Text gcUsedBytes;

    private
    {
        TreeTableView!Sprite controlStructure;
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

        import deltotum.kit.graphics.styles.graphic_style: GraphicStyle;
        import deltotum.kit.graphics.colors.rgba: RGBA;

        style = new GraphicStyle(1,  RGBA.web("#DDCC66"), false,RGBA.web("#ffb641"));

        auto infoContainer = new HBox;
        infoContainer.layout.isAlignY = true;
        addCreate(infoContainer);
        infoContainer.enableInsets;

        updateTimeMs = new Text("");
        infoContainer.addCreate([new Text("Ums:"), updateTimeMs]);

        drawTimeMs = new Text("");
        infoContainer.addCreate([new Text("Dms:"), drawTimeMs]);

        invalidNodesCount = new Text("");
        infoContainer.addCreate([ new Text("Inv:"), invalidNodesCount]);

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
        
        tb.label.text = "";
        tb.label.addCreateIcon(IconNames.locate_outline);

        auto fillStruct = new Button("");
        fillStruct.onAction = (ref e) { fillStructure; };
        btnContainer.addCreate(fillStruct);
        fillStruct.addCreateIcon(IconNames.enter_outline);

        controlStructure = new TreeTableView!Sprite;
        controlStructure.width = width - padding.width;
        controlStructure.height = 200;
        addCreate(controlStructure);

        auto controlSettings = new TabPane;
        addCreate(controlSettings);

        import IconNames = deltotum.gui.themes.icons.icon_name;

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
            if (objectOnDebug)
            {
                import std.conv : to;

                objectOnDebug.width = wInfo.text.to!double;
            }
        };
        wInfo.width = textWidth;

        hInfo = new TextField("0");
        hInfo.onEnter = (ref e) {
            if (objectOnDebug)
            {
                import std.conv : to;

                objectOnDebug.height = hInfo.text.to!double;
            }
        };
        hInfo.width = textWidth;
        h1.addCreate([new Text("w:"), wInfo, new Text("h:"), hInfo]);

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

        foreach (ch; paddingContainer.children)
        {
            if (auto tf = cast(TextField) ch)
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

        output = new TextArea();
        output.width = width - padding.width;
        output.height = 150;
        output.isVisible = false;
        controlInfo.addCreate(output);

        return controlInfoContainer;
    }

    void debugScene()
    {
        if (!scene)
        {
            return;
        }

        foreach (obj; scene.getActiveObjects)
        {
            if (obj is this)
            {
                continue;
            }

            obj.onPointerDown = (ref e) {
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
        import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
        import deltotum.kit.graphics.shapes.rectangle : Rectangle;
        import deltotum.kit.graphics.colors.rgba : RGBA;

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

        import deltotum.gui.controls.texts.text : Text;
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

        import Math = deltotum.math;
        import std.conv : to;
        import std.format : format;

        shortInfo.text = format("%s(%s)", obj.classNameShort, obj.id.length > 0 ? obj.id : "id");

        xInfo.text = Math.trunc(obj.x).to!string;
        yInfo.text = Math.trunc(obj.y).to!string;

        wInfo.text = obj.width.to!string;
        hInfo.text = obj.height.to!string;

        paddingTop.text = obj.padding.top.to!string;
        paddingRight.text = obj.padding.right.to!string;
        paddingBottom.text = obj.padding.bottom.to!string;
        paddingLeft.text = obj.padding.left.to!string;

        if (objectFullInfo && objectFullInfo.isCreated)
        {
            objectFullInfo.textView.text = obj.toString;
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
