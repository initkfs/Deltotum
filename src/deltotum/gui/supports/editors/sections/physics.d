module deltotum.gui.supports.editors.sections.physics;

import deltotum.gui.controls.control : Control;
import deltotum.phys.collision.newtonian_resolver : NewtonianResolver;
import deltotum.kit.graphics.shapes.rectangle: Rectangle;
import deltotum.kit.graphics.styles.graphic_style: GraphicStyle;
import deltotum.kit.graphics.colors.rgba: RGBA;
import deltotum.kit.graphics.shapes.circle: Circle;

import Math = deltotum.math;

import std.stdio;

/**
 * Authors: initkfs
 */
class Physics : Control
{
    this()
    {
        import deltotum.kit.sprites.layouts.vertical_layout : VerticalLayout;

        // layout = new VerticalLayout(5);
        // layout.isAutoResize = true;
        // isBackground = false;
        // layout.isAlignY = false;
    }

    NewtonianResolver collisionDetector;
    Rectangle rect1;
    Rectangle rect2;
    bool isCollisionProcess;

    override void create()
    {
        super.create;

        import deltotum.kit.graphics.shapes.rectangle : Rectangle;

        rect1 = new Rectangle(50, 50, GraphicStyle(1, RGBA.red));
        rect1.x = 100;
        rect1.mass = 10;
        rect1.y = window.height / 2 - rect1.height / 2 - 80;
        addCreate(rect1);
        rect1.isPhysicsEnabled = true;

        rect1.hitbox = new Rectangle(50, 50, GraphicStyle(1, RGBA.blue));
        //rect1.hitbox = new Circle(25, GraphicStyle(1, RGBA.blue));

        rect1.onMouseDown = (e) { rect1.velocity.x = 100; rect1.velocity.y = 10; return false; };

        rect2 = new Rectangle(50, 50);
        rect2.x = 500;
        rect2.mass = 100;
        
        rect2.y = window.height / 2 - rect2.height / 2;
        addCreate(rect2);
        rect2.isPhysicsEnabled = true;

        import deltotum.kit.graphics.shapes.circle: Circle;

        //rect2.hitbox = new Rectangle(50, 50, GraphicStyle(1, RGBA.green));
        rect2.hitbox = new Circle(25, GraphicStyle(1, RGBA.green));

        collisionDetector = new NewtonianResolver;

        rect2.onMouseDown = (e) { rect2.velocity.x = -100; return false; };

    }

    override void update(double delta)
    {
        super.update(delta);

        if (!isCollisionProcess && rect1.intersect(rect2))
        {
            isCollisionProcess = true;
            collisionDetector.resolve(rect1, rect2);
            // isCollisionProcess = false;
        }

    }

}
