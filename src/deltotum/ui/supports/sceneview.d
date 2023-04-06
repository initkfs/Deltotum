module deltotum.ui.supports.sceneview;

import deltotum.ui.containers.vbox : VBox;
import deltotum.ui.containers.hbox : HBox;
import deltotum.ui.containers.stack_box : StackBox;
import deltotum.ui.controls.buttons.toggle_switch : ToggleSwitch;
import deltotum.ui.controls.texts.text : Text;
import deltotum.toolkit.scene.scene : Scene;
import deltotum.toolkit.display.display_object : DisplayObject;
import deltotum.ui.containers.container : Container;

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
    }

    override void initialize()
    {
        super.initialize;
        isLayoutManaged = false;
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
        };
        tb.onSwitchOff = () {
            if (onDisableDebug !is null)
            {
                onDisableDebug();
            }
        };

        hbox.addCreated(text);
        hbox.addCreated(tb);

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
                if (e.button != 3)
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

        auto sizeInfo = new Text(format("%s, p: %s", obj.bounds, obj.padding));

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

}
