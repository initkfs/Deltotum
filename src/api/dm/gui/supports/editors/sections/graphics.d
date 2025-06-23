module api.dm.gui.supports.editors.sections.graphic;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
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

        import api.dm.gui.controls.containers.vbox : VBox;

        auto root = new VBox;
        root.isLayoutManaged = false;
        root.y = 350;
        addCreate(root);
        root.enablePadding;

        import api.dm.gui.controls.containers.hbox : HBox;

        auto shapeContainer = new HBox;
        root.addCreate(shapeContainer);
        shapeContainer.enablePadding;

        import api.dm.kit.sprites2d.shapes.circle : Circle;

        auto circle = new Circle(20, GraphicStyle(1, RGBA.red));
        shapeContainer.addCreate(circle);

        auto circleFill = new Circle(20, GraphicStyle(1, RGBA.blue, true, RGBA.blue));
        shapeContainer.addCreate(circleFill);

        import api.dm.kit.sprites2d.shapes.rectangle : Rectangle;

        auto rect = new Rectangle(50, 50, GraphicStyle(1, RGBA.yellow));
        shapeContainer.addCreate(rect);

        auto rectFill = new Rectangle(50, 50, GraphicStyle(1, RGBA.green, true, RGBA.green));
        shapeContainer.addCreate(rectFill);

        import api.dm.kit.sprites2d.shapes.convex_polygon : ConvexPolygon;

        auto reg = new ConvexPolygon(50, 50, GraphicStyle(1, RGBA.lightcoral), 10);
        shapeContainer.addCreate(reg);

        auto regFill = new ConvexPolygon(50, 50, GraphicStyle(1, RGBA.lightsteelblue, true, RGBA
                .lightsteelblue), 10);
        shapeContainer.addCreate(regFill);

    }

    override bool draw()
    {
        super.draw();

        graphic.line(20, 100, 200, 100, RGBA.red);
        graphic.line(20, 110, 200, 110, RGBA.yellow);
        graphic.line(20, 120, 200, 120, RGBA.green);

        graphic.setColor(RGBA.pink);
        graphic.line(20, 140, 200, 140);
        graphic.line(20, 150, 200, 150);
        graphic.restoreColor;

        graphic.setColor(RGBA.lightblue);
        foreach (i; 0 .. 10)
        {
            graphic.point(220 + i * 5, 100);
        }

        graphic.linePoints(Vec2d(220, 120), Vec2d(250, 120), (p) {
            graphic.point(p);
            return true;
        });

        graphic.circlePoints(Vec2d(235, 150), 10, (p) {
            graphic.point(p);
            return true;
        });

        graphic.restoreColor;

        graphic.fillTriangle(Vec2d(300, 100), Vec2d(325, 150), Vec2d(350, 100), RGBA
                .yellowgreen);
        graphic.fillTriangle(Vec2d(360, 150), Vec2d(410, 150), Vec2d(385, 100), RGBA
                .yellowgreen);
        graphic.fillTriangle(Vec2d(420, 150), Vec2d(450, 100), Vec2d(430, 200), RGBA
                .yellowgreen);

        graphic.fillRect(480, 100, 50, 20, RGBA.lightsalmon);
        graphic.rect(480, 130, 50, 20, RGBA.lightcoral);

        graphic.setColor(RGBA.lightskyblue);

        graphic.bezier(Vec2d(550, 150), Vec2d(510, 150), Vec2d(580, 100));

        graphic.ellipse(Vec2d(650, 100), Vec2d(40, 20), RGBA.lightseagreen, true, false);
        graphic.ellipse(Vec2d(650, 150), Vec2d(40, 20), RGBA.lightseagreen, false, true);

        import api.dm.com.graphic.com_blend_mode : ComBlendMode;

        graphic.fillRect(750, 100, 50, 50, RGBA.lightpink);
        auto color2 = RGBA.lightcoral;
        color2.a = 0.5;
        graphic.fillRect(775, 100, 50, 50, color2);

        auto points = [
            Vec2d(20, 200),
            Vec2d(75, 240),
            Vec2d(50, 270),
            Vec2d(40, 260),
            Vec2d(10, 270),
        ];
        graphic.polygon(points);

        version (DmAddon)
        {
            import Delaunay = api.dm.addon.math.geom2.triangulations.delaunay;

            auto res = Delaunay.triangulate(points);

            foreach (t; res)
            {
                graphic.line(t.a, t.b);
                graphic.line(t.b, t.c);
                graphic.line(t.c, t.a);
                //graphic.fillTriangle(t.a, t.b, t.c, RGBA.red);
            }
        }

        graphic.restoreColor;

        graphic.point(150, 200);
        graphic.arc(150, 200, 0, 90, 50);

        return true;
    }
}
