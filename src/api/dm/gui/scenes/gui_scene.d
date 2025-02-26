module api.dm.gui.scenes.gui_scene;

import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.gui.themes.theme : Theme;
import api.dm.gui.supports.sceneview : SceneView;
import api.dm.gui.components.gui_component : GuiComponent;
import api.dm.kit.sprites2d.sprite2d: Sprite2d;
import api.dm.gui.controls.control: Control;

/**
 * Authors: initkfs
 */
class GuiScene : Scene2d
{
    Theme theme;

    SceneView debugger;

    alias addCreate = Scene2d.addCreate;

    this(this ThisType)(bool isInitUDAProcessor = true)
    {
        super(isInitUDAProcessor : false);
        initProcessUDA!ThisType(isInitUDAProcessor);
    }

    void addCreate(GuiComponent guiComponent)
    {
        if (!guiComponent.hasTheme)
        {
            assert(theme, "Theme must not be null");
            guiComponent.theme = theme;
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

    override void add(Sprite2d object)
    {
        super.add(object);

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
                    if (e.keyName != ComKeyName.f12 || isPause)
                    {
                        return;
                    }

                    if (!isPause)
                    {
                        isPause = true;
                        dialogManager.showInfo("Pause!", "Info", () {
                            isPause = false;
                            eternalSprites = null;
                        });
                        eternalSprites ~= dialogManager;
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
    }

    void createDebugger()
    {
        import api.dm.gui.controls.containers.slider : Slider, SliderPos;

        auto debugWrapper = new Slider(SliderPos.right);
        addCreate(debugWrapper);
        debugger = new SceneView(this);
        debugWrapper.addContent(debugger);
        window.showingTasks ~= (dt) { debugWrapper.setInitialPos; };
    }

    override void update(double dt){
        super.update(dt);

        if (debugger && debugger.isVisible)
        {
            import Math = api.dm.math;
            import std.conv : to;

            debugger.invalidNodesCount.text = invalidNodesCount.to!dstring;
            debugger.updateTimeMs.text = Math.round(timeUpdateProcessingMs).to!dstring;
            debugger.drawTimeMs.text = Math.round(timeDrawProcessingMs).to!dstring;

            import core.memory : GC;

            auto stats = GC.stats;
            auto usedSize = stats.usedSize / 1000.0;
            debugger.gcUsedBytes.text = usedSize.to!dstring;
        }
    }

}
