module api.dm.kit.sprites2d.textures.texture2d;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.dm.com.graphics.com_texture : ComTexture;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.com.graphics.com_blend_mode : ComBlendMode;
import api.dm.com.graphics.com_texture : ComTextureScaleMode;
import api.math.geom2.rect2 : Rect2f;
import api.math.pos2.flip : Flip;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2f;

/**
 * Authors: initkfs
 */
class Texture2d : Sprite2d
{
    bool isDrawTexture = true;
    Flip flip = Flip.none;

    Vec2f rotateCenter = Vec2f.infinity;

    RGBA delegate(int x, int y, RGBA color) onColor;

    bool isInterpolationResize;
    bool isKeepOriginalColorBuffer;
    RGBA[][] originalBuffer;

    bool isKeepSurface;
    ComSurface surface;

    protected
    {
        ComTexture texture;
        ComTextureScaleMode _scaleMode = ComTextureScaleMode.quality;
    }

    private
    {
        //hack to reduce memory leak
        float oldChangedWidth = 0;
        float oldChangedHeight = 0;
        float changeSizeDelta = 5;
    }

    void delegate(float, float) onPreRecreateWidthOldNew;
    void delegate(float, float) onPreRecreateHeightOldNew;

    this()
    {
        isResizable = true;
        //isResizedByParent = true;
    }

    this(float width, float height)
    {
        this();
        this.width = width;
        this.height = height;
    }

    this(ComTexture texture)
    {
        assert(texture);

        this();

        int w, h;
        if (const sizeErr = texture.getSize(w, h))
        {
            throw new Exception(sizeErr.toString);
        }

        this.width = w;
        this.height = h;

        this.texture = texture;
    }

    override void create()
    {
        super.create;
        if (texture)
        {
            texture.setId(id);
        }
    }

    void create(ComSurface image, int requestWidth = -1, int requestHeight = -1)
    {
        if (!image)
        {
            throw new Exception("Image must not be null");
        }

        int imageWidth = image.getWidth;
        int imageHeight = image.getHeight;

        if (requestWidth > 0 && requestWidth != imageWidth || requestHeight > 0 && requestHeight != imageHeight)
        {
            bool isResized;
            if (const err = image.resize(cast(int)(requestWidth * scale), cast(int)(
                    requestHeight * scale), isResized))
            {
                throw new Exception(err.toString);
            }

            imageWidth = image.getWidth;
            imageHeight = image.getHeight;
        }
        else
        {
            if (scale != 1)
            {
                bool isResized;
                //TODO check non negative resize
                if (const err = image.resize(cast(int)(imageWidth * scale), cast(int)(
                        imageHeight * scale), isResized))
                {
                    throw new Exception(err.toString);
                }

                imageWidth = image.getWidth;
                imageHeight = image.getHeight;
            }
        }

        //TODO test functionality, remove
        if (isKeepOriginalColorBuffer || isInterpolationResize)
        {
            if (const err = image.lock)
            {
                throw new Exception(err.toString);
            }

            scope (exit)
            {
                if (const err = image.unlock)
                {
                    throw new Exception(err.toString);
                }
            }

            originalBuffer = new RGBA[][](imageHeight, imageWidth);

            foreach (y; 0 .. imageHeight)
            {
                foreach (x; 0 .. imageWidth)
                {
                    uint* pixelPtr;
                    if (const err = image.getPixel(x, y, pixelPtr))
                    {
                        throw new Exception(err.toString);
                    }
                    ubyte r, g, b, a;
                    if (const err = image.getPixelRGBA(pixelPtr, r, g, b, a))
                    {
                        throw new Exception(err.toString);
                    }
                    originalBuffer[y][x] = RGBA(r, g, b, RGBA.fromAByte(a));
                }
            }
        }

        if (onColor)
        {
            if (const err = image.lock)
            {
                throw new Exception(err.toString);
            }

            scope (exit)
            {
                if (const err = image.unlock)
                {
                    throw new Exception(err.toString);
                }
            }

            foreach (y; 0 .. imageHeight)
            {
                foreach (x; 0 .. imageWidth)
                {
                    //TODO more optimal iteration
                    uint* pixelPtr;
                    if (const err = image.getPixel(x, y, pixelPtr))
                    {
                        throw new Exception(err.toString);
                    }
                    ubyte r, g, b, a;
                    if (const err = image.getPixelRGBA(pixelPtr, r, g, b, a))
                    {
                        throw new Exception(err.toString);
                    }
                    RGBA oldColor = {r, g, b, RGBA.fromAByte(a)};
                    RGBA newColor = onColor(x, y, oldColor);
                    if (newColor != oldColor)
                    {
                        if (const err = image.setPixelRGBA(x, y, newColor.r, newColor.g, newColor.b, newColor
                                .aByte))
                        {
                            throw new Exception(err.toString);
                        }
                    }

                    if (originalBuffer)
                    {
                        originalBuffer[y][x] = newColor;
                    }
                }
            }
        }

        if (!texture)
        {
            texture = graphic.comTextureProvider.getNew();
        }

        if (const err = texture.create(image))
        {
            throw new Exception(err.toString);
        }

        int width;
        int height;

        if (const err = texture.getSize(width, height))
        {
            throw new Exception(err.toString);
        }

        forceWidth = width;
        forceHeight = height;

        if (isKeepSurface)
        {
            if (surface)
            {
                //TODO swap pointers
                surface.dispose;
            }
            else
            {
                this.surface = graphic.comSurfaceProvider.getNew();
            }

            if (const err = image.copyTo(surface))
            {
                throw new Exception(err.toString);
            }
        }
    }

