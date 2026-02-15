module api.demo.demo1.scenes.game;

import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;
import api.dm.kit.sprites2d.textures.vectors.shapes.vrectangle : VRectangle;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.factories.uda;

import api.dm.kit.graphics.colors.rgba : RGBA;

import api.math.geom2.vec2 : Vec2f;
import std.string : toStringz, fromStringz;
import Math = api.math;

import std;

/**
 * Authors: initkfs
 */
class Demo1 : GuiScene
{

    this()
    {
        name = "game";
    }

    bool isRun;

    override void create()
    {
        super.create;

        import KitConfigKeys = api.dm.kit.kit_config_keys;

        if (config.hasKey(KitConfigKeys.fontIconsList))
        {
            uint fontIconSize = 12;
            if (config.hasKey(KitConfigKeys.fontIconsSize))
            {
                fontIconSize = cast(uint) config.getPositiveInt(KitConfigKeys.fontIconsSize);
            }

            auto fontListPaths = config.getList(KitConfigKeys.fontIconsList);
            foreach (fontListPath; fontListPaths)
            {
                import api.dm.gui.icons.fonts.icon_pack : syms;

                auto font = asset.newFont(fontListPath, fontIconSize);

                import api.dm.gui.icons.fonts.icon_bitmap_generator : IconBitmapGenerator;

                auto gen = new IconBitmapGenerator();
                build(gen);

                auto bitmap = gen.generate(syms, font);
                bitmap.isDrawBounds = true;

                addCreate(bitmap);
            }
        }

    }

    override void dispose()
    {
        super.dispose;
    }

    override void update(float delta)
    {
        super.update(delta);
    }
}
