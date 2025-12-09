module api.dm.gui.supports.editors.sections.media;

// dfmt off
version(DmAddon):
// dfmt on

import api.dm.com.audio.com_audio_mixer;
import api.dm.com.audio.com_audio_clip;
import api.dm.com.audio.com_audio_chunk;

import api.dm.gui.controls.control : Control;

import api.dm.addon.dsp.signals.analog_signal : AnalogSignal;
import api.dm.addon.dsp.analyzers.analog_signal_analyzer : AnalogSignalAnalyzer;

import api.dm.addon.media.audio.music_notes;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.addon.media.audio.formats.wav.wav_writer : WavWriter;

import core.sync.mutex;

import api.dm.addon.dsp.dsp_processor : DspProcessor;
import api.dm.addon.dsp.equalizers.band_equalizer : BandEqualizer;
import api.dm.gui.controls.meters.levels.rect_level : RectLevel;
import api.dm.addon.dsp.synthesis.signal_synthesis;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.meters.spinners.spinner : Spinner;
import api.dm.gui.controls.meters.scrolls.hscroll : HScroll;
import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;
import api.dm.addon.media.audio.gui.piano : Piano;
import api.dm.addon.media.audio.synthesizers.fm_synthesizer : FMSynthesizer;

import Math = api.math;
import api.math.geom2.rect2 : Rect2f;

/**
 * Authors: initkfs
 */
class Media : Control
{
    ComAudioClip clip;

    BandEqualizer equalizer;
    RectLevel level;

