module deltotum.kit.sprites.animations.animation;

import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class Animation : Sprite
{
    bool isInverse;
    bool isCycle;

    void delegate() onEnd;

}
