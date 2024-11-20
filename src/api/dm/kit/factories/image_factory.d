module api.dm.kit.factories.image_factory;

import api.dm.kit.components.graphics_component : GraphicsComponent;
import api.dm.kit.sprites.images.image : Image;
import api.dm.kit.sprites.images.anim_image : AnimImage;

/**
 * Authors: initkfs
 */
class ImageFactory : GraphicsComponent
{
    Image[] images(string[] paths, int requestWidth = -1, int requestHeight = -1)
    {
        Image[] newImages;
        foreach (p; paths)
        {
            //TODO appender
            newImages ~= image(p, requestWidth, requestHeight);
        }
        return newImages;
    }

    Image image(string path, double requestWidth = -1, double requestHeight = -1)
    {
        import std.conv : to;

        auto newImage = new Image;
        build(newImage);
        int reqWidth = requestWidth.to!int;
        int reqHeight = requestHeight.to!int;
        if (!newImage.load(path, reqWidth, reqHeight))
        {
            logger.errorf("Unable to load image with width %s, height %s from path %s", reqWidth, reqHeight, path);
            //TODO log, exception, placeholder, blank image?
        }
        newImage.initialize;
        assert(newImage.isInitialized);
        newImage.create;
        assert(newImage.isCreated);
        return newImage;
    }

    AnimImage animated(string path, int frameWidth = 0, int frameHeight = 0, int frameDelay = 100, int requestWidth = -1, int requestHeight = -1)
    {
        auto newAnimated = new AnimImage(frameWidth, frameHeight, frameDelay);
        build(newAnimated);
        if (!newAnimated.load(path, requestWidth, requestHeight))
        {
            //TODO log, exception, placeholder, blank image?
        }
        newAnimated.initialize;
        assert(newAnimated.isInitialized);
        newAnimated.create;
        assert(newAnimated.isCreated);
        return newAnimated;
    }
}
