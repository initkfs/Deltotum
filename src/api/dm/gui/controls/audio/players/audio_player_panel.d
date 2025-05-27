module api.dm.gui.controls.audio.players.audio_player_panel;

import api.dm.gui.controls.control : Control;

import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;
import api.dm.gui.controls.meters.scrolls.base_regular_mono_scroll : BaseRegularMonoScroll;
import api.dm.gui.controls.meters.scrolls.hscroll : HScroll;
import api.dm.gui.controls.texts.text : Text;

class AudioPlayerPanel : Control
{
    Button playPauseButton;
    Button stopButton;

    RegulateTextField volumeField;

    void delegate() onPlayPause;
    void delegate() onStop;
    void delegate(double value) onVolume01;
    void delegate(double value) onSetPos;

    Text posLabel;
    BaseRegularMonoScroll positionTracker;
    Text fullTimeLabel;

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        //layout.isAlignX = true;
    }

    override void create()
    {
        super.create;

        import api.dm.gui.controls.containers.hbox : HBox;

        auto buttonBox = new HBox;
        addCreate(buttonBox);

        playPauseButton = new Button;
        buttonBox.addCreate(playPauseButton);

        playPauseButton.onAction ~= (ref e) {
            if (onPlayPause)
            {
                onPlayPause();
            }
        };
        setPlay;

        stopButton = new Button("■");
        buttonBox.addCreate(stopButton);

        stopButton.onAction ~= (ref e) {
            if (onStop)
            {
                onStop();
            }
        };

        auto timeBox = new HBox;
        addCreate(timeBox);

        posLabel = new Text("00:00");
        timeBox.addCreate(posLabel);

        positionTracker = new HScroll(0, 1);
        timeBox.addCreate(positionTracker);

        positionTracker.onValue ~= (v) {
            if (onSetPos)
            {
                onSetPos(v);
            }
        };

        fullTimeLabel = new Text("00:00");
        timeBox.addCreate(fullTimeLabel);

        volumeField = new RegulateTextField("Volume", 0.0, 1.0, (v) {
            if (onVolume01)
            {
                onVolume01(v);
            }
        });

        addCreate(volumeField);
    }

    void setPos(double v01)
    {
        positionTracker.value(v01, isTriggerListeners:
            false);
    }

    void setVolume(double v01)
    {
        assert(volumeField);
        volumeField.value = v01;
    }

    void setPause()
    {
        assert(playPauseButton);
        playPauseButton.label.text = "||";
    }

    void setPlay()
    {
        assert(playPauseButton);
        playPauseButton.label.text = "▶";
    }

    void setPosTimeText(double ms)
    {
        assert(posLabel);
        posLabel.text = formatTime(ms);
    }

    void setFullTimeText(double ms)
    {
        assert(fullTimeLabel);
        fullTimeLabel.text = formatTime(ms);
    }

    string formatTime(double ms)
    {
        const int fullSecs = cast(int)(ms / 1000);
        const min = fullSecs / 60;
        const secs = fullSecs % 60;

        return formatTime(min, secs);
    }

    string formatTime(int min, int sec)
    {
        import std.format : format;

        return format("%02d:%02d", min, sec);
    }

}
