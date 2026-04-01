module api.dm.gui.supports.debuggers.base_debugger_panel;

import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.scenes.scene2d : Scene2d;

/**
 * Authors: initkfs
 */
class BaseDebuggerPanel : Container
{

    Scene2d targetScene;

    this(Scene2d newScene)
    {
        assert(newScene);
        this.targetScene = newScene;
        setVLayout;
        layout.isAutoResize = true;
    }
}
