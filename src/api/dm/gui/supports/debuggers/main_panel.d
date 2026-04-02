module api.dm.gui.supports.debuggers.main_panel;

import api.dm.gui.supports.debuggers.base_debugger_panel : BaseDebuggerPanel;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.texts.text_field : TextField;
import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.gui.controls.containers.tabs.tabbox : TabBox;
import api.dm.gui.controls.containers.tabs.tab : Tab;
import api.dm.gui.scenes.gui_scene: GuiScene;
import api.dm.gui.supports.debuggers.manages.scene_manager : SceneManager;
import api.dm.gui.supports.debuggers.manages.env_manager: EnvManager;
import api.dm.gui.controls.containers.splits.vsplit_box: VSplitBox;

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
class MainPanel : BaseDebuggerPanel
{
    void delegate() onEnableDebug;
    void delegate() onDisableDebug;

    const string debugUserDataKey = "debugData";

    VSplitBox mainContainer;

    SceneManager sceneManager;
    EnvManager envManager;

    // TextArea output;

    // TextField shortInfo;
    // TextField xInfo;
    // TextField yInfo;
    // TextField xpInfo;
    // TextField ypInfo;
    // TextField wInfo;
    // TextField hInfo;
    // TextField rInfo;

    // TextField paddingTop;
    // TextField paddingRight;
    // TextField paddingBottom;
    // TextField paddingLeft;

    // Check isDrag;

    // private
    // {

    //     Sprite2d objectOnDebug;
    //     size_t objectOnDebugSceneIndex;
    //     bool isDebug;
    //     TextArea objectFullInfo;
    // }

    this(GuiScene scene)
    {
        super(scene);
    }

    override void create()
    {
        super.create();

        mainContainer = new VSplitBox;
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

        sceneManager = new SceneManager(targetScene);
        auto sceneTab = mainBox.createTab(sceneManager, "Scene");
        sceneManager.height = window.height / 2;
        buildInitCreate(sceneManager);
        sceneManager.loadSceneTree;

        envManager = new EnvManager(targetScene);
        buildInitCreate(envManager);
        mainBox.createTab(envManager, "Env");
        envManager.height = window.height / 2;

        mainBox.changeTab(sceneTab);

        import api.dm.gui.controls.containers.vbox: VBox;

        auto additionalContainer = new VBox;
        additionalContainer.width = width;
        additionalContainer.height = window.height / 2;
        buildInitCreate(additionalContainer);

        mainContainer.addContent([mainBox, additionalContainer]);

        // auto btnContainer = new HBox;
        // btnContainer.layout.isAlignY = true;
        // addCreate(btnContainer);

        // auto tb = new Toggle;
        // btnContainer.addCreate(tb);

        // tb.onOldNewValue ~= (oldValue, newValue) {
        //     if (newValue)
        //     {
        //         if (onEnableDebug !is null)
        //         {
        //             onEnableDebug();
        //         }
        //         isDebug = true;
        //     }
        //     else
        //     {
        //         if (onDisableDebug !is null)
        //         {
        //             onDisableDebug();
        //         }

        //         isDebug = false;
        //         if (objectOnDebug)
        //         {
        //             removeDebugInfo(objectOnDebug);
        //             objectOnDebug = null;
        //         }
        //     }

        // };

        // //tb.addCreateIcon(IconNames.locate_outline);
        // tb.text = "";

        // auto fillStruct = new Button("");
        // fillStruct.onAction ~= (ref e) { fillStructure; };
        // btnContainer.addCreate(fillStruct);
        // //fillStruct.addCreateIcon(IconNames.enter_outline);

        // auto fillScene = new Button("Scene");
        // fillScene.onAction ~= (ref e) { loadSceneTree; };
        // btnContainer.addCreate(fillScene);

        // controlStructure = newTreeList!Sprite2d;
        // controlStructure.itemTextProvider = (Sprite2d item) {
        //     if (!item)
        //     {
        //         return "null"d;
        //     }
        //     import std.conv : to;

        //     return (item.id.length) > 0 ? item.id.to!dstring : item.classNameShort.to!dstring;
        // };
        // controlStructure.width = width - padding.width;
        // controlStructure.height = 200;
        // addCreate(controlStructure);

        // auto controlSettings = new TabBox;
        // addCreate(controlSettings);

        // auto controlTab = new Tab("", IconNames.options_outline);
        // controlTab.content = createControlTab;
        // controlSettings.addCreate(controlTab);

        // auto layoutTab = new Tab("", IconNames.grid_outline);
        // layoutTab.content = createLayoutTab;
        // controlSettings.addCreate(layoutTab);

        // auto dumpTab = new Tab("", IconNames.construct_outline);
        // dumpTab.content = createDumpTab;
        // controlSettings.addCreate(dumpTab);

        // controlSettings.changeTab(controlTab);

        // controlStructure.onChangeOldNew = (oldSprite, newSprite) {

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

    }

