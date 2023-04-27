module deltotum.gui.supports.sceneview;

import deltotum.gui.containers.vbox : VBox;
import deltotum.gui.containers.hbox : HBox;
import deltotum.gui.containers.stack_box : StackBox;
import deltotum.gui.controls.buttons.toggle_switch : ToggleSwitch;
import deltotum.gui.controls.texts.text : Text;
import deltotum.kit.scenes.scene : Scene;
import deltotum.kit.display.display_object : DisplayObject;
import deltotum.gui.containers.container : Container;
import deltotum.gui.controls.texts.text_area : TextArea;

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

    TextArea output;

    private
    {
        DisplayObject objectOnDebug;
        size_t objectOnDebugSceneIndex;
        bool isDebug;
        TextArea objectFullInfo;
    }

    this(){
        super(5);
    }

    override void initialize()
    {
        super.initialize;
        isLayoutManaged = false;
    }

    override void create()
    {
        super.create;

        import deltotum.math.geometry.insets : Insets;

        auto hbox = new HBox;
        addCreated(hbox);

        auto tb = new ToggleSwitch;
        import deltotum.kit.display.alignment: Alignment;
        tb.alignment = Alignment.y;

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

        hbox.addCreated(tb);

        objectFullInfo = new TextArea();
        objectFullInfo.width = width - padding.width;
        objectFullInfo.height = 400;
        addCreated(objectFullInfo);

        output = new TextArea();
        output.width = width - padding.width;
        output.height = 150;
        addCreated(output);
    }

    void debugScene(){
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

                return false;
            };
        }
    }

    private DebugInfo createDebugInfo(DisplayObject obj)
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

        obj.addCreated(container);

        //Random color?
        auto border = new Rectangle(container.width, container.height, borderStyle);
        border.isLayoutManaged = false;

        container.addCreated(border);

        import deltotum.gui.controls.texts.text : Text;
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
