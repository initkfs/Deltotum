module api.dm.gui.controls.audio.players.audio_player;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.audio.players.audio_player_panel : AudioPlayerPanel;
import api.dm.kit.sprites2d.tweens.pause_tween2d : PauseTween2d;

import api.dm.com.audio.com_audio_clip : ComAudioClip;

/**
 * Authors: initkfs
 */

enum AudioPlayerState
{
    stop,
    play,
    pause,
}

class AudioPlayer : Control
{
    AudioPlayerPanel panel;

    void delegate() onPlay;
    void delegate() onPause;
    void delegate() onResume;
    void delegate() onStop;

    protected
    {
        ComAudioClip audio;
        string _path;

        double audioFullTime = 0;

        PauseTween2d checkPosTween;
    }

    double volume = 0;

    protected
    {
        AudioPlayerState _state;
    }

    this(string path, double volume = 1.0)
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;

        this.volume = volume;

        _path = path;
    }

    override void create()
    {
        super.create;

        panel = new AudioPlayerPanel;
        addCreate(panel);

        panel.setVolume = volume;

        panel.onPlayPause = () {

            final switch (_state)
            {
                case AudioPlayerState.stop, AudioPlayerState.pause:
                    run;
                    break;
                case AudioPlayerState.play:
                    pause;
                    break;
            }
        };

        panel.onStop = () { stop; };

        panel.onVolume01 = (v) {
            if (audio)
            {
                if (const err = audio.setVolume(v))
                {
                    logger.error(err);
                }
            }
        };

        checkPosTween = new PauseTween2d(1100);
        addCreate(checkPosTween);
        checkPosTween.isInfinite = true;
        checkPosTween.onEnd ~= () {

            if (isRunning && audio && !audio.isPlaying)
            {
                stop;
                return;
            }

            if (audioFullTime == 0)
            {
                logger.error("Cannot set audio position, full time is 0");
                return;
            }

            assert(panel);
            double pos;
            if (const err = audio.getPosTimeMs(pos))
            {
                logger.error(err);
                return;
            }
            auto panelPos = pos / audioFullTime;
            panel.setPos(panelPos);
            panel.setPosTimeText(pos);
        };

        panel.onSetPos = (v) {
            if (audio && audioFullTime > 0)
            {
                auto pos = v * audioFullTime;
                if (const err = audio.setPos(pos))
                {
                    logger.error("Error setting music position: ", err);
                    return;
                }
                //logger.trace("Set position: ", pos, " full time: ", audioFullTime);
            }
        };
    }

    override void run()
    {
        if (isRunning)
        {
            return;
        }

        super.run;

        if (_state == AudioPlayerState.pause)
        {
            resume;
            return;
        }

        if (!audio)
        {
            try
            {
                audio = media.newClip(_path);
                if (const err = audio.setVolume(volume))
                {
                    logger.error(err);
                }

                double timeMs;
                if (const err = audio.getDurationTimeMs(timeMs))
                {
                    logger.error("Error getting audio duration: ", err);
                }
                else
                {
                    audioFullTime = timeMs;
                    assert(panel);
                    panel.setFullTimeText(audioFullTime);
                }

                logger.trace("Create new audio: ", _path);
            }
            catch (Exception e)
            {
                logger.error("Audio player exception ", e);
                return;
            }
        }

        assert(panel);
        if (const err = audio.play)
        {
            logger.error("Error playing audio: ", err.toString);
            return;
        }

        _state = AudioPlayerState.play;
        panel.setPause;
        checkPosTween.run;
        if(onPlay){
            onPlay();
        }
        logger.trace("Play audio, state ", _state, " ", _path);
    }

    void resume()
    {
        if (const err = audio.resume)
        {
            logger.error("Error resume audio: ", err.toString);
            return;
        }
        _state = AudioPlayerState.play;
        panel.setPause;
        checkPosTween.run;
        if(onResume){
            onResume();
        }
        logger.trace("Resume audio, state ", _state, " ", _path);
    }

    override void pause()
    {
        if (isPaused)
        {
            return;
        }

        super.pause;

        if (audio)
        {
            if (const err = audio.pause)
            {
                logger.error("Audio pause error: ", err);
                return;
            }
        }

        _state = AudioPlayerState.pause;
        panel.setPlay;
        checkPosTween.pause;
        if(onPause){
            onPause();
        }
        logger.trace("Pause playing, state: ", _state);
    }

    override void stop()
    {
        if (isStopped && _state != AudioPlayerState.pause)
        {
            return;
        }

        super.stop;

        if (audio)
        {
            if (const err = audio.stop)
            {
                logger.error(err);
                return;
            }
        }

        _state = AudioPlayerState.stop;
        panel.setPlay;
        checkPosTween.pause;
        panel.setPos = 0;
        panel.setPosTimeText(0);
        if(onStop){
            onStop();
        }
        logger.trace("Stop playing, state: ", _state);
    }

    override void dispose()
    {
        super.dispose;
        if (audio)
        {
            audio.dispose;
        }
    }

}