    //  Container createLayoutTab()
    // {
    //     auto box = new HBox;
    //     build(box);
    //     box.create;
    //     return box;
    // }

    // Container createDumpTab()
    // {
    //     objectFullInfo = new TextArea();
    //     objectFullInfo.width = width - padding.width;
    //     objectFullInfo.height = 400;
    //     build(objectFullInfo);
    //     return objectFullInfo;
    // }

    // Container createControlTab()
    // {
    //     VBox controlInfoContainer = new VBox;
    //     controlInfoContainer.isHGrow = true;
    //     controlInfoContainer.isVGrow = true;
    //     build(controlInfoContainer);
    //     controlInfoContainer.create;

    //     VBox controlInfo = new VBox;
    //     controlInfo.isHGrow = true;
    //     controlInfoContainer.addCreate(controlInfo);
    //     controlInfo.enablePadding;

    //     shortInfo = new TextField("");
    //     controlInfo.addCreate(shortInfo);

    //     enum textWidth = 50;

    //     HBox h1 = new HBox();
    //     h1.layout.isAlignY = true;
    //     controlInfo.addCreate(h1);
    //     h1.enablePadding;
    //     wInfo = new TextField("0");
    //     wInfo.onEnter = (ref e) {
    //         onObjectDebug((object) { object.width = wInfo.text.to!float; });
    //     };
    //     wInfo.width = textWidth;

    //     hInfo = new TextField("0");
    //     hInfo.onEnter = (ref e) {
    //         onObjectDebug((object) { object.height = hInfo.text.to!float; });
    //     };
    //     hInfo.width = textWidth;

    //     rInfo = new TextField("0");
    //     rInfo.onEnter = (ref e) {
    //         onObjectDebug((object) { object.angle = rInfo.text.to!float; });
    //     };
    //     rInfo.width = textWidth;

    //     h1.addCreate([
    //         new Text("w:"), wInfo, new Text("h:"), hInfo, new Text("r:"), rInfo
    //     ]);

    //     HBox h2 = new HBox();
    //     h2.layout.isAlignY = true;
    //     controlInfo.addCreate(h2);
    //     h2.enablePadding;
    //     xInfo = new TextField("0");
    //     xInfo.onEnter = (ref e) {
    //         if (objectOnDebug)
    //         {
    //             import std.conv : to;

    //             objectOnDebug.x = xInfo.text.to!float;
    //         }
    //     };
    //     xInfo.width = textWidth;
    //     yInfo = new TextField("0");
    //     yInfo.onEnter = (ref e) {
    //         if (objectOnDebug)
    //         {
    //             import std.conv : to;

    //             objectOnDebug.y = yInfo.text.to!float;
    //         }
    //     };
    //     yInfo.width = textWidth;
    //     h2.addCreate([new Text("x:"), xInfo, new Text("y:"), yInfo]);

    //     HBox coordsParent = new HBox();
    //     coordsParent.layout.isAlignY = true;
    //     controlInfo.addCreate(coordsParent);
    //     coordsParent.enablePadding;
    //     xpInfo = new TextField("0");
    //     xpInfo.width = textWidth;
    //     ypInfo = new TextField("0");
    //     ypInfo.width = textWidth;
    //     coordsParent.addCreate([new Text("xp:"), xpInfo, new Text("yp:"), ypInfo]);

