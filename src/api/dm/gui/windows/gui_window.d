module api.dm.gui.windows.gui_window;

import api.dm.kit.windows.window : Window;
import api.dm.com.graphics.com_window : ComWindow;
import api.dm.gui.themes.theme : Theme;
import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.kit.scenes.scene : Scene;

/**
 * Authors: initkfs
 */
class GuiWindow : Window
{

    Theme theme;

    this(ComWindow window)
    {
        super(window);
    }

    alias build = Window.build;

    override void build(Scene scene)
    {
        //simplification to prevent overload set growth
        if (auto guiScene = cast(GuiScene) scene)
        {
            assert(theme, "Theme must not be null");
            guiScene.theme = theme;
        }

        super.build(scene);
    }

}
