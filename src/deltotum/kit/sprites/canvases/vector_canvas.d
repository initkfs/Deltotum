module deltotum.kit.sprites.canvases.vector_canvas;

import deltotum.kit.sprites.textures.texture : Texture;
import deltotum.kit.graphics.colors.rgba : RGBA;

//TODO remove native api
import deltotum.sys.sdl.sdl_surface : SdlSurface;
import deltotum.sys.cairo.cairo_surface : CairoSurface;
import deltotum.sys.cairo.cairo_context : CairoContext;

//TODO remove native api
import deltotum.sys.cairo.libs;

/**
 * Authors: initkfs
 */
class VectorCanvas : Texture
{
    protected
    {
        SdlSurface comSurface;
        CairoSurface cairoSurface;
        CairoContext cairoContext;
    }

    this(double width, double height)
    {
        this.width = width;
        this.height = height;
    }

    override bool setColor(RGBA color)
    {
        if (!isCreated)
        {
            return false;
        }
        auto ctx = cairoContext.getObject;
        cairo_set_source_rgb(ctx, color.rNorm, color.gNorm, color.bNorm);
        return true;
    }

    void createTextureContent()
    {

    }

    private void createTempSurface()
    {
        comSurface = graphics.newComSurface;

        import deltotum.com.platforms.results.com_result : ComResult;

        //TODO or SDL_BYTEORDER?
        version (BigEndian)
        {
            const createErr = comSurface.createRGBSurface(
                0,
                cast(int) width,
                cast(int) height,
                32,
                0x0000FF00,
                0x00FF0000,
                0xFF000000,
                0x000000FF);
        }

        version (LittleEndian)
        {
            const createErr = comSurface.createRGBSurface(0, cast(int) width, cast(int) height, 32,
                0x00ff0000,
                0x0000ff00,
                0x000000ff,
                0xff000000);
        }

        if (createErr)
        {
            throw new Exception(createErr.toString);
        }

    }

    private void createCairoContext()
    {
        import deltotum.sys.cairo.libs : cairo_format_t;

        cairoSurface = new CairoSurface(cast(ubyte*) comSurface.pixels, cairo_format_t
                .CAIRO_FORMAT_ARGB32, cast(int) width, cast(int) height, comSurface.pitch);

        cairoContext = new CairoContext(cairoSurface);
    }

    override void initialize()
    {
        super.initialize;

        //createTempSurface;
        //createCairoContext;
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

        texture = graphics.newComTexture;
        //TODO toInt?
        const createErr = texture.fromSurface(comSurface);
        if (createErr)
        {
            throw new Exception(createErr.toString);
        }

        if (const err = texture.setModeBlend)
        {
            throw new Exception(err.toString);
        }

        comSurface.dispose;
        comSurface = null;

        cairoSurface.dispose;
        cairoContext.dispose;
    }
}