    void create(RGBA[][] colorBuf, bool isKeepColorBuffer = false)
    {
        if (colorBuf.length == 0)
        {
            throw new Exception("Color buffer is empty");
        }

        height = colorBuf.length;
        if (colorBuf[0].length == 0)
        {
            throw new Exception("Color buffer row is empty");
        }

        width = colorBuf[0].length;

        //TODO check is mutable.
        if (texture)
        {
            texture.dispose;
            texture = null;
        }

        //TODO check width, height == colorBuf.dims
        createMutRGBA32;
        assert(texture);

        lock;
        scope (exit)
        {
            unlock;
        }

        foreach (yy, ref RGBA[] colors; colorBuf)
        {
            foreach (xx, ref RGBA color; colors)
            {
                uint x = cast(uint) xx;
                uint y = cast(uint) yy;

                RGBA newColor = onColor ? onColor(x, y, color) : color;
                changeColor(x, y, newColor);
            }
        }

        if (isKeepColorBuffer)
        {
            originalBuffer = colorBuf;
        }
    }

    void createMutRGBA32()
    {
        assert(width > 0);
        assert(height > 0);

        texture = graphic.comTextureProvider.getNew();
        if (const err = texture.createMutRGBA32(cast(int) width, cast(int) height))
        {
            throw new Exception(err.toString);
        }
    }

    void createMutBGRA32()
    {
        assert(width > 0);
        assert(height > 0);

        texture = graphic.comTextureProvider.getNew();
        if (const err = texture.createMutBGRA32(cast(int) width, cast(int) height))
        {
            throw new Exception(err.toString);
        }
    }

    void createTargetRGBA32()
    {
        assert(width > 0);
        assert(height > 0);
        assert(graphic);

        texture = graphic.comTextureProvider.getNew();
        if (const err = texture.createTargetRGBA32(cast(int) width, cast(int) height))
        {
            throw new Exception(err.toString);
        }
    }

    void createMutYV()
    {
        assert(width > 0);
        assert(height > 0);
        assert(graphic);

        texture = graphic.comTextureProvider.getNew();
        if (const err = texture.createMutYV(cast(int) width, cast(int) height))
        {
            throw new Exception(err.toString);
        }
    }

    void blendMode(ComBlendMode mode)
    {
        if (const err = texture.setBlendMode(mode))
        {
            throw new Exception(err.toString);
        }
    }

