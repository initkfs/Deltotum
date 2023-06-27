module deltotum.gui.supports.editors.sections.physics;

import deltotum.gui.controls.control : Control;
import deltotum.phys.collision.newtonian_resolver : NewtonianResolver;
import deltotum.kit.graphics.shapes.rectangle : Rectangle;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.graphics.shapes.circle : Circle;
import deltotum.math.vector2d : Vector2d;
import deltotum.kit.sprites.sprite: Sprite;
import deltotum.kit.sprites.images.image: Image;

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
    Sprite rect3;

    override void create()
    {
        super.create;

        import deltotum.kit.graphics.shapes.rectangle : Rectangle;

        import deltotum.kit.sprites.images.image: Image;

        rect1 = new Rectangle(50, 50, GraphicStyle(1, RGBA.red));
       
        rect1.x = 100;
        rect1.mass = 100;
        rect1.y = window.height / 2 - rect1.height / 2;
        addCreate(rect1);

        rect1.isPhysicsEnabled = true;
        spriteForCollisions ~= rect1;

        //rect1.hitbox = new Rectangle(50, 50, GraphicStyle(1, RGBA.blue));
        auto c = new Circle(25, GraphicStyle(1, RGBA.blue));
        c.isVisible = false;
        c.x = 35;
        rect1.hitbox = c;
        // rect1.onScreenBoundsIsStop = () {
        //     rect1.velocity = rect1.velocity.reflect;
        //     return false;
        // };

       

        rect2 = new Rectangle(50, 50);

         rect1.onMouseDown = (e) {
            rect1.velocity.x = 50;
            rect2.velocity.x = -50;
            //rect1.velocity.y = 50; 
            //rect1.gravity = Vector2d(0, 10);
            return false;
        };
       
        rect2.x =  window.width - 200;
        rect2.mass = 10;

        rect2.y = window.height / 2 - rect2.height / 2;
        addCreate(rect2);
        rect2.isPhysicsEnabled = true;

        import deltotum.kit.graphics.shapes.circle : Circle;

        //rect2.hitbox = new Rectangle(50, 50, GraphicStyle(1, RGBA.green));
        rect2.hitbox = new Circle(25, GraphicStyle(1, RGBA.green));
        rect2.hitbox.isVisible = false;

        // rect2.onScreenBoundsIsStop = () {
        //     rect2.velocity = rect2.velocity.reflect;
        //     return false;
        // };

        collisionDetector = new NewtonianResolver;

        rect2.onMouseDown = (e) { rect2.velocity.x = -20; return false; };
        spriteForCollisions ~= rect2;

        rect3 = new Rectangle(50, 50, GraphicStyle(1, RGBA.green));
        rect3.x = window.width - 100;
        rect3.y = window.height - 200;
        rect3.isPhysicsEnabled = true;
        rect3.mass = 10;
        addCreate(rect3);
        rect3.hitbox = new Circle(25, GraphicStyle(1, RGBA.green));
        spriteForCollisions ~= rect3;

        onCollision = (first, second) {
            collisionDetector.resolve(first, second);
        };

    }
}
