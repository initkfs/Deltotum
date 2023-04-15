module deltotum.ui.supports.sceneview;

import deltotum.ui.containers.vbox : VBox;
import deltotum.ui.containers.hbox : HBox;
import deltotum.ui.containers.stack_box : StackBox;
import deltotum.ui.controls.buttons.toggle_switch : ToggleSwitch;
import deltotum.ui.controls.texts.text : Text;
import deltotum.toolkit.scene.scene : Scene;
import deltotum.toolkit.display.display_object : DisplayObject;
import deltotum.ui.containers.container : Container;
import deltotum.ui.controls.texts.text_area : TextArea;

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
    void delegate() onEnableDebug;
    void delegate() onDisableDebug;
    Scene delegate() sceneProvider;
    const string debugUserDataKey = "debugData";

    private
    {
        DisplayObject objectOnDebug;
        size_t objectOnDebugSceneIndex;
        bool isDebug;
        TextArea objectFullInfo;
    }

    override void initialize()
    {
        super.initialize;
        isLayoutManaged = false;
        spacing = 5;

        import deltotum.maths.geometry.insets : Insets;

        padding = Insets(5);
    }

    override void create()
    {
        super.create;

        auto hbox = new HBox;
        
        addCreated(hbox);
        auto text = new Text("Debug");
        auto tb = new ToggleSwitch;
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

        hbox.addCreated(text);
        hbox.addCreated(tb);

        objectFullInfo = new TextArea();
        objectFullInfo.width = width - padding.width;
        objectFullInfo.height = 400;
        addCreated(objectFullInfo);

        auto scene = sceneProvider();
        if (scene is null)
        {
            return;
        }

        foreach (obj; scene.getActiveObjects)
        {
            if (obj is this)
            {
                continue;
            }

            obj.onMouseDown = (e) {
                if (!isDebug || e.button != 3)
                {
                    return false;
                }

                DisplayObject nextForDebug = objectOnDebug;

                size_t inBoundsChildCount = 0;
                obj.onChildrenRecursive((child) {

                    if (cast(DebugInfo) child)
                    {
                        return true;
                    }

                    if (child.bounds.contains(e.x, e.y) && child !is nextForDebug)
                    {
                        if (inBoundsChildCount > objectOnDebugSceneIndex || !nextForDebug)
                        {
                            objectOnDebugSceneIndex = inBoundsChildCount;
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

                return false;
            };
        }
    }

    private DebugInfo createDebugInfo(DisplayObject obj)
    {
        import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;
        import deltotum.toolkit.graphics.shapes.rectangle : Rectangle;
        import deltotum.toolkit.graphics.colors.rgba : RGBA;

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

        obj.addCreated(container);

        //Random color?
        auto border = new Rectangle(container.width, container.height, borderStyle);
        border.isLayoutManaged = false;

        container.addCreated(border);

        import deltotum.ui.controls.texts.text : Text;
        import std.format : format;
        import std.conv: to;

        auto sizeInfo = new Text(format("%s, p: %s", obj.bounds, obj.padding).to!dstring);

        container.addCreated(sizeInfo);

        return container;
    }

    private void setDebugInfo(DisplayObject obj)
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

    private void fillDebugInfo(DisplayObject obj)
    {
        if( objectFullInfo is null){
            return;
        }
        import std.array : appender;

        objectFullInfo.textView.text = obj.toString;
    }

    private void removeDebugInfo(DisplayObject obj)
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

    override void update(double delta){
        super.update(delta);
    }

}
