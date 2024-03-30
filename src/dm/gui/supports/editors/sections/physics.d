module dm.gui.supports.editors.sections.physics;

import dm.gui.controls.control : Control;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.math.flip : Flip;

import Math = dm.math;
import dm.math.vector2 : Vector2;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.math.rect2d : Rect2d;

import std.stdio;

/**
 * Authors: initkfs
 */
class Physics : Control
{
    Sprite material;

    this()
    {
        id = "deltotum_gui_editor_section_physics";
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    override void create()
    {
        super.create;

        import dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

        auto style = createDefaultStyle;
        style.fillColor = graphics.theme.colorAccent;
        style.isFill = true;
        material = new VRegularPolygon(50, 50, style, 10);
        material.isLayoutManaged = false;

        material.x = 100;
        material.y = 50;
        addCreate(material);

        material.onPointerDown ~= (ref e) {
            material.velocity.x = 10;
            material.velocity.y = 10;
            material.isPhysicsEnabled = true;
        };
    }

    override void update(double dt)
    {
        super.update(dt);

        if (!material)
        {
            return;
        }

        if (!screen.first.bounds.contains(material.bounds))
        {
            material.velocity = material.velocity.reflect;
        }
    }
}
