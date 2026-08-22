module api.dm.gui.scenes.gui_scene;

import api.dm.kit.scenes.scene3d : Scene3d;
import api.dm.gui.themes.theme : Theme;
import api.dm.gui.interacts.interact : Interact;
import api.dm.gui.supports.sceneview : SceneView;
import api.dm.gui.components.gui_component : GuiComponent;
import api.dm.kit.components.graphic_component : GraphicComponent;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class GuiScene : Scene3d
{
    Theme theme;
    Interact interact;

    SceneView debugger;

    Sprite2d[] focusQueue;
    size_t focusQueueIndex;
    size_t prevFocusIndex;

    alias addCreate = Scene3d.addCreate;

    this(this ThisType)(bool isInitUDAProcessor = true)
    {
        super(isInitUDAProcessor : false);
        initProcessUDA!ThisType(isInitUDAProcessor);
    }

    override void create()
    {
        super.create;

        import GuiConfigKeys = api.dm.gui.gui_config_keys;

        if (config.hasKey(GuiConfigKeys.guiFocusTraverse))
        {
            bool isFocusTraverse = config.getBool(GuiConfigKeys.guiFocusTraverse);

            if (isFocusTraverse)
            {

                import api.dm.com.inputs.com_keyboard : ComKeyName;

                onKeyPress ~= (ref e) {
                    if (e.keyName == ComKeyName.key_tab)
                    {
                        traverseFocus;
                    }
                    else if (e.keyName == ComKeyName.key_return)
                    {
                        if (focusQueue.length > 0)
                        {
                            auto index = focusQueueIndex > 0 ? focusQueueIndex - 1 : 0;
                            auto sp = focusQueue[index];
                            if (sp.isFocus)
                            {
                                import api.dm.gui.controls.control : Control;

                                if (auto control = cast(Control) sp)
                                {
                                    control.startVisibleAction;
                                }
                            }
                        }
                    }

                };
            }
        }
    }

    alias build = Scene3d.build;

    //TODO UniComponent
    override void build(GraphicComponent sprite)
    {
        if (auto guiComponent = cast(GuiComponent) sprite)
        {
            if (!guiComponent.hasTheme)
            {
                assert(theme, "Theme must not be null");
                guiComponent.theme = theme;
            }

            if (!guiComponent.hasInteract)
            {
                assert(interact, "Interact must not be null");
                guiComponent.interact = interact;
            }
        }

        super.build(sprite);
    }

    void addCreate(GuiComponent guiComponent)
    {
        if (!guiComponent.hasTheme)
        {
            assert(theme, "Theme must not be null");
            guiComponent.theme = theme;
        }

        if (!guiComponent.hasInteract)
        {
            assert(interact, "Interaction must not be null");
            guiComponent.interact = interact;
        }
        super.addCreate(guiComponent);
    }

    void add(GuiComponent guiComponent)
    {
        if (!guiComponent.hasTheme)
        {
            assert(theme, "Theme must not be null");
            guiComponent.theme = theme;
        }
        add(cast(Sprite2d) guiComponent);
    }

    override bool add(Sprite2d object)
    {
        if (!super.add(object))
        {
            return false;
        }

        if (auto guiSprite = cast(Control) object)
        {
            if (!guiSprite.interact.hasDialog)
            {
                import api.dm.gui.interacts.dialogs.gui_dialog_manager : GuiDialogManager;

                auto dialogManager = new GuiDialogManager;
                guiSprite.addCreate(dialogManager, 0);
                guiSprite.interact.dialog = dialogManager;

                onKeyPress ~= (ref e) {
                    import api.dm.com.inputs.com_keyboard : ComKeyName;

                    //TODO toggle pause?
                    if (e.keyName != ComKeyName.key_f12 || isFreeze)
                    {
                        return;
                    }

                    if (!isFreeze)
                    {
                        isFreeze = true;
                        externalSprites ~= dialogManager;
                        dialogManager.showInfo("Pause!", "Info", () {
                            isFreeze = false;
                            //externalSprites = null;
                        });
                    }
                };
            }

            if (!guiSprite.interact.hasPopup)
            {
                import api.dm.gui.controls.popups.gui_popup_manager : GuiPopupManager;

                auto popupManager = new GuiPopupManager;
                //TODO first, after dialogs
                guiSprite.addCreate(popupManager, 1);
                guiSprite.interact.popup = popupManager;
            }

        }

        return true;
    }

    bool addFocusTraverse(Sprite2d sprite)
    {
        //TODO reorder?
        foreach (sp; focusQueue)
        {
            if (sp is sprite)
            {
                return false;
            }
        }
        focusQueue ~= sprite;
        return true;
    }

    bool removeFocusTraverse(Sprite2d sprite)
    {
        import api.core.utils.arrays : drop;

        return focusQueue.drop(sprite);
    }

    void traverseFocus()
    {
        if (focusQueue.length == 0)
        {
            return;
        }

        if (focusQueueIndex >= focusQueue.length)
        {
            focusQueueIndex = 0;
        }

        while (focusQueueIndex < focusQueue.length)
        {
            auto currQueueIndex = focusQueueIndex;
            auto sp = focusQueue[currQueueIndex];
            focusQueueIndex++;
            if (sp.isNeedDraw)
            {
                sp.focus;
                if (prevFocusIndex != currQueueIndex)
                {
                    focusQueue[prevFocusIndex].unfocus;
                }
                prevFocusIndex = currQueueIndex;
                return;
            }
        }
    }

    void createDebugger()
    {
        debugger = new SceneView(this);
        addTaken(debugger);
        debugger.isDrawOnlyConrolled = true;
        addCreate(debugger);
    }

    override bool hasDebugger() => debugger !is null;

    override void update(float dt)
    {
        super.update(dt);

        static ubyte statFrameCounter;

        if (debugger && debugger.isVisible)
        {
            //TODO avg value
            if (statFrameCounter >= 10)
            {
                statFrameCounter = 0;

                import Math = api.dm.math;
                import std.conv : to;

                debugger.infoPanel.invalidNodesCount.text = invalidNodesCount.to!dstring;

                debugger.infoPanel.counterFps.text = Math.round(window.updateCounter.fps)
                    .to!dstring;
                debugger.infoPanel.counterFixedFps.text = Math.round(window.fixedCounter.fps)
                    .to!dstring;

                debugger.infoPanel.timeDrawScene.text = Math.round(window.timeDrawSceneMs)
                    .to!dstring;
                debugger.infoPanel.timeUpdateScene.text = Math.round(window.timeUpdateSceneMs)
                    .to!dstring;

                import core.memory : GC;

                auto stats = GC.stats;
                auto usedSize = stats.usedSize / 1000.0 / 1000.0;
                debugger.infoPanel.gcUsed.text = usedSize.to!dstring;
            }
            else
            {
                statFrameCounter++;
            }

        }
    }

    override void setDebugField(void delegate(float) onValue, float startValue = 0, float minValue = 0, float maxValue = 1, float dt = 0.01, dstring name = "Field")
    {
        if (!debugger)
        {
            return;
        }

        debugger.mainPanel.envManager.setDebugField(onValue, startValue, minValue, maxValue, dt, name);
    }

    override void setDebugColor(void delegate(RGBA) onValue, RGBA startValue = RGBA.white, dstring name = "Color")
    {
        if (!debugger)
        {
            return;
        }

        debugger.mainPanel.envManager.setDebugColor(onValue, startValue, name);
    }
}
