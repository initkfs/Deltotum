module deltotum.gui.supports.editors.sections.graphics;

import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.sprite : Sprite;
import deltotum.kit.graphics.colors.rgba : RGBA;

import Math = deltotum.math;
import deltotum.math.vector2d : Vector2d;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

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

        graphics.linePoints(Vector2d(220, 120), Vector2d(250, 120), (p) {
            graphics.point(p);
            return true;
        });

        graphics.circlePoints(Vector2d(235, 150), 10, (p) {
            graphics.point(p);
            return true;
        });

        graphics.restoreColor;

        graphics.fillTriangle(Vector2d(300, 100), Vector2d(325, 150), Vector2d(350, 100), RGBA
                .yellowgreen);
        //The middle of the triangle is shown last to control for fill artifacts
        graphics.fillTriangle(Vector2d(400, 100), Vector2d(450, 100), Vector2d(425, 150), RGBA
                .yellowgreen);

        graphics.fillRect(480, 100, 50, 20, RGBA.lightsalmon);
        graphics.rect(480, 130, 50, 20, RGBA.lightcoral);

        graphics.setColor(RGBA.lightskyblue);

        graphics.bezier(Vector2d(550, 150), Vector2d(530, 130), Vector2d(580, 100));

        graphics.restoreColor;

        return true;
    }

}
