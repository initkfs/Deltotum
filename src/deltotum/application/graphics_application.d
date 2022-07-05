module deltotum.application.graphics_application;

import deltotum.application.components.uni.uni_component : UniComponent;

/**
 * Authors: initkfs
 */
abstract class GraphicsApplication : UniComponent
{

    abstract void initialize(double frameRate);
    abstract void runWait();
    abstract void quit();
    abstract bool update();

}