    void blendModeBlend()
    {
        blendMode(ComBlendMode.blend);
    }

    void blendModeNone()
    {
        blendMode(ComBlendMode.none);
    }

    ComTextureScaleMode scaleMode()
    {
        assert(texture);
        ComTextureScaleMode mode;
        if (const err = texture.getScaleMode(mode))
        {
            logger.error(err.toString);
        }

        if (mode != _scaleMode)
        {
            if (const err = texture.setScaleMode(_scaleMode))
            {
                logger.error(err.toString);
            }
        }

        return _scaleMode;
    }

    void scaleMode(ComTextureScaleMode mode)
    {
        assert(texture);
        if (const err = texture.setScaleMode(mode))
        {
            logger.error(err.toString);
        }
        _scaleMode = mode;
    }

    void bestScaleMode()
    {
        scaleMode(ComTextureScaleMode.quality);
    }

    override void drawContent()
    {
        if (texture is null)
        {
            return;
        }

        if (isDrawTexture)
        {
            drawTexture;
        }

        super.drawContent;
    }

    void drawTexture()
    {
        Rect2f textureBounds = {0, 0, width, height};
        //TODO flip, toInt?
        Rect2f destBounds = {x, y, width, height};
        drawTexture(texture, textureBounds, destBounds, angle, flip);
    }

    void drawTexture(Rect2f src)
    {
        Rect2f dest = {x, y, src.width, src.height};
        drawTexture(src, dest, this.angle, this.flip);
    }

    void drawTexture(Rect2f textureBounds, Rect2f destBounds)
    {
        drawTexture(textureBounds, destBounds, this.angle, this.flip);
    }

    void drawTexture(Rect2f textureBounds, Rect2f destBounds, float angle = 0, Flip flip = Flip
            .none)
    {
        drawTexture(texture, textureBounds, destBounds, angle, flip);
    }

    void drawTexture(ComTexture texture, Rect2f textureBounds, Rect2f destBounds, float angle = 0, Flip flip = Flip
            .none)
    {
        if (!texture.draw(textureBounds, destBounds, angle, flip, rotateCenter))
        {
            logger.error("Error texture drawing: ", texture.getLastErrorNew);
        }
    }

    void color(RGBA color)
    {
        assert(texture, "Texture2d not created");
        if (const err = texture.setColor(color.r, color.g, color.b, color.aByte))
        {
            throw new Exception(err.toString);
        }
    }

    RGBA color()
    {
        assert(texture, "Texture2d not created");

        ubyte r, g, b, a;
        if (const err = texture.getColor(r, g, b, a))
        {
            throw new Exception(err.toString);
        }
        return RGBA(r, g, b, a / (cast(float) ubyte.max));
    }

    override float width() => super.width;

    override bool width(float v)
    {
        auto isResized = super.width(v);

        if (!isResizable)
        {
            return isResized;
        }

        import Math = api.math;

        bool isNeedResize = Math.abs(oldChangedWidth - v) > changeSizeDelta;
        if (!isNeedResize)
        {
            return isResized;
        }

        if (isInterpolationResize && originalBuffer && originalBuffer.length > 0)
        {
            import Transform = api.dm.kit.graphics.colors.processings.transforms;

            if (width < 0)
            {
                throw new Exception("Width must be positive");
            }

            if (height < 0)
            {
                throw new Exception("Height must be positive");
            }
            //TODO recreate?
            auto biBuff = Transform.bilinear(originalBuffer, cast(size_t) width, cast(size_t) height);
            create(biBuff);
        }
        else
        {
            if (texture)
            {
                bool isTextureCreated;
                if (const err = texture.isCreating(isTextureCreated))
                {
                    logger.error(err.toString);
                }

                if (isTextureCreated && !isDisableRecreate)
                {
                    if (onPreRecreateWidthOldNew)
                    {
                        onPreRecreateWidthOldNew(oldChangedWidth, width);
                    }
                    recreate;
                }
            }
        }

        oldChangedWidth = width;
        return true;
    }

    override float height() => super.height;

