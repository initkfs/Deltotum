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

        texture.lock;
        scope (exit)
        {
            texture.unlock;
        }

        import api.dm.kit.graphics.colors.rgba : RGBA;

        foreach (y; 0 .. (cast(uint) texture.height))
        {
            foreach (x; 0 .. (cast(uint)(texture.width)))
            {
                texture.changeColor(x, y, RGBA.red);
            }
        }

        panel = new VideoPlayerPanel;
        addCreate(panel);
        panel.onPlay = () { engine.load; };

        engine.onUpdateYV = (yplane, ypitch, uplane, upitch, vplane, vpitch) {
            if (!texture.updateTextureUV(yplane, cast(int) ypitch, uplane, cast(int) upitch, vplane, cast(
                    int) vpitch))
            {
                logger.error("Update YV-texture error:", texture.lastErrorNew);
            }
        };
    }

}
