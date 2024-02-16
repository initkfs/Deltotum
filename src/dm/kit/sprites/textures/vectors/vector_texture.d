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
        isResizable = true;
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

        if (cairoSurface)
        {
            cairoSurface.dispose;
        }

        if (cairoContext)
        {
            cairoContext.dispose;
        }

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
        else
        {
            comSurface.dispose;
            createTempSurface;
            //TODO bug
            // if (width > 0 && height > 0)
            // {
            //     bool isResized;
            //     if(const err = comSurface.resize(cast(int) width, cast(int) height, isResized)){
            //         logger.error(err.toString);
            //     }
            // }
        }

        //TODO separate
        if (!cairoSurface || !cairoContext)
        {
            createCairoContext;
        }

        createTextureContent;

        if (!texture)
        {
            texture = graphics.comTextureProvider.getNew();
        }

        //TODO toInt?
        const createErr = texture.fromSurface(comSurface);
        if (createErr)
        {
            throw new Exception(createErr.toString);
        }

        scope (exit)
        {
            disposeContext;
        }

        if (const err = texture.setBlendModeBlend)
        {
            throw new Exception(err.toString);
        }
    }

    void disposeContext()
    {
        if (cairoSurface)
        {
            cairoSurface.dispose;
            cairoSurface = null;
        }

        if (cairoContext)
        {
            cairoContext.dispose;
            cairoContext = null;
        }
    }

    override void dispose()
    {
        super.dispose;
        disposeContext;
        if (comSurface)
        {
            comSurface.dispose;
            comSurface = null;
        }
    }

    void snapToPixel(cairo_t* cr, out double x, out double y)
    {
        import Math = dm.math;

        cairo_user_to_device(cr, &x, &y);
        x = Math.round(x);
        y = Math.round(y);
        cairo_device_to_user(cr, &x, &y);
    }
}
