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
import deltotum.ui.text : Text;

import deltotum.animation.transition : Transition;
import deltotum.animation.object.value_transition : ValueTransition;

import deltotum.physics.collision.aabb_collision.detector : AABBCollisionDetector;
import deltotum.physics.collision.newtonian_collision_resolver : NewtonianCollisionResolver;

import std.stdio;
import std.format : format;

import demo.cybercity.world.town.street1 : Street1;
import demo.cybercity.world.town.street2 : Street2;
import demo.cybercity.world.people.player : Player;
import demo.cybercity.world.animals.dog: Dog;

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
        Street1 street1;
        Street2 street2;

        Scroller backgroundScroller;
        Scroller foregroundScroller;

        Player player;
        Dog dog;

        Emitter emitter;

        double jumpTimer = 0;
        bool jumping;
        bool fall;
        AABBCollisionDetector collisionDetector;
        NewtonianCollisionResolver collisionResolver;
        LinearMotionTransition transition;
        Text fps;
    }

    override void create()
    {
        super.create;

        townBackground = new Bitmap;
        build(townBackground);
        townBackground1 = new Bitmap;
        build(townBackground1);

        backgroundScroller = new Scroller;
        build(backgroundScroller);
        backgroundScroller.speed = 20;
        backgroundScroller.direction = Direction.left;

        townBackground.load("cybercity/town/town_background.png", gameWidth, gameHeight);
        townBackground1.load("cybercity/town/town_background.png", gameWidth, gameHeight);

        backgroundScroller.current = townBackground;
        backgroundScroller.next = townBackground1;

        street1 = new Street1;
        build(street1);
        street1.create;

        street2 = new Street2;
        build(street2);
        street2.create;

        foregroundScroller = new Scroller;
        build(foregroundScroller);
        foregroundScroller.speed = 30;
        foregroundScroller.direction = Direction.left;

        foregroundScroller.current = street1;
        foregroundScroller.next = street2;

        add(backgroundScroller);
        add(foregroundScroller);

        player = new Player;
        build(player);
        player.create;

        add(player);

        player.x = 100;
        player.y = 370;

        dog = new Dog;
        build(dog);
        dog.create;
        dog.owner = player;
        add(dog);

        dog.x = 50;
        dog.y = 410;

        import demo.cybercity.world.vehicles.police: Police;
        auto police = new Police;
        build(police);
        police.create;
        add(police); 

        fps = new Text(assets.defaultFont);
        build(fps);
        fps.x = 10;
        fps.y = 10;
        fps.text = "Hello";
        add(fps);
    }

    override void update(double delta)
    {
        super.update(delta);

        const timeCycle = timeEventProcessing + timeUpdate;
        string fpsInfo = format("%s. u: %s ms, e: %s ms, c: %s ms", timeRate, timeUpdate, timeEventProcessing, timeCycle);
        fps.text = fpsInfo;

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
                player.runRigth;
            }

            if (player.x >= worldBounds.width / 2 - player.width)
            {
                backgroundScroller.isScroll = true;
                foregroundScroller.isScroll = true;
            }
        }
        else if (left)
        {
            if (!up && !fall)
            {
                player.runLeft;
            }
        }
        else if (up)
        {
            player.jump;
        }
        else if (down)
        {
            player.crouch;
        }
        else
        {
            player.stop;
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
