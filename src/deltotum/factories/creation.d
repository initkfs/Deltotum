module deltotum.factories.creation;

import deltotum.application.components.uni.uni_component : UniComponent;

import deltotum.factories.creation_images : CreationImages;
import deltotum.factories.creation_shapes: CreationShapes;

/**
 * Authors: initkfs
 */
class Creation : UniComponent
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
