module game.state.demo_state;

import deltotum.state.state : State;

import deltotum.display.bitmap.bitmap : Bitmap;
import deltotum.display.bitmap.sprite_sheet : SpriteSheet;

import std.stdio;

class DemoState : State
{
    enum gameWidth = 640;
    enum gameHeight = 480;

    private
    {
        Bitmap foreground;
        SpriteSheet player;
    }
    override void create()
    {
        foreground = new Bitmap;
        build(foreground);

        bool isLoad = foreground.load("foreground.png", gameWidth, gameHeight);
        if (!isLoad)
        {
            logger.error("Unable to load test sprite");
        }

        add(foreground);

        auto player = new SpriteSheet(71, 67, 100);
        build(player);
        player.load("player.png");

        player.addAnimation("idle", [0, 1, 2, 3]);
        player.addAnimation("walk", [
                0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
            ], 1);
        player.addAnimation("run", [0, 1, 2, 3, 4, 5, 6, 7], 2);
        player.addAnimation("run-shoot", [0, 1, 2, 3, 4, 5, 6, 7], 3);
        player.addAnimation("jump", [0, 1, 2, 3], 4);
        player.addAnimation("jump-back", [0, 1, 2, 3, 4, 5, 6], 5);
        player.addAnimation("climp", [0, 1, 2, 3, 4, 5], 6);
        player.addAnimation("crouch", [0], 7);
        player.addAnimation("shoot", [0], 8);
        player.addAnimation("hurt", [0], 9);

        // player.playAnimation("idle");
        player.x = 100;
        player.y = 350;

        add(player);
    }

    override void update(double delta)
    {
        super.update(delta);
    }
}
