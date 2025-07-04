module api.dm.kit.sprites2d.textures.vectors.vector_texture_mut;

import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.textures.vectors.canvases.vector_canvas : VectorCanvas;

import api.dm.com.graphic.com_surface : ComSurface;
import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.vec2 : Vec2d;

//TODO remove native api
import api.dm.lib.cairo.cairo_surface : CairoSurface;
import api.dm.lib.cairo.cairo_context : CairoContext;

//TODO remove native api
import api.dm.lib.cairo;

/**
 * Authors: initkfs
 */
class VectorTextureMut : Texture2d
{
    GraphicStyle style;
    //TODO moveTo + lineTo + stroke, extract class?
    Vec2d center;
    Vec2d prevPoint;

    this(double width, double height)
    {
        this.width = width;
        this.height = height;
        isResizable = true;
    }

    override void create()
    {
        super.create;
        texture = graphic.comTextureProvider.getNew();

        if (const err = texture.createMutARGB32(cast(int) width, cast(int) height))
        {
            throw new Exception(err.toString);
        }

        if (const err = texture.setBlendModeBlend)
        {
            throw new Exception(err.toString);
        }
    }

    void updateTexture(Vec2d[] points)
    {
        if (points.length < 2)
        {
            return;
        }
        prevPoint = points[0];
        updateTextureDraw((context) {
            foreach (p; points)
            {
                drawTo(context, p);
                prevPoint = p;
            }
        });
    }

    void updateTexture(Vec2d next)
    {
        updateTextureDraw((context) {
            drawTo(context, next);
            prevPoint = next;
        });
    }

    protected void drawTo(GraphicCanvas context, Vec2d next)
    {
        context.moveTo(center.x + prevPoint.x, center.y + prevPoint.y);
        context.lineTo(center.x + next.x, center.y + next.y);
    }

    void updateTextureDraw(scope void delegate(VectorCanvas) onContext)
    {
        updateTexture((context) {
            context.color = style.lineColor;
            context.lineWidth = style.lineWidth;

            onContext(context);

            context.stroke;

            if (style.isFill)
            {
                context.fill;
            }
        });
    }

    void updateTexture(scope void delegate(VectorCanvas) onContext)
    {
        assert(texture);
        if (const err = texture.lock)
        {
            throw new Exception(err.toString);
        }

        int pitch;
        if (const err = texture.getPixelRowLenBytes(pitch))
        {
            throw new Exception(err.toString);
        }

        void* pixels;
        if (const err = texture.getPixels(pixels))
        {
            throw new Exception(err.toString);
        }

        import api.dm.lib.cairo : cairo_format_t;

        cairo_surface_t* cairoSurfacePtr = cairo_image_surface_create_for_data(
            cast(ubyte*) pixels,
            cairo_format_t.CAIRO_FORMAT_ARGB32,
            cast(int) width, cast(int) height, pitch);
        assert(cairoSurfacePtr);

        //TODO remove allocations
        auto cairoSurface = new CairoSurface(cairoSurfacePtr);
        scope (exit)
        {
            cairoSurface.dispose;
        }
        auto cairoContext = new CairoContext(cairoSurface);
        scope (exit)
        {
            cairoContext.dispose;
        }

        auto graphicContext = new VectorCanvas(cairoContext);
        onContext(graphicContext);

        // if (const err = texture.update(Rect2d(0, 0, width, height), pixels, pitch))
        // {
        //     throw new Exception(err.toString);
        // }
        unlock;
    }

}
