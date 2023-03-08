module deltotum.core.applications.graphic_application;

import deltotum.core.applications.cli_application : CliApplication;
import deltotum.engine.applications.components.graphics_component : GraphicsComponent;
import deltotum.core.applications.components.uni.uni_component : UniComponent;

/**
 * Authors: initkfs
 */
abstract class GraphicApplication : CliApplication
{
    double frameRate = 60;

    GraphicsComponent graphicsComponentBuilder;

    override void build(UniComponent component)
    {
        return super.build(component);
    }

    void build(GraphicsComponent component)
    {
        graphicsComponentBuilder.build(component);
    }
}
