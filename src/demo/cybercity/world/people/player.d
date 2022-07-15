module demo.cybercity.world.people.player;

import deltotum.display.bitmap.sprite_sheet : SpriteSheet;
import deltotum.display.bitmap.bitmap : Bitmap;
import deltotum.ai.fsm.fsm_numeric : FsmNumeric;
import deltotum.math.direction : Direction;

//TODO remove HAL layer
import bindbc.sdl;

import std.stdio : writeln;

import deltotum.utils.type_util;

/**
 * Authors: initkfs
 */
class Player : SpriteSheet
{
    @property speed = 100;

    private
    {
        mixin NamedEnum!("Animation",
            "idle",
            "walk",
            "run",
            "run_shoot",
            "jump",
            "jump_back",
            "climp",
            "crouch",
            "shoot",
            "hurt");
    }

    this()
    {
        super(71, 67, 200);
    }

    override void create()
    {
        load("player.png");
        addAnimation(Animation.idle, [0, 1, 2, 3], 0, true);
        addAnimation(Animation.walk, [
                0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
            ], 1);
        addAnimation(Animation.run, [0, 1, 2, 3, 4, 5, 6, 7], 2);
        addAnimation(Animation.run_shoot, [0, 1, 2, 3, 4, 5, 6, 7], 3);
        addAnimation(Animation.jump, [0, 1, 2, 3], 4);
        addAnimation(Animation.jump_back, [0, 1, 2, 3, 4, 5, 6], 5);
        addAnimation(Animation.climp, [0, 1, 2, 3, 4, 5], 6);
        addAnimation(Animation.crouch, [0], 7);
        addAnimation(Animation.shoot, [0], 8);
        addAnimation(Animation.hurt, [0], 9);
    }

    void stand()
    {
        playAnimation(Animation.idle);
    }

    void runLeft(double delta)
    {
        playAnimation(Animation.run, SDL_RendererFlip.SDL_FLIP_HORIZONTAL);
        x = x - (speed * delta);
    }

    void runRigth(double delta)
    {
        playAnimation(Animation.run);
        auto worldBounds = window.getWorldBounds;
        if (x <= worldBounds.width / 2 - width)
        {
            x = x + (speed * delta);
        }
    }

    void jump()
    {
        playAnimation(Animation.jump);
    }

    void crouch()
    {
        playAnimation(Animation.crouch);
    }
}
