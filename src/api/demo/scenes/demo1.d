module api.demo.demo1.scenes.game;

import api.sims.phys.rigids2d.movings.moving;
import api.sims.phys.rigids2d.movings.boundaries;
import api.sims.phys.rigids2d.movings.physeffects;

import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.vectors.shapes.vcircle : VCircle;
import api.dm.kit.sprites2d.textures.vectors.shapes.vrectangle : VRectangle;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.sims.phys.rigids2d.movings.moving;
import api.sims.phys.rigids2d.movings.physeffects;
import api.sims.phys.rigids2d.collisions.impulse_resolver;
import api.sims.phys.rigids2d.collisions.joints;
import api.dm.kit.sprites2d.images.image : Image;
import api.math.geom2.circle2 : Circle2f;
import api.dm.kit.factories.uda;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.sims.phys.rigids2d.movings.gravity;
import api.dm.kit.media.buffers.audio_buffer : AudioBuffer;
import api.sims.phys.rigids2d.fk;
import api.sims.phys.rigids2d.ik;
import std.stdio;

import api.math.geom2.vec2 : Vec2f;
import std.string : toStringz, fromStringz;
import Math = api.math;

import api.dm.gui.webs.web_engine: WebEngine;

import api.dm.lib.wpe.native;

import std;

/**
 * Authors: initkfs
 */
class Demo1 : GuiScene
{

    this()
    {
        name = "game";
    }

    WebEngine engine;

    bool isRun;

    override void create()
    {
        super.create;

        engine = new WebEngine;
        addCreate(engine);
        import std.path: buildPath;

        auto textFile = buildPath(context.app.userDir, "test.html");
        engine.loadUri("file://" ~ textFile);

        // import api.dm.lib.libjpeg.native;

        // auto lib = new LibjpegLib();
        // lib.onLoad = () { writeln("Load libjpeg library."); };
        // lib.onLoadErrors = (err) { writeln("libjpeg loading error: ", err); };
        // lib.load;

        // string filename = "container.jpg";

        // ubyte[] jpegBuf = cast(ubyte[]) read(filename);
        // const jpegSize = jpegBuf.length;

        // if (jpegSize >= 2 && (jpegBuf[0] != 0xFF || jpegBuf[1] != 0xD8))
        // {
        //     throw new Exception("Not a jpeg file");
        // }

        // tjhandle decompressor = tjInitDecompress();
        // if (!decompressor)
        // {
        //     throw new Exception("tjInitDecompress");
        // }

        // scope (exit)
        // {
        //     tjDestroy(decompressor);
        // }

        // assert(tjDecompressHeader3);

        // int w, h, jpegSubsamp, jpegColorspace;
        // if (tjDecompressHeader3(decompressor, jpegBuf.ptr, jpegBuf.length,
        //         &w, &h, &jpegSubsamp, &jpegColorspace))
        // {
        //     throw new Exception(tjGetErrorStr2().fromStringz.idup);
        // }

        // import api.dm.back.sdl3.sdl_surface;

        // scope surface = new SdlSurface;
        // if (const err = surface.createRGB24(w, h))
        // {
        //     throw new Exception(err.toString);
        // }

        // if (tjDecompress2(decompressor, jpegBuf.ptr, jpegBuf.length,
        //         cast(ubyte*) surface.pixels,
        //         w, surface.pitch, h,
        //         TJPF.TJPF_RGB, TJFLAG_ACCURATEDCT) != 0)
        // {
        //     throw new Exception("Decompress");
        // }

        // import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

        // auto tex = new Texture2d(surface.getWidth, surface.getHeight);
        // build(tex);

        // tex.loadFromSurface(surface);
        // addCreate(tex);

        // //hi 85-95, mid 75-85, artefacts 50-75
        // int quality = 40;

        // int pixelFormat = TJPF.TJPF_RGB;
        // int jpegSubsampOut = TJSAMP.TJSAMP_422;

        // tjhandle compressor = tjInitCompress();
        // if (!compressor)
        //     return;
        // scope (exit)
        //     tjDestroy(compressor);

        // ubyte* jpegBufOut = null;
        // ulong jpegSizeOut = 0;

        // int result = tjCompress2(compressor,
        //     cast(ubyte*) surface.pixels,
        //     surface.getWidth,
        //     surface.pitch,
        //     surface.getWidth,
        //     pixelFormat,
        //     &jpegBufOut,
        //     &jpegSizeOut,
        //     jpegSubsampOut,
        //     quality,
        //     TJFLAG_ACCURATEDCT);
        // if (result != 0)
        // {
        //     throw new Exception("tjCompress2");
        // }

        // scope(exit){
        //     tjFree(jpegBufOut);
        // }

        // auto f = File("output.jpeg", "w");
        // f.rawWrite(jpegBufOut[0..jpegSize]);

        // addCreate(tex);

        // import api.dm.lib.libpng.native;

        // auto pngLib = new LibpngLib();
        // pngLib.onLoad = () { writeln("Load libpng library."); };

        // pngLib.onLoadErrors = (err) { writeln("libpng loading error: ", err); };

        // pngLib.load;

        // import core.stdc.stdio : fopen, fclose, fread, fseek, SEEK_END, SEEK_SET, FILE;
        // import core.stdc.stdlib : malloc, free;
        // import core.stdc.string : memset;

        // char* filename = cast(char*) "container2.png".ptr;

        // png_image image;
        // image._version = PNG_IMAGE_VERSION;

        // if (!png_image_begin_read_from_file(&image, filename))
        // {
        //     throw new Exception(image.message.fromStringz.idup);
        // }

        // scope (exit)
        // {
        //     png_image_free(&image);
        // }

        // image.format = PNG_FORMAT_RGBA;

        // import api.dm.back.sdl3.sdl_surface;

        // scope surface = new SdlSurface;
        // if (const err = surface.createRGBA32(image.width, image.height))
        // {

        // }

        // if (png_image_finish_read(&image, null, surface.pixels,
        //         surface.pitch, null) == 0)
        // {
        //     //SDL_DestroySurface(surface);
        //     //return null;
        //     throw new Exception("ERR");
        // }

        // import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

        // auto tex = new Texture2d(image.width, image.height);
        // build(tex);

        // tex.loadFromSurface(surface);

        // addCreate(tex);

        // png_image saveImage;
        // saveImage._version = PNG_IMAGE_VERSION;
        // saveImage.width = surface.getWidth;
        // saveImage.height = surface.getHeight;
        // saveImage.format = PNG_FORMAT_RGBA;
        // image.flags = 0;
        // image.colormap_entries = 0;

        // png_uint_32 stride = cast(png_uint_32) surface.pitch;

        // char* savefile = cast(char*) "avefile.png";

        // if (png_image_write_to_file(&image, savefile, 0,
        //         surface.pixels, stride, null) == 0)
        // {
        //     throw new Exception(image.message.fromStringz.idup);
        // }

        // auto segment = new SegmentDrag;
        // addCreate(segment);

        // segment.toCenter;

        // audio = new typeof(audio);
        // audio.create;

        // //segment.isPhysics = true;
        // //segment.angularVelocity = 10;

        // onPointerPress ~= (ref e){
        //     audio.writeTestTone(500, 5);
        // };

    }

    override void dispose()
    {
        super.dispose;
    }

    override void update(float delta)
    {
        super.update(delta);
    }
}
