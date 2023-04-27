module deltotum.kit.factories.creation;

import deltotum.kit.apps.components.graphics_component : GraphicsComponent;

import deltotum.kit.factories.creation_images : CreationImages;
import deltotum.kit.factories.creation_shapes: CreationShapes;

/**
 * Authors: initkfs
 */
class Creation : GraphicsComponent
{

    CreationImages images;
    CreationShapes shapes;

    this(CreationImages images, CreationShapes shapes)
    {
        import std.exception : enforce;

        enforce(images !is null, "Image factory must not be null");
        enforce(shapes !is null, "Shape factory must not be null");

        this.images = images;
        this.shapes = shapes;
    }

}
