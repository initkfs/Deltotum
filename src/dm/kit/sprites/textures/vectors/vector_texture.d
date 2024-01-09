module dm.kit.sprites.textures.vectors.vector_texture;

import dm.kit.sprites.textures.texture : Texture;
import dm.kit.graphics.colors.rgba : RGBA;

import dm.com.graphics.com_surface : ComSurface;

//TODO remove native api
import dm.sys.cairo.cairo_surface : CairoSurface;
import dm.sys.cairo.cairo_context : CairoContext;

//TODO remove native api
import dm.sys.cairo.libs;

/**
 * Authors: initkfs
 */
class VectorTexture : Texture
{
    protected
    {
        ComSurface comSurface;
        CairoSurface cairoSurface;
        CairoContext cairoContext;
    }

    this(double width, double height)
    {
        this.width = width;
        this.height = height;
    }

    override void color(RGBA color)
    {
        assert(isCreated);
        auto ctx = cairoContext.getObject;
        cairo_set_source_rgb(ctx, color.rNorm, color.gNorm, color.bNorm);
    }

    void createTextureContent()
    {

    }

    private void createTempSurface()
    {
        comSurface = graphics.comSurfaceProvider.getNew();

        import dm.com.platforms.results.com_result : ComResult;

        if (const createErr = comSurface.createRGBSurface(width, height))
        {
            throw new Exception(createErr.toString);
        }
    }

    private void createCairoContext()
    {
        import dm.sys.cairo.libs : cairo_format_t;

        cairoSurface = new CairoSurface(cast(ubyte*) comSurface.pixels, cairo_format_t
                .CAIRO_FORMAT_ARGB32, cast(int) width, cast(int) height, comSurface.pitch);

        cairoContext = new CairoContext(cairoSurface);
    }

    override void create()
    {
        super.create;

        if (!comSurface)
        {
            createTempSurface;
        }

        //TODO separate
        if (!cairoSurface || !cairoContext)
        {
            createCairoContext;
        }

        createTextureContent;

        texture = graphics.comTextureProvider.getNew();
        //TODO toInt?
        const createErr = texture.fromSurface(comSurface);
        if (createErr)
        {
            throw new Exception(createErr.toString);
        }

        scope (exit)
        {
            comSurface.dispose;
            comSurface = null;

            cairoSurface.dispose;
            cairoContext.dispose;
        }

        if (const err = texture.setBlendModeBlend)
        {
            throw new Exception(err.toString);
        }
    }
}
