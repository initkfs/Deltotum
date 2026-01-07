module api.dm.gui.supports.editors.sections.physics;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.pos2.flip : Flip;

import Math = api.dm.math;
import api.math.geom2.vec2 : Vec2f;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.geom2.rect2 : Rect2f;
import api.sims.phys.movings.boundaries;

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

        import api.dm.kit.sprites2d.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

        auto style = createStyle;
        style.fillColor = theme.colorAccent;
        style.isFill = true;
        material = new VConvexPolygon(50, 50, style, 10);
        material.isLayoutManaged = false;

        material.x = 100;
        material.y = 50;
        addCreate(material);

        material.onPointerPress ~= (ref e) {
            material.velocity.x = 300;
            material.velocity.y = 300;
            material.isPhysics = true;
        };

        import api.sims.phys.movings.friction;

        material.friction = 0.5; 
    }

    override bool draw(float dt){
        super.draw(dt);
        graphic.color = RGBA.green;
        graphic.rect(graphic.renderBounds);
        return true;
    }

    override void update(float dt)
    {
        super.update(dt);

        import api.dm.kit.graphics.colors.rgba: RGBA;

        if (!material)
        {
            return;
        }

        //wrapSimple(material, graphic.renderBounds);

        // if (!window.screen.bounds.contains(material.boundsRect))
        // {
        //     material.velocity = material.velocity.reflect;
        // }
    }
}
