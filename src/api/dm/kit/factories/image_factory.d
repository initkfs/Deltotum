module api.dm.kit.factories.image_factory;

import api.dm.kit.components.window_component: WindowComponent;
import api.dm.kit.sprites.images.image : Image;
import api.dm.kit.sprites.images.animated_image : AnimatedImage;

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

    Image image(string path, int requestWidth = -1, int requestHeight = -1)
    {
        auto newImage = new Image;
        build(newImage);
        if (!newImage.load(path, requestWidth, requestHeight))
        {
            //TODO log, exception, placeholder, blank image?
        }
        newImage.create;
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
