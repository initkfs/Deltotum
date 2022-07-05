module game.state.demo_state;

import deltotum.state.state : State;

import deltotum.display.bitmap.bitmap : Bitmap;
import deltotum.display.bitmap.sprite_sheet : SpriteSheet;
import deltotum.hal.sdl.mix.sdl_mix_music : SdlMixMusic;

import std.stdio;

import bindbc.sdl;

class DemoState : State
{
    enum gameWidth = 640;
    enum gameHeight = 480;

    private
    {
        Bitmap foreground;
        SpriteSheet player;

        double jumpTimer = 0;
        bool jumping;
        bool fall;
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

        player = new SpriteSheet(71, 67, 160);
        build(player);
        player.load("player.png");

        player.addAnimation("idle", [0, 1, 2, 3], 0, true);
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

        player.x = 100;
        player.y = 350;

        add(player);
    }

    override void update(double delta)
    {
        super.update(delta);

        enum speed = 100;

        auto up = input.pressed(SDLK_w);
        auto down = input.pressed(SDLK_s);
        auto left = input.pressed(SDLK_a);
        auto right = input.pressed(SDLK_d);
        //auto shoot = input.pressed(SDLK_SPACE);

        if (up && down)
        {
            up = false;
            down = false;
        }

        if (left && right)
        {
            left = false;
            right = false;
        }

        if (right)
        {
            if (!up && !fall)
            {
                player.playAnimation("run");
            }
            player.x += speed * delta;
        }
        else if (left)
        {
            if (!up && !fall)
            {
                player.playAnimation("run", SDL_RendererFlip.SDL_FLIP_HORIZONTAL);
            }

            player.x -= speed * delta;
        }
        else if (up)
        {
            player.playAnimation("jump");
        }
        else if (down)
        {
            player.playAnimation("crouch");
        }
        else
        {
            player.playAnimation("idle");
        }

        if (up)
        {
            player.velocity.y = -5000 * delta;
            fall = false;
            jumping = true;
        }
        else
        {
            if (jumping)
            {
                player.velocity.y = 5000 * delta;
                jumping = false;
                fall = true;
            }
        }

        if (fall && player.y >= 350)
        {
            player.velocity.y = 0;
            fall = false;
            jumping = false;
        }

    }
}
