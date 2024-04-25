module dm.kit.sprites.textures.vectors.vector_texture;

import dm.kit.sprites.textures.texture : Texture;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.graphics.contexts.graphics_context : GraphicsContext;

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

    bool delegate(ComSurface) onSurfaceIsContinue;

    bool isMutable;

    this(double width, double height)
    {
        this.width = width;
        this.height = height;
        isResizable = true;
    }

    void createTextureContent()
    {

    }

    private void tryCreateTempSurface()
    {
        if (!comSurface)
        {
            comSurface = graphics.comSurfaceProvider.getNew();
        }

        import dm.com.platforms.results.com_result : ComResult;

        if (const createErr = comSurface.createRGB(cast(int) width, cast(int) height))
        {
            throw new Exception(createErr.toString);
        }
    }

    private void tryCreateCairoContext()
    {
        import dm.sys.cairo.libs : cairo_format_t;

        assert(comSurface);

        if (cairoSurface && !cairoSurface.isDisposed)
        {
            cairoSurface.dispose;
        }

        if (cairoContext && !cairoContext.isDisposed)
        {
            cairoContext.dispose;
        }

        void* pixels;
        if (const err = comSurface.getPixels(pixels))
        {
            throw new Exception(err.toString);
        }
        int pitch;
        if (const err = comSurface.getPitch(pitch))
        {
            throw new Exception(err.toString);
        }

        cairoSurface = new CairoSurface(cast(ubyte*) pixels, cairo_format_t
                .CAIRO_FORMAT_ARGB32, cast(int) width, cast(int) height, pitch);

        cairoContext = new CairoContext(cairoSurface);

        createGraphicsContext;
    }

    override void create()
    {
        super.create;
        if (isMutable)
        {
            createMutTexture;
            return;
        }

        createStaticTexture;
    }

    private void createStaticTexture()
    {
        tryCreateTempSurface;
        tryCreateCairoContext;

        //There may be graphical artifacts when reloading textures
        scope (exit)
        {
            disposeContext;
        }

        createTextureContent;

        if (onSurfaceIsContinue)
        {
            if (!onSurfaceIsContinue(comSurface))
            {
                return;
            }
        }

        if (!texture)
        {
            texture = graphics.comTextureProvider.getNew();
        }

        loadStaticTexture;
    }

    private void loadStaticTexture()
    {
        assert(texture);
        assert(comSurface);

        const createErr = texture.createFromSurface(comSurface);
        if (createErr)
        {
            throw new Exception(createErr.toString);
        }
    }

    private void createMutTexture()
    {
        tryCreateTempSurface;
        tryCreateCairoContext;

        createTextureContent;

        if (onSurfaceIsContinue)
        {
            if (!onSurfaceIsContinue(comSurface))
            {
                return;
            }
        }

        if (!texture)
        {
            texture = graphics.comTextureProvider.getNew();
        }

        const createErr = texture.createMutARGB32(cast(int) width, cast(int) height);
        if (createErr)
        {
            throw new Exception(createErr.toString);
        }

        if (const err = texture.setBlendModeBlend)
        {
            throw new Exception(err.toString);
        }

        loadMutTexture;
    }

    private void loadMutTexture()
    {
        assert(texture);
        assert(comSurface);

        if (const err = texture.lock)
        {
            throw new Exception(err.toString);
        }
        scope (exit)
        {
            if (const err = texture.unlock)
            {
                throw new Exception(err.toString);
            }
        }

        void* texturePixels;
        if (const err = texture.getPixels(texturePixels))
        {
            throw new Exception(err.toString);
        }

        int pitch;
        if (const err = texture.getPitch(pitch))
        {
            throw new Exception(err.toString);
        }

        void* surfPixels;
        if (const err = comSurface.getPixels(surfPixels))
        {
            throw new Exception(err.toString);
        }

        int surfacePitch;
        if (const err = comSurface.getPitch(surfacePitch))
        {
            throw new Exception(err.toString);
        }

        if (pitch != surfacePitch)
        {
            import std.format : format;

            throw new Exception(format("Pitch values do not match. Texture: %s, surface: %s", pitch, surfacePitch));
        }

        int surfHeight;
        if(const err = comSurface.getHeight(surfHeight)){
            throw new Exception(err.toString);
        }

        assert(height > 0);

        int textureHeight = cast(int) height;
        assert((textureHeight > 0));

        if(surfHeight != textureHeight){
            import std.format : format;

            throw new Exception(format("Height values do not match. Texture: %s, surface: %s", textureHeight, surfHeight));
        }
        
        //TODO unsafe cast to size_t, overflow, NaN;
        size_t endBuff = cast(size_t) (pitch * textureHeight);
        texturePixels[0 .. endBuff] = surfPixels[0 .. endBuff];
    }

    override void recreate()
    {
        if (!isMutable)
        {
            createStaticTexture;
            return;
        }

        if (!texture)
        {
            createMutTexture;
            return;
        }
        
        int w, h;
        if (const err = texture.getSize(w, h))
        {
            throw new Exception(err.toString);
        }
        int newWidth = cast(int) width;
        int newHeight = cast(int) height;
        if (newWidth != w || newHeight != h)
        {
            createMutTexture;
            return;
        }

        _gContext.clear(RGBA.transparent);
        createTextureContent;

        if (onSurfaceIsContinue)
        {
            if (!onSurfaceIsContinue(comSurface))
            {
                return;
            }
        }

        loadMutTexture;
    }

    override GraphicsContext newGraphicsContext()
    {
        import dm.kit.sprites.textures.vectors.contexts.vector_graphics_context : VectorGraphicsContext;

        return new VectorGraphicsContext(cairoContext);
    }

    override void color(RGBA color)
    {
        assert(isCreated);
        auto ctx = cairoContext.getObject;
        cairo_set_source_rgba(ctx, color.rNorm, color.gNorm, color.bNorm, color.a);
    }

    void disposeContext()
    {
        if (comSurface)
        {
            comSurface.dispose;
        }

        if (cairoSurface)
        {
            cairoSurface.dispose;
        }

        if (cairoContext)
        {
            cairoContext.dispose;
        }
    }

    override void dispose()
    {
        super.dispose;
        disposeContext;
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
