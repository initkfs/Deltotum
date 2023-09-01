module deltotum.gui.supports.editors.sections.physics;

import deltotum.gui.controls.control : Control;
import deltotum.phys.collision.newtonian_resolver : NewtonianResolver;
import deltotum.kit.graphics.shapes.rectangle : Rectangle;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.graphics.shapes.circle : Circle;
import deltotum.math.vector2d : Vector2d;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.sprites.images.image : Image;
import deltotum.kit.sprites.images.image : Image;
import deltotum.sys.chipmunk.chipm_space : ChipmSpace;
import deltotum.sys.chipmunk.chipm_body : ChipmBody;
import deltotum.sys.chipmunk.chipm_shape : ChipmShape;
import deltotum.math.random : Random;

import Math = deltotum.math;

import std.stdio;

import chipmunk;

/**
 * Authors: initkfs
 */
class Physics : Control
{
    Random random;
    this()
    {
        import deltotum.kit.sprites.layouts.vlayout : VLayout;

        // layout = new VLayout(5);
        // layout.isAutoResize = true;
        // isBackground = false;
        // layout.isAlignY = false;

        random = new Random;
    }

    private
    {
        ChipmShape ground;
        ChipmShape ground2;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    override void create()
    {
        super.create;

        import deltotum.kit.graphics.shapes.rectangle : Rectangle;

        auto space = new ChipmSpace;
        physSpace = space;

        space.width = window.width;
        space.height = window.height;
        space.setGravityNorm(0, -5);

        ground = space.newStaticSegmentShape(Vector2d(0, 300), Vector2d(window.width, 700));
        ground.setFriction(1.0);

        ground2 = space.newStaticSegmentShape(Vector2d(window.width - 10, 10), Vector2d(window.width - 10, window
                .height));
        ground2.setFriction(1.0);

        import deltotum.gui.controls.buttons.button : Button;

        auto c = new Button("Run!");
        c.isBackground = true;
        c.x = 100;
        c.y = 100;
        addCreate(c);

        c.onAction = (ref e) {
            foreach (i; 0 .. 100)
            {
                createShape;
            }
            c.isVisible = false;
        };
    }

    Sprite createShape()
    {
        enum radius = 25;
        auto obj = new Circle(radius, GraphicStyle(1, RGBA.green, true, RGBA.red));

        addCreate(obj);

        cpFloat mass = random.randomBetween!double(1.0, 100);

        cpFloat moment = physSpace.momentForCircle(mass, 0, radius);

        auto ballBody = new ChipmBody(mass, moment);
        physSpace.addBody(ballBody.getObject);
        ballBody.setPosition(Vector2d(200, 200));

        ChipmShape ballShape = ChipmShape.newCircleShape(ballBody, radius);

        ballShape.setFriction(random.randomBetween(0.0, 2.0));
        ballShape.setElasticity(random.randomBetween(0.0, 2.0));

        physSpace.addShape(ballShape.getObject);
        ballBody.shape = ballShape;
        obj.physBody = ballBody;

        return obj;
    }

    override bool draw()
    {
        super.draw;
        graphics.drawLine(0, 300, window.width, 700, RGBA
                .red);

        graphics.drawLine(window.width - 10, 10, window.width - 10, window.height, RGBA
                .red);
        return true;
    }
}
