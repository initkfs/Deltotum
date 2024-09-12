module api.dm.kit.events.kit_event_manager;

import api.core.events.processing.event_processor : EventProcessor;
import api.core.events.event_manager: EventManager;
import api.dm.kit.events.processing.kit_event_processor : KitEventProcessor;
import api.dm.kit.scenes.scene_manager : SceneManager;

import api.core.apps.events.app_event : AppEvent;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.dm.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import api.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import api.dm.kit.windows.events.window_event : WindowEvent;

import api.dm.kit.windows.window : Window;
import api.dm.kit.scenes.scene : Scene;
import api.dm.kit.sprites.sprite : Sprite;
import std.container : DList;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class KitEventManager : EventManager
{
    Nullable!(Window) delegate(long) windowProviderById;

    void delegate(ref KeyEvent) onKey;
    void delegate(ref JoystickEvent) onJoystick;
    void delegate(ref WindowEvent) onWindow;
    void delegate(ref PointerEvent) onPointer;
    void delegate(ref TextInputEvent) onTextInput;

    void dispatchEvent(E)(ref E e)
    {
        if (!windowProviderById)
        {
            return;
        }

        const windowId = e.ownerId;

        auto mustBeTargetWindow = windowProviderById(windowId);
        if (mustBeTargetWindow.isNull)
        {
            return;
        }

        Window targetWindow = mustBeTargetWindow.get;
        Scene targetScene = targetWindow.scenes.currentScene;
        Sprite[] targets = targetScene.activeSprites;

        targetScene.runEventHandlers(e);
        if (e.isConsumed)
        {
            return;
        }

        foreach (Sprite target; targets)
        {
            target.dispatchEvent(e);
            if(e.isConsumed){
                return;
            }
        }
        
    }
}