    override bool height(float value)
    {
        auto isResized = super.height(value);

        if (!isResizable)
        {
            return isResized;
        }

        import Math = api.math;

        bool isNeedResize = Math.abs(oldChangedHeight - value) > changeSizeDelta;
        if (!isNeedResize)
        {
            return isResized;
        }

        if (isInterpolationResize && originalBuffer && originalBuffer.length > 0)
        {
            if (width < 0)
            {
                throw new Exception("Width must be positive");
            }

            if (height < 0)
            {
                throw new Exception("Height must be positive");
            }

            import Transform = api.dm.kit.graphics.colors.processings.transforms;

            auto biBuff = Transform.bilinear(originalBuffer, cast(size_t) width, cast(size_t) height);
            create(biBuff);
        }
        else
        {
            if (texture)
            {
                bool isTextureCreated;
                if (const err = texture.isCreating(isTextureCreated))
                {
                    logger.error(err.toString);
                }

                if (isTextureCreated && !isDisableRecreate)
                {
                    if (onPreRecreateHeightOldNew)
                    {
                        onPreRecreateHeightOldNew(oldChangedHeight, value);
                    }
                    recreate;
                }
            }
        }

        oldChangedHeight = value;
        return true;
    }

    override bool recreate()
    {
        return false;
    }

    Texture2d copy()
    {
        assert(texture);
        ComTexture newTexture;
        if (const err = texture.copyToNew(newTexture))
        {
            throw new Exception(err.toString);
        }
        auto toTexture = new Texture2d(newTexture);
        build(toTexture);
        toTexture.initialize;
        toTexture.create;
        return toTexture;
    }

    Texture2d copyTo(float toWidth, float toHeight, bool isToCenter = false)
    {
        auto newTexture = new Texture2d(toWidth, toHeight);
        buildInitCreate(newTexture);

        newTexture.createTargetRGBA32;
        newTexture.setRenderTarget;
        scope (exit)
        {
            newTexture.restoreRenderTarget;
        }
        graphic.clearTransparent;

        copyTo(newTexture, isToCenter);
        return newTexture;
    }

    void copyTo(Texture2d other, bool isToCenter = false)
    {
        other.copyFrom(this, isToCenter);
    }

    void copyFrom(Texture2d other, bool isToCenter = false)
    {
        //TODO check bounds;
        Rect2f srcRect = {0, 0, other.width, other.height};
        Rect2f destRect = !isToCenter ? Rect2f(0, 0, width, height) : Rect2f(width / 2 - other.width / 2, height / 2 - other
                .height / 2, other.width, other.height);

        copyFrom(other, srcRect, destRect);
    }

    void copyFrom(Texture2d other, Rect2f srcRect, Rect2f dstRect)
    {
        assert(texture);
        if (const err = texture.copyFrom(other.nativeTexture, srcRect, dstRect, other.angle, other
                .flip))
        {
            throw new Exception(err.toString);
        }
    }

    inout(ComTexture) nativeTexture() inout nothrow
    {
        return this.texture;
    }

    bool isLocked()
    {
        assert(texture);
        bool locked;
        if (const err = texture.isLocked(locked))
        {
            throw new Exception(err.toString);
        }
        return locked;
    }

    void lock()
    {
        if (const err = texture.lock)
        {
            throw new Exception(err.toString);
        }
    }

    void fillColor(RGBA color)
    {
        lock;
        scope (exit)
        {
            unlock;
        }
        if (const err = texture.fill(color.r, color.g, color.b, color.aByte))
        {
            throw new Exception(err.toString);
        }
    }

    void changeColor(uint x, uint y, ubyte r, ubyte g, ubyte b, ubyte a)
    {
        if (const err = texture.setPixelColor(x, y, r, g, b, a))
        {
            throw new Exception(err.toString);
        }
    }

    void changeColor(uint x, uint y, RGBA color)
    {
        if (const err = texture.setPixelColor(x, y, color.r, color.g, color.b, color.aByte))
        {
            throw new Exception(err.toString);
        }
    }

