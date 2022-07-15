module demo.cybercity.world.animals.dog;

import deltotum.display.bitmap.sprite_sheet : SpriteSheet;
import deltotum.display.bitmap.bitmap : Bitmap;
import deltotum.ai.fsm.fsm_numeric : FsmNumeric;
import deltotum.math.direction : Direction;
import deltotum.ai.fsm.fsm_string : FsmString;

import demo.cybercity.world.people.player : Player;

//TODO remove HAL layer
import bindbc.sdl;

import std.stdio : writeln;

import deltotum.utils.type_util;

/**
 * Authors: initkfs
 */
class Dog : SpriteSheet
{
    @property speed = 200;
    @property Player owner;

    private
    {
        mixin NamedEnum!("State",
            "idle",
            "walk",
            "attack",
            "death",
            "hurt");

        FsmString states;
        @property Direction runDirection = Direction.none;
    }

    this()
    {
        super(48, 48, 200);
        states = new FsmString;
    }

    override void create()
    {
        load("cybercity/town/animals/Dog2/dog2.png");
        addAnimation(State.idle, [0, 1, 2, 3], 0, true);
        addAnimation(State.walk, [
                0, 1, 2, 3, 4, 5
            ], 1);
        addAnimation(State.attack, [0, 1, 2, 3], 2);
        addAnimation(State.death, [0, 1, 2, 3], 3);
        addAnimation(State.hurt, [0, 1], 4);

        states.push(State.idle);
    }

    void run()
    {
        if (states.state != State.walk)
        {
            states.push(State.walk);
        }
    }

    void stop()
    {
        if (states.state != State.walk)
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

    override void update(double delta)
    {
        super.update(delta);

        if (owner !is null && owner.isRun && owner.runDirection == Direction.right)
        {
            //TODO direction
            runRigth;
        }
        else
        {
            stop;
        }

        const mustBeState = states.state;
        if (mustBeState.isNull)
        {
            return;
        }
        const state = mustBeState.get;
        switch (state)
        {
        case State.idle:
            playAnimation(State.idle);
            break;
        case State.walk:
            playAnimation(State.walk);
            x = x + speed * delta;
            break;
        default:
            break;
        }

    }
}