    //     auto paddingContainer = new HBox;
    //     paddingContainer.layout.isAlignY = true;
    //     controlInfo.addCreate(paddingContainer);
    //     paddingContainer.enablePadding;

    //     paddingContainer.addCreate(new Text("p:"));

    //     paddingTop = new TextField("0");
    //     paddingContainer.addCreate(paddingTop);
    //     paddingTop.onEnter = (ref e) {
    //         if (objectOnDebug)
    //         {
    //             objectOnDebug.padding.top = paddingTop.textTo!float;
    //         }
    //     };
    //     paddingRight = new TextField("0");
    //     paddingContainer.addCreate(paddingRight);
    //     paddingRight.onEnter = (ref e) {
    //         if (objectOnDebug)
    //         {
    //             objectOnDebug.padding.right = paddingRight.textTo!float;
    //         }
    //     };
    //     paddingBottom = new TextField("0");
    //     paddingContainer.addCreate(paddingBottom);
    //     paddingBottom.onEnter = (ref e) {
    //         if (objectOnDebug)
    //         {
    //             objectOnDebug.padding.bottom = paddingBottom.textTo!float;
    //         }
    //     };
    //     paddingLeft = new TextField("0");
    //     paddingContainer.addCreate(paddingLeft);
    //     paddingLeft.onEnter = (ref e) {
    //         if (objectOnDebug)
    //         {
    //             objectOnDebug.padding.left = paddingLeft.textTo!float;
    //         }
    //     };

    //     import api.core.utils.types : castSafe;

    //     foreach (ch; paddingContainer.children)
    //     {
    //         if (auto tf = ch.castSafe!TextField)
    //         {
    //             tf.width = 50;
    //         }
    //     }

    //     auto invalidBtn = new Button("");
    //     invalidBtn.onAction ~= (ref e) {
    //         if (objectOnDebug)
    //         {
    //             objectOnDebug.setInvalid;
    //         }
    //     };
    //     controlInfo.addCreate(invalidBtn);
    //     //invalidBtn.addCreateIcon(IconNames.copy_outline);

    //     auto updateBtn = new Button("Update");
    //     updateBtn.onAction ~= (ref e) {
    //         if (objectOnDebug)
    //         {
    //             fillDebugInfo(objectOnDebug);
    //         }
    //     };
    //     controlInfo.addCreate(updateBtn);

    //     isDrag = new Check("IsDrag");
    //     isDrag.onOldNewValue ~= (old, newValue) {
    //         onObjectDebug((object) { object.isDraggable = newValue; });
    //     };
    //     controlInfo.addCreate(isDrag);

    //     output = new TextArea();
    //     output.width = width - padding.width;
    //     output.height = 150;
    //     output.isVisible = false;
    //     controlInfo.addCreate(output);

    //     return controlInfoContainer;
    // }

    // void onObjectDebug(scope void delegate(Sprite2d) onObject)
    // {
    //     if (objectOnDebug)
    //     {
    //         onObject(objectOnDebug);
    //     }
    // }

    // void sceneIsDebug()
    // {
    //     if (!scene)
    //     {
    //         return;
    //     }

    //     foreach (obj; scene.activeSprites)
    //     {
    //         if (obj is this)
    //         {
    //             continue;
    //         }

    //         obj.onPointerPress ~= (ref e) {
    //             if (!isDebug || e.button != 3)
    //             {
    //                 return;
    //             }

    //             Sprite2d nextForDebug = objectOnDebug;

    //             size_t inBoundsChildCount = 0;
    //             obj.onChildrenRec((child) {

    //                 if (cast(DebugInfo) child)
    //                 {
    //                     return true;
    //                 }

    //                 if (child.boundsRect.contains(e.x, e.y) && child !is nextForDebug)
    //                 {
    //                     if (inBoundsChildCount > objectOnDebugSceneIndex || !nextForDebug)
    //                     {
    //                         objectOnDebugSceneIndex = inBoundsChildCount + 1;
    //                         nextForDebug = child;
    //                         return false;
    //                     }

