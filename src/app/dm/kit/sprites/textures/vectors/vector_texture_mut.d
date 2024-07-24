module app.dm.kit.sprites.textures.vectors.vector_texture_mut;

import app.dm.kit.sprites.textures.texture : Texture;
import app.dm.kit.graphics.colors.rgba : RGBA;
import app.dm.kit.graphics.contexts.graphics_context : GraphicsContext;
import app.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import app.dm.kit.sprites.textures.vectors.contexts.vector_graphics_context : VectorGraphicsContext;

import app.dm.com.graphics.com_surface : ComSurface;
import app.dm.math.rect2d : Rect2d;
import app.dm.math.vector2 : Vector2;

//TODO remove native api
import app.dm.sys.cairo.cairo_surface : CairoSurface;
import app.dm.sys.cairo.cairo_context : CairoContext;

//TODO remove native api
import app.dm.sys.cairo.libs;

/**
 * Authors: initkfs
 */
class VectorTextureMut : Texture
{
    GraphicStyle style;
    //TODO moveTo + lineTo + stroke, extract class?
    Vector2 center;
    Vector2 prevPoint;

    this(double width, double height)
    {
        this.width = width;
        this.height = height;
        isResizable = true;
    }

    override void create()
    {
        super.create;
        texture = graphics.comTextureProvider.getNew();

        if (const err = texture.createMutARGB8888(cast(int) width, cast(int) height))
        {
            throw new Exception(err.toString);
        }

        if (const err = texture.setBlendModeBlend)
        {
            throw new Exception(err.toString);
        }
    }

    void updateTexture(Vector2[] points)
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

    void updateTexture(Vector2 next)
    {
        updateTextureDraw((context) {
            drawTo(context, next);
            prevPoint = next;
        });
    }

    protected void drawTo(GraphicsContext context, Vector2 next)
    {
        context.moveTo(center.x + prevPoint.x, center.y + prevPoint.y);
        context.lineTo(center.x + next.x, center.y + next.y);
    }

    void updateTextureDraw(scope void delegate(VectorGraphicsContext) onContext)
    {
        updateTexture((context) {
            context.setColor(style.lineColor);
            context.setLineWidth(style.lineWidth);

            onContext(context);

            context.stroke;

            if (style.isFill)
            {
                context.fill;
            }
        });
    }

    void updateTexture(scope void delegate(VectorGraphicsContext) onContext)
    {
        assert(texture);
        if (const err = texture.lock)
        {
            throw new Exception(err.toString);
        }

        int pitch;
        if (const err = texture.getPitch(pitch))
        {
            throw new Exception(err.toString);
        }

        void* pixels;
        if (const err = texture.getPixels(pixels))
        {
            throw new Exception(err.toString);
        }

        import app.dm.sys.cairo.libs : cairo_format_t;

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

        auto graphicContext = new VectorGraphicsContext(cairoContext);
        onContext(graphicContext);

        // if (const err = texture.update(Rect2d(0, 0, width, height), pixels, pitch))
        // {
        //     throw new Exception(err.toString);
        // }
        unlock;
    }

}
