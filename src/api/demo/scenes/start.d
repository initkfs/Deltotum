module api.demo.demo1.scenes.start;

import api.dm.kit.scenes.scene : Scene;
import api.dm.gui.containers.vbox : VBox;
import api.dm.gui.containers.hbox : HBox;
import api.dm.gui.controls.buttons.button : Button;
import api.dm.kit.sprites.textures.texture : Texture;
import api.dm.kit.sprites.images.image : Image;

import Math = api.dm.math;
import api.math.random : Random;
import api.math.geom2.vec2 : Vec2d;

import api.dm.kit.factories;

/**
 * Authors: initkfs
 */
class Start : Scene
{
    this()
    {
        name = "start";
    }

    import api.math;
    import api.dm.kit.graphics.colors.rgba : RGBA;

    import api.dm.phys.steerings.steering_behavior;

    Random rnd;

    @StubF(50, 50, true) Texture item1;

    SteeringBehavior sb;

    public float mass = 15;
    public float maxVelocity = 3;
    public float maxForce = 15;

    override void create()
    {
        super.create;
        rnd = new Random;

        sb = new SteeringBehavior;

        item1.isPhysicsEnabled = true;

        item1.velocity = Vec2d(0, 15);
        item1.move(window.width / 2, window.height / 2);

        createDebugger;

        pointerLastPos = input.pointerPos;
    }

    Vec2d pointerLastPos;

    override void update(double dt)
    {
        super.update(dt);

        auto pdx = Math.abs(input.pointerPos.x - pointerLastPos.x);
        auto pdy = Math.abs(input.pointerPos.y - pointerLastPos.y);
        pointerLastPos = input.pointerPos;

        auto mousePos = input.pointerPos;
        Vec2d steer;

        steer = sb.evadeVelocity(item1.pos, input.pointerPos, item1.velocity, Vec2d(pdx, pdy), 10);

        // auto wres = sb.wander(item1.velocity, 10, WanderCircle(150, 200), WanderAngle(item1.angle, 0.3, 50), rnd);
        // item1.angle = wres.newWanderAngleDeg;
        // steer = wres.velocity;
        //if (item1.pos.subtract(mousePos).length > 200)
        //{
          //  steer = sb.arrivalVelocity(item1.pos, input.pointerPos, item1.velocity, 50, 20);
        //}
        //else
        //{
        //    steer = sb.fleeVelocity(item1.pos, input.pointerPos, item1.velocity, 20);
        //}

        if (!item1.isInScreenBounds)
        {
            item1.velocity = Vec2d.zero;
        }
        else
        {
            item1.velocity = steer;
        }

    }

    override void draw()
    {
        super.draw;
    }
}