    void updateTexture(void* pixels, int pitch)
    {
        updateTexture(boundsRectGeom, pixels, pitch);
    }

    void updateTexture(Rect2f rect, void* pixels, int pitch)
    {
        if (const err = texture.update(rect, pixels, pitch))
        {
            throw new Exception(err.toString);
        }
    }

    bool updateTextureUV(ubyte[] yplane, int ypitch, ubyte[] uplane, int upitch, ubyte[] vplane, int vpitch)
    {
        return texture.updateUV(yplane.ptr, ypitch, uplane.ptr, upitch, vplane.ptr, vpitch);
    }

    uint format()
    {
        assert(texture);
        assert(isLocked);
        uint format;
        if (const err = texture.getFormat(format))
        {
            throw new Exception(err.toString);
        }
        return format;
    }

    int pitch()
    {
        assert(texture);
        assert(isLocked);
        int pitch;
        if (const err = texture.getPixelRowLenBytes(pitch))
        {
            throw new Exception(err.toString);
        }
        return pitch;
    }

    void* pixels()
    {
        assert(texture);
        assert(isLocked);
        void* ptr;
        if (const err = texture.getPixels(ptr))
        {
            throw new Exception(err.toString);
        }
        assert(ptr);
        return ptr;
    }

    uint* pixel(uint x, uint y)
    {
        assert(texture);
        assert(isLocked);
        uint* ptr;
        if (const err = texture.getPixel(x, y, ptr))
        {
            throw new Exception(err.toString);
        }
        return ptr;
    }

    RGBA[][] pixelColors()
    {
        assert(width > 0);
        assert(height > 0);
        RGBA[][] buff = new RGBA[][](cast(size_t) height, cast(size_t) width);
        pixelColors(buff);
        return buff;
    }

    void pixelColors(RGBA[][] buff)
    {
        assert(width > 0);
        assert(height > 0);
        assert(texture);
        assert(isLocked);
        assert(buff.length >= height);

        //TODO all rows
        assert(buff[0].length >= width);

        foreach (y; 0 .. (cast(uint) height))
        {
            foreach (x; 0 .. (cast(uint)(width)))
            {
                buff[y][x] = pixelColor(x, y);
            }
        }
    }

    void setPixelColors(RGBA[][] buff)
    {
        //TODO width > 0, etc
        //TODO check buffer size
        foreach (y; 0 .. (cast(uint) height))
        {
            foreach (x; 0 .. (cast(uint)(width)))
            {
                auto color = buff[y][x];
                changeColor(x, y, color);
            }
        }
    }

    RGBA pixelColor(float x, float y)
    {
        import std.conv : to;

        return pixelColor(x.to!uint, y.to!uint);
    }

    RGBA pixelColor(uint x, uint y)
    {
        assert(texture);
        assert(isLocked);
        ubyte r, g, b, a;
        if (const err = texture.getPixelColor(x, y, r, g, b, a))
        {
            throw new Exception(err.toString);
        }
        return RGBA(r, g, b, RGBA.fromAByte(a));
    }

    void unlock()
    {
        if (const err = texture.unlock)
        {
            throw new Exception(err.toString);
        }
    }

    override float opacity() => super.opacity;

    override bool opacity(float value)
    {
        assert(texture);

        bool isSet = super.opacity(value);
        if (!isSet)
        {
            return isSet;
        }

        if (const err = texture.setOpacity(value))
        {
            logger.error(err.toString);
        }

        return isSet;
    }

    void setRenderTarget()
    {
        assert(texture);
        if (const err = texture.setRenderTarget)
        {
            logger.error(err.toString);
        }
    }

    void restoreRenderTarget()
    {
        assert(texture);
        if (const err = texture.restoreRenderTarget)
        {
            logger.error(err.toString);
        }
    }

    string lastErrorNew()
    {
        if (!texture)
        {
            return null;
        }
        return texture.getLastErrorNew;
    }

    override void dispose()
    {
        super.dispose;
        if (texture)
        {
            texture.dispose;
        }
    }
}
