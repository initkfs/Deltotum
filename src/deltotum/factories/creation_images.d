module deltotum.factories.creation_images;

import deltotum.application.components.uni.uni_component : UniComponent;
import deltotum.display.images.image : Image;
import deltotum.display.images.animated_image : AnimatedImage;

/**
 * Authors: initkfs
 */
class CreationImages : UniComponent
{

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
