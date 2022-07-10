module game.state.demo_state;

import deltotum.state.state : State;

import deltotum.display.bitmap.bitmap : Bitmap;
import deltotum.display.scrolling.scroller : Scroller;
import deltotum.display.bitmap.sprite_sheet : SpriteSheet;
import deltotum.hal.sdl.mix.sdl_mix_music : SdlMixMusic;
import deltotum.math.direction : Direction;
import deltotum.particles.emitter : Emitter;
import deltotum.particles.particle : Particle;
import deltotum.animation.interp.interpolator: Interpolator;
import deltotum.animation.interp.uni_interpolator: UniInterpolator;

import deltotum.animation.transition: Transition;

import deltotum.physics.collision.aabb_collision.detector : AABBCollisionDetector;
import deltotum.physics.collision.newtonian_collision_resolver : NewtonianCollisionResolver;

import std.stdio;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class DemoState : State
{
    enum gameWidth = 640;
    enum gameHeight = 480;

    private
    {
        Bitmap foreground;
        Bitmap foreground2;
        SpriteSheet player;
        Scroller scroller;
        Emitter emitter;

        double jumpTimer = 0;
        bool jumping;
        bool fall;
        AABBCollisionDetector collisionDetector;
        NewtonianCollisionResolver collisionResolver;
        Transition transition;
    }
    override void create()
    {
        foreground = new Bitmap;
        build(foreground);
        foreground2 = new Bitmap;
        build(foreground2);

        scroller = new Scroller;
        add(scroller);
        build(scroller);
        scroller.speed = 30;
        scroller.direction = Direction.left;

        foreground.load("foreground.png", gameWidth, gameHeight);
        foreground2.load("foreground.png", gameWidth, gameHeight);

        scroller.current = foreground;
        scroller.next = foreground2;

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

        emitter = new Emitter;
        emitter.countPerFrame = 1;
        build(emitter);
        add(emitter);

        emitter.lifetime = 200;
        emitter.countPerFrame = 1;
        emitter.particleVelocity.y = 100;

        emitter.particleFactory = () {
            //TODO cache
            auto particle = new Particle();
            build(particle);
            particle.load("laser1.png", 12, 18);
            //TODO fix implicit boolean parameter casting
            particle.addAnimation("idle", [0], 0, true);
            return particle;
        };

        emitter.particleMass = 0.1;
        player.mass = 0.1;

        emitter.x = 100 + player.width / 2;
        emitter.y = 200;

        collisionResolver = new NewtonianCollisionResolver;
        collisionDetector = new AABBCollisionDetector;
        // emitter.onParticleUpdate = (Particle p) {
        //     if (collisionDetector.intersect(p.bounds, player.bounds))
        //     {
        //         collisionResolver.resolve(p, player);
        //         return false;
        //     }

        //     return true;
        // };

        transition = new Transition(0, 1, 2000, window.frameRate);
        build(transition);
        transition.isInverse = true;
        transition.onValue = (value) { foreground.opacity = value; };
        transition.interpolator.interpolateMethod = &transition.interpolator.elasticOut;
        add(transition);
        transition.run;

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

        if (scroller.direction == Direction.left && !right)
        {
            scroller.isScroll = false;
        }

        if (scroller.direction == Direction.right && !left)
        {
            scroller.isScroll = false;
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
                scroller.isScroll = true;
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
