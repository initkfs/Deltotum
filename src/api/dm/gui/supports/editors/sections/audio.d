module api.dm.gui.supports.editors.sections.audio;

import api.dm.gui.controls.control : Control;
import api.dm.com.audio.com_audio_mixer : ComAudioMixer;
import api.dm.com.audio.com_audio_clip : ComAudioClip;
import api.math.geom2.rect2 : Rect2d;

import std.stdio;

/**
 * Authors: initkfs
 */
class Audio : Control
{
    ComAudioClip clip;

    this()
    {
        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout;
        layout.isAutoResize = true;
        isBackground = false;
        layout.isAlignY = false;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    override void create()
    {
        super.create;

        import api.dm.gui.controls.containers.vbox: VBox;
        import api.dm.gui.controls.containers.hbox: HBox;

        auto musicContainer = new HBox;
        addCreate(musicContainer);
        musicContainer.enablePadding;
        musicContainer.isAlignY = true;

        import api.dm.gui.controls.texts.text: Text;

        auto musicFile = new Text("/home/user/sdl-music/neocrey - System Shock.mp3");
        musicContainer.addCreate(musicFile);

        import api.dm.gui.controls.switches.buttons.button: Button;

        auto play = new Button("Play");
        play.onAction ~= (ref e){

            auto path = musicFile.textString;

            if(clip){
                return;
            }

            clip = media.mixer.newClip(path);
            if(const err = clip.play){
                throw new Exception(err.toString);
            }
        };
        addCreate(play);

    }
}
