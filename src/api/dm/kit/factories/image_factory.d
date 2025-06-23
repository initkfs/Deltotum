module api.dm.kit.factories.image_factory;

import api.dm.kit.components.graphic_component : GraphicComponent;
import api.dm.kit.sprites2d.images.image : Image;
import api.dm.kit.sprites2d.images.anim_image : AnimImage;

/**
 * Authors: initkfs
 */
class ImageFactory : GraphicComponent
{
    Image[] images(string[] paths, int requestWidth = -1, int requestHeight = -1)
    {
        Image[] newImages = new Image[paths.length];
        foreach (pi, p; paths)
        {
            newImages[pi] = image(p, requestWidth, requestHeight);
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
        initCreate(newImage);
        return newImage;
    }

    AnimImage animated(string path, size_t frameCols, size_t frameRows, int frameWidth = 0, int frameHeight = 0, int frameDelay = 100, int requestWidth = -1, int requestHeight = -1)
    {
        auto newAnimated = new AnimImage(frameCols, frameRows, frameWidth, frameHeight, frameDelay);
        build(newAnimated);
        if (!newAnimated.load(path, requestWidth, requestHeight))
        {
            //TODO log, exception, placeholder, blank image?
        }
        initCreate(newAnimated);
        return newAnimated;
    }
}
