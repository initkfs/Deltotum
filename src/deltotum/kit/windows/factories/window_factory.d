module deltotum.kit.windows.factories.window_factory;

import deltotum.kit.apps.components.graphics_component : GraphicsComponent;
import deltotum.kit.windows.window : Window;

/**
 * Authors: initkfs
 */
abstract class WindowFactory : GraphicsComponent
{

    abstract
    {
        Window createWindow();
    }
}
