module api.dm.gui.supports.editors.sections.physics;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.flip : Flip;

import Math = api.dm.math;
import api.math.geom2.vec2 : Vec2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.rect2 : Rect2d;

import std.stdio;

/**
 * Authors: initkfs
 */
class Physics : Control
{
    Sprite2d material;

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

        import api.dm.kit.sprites.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

        auto style = createStyle;
        style.fillColor = theme.colorAccent;
        style.isFill = true;
        material = new VConvexPolygon(50, 50, style, 10);
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

        if (!screen.first.bounds.contains(material.boundsRect))
        {
            material.velocity = material.velocity.reflect;
        }
    }
}
