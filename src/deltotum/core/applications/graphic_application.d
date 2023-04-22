module deltotum.core.applications.graphic_application;

import deltotum.core.applications.application_exit : ApplicationExit;
import deltotum.core.applications.cli_application : CliApplication;
import deltotum.kit.applications.components.graphics_component : GraphicsComponent;
import deltotum.core.applications.components.uni.uni_component : UniComponent;

/**
 * Authors: initkfs
 */
abstract class GraphicApplication : CliApplication
{
    double frameRate = 60;

    abstract
    {
        void runWait();
        bool update();
    }

    override void build(UniComponent component)
    {
        return super.build(component);
    }
}
