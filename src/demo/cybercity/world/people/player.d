module demo.cybercity.world.people.player;

import deltotum.display.bitmap.sprite_sheet : SpriteSheet;
import deltotum.display.bitmap.bitmap : Bitmap;

/**
 * Authors: initkfs
 */
class Player : SpriteSheet {

    this(){
        super(71, 67, 200);
    }

    override void create(){
        load("player.png");
        addAnimation("idle", [0, 1, 2, 3], 0, true);
        addAnimation("walk", [
                0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
            ], 1);
        addAnimation("run", [0, 1, 2, 3, 4, 5, 6, 7], 2);
        addAnimation("run-shoot", [0, 1, 2, 3, 4, 5, 6, 7], 3);
        addAnimation("jump", [0, 1, 2, 3], 4);
        addAnimation("jump-back", [0, 1, 2, 3, 4, 5, 6], 5);
        addAnimation("climp", [0, 1, 2, 3, 4, 5], 6);
        addAnimation("crouch", [0], 7);
        addAnimation("shoot", [0], 8);
        addAnimation("hurt", [0], 9);
    }
}