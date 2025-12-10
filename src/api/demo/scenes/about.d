module api.demo.demo1.scenes.about;

import api.dm.gui.scenes.gui_scene : GuiScene;

import api.dm.lib.box2d;
import std.string : toStringz, fromStringz;

/**
 * Authors: initkfs
 */
class About : GuiScene
{

    this()
    {
        name = "about";
    }

    override void create()
    {
        super.create;

        import api.dm.lib.vips.native;

        auto source = "/home/user/Account/Downloads/Lenna.png";
        auto dest = "/home/user/Account/Downloads/Lenna1.png";

        VipsImage* image = vips_image_new_from_file(source.toStringz, null);
        if (!image)
        {
            throw new Exception(vips_error_buffer_copy().fromStringz.idup);
        }

        VipsImage* blur;

        if (vips_gaussblur(image, &blur, 10))
        {
            throw new Exception(vips_error_buffer_copy().fromStringz.idup);
        }

        assert(blur);

        scope (exit)
        {
            _vips_destroy(image);
            _vips_destroy(blur);
        }

        if (vips_image_write_to_file(blur, dest.toStringz, null))
        {
            throw new Exception(vips_error_buffer_copy().fromStringz.idup);
        }

    }

    override void dispose()
    {
        super.dispose;

    }
}
