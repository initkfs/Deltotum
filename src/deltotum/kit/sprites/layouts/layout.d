module deltotum.kit.sprites.layouts.layout;

import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
abstract class Layout
{
    bool isAlignX;
    bool isAlignY;

    abstract void applyLayout(Sprite root);
}
