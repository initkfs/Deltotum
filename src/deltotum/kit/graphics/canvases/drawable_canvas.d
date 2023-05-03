module deltotum.kit.graphics.canvases.drawable_canvas;

import deltotum.kit.display.textures.texture : Texture;
import deltotum.kit.graphics.colors.rgba : RGBA;

//TODO remove native api
import deltotum.sys.sdl.sdl_surface : SdlSurface;
import deltotum.sys.cairo.cairo_surface : CairoSurface;
import deltotum.sys.cairo.cairo_context : CairoContext;

/**
 * Authors: initkfs
 */
class DrawableCanvas : Texture
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

    void createTextureContent()
    {

    }

    private void createTempSurface()
    {
        comSurface = graphics.newComSurface;

        import deltotum.com.results.platform_result : PlatformResult;

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

        createTempSurface;
        createCairoContext;
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

        if (const err = texture.setBlendModeBlend)
        {
            throw new Exception(err.toString);
        }

        comSurface.destroy;
        comSurface = null;

        cairoSurface.destroy;
        cairoContext.destroy;
    }
}
