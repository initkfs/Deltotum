module api.dm.gui.controls.media.video.video_player_panel;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.switches.buttons.icon_button : IconButton;

/**
 * Authors: initkfs
 */

class VideoPlayerPanel : Control
{
    Button playButton;

    void delegate() onPlay;

    this()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
        layout.isAlignY = true;
    }

    override void create()
    {
        super.create;

        import Icons = api.dm.gui.themes.icons.pack_bootstrap;

        playButton = new IconButton(Icons.play_fill);
        addCreate(playButton);
        playButton.onAction ~= (ref e) {
            if (onPlay)
            {
                onPlay();
            }
        };
    }
}