    Piano piano;

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        isBackground = false;
        layout.isAlignY = false;
    }

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    alias SignalType = short;

    DspProcessor!(SignalType, sampleBufferSize * 2, 2) dspProcessor;

    shared static
    {
        enum sampleWindowSize = 4096;
        enum sampleBufferSize = 40960;
    }

    float sampleFreq = 0;

    alias Sint16 = short;
    alias Uint8 = ubyte;

    static shared Mutex sampleBufferMutex;

    import api.dm.kit.media.audio.chunks.audio_chunk : AudioChunk;
    import api.math.numericals.interp;

    AudioChunk!short[] chunks;
    FMSynthesizer!short synt;
    FMSynthesizer!short drumSynt;

    AudioChunk!short[size_t] channels;

    import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;

    RegulateTextField rField;
    RegulateTextField gField;
    RegulateTextField bField;

    override void create()
    {
        super.create;

        sampleFreq = media.audioOutSpec.freqHz;

        sampleBufferMutex = new shared Mutex();

        dspProcessor = new typeof(dspProcessor)(sampleBufferMutex, new AnalogSignalAnalyzer, sampleFreq, sampleWindowSize, logging);
        dspProcessor.dspBuffer.block;

        equalizer = new BandEqualizer(sampleWindowSize, sampleFreq, (fftIndex) {
            return dspProcessor.fftBuffer[fftIndex];
        }, 100, 8);

        dspProcessor.onUpdateFTBuffer = () { equalizer.update; };

        auto root = new VBox;
        addCreate(root);

        auto panelRoot = new HBox;
        panelRoot.isAlignY = true;
        root.addCreate(panelRoot);

        piano = new Piano;

        //TODO fix window width
        //pianoContainer.width = window.width == 0 ? 1200 : window.width;
        piano.width = 1275;
        piano.height = 200;
        root.addCreate(piano);

        if (const err = media.mixer.mixer.allocChannels(32))
        {
            throw new Exception(err.toString);
        }

        synt = new FMSynthesizer!short(sampleFreq);

        piano.settings.adsr(synt.adsr);
        piano.settings.amp = 0.3;
        piano.settings.isFcMulFm = true;
        piano.settings.fmIndex = 1;
        piano.settings.noteType = NoteType.note1_4;

        drumSynt = new FMSynthesizer!short(sampleFreq);

        piano.onPianoKey = (key, ref e) {

            auto freq = key.freqHz;

            import api.dm.com.inputs.com_keyboard : ComKeyName;

            if (input.isPressedKey(ComKeyName.key_a))
            {
                piano.settings.noteType = NoteType.note1;
            }
            else if (input.isPressedKey(ComKeyName.key_s))
            {
                piano.settings.noteType = NoteType.note1_2;
            }
            else if (input.isPressedKey(ComKeyName.key_d))
            {
                piano.settings.noteType = NoteType.note1_4;
            }
            else if (input.isPressedKey(ComKeyName.key_f))
            {
                piano.settings.noteType = NoteType.note1_8;
            }
            else if (input.isPressedKey(ComKeyName.key_g))
            {
                piano.settings.noteType = NoteType.note1_16;
            }

            // MusicNote[] notes = [
            //     {Octave.C4}, {Octave.C4}, {Octave.D4}, {Octave.C4}, {
            //         Octave.F4},
            //         {Octave.E4},
            //         {Octave.C4}, {Octave.C4}, {Octave.D4
            //     },
            //     {Octave.C4}, {Octave.G4},
            //     {Octave.F4},
            // ];

            // synt.sequence(notes, 44100, (short[] buff, float time) {

            //     auto chunk = media.newHeapChunk!short(time);
            //     chunks ~= chunk;
            //     chunk.data.buffer[] = buff;
            //     chunk.play;

            //auto newChunk = media.newHeapChunk!short(1000);
            //synt.sound(newChunk.data.buffer[], freq);

            // chunk.play;
            ///dspProcessor.lock;

            auto noteType = piano.settings.noteType;

            synt.adsr = piano.settings.adsr;

            float amp = piano.settings.amp;
            synt.fm = piano.settings.fm;
            synt.index = piano.settings.fmIndex;
            synt.isFcMulFm = piano.settings.isFcMulFm;

            AudioChunk!short noteChunk;

            synt.note(MusicNote(freq, noteType, 120), amp, (data, time) {
                foreach (chunk; chunks)
                {
                    if (chunk.data.buffer.length == data.length)
                    {
                        const lastChannel = chunk.lastChannel;
                        if (lastChannel >= 0 && !media.mixer.isPlaying(lastChannel))
                        {
                            noteChunk = chunk;
                            break;
                        }
                    }
                }

                if (!noteChunk)
                {
                    noteChunk = media.newHeapChunk!short(time);
                    chunks ~= noteChunk;
                }
                assert(noteChunk.data.buffer.length == data.length);
                noteChunk.data.buffer[] = data;
            });

            // synt.note(MusicNote(freq, NoteType.note1_4), (buff, time) {
            //     if(noteChunk.data.buffer.length != buff.length){
            //         import std.format: format;
            //         throw new Exception(format("Src buffer len: %s, target %s", buff.length, noteChunk.data.buffer.length));
            //     }
            //     noteChunk.data.buffer[] = buff;
            // }, 120, amp);

            // auto writer = new WavWriter;
            // writer.save("/home/user/sdl-music/out.wav", noteChunk.data.buffer, noteChunk
            //         .spec);

            //synt.note(noteChunk.data.buffer, freq, 0, noteChunk.data.durationMs, 0, sampleFreq);

            assert(noteChunk);

            if (noteChunk.lastChannel >= 0)
            {
                media.mixer.mixer.stopChannel(noteChunk.lastChannel);
            }

            if (noteChunk.lastChannel >= 0)
            {
                media.mixer.mixer.fadeOut(noteChunk.lastChannel, 5);
            }

            // context.platform.sleep(5);
            // if (const err = noteChunk.comChunk.playFadeIn(400))
            // {
            //     logger.error(err.toString);
            // }

            noteChunk.play;
        };

        if (const err = media.mixer.mixer.setPostCallback(&typeof(dspProcessor)
                .signal_callback, cast(void*)&dspProcessor
                .dspBuffer))
        {
            throw new Exception(err.toString);
        }

        level = new RectLevel((i) {
            if (i < equalizer.bandValues.length)
            {
                return equalizer.bandValues[i] * 2;
            }
            return 0;
        }, () { return 1; });
        level.levels = 100;
        level.rows = 2;

        level.marginTop = 10;

        equalizer.onUpdateIndexFreqStartEnd = (band, startFreq, endFreq) {
            import std.format : format;

            auto label = format("%s\n%s", Math.round(startFreq), Math.round(
                    endFreq));
            level.labels[band].text = label;
        };

        addCreate(level);

        import api.dm.addon.media.video.gui.video_player : mediaPlayer;
        import api.dm.gui.controls.containers.hbox: HBox;

        auto playerBox = new HBox;
        playerBox.isAlignY = true;
        addCreate(playerBox);

        import api.dm.addon.media.video.gui.video_player : mediaPlayer, VideoPlayer;

        auto player = mediaPlayer("https://ndtv24x7elemarchana.akamaized.net/hls/live/2003678/ndtv24x7/master.m3u8");
        playerBox.addCreate(player);

        player.onPointerPress ~= (ref e) {
            player.load;
            player.demuxer.setStatePlay;
        };

        import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;
        import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;

        void delegate() updatePlayer = () {
            auto r = rField.value;
            auto g = gField.value;
            auto b = bField.value;
            player.videoDecoder.setColor(r, g, b);
        };

        auto tp = new RegulateTextPanel;
        playerBox.addCreate(tp);

        rField = new RegulateTextField("R", 0, 1.0, (dt) { updatePlayer(); });

        gField = new RegulateTextField("G", 0, 1.0, (dt) { updatePlayer(); });

        bField = new RegulateTextField("B", 0, 1.0, (dt) { updatePlayer(); });

        tp.addCreate([rField, gField, bField]);
        tp.alignFields;
    }

    AudioChunk!short newChunk()
    {
        return media.newHeapChunk!short(noteTimeMs(120, NoteType.note1_4));
    }

    override void pause()
    {
        super.pause;
        dspProcessor.block;
    }

    override void run()
    {
        super.run;
        dspProcessor.unblock;
    }

    override void update(float delta)
    {
        super.update(delta);
        dspProcessor.step;
    }

    override void dispose()
    {
        super.dispose;
        foreach (chunk; chunks)
        {
            chunk.dispose;
        }
    }
}
