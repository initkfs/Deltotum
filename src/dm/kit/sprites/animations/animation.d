module dm.kit.sprites.animations.animation;

import dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class Animation : Sprite
{
    bool isInverse;
    bool isCycle;

    void delegate() onEnd;

}
