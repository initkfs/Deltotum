module demo.cybercity.world.people.player;

import deltotum.display.bitmap.sprite_sheet : SpriteSheet;
import deltotum.display.bitmap.bitmap : Bitmap;
import deltotum.ai.fsm.fsm_string : FsmString;
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
    @property Direction runDirection = Direction.none;

    private
    {
        mixin NamedEnum!("State",
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

        FsmString states;

    }

    this()
    {
        super(71, 67, 200);
        states = new FsmString;
    }

    override void create()
    {
        load("player.png");
        addAnimation(State.idle, [0, 1, 2, 3], 0, true);
        addAnimation(State.walk, [
                0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
            ], 1);
        addAnimation(State.run, [0, 1, 2, 3, 4, 5, 6, 7], 2);
        addAnimation(State.run_shoot, [0, 1, 2, 3, 4, 5, 6, 7], 3);
        addAnimation(State.jump, [0, 1, 2, 3], 4);
        addAnimation(State.jump_back, [0, 1, 2, 3, 4, 5, 6], 5);
        addAnimation(State.climp, [0, 1, 2, 3, 4, 5], 6);
        addAnimation(State.crouch, [0], 7);
        addAnimation(State.shoot, [0], 8);
        addAnimation(State.hurt, [0], 9);

        states.push(State.idle);
    }

    void stop()
    {
        if (states.state != State.run)
        {
            return;
        }
        states.pop;
        stand;
    }

    void stand()
    {
        while (!states.isEmpty && states.state != State.idle)
        {
            states.pop;
        }
    }

    bool isRun()
    {
        return states.state == State.run;
    }

    void run()
    {
        if (states.state != State.run)
        {
            states.push(State.run);
        }
    }

    void runLeft()
    {
        run;
        runDirection = Direction.left;
    }

    void runRigth()
    {
        run;
        runDirection = Direction.right;
    }

    void jump()
    {
        states.push(State.jump);
    }

    void crouch()
    {
        states.push(State.crouch);
    }

    override void update(double delta)
    {
        super.update(delta);

        const mustBeState = states.state;
        if (mustBeState.isNull)
        {
            return;
        }
        string state = mustBeState.get;
        switch (state)
        {
        case State.idle:
            playAnimation(State.idle);
            break;
        case State.run:
            if (runDirection == Direction.right)
            {
                playAnimation(State.run);
                auto worldBounds = window.getWorldBounds;
                if (x <= worldBounds.width / 2 - width)
                {
                    x = x + (speed * delta);
                }
            }
            else if (runDirection == Direction.left)
            {
                playAnimation(State.run, SDL_RendererFlip.SDL_FLIP_HORIZONTAL);
                x = x - (speed * delta);
            }
            break;
        case State.jump:
            playAnimation(State.jump);
            states.pop;
            break;
        case State.crouch:
            playAnimation(State.crouch);
            states.pop;
            break;
        default:
            break;
        }
    }
}
