module api.dm.kit.sprites2d.textures.vectors.vector_texture;

import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;

import api.dm.com.graphic.com_surface : ComSurface;

//TODO remove native api
import api.dm.lib.cairo.cairo_surface : CairoSurface;
import api.dm.lib.cairo.cairo_context : CairoContext;

//TODO remove native api
import api.dm.lib.cairo;

struct BufferWrapper {
    char[] data;
    void put(const char[] slice) { data ~= slice; }
}

extern (C) cairo_status_t writeSvgToBuffer(void* closure, const ubyte* data, uint length)
{
    auto buffer = cast(BufferWrapper*) closure;
    buffer.put(cast(char[]) data[0 .. length]);
    return cairo_status_t.CAIRO_STATUS_SUCCESS;
}

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
    bool isClearOnRecreate = true;

    this(double width, double height)
    {
        this.width = width;
        this.height = height;
        isResizable = true;
        //isResizedByParent = true;

        this.id = "vector_texture";
    }

    void createTextureContent(GraphicCanvas ctx)
    {

    }

    void createTextureContent()
    {

    }

    string createSVG()
    {
        import std.array : Appender;

        BufferWrapper svgBuffer;

        auto svgCairoSurface = new CairoSurface(&writeSvgToBuffer, &svgBuffer, width, height);
        scope (exit)
        {
            svgCairoSurface.dispose;
        }

        auto svgContext = new CairoContext(svgCairoSurface);
        scope (exit)
        {
            svgContext.dispose;
        }

        import api.dm.kit.sprites2d.textures.vectors.canvases.vector_canvas : VectorCanvas;

        auto ctx = new VectorCanvas(svgContext);

        createTextureContent(ctx);

        svgCairoSurface.flush;
        svgCairoSurface.finish;

        import std.conv : to;

        return svgBuffer.data.to!string;
    }

    private void tryCreateTempSurface()
    {
        if (!comSurface)
        {
            comSurface = graphic.comSurfaceProvider.getNew();
        }

        import api.dm.com.com_result : ComResult;

        if (const createErr = comSurface.createBGRA32(cast(int) width, cast(int) height))
        {
            throw new Exception(createErr.toString);
        }
    }

    private void tryCreateCairoContext()
    {
        import api.dm.lib.cairo : cairo_format_t;

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
        createTextureContent(canvas);

        if (onSurfaceIsContinue)
        {
            if (!onSurfaceIsContinue(comSurface))
            {
                return;
            }
        }

        if (!texture)
        {
            texture = graphic.comTextureProvider.getNew();
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
        createTextureContent(canvas);

        if (onSurfaceIsContinue)
        {
            if (!onSurfaceIsContinue(comSurface))
            {
                return;
            }
        }

        if (!texture)
        {
            texture = graphic.comTextureProvider.getNew();
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

        if (isClearOnRecreate)
        {
            fillColor(RGBA.transparent);
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

        canvas.clear(RGBA.transparent);
        createTextureContent;
        createTextureContent(canvas);

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

    override GraphicCanvas newGraphicsContext()
    {
        import api.dm.kit.sprites2d.textures.vectors.canvases.vector_canvas : VectorCanvas;

        return new VectorCanvas(cairoContext);
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
