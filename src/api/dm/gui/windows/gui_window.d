module api.dm.gui.windows.gui_window;

import api.dm.kit.windows.window : Window;
import api.dm.com.graphic.com_window : ComWindow;
import api.dm.gui.themes.theme : Theme;
import api.dm.gui.interacts.interact : Interact;
import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.kit.scenes.scene2d : Scene2d;

/**
 * Authors: initkfs
 */
class GuiWindow : Window
{

    Theme theme;
    Interact interact;

    this(ComWindow window)
    {
        super(window);
    }

    alias build = Window.build;

    override void build(Scene2d scene)
    {
        //simplification to prevent overload set growth
        if (auto guiScene = cast(GuiScene) scene)
        {
            assert(theme, "Theme must not be null");
            guiScene.theme = theme;
            guiScene.interact = interact;
        }

        super.build(scene);
    }

    override void dispose()
    {
        if (gpuDevice && comWindow)
        {
            if (const err = gpuDevice.releaseFromWindow(comWindow))
            {
                throw new Exception(err.toString);
            }
            logger.trace("Release window from GPU device");
        }

        super.dispose;
    }

}
