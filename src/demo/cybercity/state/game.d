module demo.cybercity.state.game;

import deltotum.state.state : State;

import deltotum.display.bitmap.bitmap : Bitmap;
import deltotum.display.scrolling.scroller : Scroller;
import deltotum.display.bitmap.sprite_sheet : SpriteSheet;
import deltotum.hal.sdl.mix.sdl_mix_music : SdlMixMusic;
import deltotum.math.direction : Direction;
import deltotum.particles.emitter : Emitter;
import deltotum.particles.particle : Particle;
import deltotum.animation.interp.interpolator : Interpolator;
import deltotum.animation.interp.uni_interpolator : UniInterpolator;
import deltotum.animation.object.property.opacity_transition : OpacityTransition;
import deltotum.animation.object.motion.circular_motion_transition : CircularMotionTransition;
import deltotum.animation.object.motion.linear_motion_transition : LinearMotionTransition;
import deltotum.math.vector2d : Vector2D;

import deltotum.animation.transition : Transition;
import deltotum.animation.object.value_transition : ValueTransition;

import deltotum.physics.collision.aabb_collision.detector : AABBCollisionDetector;
import deltotum.physics.collision.newtonian_collision_resolver : NewtonianCollisionResolver;

import std.stdio;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Game : State
{
    enum gameWidth = 640;
    enum gameHeight = 480;

    private
    {
        Bitmap townBackground;
        Bitmap townBackground1;
        Bitmap townForeground;
        Bitmap townForeground1;

        Scroller backgroundScroller;
        Scroller foregroundScroller;

        SpriteSheet player;

        Emitter emitter;

        double jumpTimer = 0;
        bool jumping;
        bool fall;
        AABBCollisionDetector collisionDetector;
        NewtonianCollisionResolver collisionResolver;
        LinearMotionTransition transition;
    }

    override void create()
    {
        super.create;

        townBackground = new Bitmap;
        build(townBackground);
        townBackground1 = new Bitmap;
        build(townBackground1);
        townForeground = new Bitmap;
        build(townForeground);
        townForeground1 = new Bitmap;
        build(townForeground1);

        backgroundScroller = new Scroller;
        build(backgroundScroller);
        backgroundScroller.speed = 20;
        backgroundScroller.direction = Direction.left;

        foregroundScroller = new Scroller;
        build(foregroundScroller);
        foregroundScroller.speed = 30;
        foregroundScroller.direction = Direction.left;

        //TODO clone
        townBackground.load("cybercity/town/town_background.png", gameWidth, gameHeight);
        townBackground1.load("cybercity/town/town_background.png", gameWidth, gameHeight);
        townForeground.load("cybercity/town/town_foreground.png", gameWidth, gameHeight);
        townForeground1.load("cybercity/town/town_foreground.png", gameWidth, gameHeight);

        backgroundScroller.current = townBackground;
        backgroundScroller.next = townBackground1;

        foregroundScroller.current = townForeground;
        foregroundScroller.next = townForeground1;

        add(backgroundScroller);
        add(foregroundScroller);

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

        import deltotum.display.layer.light_layer : LightLayer;
        import deltotum.display.light.light_spot : LightSpot;

        auto lightLayer = new LightLayer(window.renderer, window.getWidth, window.getHeight);
        build(lightLayer);

        auto light = new LightSpot;
        build(light);
        light.load("world/light/lightmap2.png");
        light.x = 100;
        light.y = 100;

        lightLayer.addLight(light);
        addLayer(lightLayer);
    }

    override void update(double delta)
    {
        super.update(delta);

        enum speed = 100;

        auto worldBounds = window.getWorldBounds;

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

        if (backgroundScroller.direction == Direction.left && !right)
        {
            backgroundScroller.isScroll = false;
        }

        if (foregroundScroller.direction == Direction.left && !right)
        {
            foregroundScroller.isScroll = false;
        }

        if (backgroundScroller.direction == Direction.right && !left)
        {
            backgroundScroller.isScroll = false;
        }

        if (foregroundScroller.direction == Direction.right && !left)
        {
            foregroundScroller.isScroll = false;
        }

        if (right)
        {
            if (!up && !fall)
            {
                player.playAnimation("run");
            }

            if (player.x <= worldBounds.width / 2 - player.width)
            {
                player.x += speed * delta;
            }
            else
            {
                backgroundScroller.isScroll = true;
                foregroundScroller.isScroll = true;
            }

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
