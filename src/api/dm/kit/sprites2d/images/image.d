module api.dm.kit.sprites2d.images.image;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.dm.com.graphics.com_texture : ComTexture;
import api.dm.com.graphics.com_image_codec : ComImageCodec;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.math.geom2.rect2 : Rect2f;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.pos2.flip : Flip;

import Math = api.math;

/**
 * Authors: initkfs
 */
//TODO remove duplication with animation bitmap
class Image : Texture2d
{
    this()
    {

    }

    this(float width, float height)
    {
        super(width, height);
    }

    this(ComTexture texture)
    {
        super(texture);
    }

    alias create = Texture2d.create;

    void create(string path, int requestWidth = -1, int requestHeight = -1)
    {
        import std.path : isAbsolute;
        import std.file : isFile, exists;

        assert(isBuilt);

        string imagePath = path.isAbsolute ? path : asset.imagePath(path);
        if (imagePath.length == 0 || !imagePath.exists || !imagePath.isFile)
        {
            throw new Exception("Unable to load image, empty path or not a file: " ~ imagePath);
        }

        ComSurface comSurf;

        foreach (codec; graphic.comImageCodecs)
        {
            if (codec.isSupport(path))
            {
                comSurf = graphic.comSurfaceProvider.getNew();
                if (const err = codec.load(path, comSurf))
                {
                    throw new Exception(err.toString);
                }
                break;
            }
        }

        if (!comSurf)
        {
            throw new Exception("Image not loaded: ", path);
        }

        scope (exit)
        {
            comSurf.dispose;
        }

        create(comSurf, requestWidth, requestHeight);
    }

    void create(const(ubyte[]) buff, int requestWidth = -1, int requestHeight = -1)
    {
        //TODO remove duplication with load
        ComSurface comSurf;

        foreach (codec; graphic.comImageCodecs)
        {
            if (codec.isSupport(buff))
            {
                comSurf = graphic.comSurfaceProvider.getNew();
                if (const err = codec.load(buff, comSurf))
                {
                    throw new Exception(err.toString);
                }
                break;
            }
        }

        if (!comSurf)
        {
            throw new Exception("Image not loaded from memory buffer");
        }

        scope (exit)
        {
            comSurf.dispose;
        }

        create(comSurf, requestWidth, requestHeight);
    }

    void save(ComSurface surf, string path)
    {
        bool isSave;

        foreach (codec; graphic.comImageCodecs)
        {
            if (codec.isSupport(path))
            {
                if (const err = codec.save(path, surf))
                {
                    throw new Exception(err.toString);
                }
                isSave = true;
                break;
            }
        }

        if (!isSave)
        {
            throw new Exception("Image not saved: ", path);
        }
    }

    void save(string path)
    {
        //TODO texture must be streaming
        // graphic.comSurfaceProvider.getNewScoped((surface) {
        //     if (const err = texture.lockToSurface(surface))
        //     {
        //         throw new Exception(err.toString);
        //     }

        //     save(surface, path);
        // });

        if (!surface)
        {
            throw new Exception("Surface is null");
        }

        save(surface, path);
    }
}
