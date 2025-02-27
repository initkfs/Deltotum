module api.dm.kit.sprites2d.textures.vectors.vector_texture;

import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.contexts.graphics_context : GraphicsContext;

import api.dm.com.graphics.com_surface : ComSurface;

//TODO remove native api
import api.dm.sys.cairo.cairo_surface : CairoSurface;
import api.dm.sys.cairo.cairo_context : CairoContext;

//TODO remove native api
import api.dm.sys.cairo.libs;

/**
 * Authors: initkfs
 */
class VectorTexture : Texture2d
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
        isResizedByParent = true;

        this.id = "vector_texture";
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

        import api.dm.com.platforms.results.com_result : ComResult;

        if (const createErr = comSurface.createRGBA32(cast(int) width, cast(int) height))
        {
            throw new Exception(createErr.toString);
        }
    }

    private void tryCreateCairoContext()
    {
        import api.dm.sys.cairo.libs : cairo_format_t;

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
        if (const err = comSurface.getPixelRowLenBytes(pitch))
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

        const createErr = texture.create(comSurface);
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
        if (const err = texture.getPixelRowLenBytes(pitch))
        {
            throw new Exception(err.toString);
        }

        void* surfPixels;
        if (const err = comSurface.getPixels(surfPixels))
        {
            throw new Exception(err.toString);
        }

        int surfacePitch;
        if (const err = comSurface.getPixelRowLenBytes(surfacePitch))
        {
            throw new Exception(err.toString);
        }

        if (pitch != surfacePitch)
        {
            import std.format : format;

            throw new Exception(format("Pitch values do not match. Texture2d: %s, surface: %s", pitch, surfacePitch));
        }

        int surfHeight;
        if (const err = comSurface.getHeight(surfHeight))
        {
            throw new Exception(err.toString);
        }

        assert(height > 0);

        int textureHeight = cast(int) height;
        assert((textureHeight > 0));

        if (surfHeight != textureHeight)
        {
            import std.format : format;

            throw new Exception(format("Height values do not match. Texture2d: %s, surface: %s", textureHeight, surfHeight));
        }

        //TODO unsafe cast to size_t, overflow, NaN;
        size_t endBuff = cast(size_t)(pitch * textureHeight);
        texturePixels[0 .. endBuff] = surfPixels[0 .. endBuff];
    }

    override bool recreate()
    {
        if (!isMutable)
        {
            createStaticTexture;
            return true;
        }

        if (!texture)
        {
            createMutTexture;
            return true;
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
            return true;
        }

        _gContext.clear(RGBA.transparent);
        createTextureContent;

        if (onSurfaceIsContinue)
        {
            if (!onSurfaceIsContinue(comSurface))
            {
                return false;
            }
        }

        loadMutTexture;

        return true;
    }

    override GraphicsContext newGraphicsContext()
    {
        import api.dm.kit.sprites2d.textures.vectors.contexts.vector_graphics_context : VectorGraphicsContext;

        return new VectorGraphicsContext(cairoContext);
    }

    override void color(RGBA newColor)
    {
        assert(isCreated);
        if (cairoContext && cairoContext.hasObject)
        {
            auto ctx = cairoContext.getObject;
            assert(ctx);
            cairo_set_source_rgba(ctx, newColor.rNorm, newColor.gNorm, newColor.bNorm, newColor.a);
            return;
        }

        super.color(newColor);
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
        import Math = api.dm.math;

        cairo_user_to_device(cr, &x, &y);
        x = Math.round(x);
        y = Math.round(y);
        cairo_device_to_user(cr, &x, &y);
    }
}
