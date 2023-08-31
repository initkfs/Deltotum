module deltotum.gui.supports.sceneview;

import deltotum.gui.containers.vbox : VBox;
import deltotum.gui.containers.hbox : HBox;
import deltotum.gui.containers.stack_box : StackBox;
import deltotum.gui.controls.choices.toggle_switch : ToggleSwitch;
import deltotum.gui.controls.texts.text : Text;
import deltotum.kit.scenes.scene : Scene;
import deltotum.gui.controls.buttons.button : Button;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.containers.container : Container;
import deltotum.gui.controls.texts.text_area : TextArea;
import deltotum.gui.controls.data.tree_table_view : TreeItem, TreeTableView;
import deltotum.math.geom.insets : Insets;
import deltotum.gui.containers.scroll_box : ScrollBox;

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

    Text shortInfo;
    Text xInfo;
    Text yInfo;
    Text wInfo;
    Text hInfo;

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

        isLayoutManaged = false;

        //TODO autosize
        width = 300;
        height = scene.window.height;

        auto btnContainer = new HBox;
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

        tb.label.text = "Debug";

        auto fillStruct = new Button("Structure");
        fillStruct.onAction = (ref e) { fillStructure; };
        btnContainer.addCreate(fillStruct);

        controlStructure = new TreeTableView!Sprite;
        controlStructure.width = width - padding.width;
        controlStructure.height = 200;
        addCreate(controlStructure);

        controlStructure.onSelectedOldNew = (oldSprite, newSprite) {
            import std;
            writefln("%s %s", oldSprite.classNameShort, newSprite.classNameShort);
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

        ScrollBox controlInfoContainer = new ScrollBox;
        controlInfoContainer.width = width - padding.width;
        //TODO children height from layout
        controlInfoContainer.height = height - controlStructure.height - tb.height - spacing * 2 - padding
            .bottom;
        addCreate(controlInfoContainer);

        VBox controlInfo = new VBox;
        controlInfoContainer.setContent(controlInfo);

        shortInfo = new Text("");
        controlInfo.addCreate(shortInfo);

        HBox h1 = new HBox();
        controlInfo.addCreate(h1);
        wInfo = new Text("0");
        hInfo = new Text("0");
        h1.addCreate([new Text("w:"), wInfo, new Text("h:"), hInfo]);

        HBox h2 = new HBox();
        controlInfo.addCreate(h2);
        xInfo = new Text("0");
        yInfo = new Text("0");
        h2.addCreate([new Text("x:"), xInfo, new Text("y:"), yInfo]);

        objectFullInfo = new TextArea();
        objectFullInfo.width = width - padding.width;
        objectFullInfo.height = 400;
        controlInfo.addCreate(objectFullInfo);

        output = new TextArea();
        output.width = width - padding.width;
        output.height = 150;
        controlInfo.addCreate(output);

        x = scene.window.width - width;

        debugScene;
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

            obj.onMouseDown = (ref e) {
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

        auto sizeInfo = new Text(format("%s, p: %s", obj.bounds, obj.padding));

        container.addCreate(sizeInfo);

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
        import std.conv: to;
        import std.format: format;

        shortInfo.text = format("%s(%s)", obj.classNameShort, obj.id.length > 0 ? obj.id : "id");

        xInfo.text = Math.trunc(obj.x).to!string;
        yInfo.text = Math.trunc(obj.y).to!string;

        wInfo.text = obj.width.to!string;
        hInfo.text = obj.height.to!string;

        objectFullInfo.textView.text = obj.toString;
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
