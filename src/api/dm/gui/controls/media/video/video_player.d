module api.dm.gui.controls.media.video.video_player;

import api.dm.kit.media.engines.media_engine : MediaEngine;
import api.dm.gui.controls.media.video.video_player_panel : VideoPlayerPanel;
import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

/**
 * Authors: initkfs
 */

class VideoPlayer : Control
{
    enum
    {
        size_t VideoQueueSize = 40960,
        size_t AudioQueueSize = 40960,
        size_t VideoBufferSize = 256,
        size_t AudioBufferSize = 819200
    }

    MediaEngine!(
        VideoQueueSize,
        AudioQueueSize,
        VideoBufferSize,
        AudioBufferSize) engine;

    Texture2d texture;

    VideoPlayerPanel panel;
    string path;

    void delegate() onStart;

    this(string path, size_t width = 200, size_t height = 200)
    {
        initSize(width, height);
        this.path = path;

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout(0);
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        engine = new typeof(engine)(path, width, height, media.audio);
        addCreate(engine);
        engine.isLayoutManaged = false;

        texture = new Texture2d(width, height);
        addCreate(texture);
        texture.createMutYV;

        import api.dm.kit.graphics.colors.rgba : RGBA;

        //TODO extract changeColorYV

        //IYUV
        const fillColor = RGBA.gray.toYUVA;

        size_t ysize = cast(size_t)(width * height);
        ubyte[] yplane = new ubyte[ysize];

        int uvWidth = cast(int)((width + 1) / 2);
        int uvHeight = cast(int)((height + 1) / 2);
        int uvSize = uvWidth * uvHeight;
        ubyte[] uplane = new ubyte[uvSize];
        ubyte[] vplane = new ubyte[uvSize];

        yplane[] = fillColor.y;
        uplane[] = fillColor.u;
        vplane[] = fillColor.v;

        if (!texture.updateTextureUV(yplane, widthi, uplane, uvWidth, vplane, uvWidth))
        {
            logger.error(texture.lastErrorNew);
        }

        panel = new VideoPlayerPanel;
        addCreate(panel);
        panel.onPlay = () {

            if (onStart)
            {
                onStart();
            }

            engine.load;
        };

        engine.onUpdateYV = (yplane, ypitch, uplane, upitch, vplane, vpitch) {
            
            if(!texture.isVisible){
                return;
            }
            
            if (!texture.updateTextureUV(yplane, cast(int) ypitch, uplane, cast(int) upitch, vplane, cast(
                    int) vpitch))
            {
                logger.error("Update YV-texture error:", texture.lastErrorNew);
            }
        };
    }

}