    //                     inBoundsChildCount++;
    //                 }

    //                 return true;
    //             });

    //             if (!nextForDebug || nextForDebug is objectOnDebug)
    //             {
    //                 objectOnDebugSceneIndex = 0;
    //             }

    //             if (nextForDebug !is null)
    //             {
    //                 if (objectOnDebug)
    //                 {
    //                     removeDebugInfo(objectOnDebug);
    //                 }

    //                 objectOnDebug = nextForDebug;
    //                 setDebugInfo(objectOnDebug);
    //             }
    //         };
    //     }
    // }

    // private DebugInfo createDebugInfo(Sprite2d obj)
    // {
    //     import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
    //     import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;
    //     import api.dm.kit.graphics.colors.rgba : RGBA;

    //     auto container = new DebugInfo;
    //     container.width = obj.width;
    //     container.height = obj.height;
    //     container.isLayoutManaged = false;

    //     auto borderStyle = GraphicStyle(1, RGBA.red);

    //     if (container.width == 0 || container.height == 0)
    //     {
    //         borderStyle = GraphicStyle(1, RGBA.green);
    //         container.width = 10;
    //         container.height = 10;
    //     }

    //     obj.addCreate(container);

    //     //Random color?
    //     auto border = new Rectangle(container.width, container.height, borderStyle);
    //     border.isLayoutManaged = false;

    //     container.addCreate(border);

    //     import api.dm.gui.controls.texts.text : Text;
    //     import std.format : format;

    //     // auto sizeInfo = new TextField(format("%s, p: %s", obj.boundsRect, obj.padding));

    //     // container.addCreate(sizeInfo);

    //     return container;
    // }

    // private void setDebugInfo(Sprite2d obj)
    // {
    //     if (obj is null)
    //     {
    //         return;
    //     }

    //     // if (auto debugData = cast(DebugInfo) obj.userData.get(debugUserDataKey, null))
    //     // {
    //     //     return;
    //     // }

    //     // obj.userData[debugUserDataKey] = createDebugInfo(obj);
    //     fillDebugInfo(obj);
    // }

    // private void fillDebugInfo(Sprite2d obj)
    // {
    //     if (objectFullInfo is null)
    //     {
    //         return;
    //     }

    //     import Math = api.dm.math;
    //     import std.conv : to;
    //     import std.format : format;

    //     shortInfo.text = format("%s(%s)", obj.classNameShort, obj.id.length > 0 ? obj.id : "id");

    //     xInfo.text = Math.trunc(obj.x).to!string;
    //     yInfo.text = Math.trunc(obj.y).to!string;

    //     auto parentBounds = obj.boundsRectInParent;

    //     xpInfo.text = Math.trunc(parentBounds.x).to!string;
    //     ypInfo.text = Math.trunc(parentBounds.y).to!string;

    //     wInfo.text = obj.width.to!string;
    //     hInfo.text = obj.height.to!string;
    //     rInfo.text = obj.angle.to!string;

    //     paddingTop.text = obj.padding.top.to!string;
    //     paddingRight.text = obj.padding.right.to!string;
    //     paddingBottom.text = obj.padding.bottom.to!string;
    //     paddingLeft.text = obj.padding.left.to!string;

    //     isDrag.isOn = obj.isDraggable;

    //     if (objectFullInfo && objectFullInfo.isCreated)
    //     {
    //         objectFullInfo.textView.text = obj.toString;
    //     }
    // }

    // private void fillStructure()
    // {
    //     if (!objectOnDebug)
    //     {
    //         return;
    //     }
    //     auto treeRootNode = buildSpriteTree(objectOnDebug);
    //     controlStructure.fill(treeRootNode);
    // }

    // private void removeDebugInfo(Sprite2d obj)
    // {
    //     if (obj is null)
    //     {
    //         return;
    //     }

    //     // if (auto debugData = cast(DebugInfo) obj.userData.get(debugUserDataKey, null))
    //     // {
    //     //     obj.remove(debugData);
    //     //     obj.userData = null;
    //     // }
    // }
}
