module api.dm.kit.factories.image_factory;

import api.dm.kit.components.window_component: WindowComponent;
import api.dm.kit.sprites.images.image : Image;
import api.dm.kit.sprites.images.animated_image : AnimatedImage;

struct image {
    string path;
    double width = -1;
    double height = -1;
    bool isAdd;
}

/**
 * Authors: initkfs
 */
class ImageFactory : WindowComponent
{
    Image[] images(string[] paths, int requestWidth = -1, int requestHeight = -1){
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
        import std.conv: to;
        auto newImage = new Image;
        build(newImage);
        if (!newImage.load(path, requestWidth.to!int, requestHeight.to!int))
        {
            //TODO log, exception, placeholder, blank image?
        }
        newImage.initialize;
        assert(newImage.isInitialized);
        newImage.create;
        assert(newImage.isCreated);
        return newImage;
    }

    AnimatedImage animated(string path, int frameWidth = 0, int frameHeight = 0, int commonFrameDelay = 100, int requestWidth = -1, int requestHeight = -1)
    {
        auto newAnimated = new AnimatedImage(frameWidth, frameHeight, commonFrameDelay);
        build(newAnimated);
        if (!newAnimated.load(path, requestWidth, requestHeight))
        {
            //TODO log, exception, placeholder, blank image?
        }
        newAnimated.create;
        return newAnimated;
    }
}
