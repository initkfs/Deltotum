module api.dm.gui.supports.editors.sections.graphics;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.graphics.colors.rgba : RGBA;

import Math = api.dm.math;
import api.math.geom2.vec2 : Vec2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import std.stdio;

/**
 * Authors: initkfs
 */
class Grahpics : Control
{
    this()
    {
        id = "deltotum_gui_editor_section_graphics";
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    override void create()
    {
        super.create;

        import api.dm.gui.containers.vbox : VBox;

        auto root = new VBox;
        root.isLayoutManaged = false;
        root.y = 350;
        addCreate(root);
        root.enableInsets;

        import api.dm.gui.containers.hbox : HBox;

        auto shapeContainer = new HBox;
        root.addCreate(shapeContainer);
        shapeContainer.enableInsets;

        import api.dm.kit.sprites.shapes.circle : Circle;

        auto circle = new Circle(20, GraphicStyle(1, RGBA.red));
        shapeContainer.addCreate(circle);

        auto circleFill = new Circle(20, GraphicStyle(1, RGBA.blue, true, RGBA.blue));
        shapeContainer.addCreate(circleFill);

        import api.dm.kit.sprites.shapes.rectangle : Rectangle;

        auto rect = new Rectangle(50, 50, GraphicStyle(1, RGBA.yellow));
        shapeContainer.addCreate(rect);

        auto rectFill = new Rectangle(50, 50, GraphicStyle(1, RGBA.green, true, RGBA.green));
        shapeContainer.addCreate(rectFill);

        import api.dm.kit.sprites.shapes.regular_polygon : RegularPolygon;

        auto reg = new RegularPolygon(50, 50, GraphicStyle(1, RGBA.lightcoral), 10);
        shapeContainer.addCreate(reg);

        auto regFill = new RegularPolygon(50, 50, GraphicStyle(1, RGBA.lightsteelblue, true, RGBA
                .lightsteelblue), 10);
        shapeContainer.addCreate(regFill);

    }

    override bool draw()
    {
        super.draw();

        graphics.line(20, 100, 200, 100, RGBA.red);
        graphics.line(20, 110, 200, 110, RGBA.yellow);
        graphics.line(20, 120, 200, 120, RGBA.green);

        graphics.setColor(RGBA.pink);
        graphics.line(20, 140, 200, 140);
        graphics.line(20, 150, 200, 150);
        graphics.restoreColor;

        graphics.setColor(RGBA.lightblue);
        foreach (i; 0 .. 10)
        {
            graphics.point(220 + i * 5, 100);
        }

        graphics.linePoints(Vec2d(220, 120), Vec2d(250, 120), (p) {
            graphics.point(p);
            return true;
        });

        graphics.circlePoints(Vec2d(235, 150), 10, (p) {
            graphics.point(p);
            return true;
        });

        graphics.restoreColor;

        graphics.fillTriangle(Vec2d(300, 100), Vec2d(325, 150), Vec2d(350, 100), RGBA
                .yellowgreen);
        graphics.fillTriangle(Vec2d(360, 150), Vec2d(410, 150), Vec2d(385, 100), RGBA
                .yellowgreen);
        graphics.fillTriangle(Vec2d(420, 150), Vec2d(450, 100), Vec2d(430, 200), RGBA
                .yellowgreen);

        graphics.fillRect(480, 100, 50, 20, RGBA.lightsalmon);
        graphics.rect(480, 130, 50, 20, RGBA.lightcoral);

        graphics.setColor(RGBA.lightskyblue);

        graphics.bezier(Vec2d(550, 150), Vec2d(510, 150), Vec2d(580, 100));

        graphics.ellipse(Vec2d(650, 100), Vec2d(40, 20), RGBA.lightseagreen, true, false);
        graphics.ellipse(Vec2d(650, 150), Vec2d(40, 20), RGBA.lightseagreen, false, true);

        import api.dm.com.graphics.com_blend_mode : ComBlendMode;

        graphics.fillRect(750, 100, 50, 50, RGBA.lightpink);
        auto color2 = RGBA.lightcoral;
        color2.a = 0.5;
        graphics.fillRect(775, 100, 50, 50, color2);

        auto points = [
            Vec2d(20, 200),
            Vec2d(75, 240),
            Vec2d(50, 270),
            Vec2d(40, 260),
            Vec2d(10, 270),
        ];
        graphics.polygon(points);

        version (DmAddon)
        {
            import Delaunay = api.dm.addon.math.geom2.triangulations.delaunay;

            auto res = Delaunay.triangulate(points);

            foreach (t; res)
            {
                graphics.line(t.a, t.b);
                graphics.line(t.b, t.c);
                graphics.line(t.c, t.a);
                //graphics.fillTriangle(t.a, t.b, t.c, RGBA.red);
            }
        }

        graphics.restoreColor;

        graphics.point(150, 200);
        graphics.arc(150, 200, 0, 90, 50);

        return true;
    }
}
