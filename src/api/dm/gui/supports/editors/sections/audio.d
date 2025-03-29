module api.dm.gui.supports.editors.sections.audio;

import api.dm.gui.controls.control : Control;
import api.dm.com.audio.com_audio_mixer : ComAudioMixer;
import api.dm.com.audio.com_audio_clip : ComAudioClip;
import api.dm.com.audio.com_audio_chunk : ComAudioChunk;
import api.dm.kit.media.dsp.signals.analog_signal : AnalogSignal;
import api.math.geom2.rect2 : Rect2d;
import api.dm.kit.graphics.colors.rgba : RGBA;

import std.stdio;

import api.dm.back.sdl3.externs.csdl3;
import api.dm.com.audio.com_audio_mixer;

import core.sync.mutex;
import core.sync.semaphore;
import api.dm.kit.media.dsp.analysis.analog_signal_analyzer : AnalogSignalAnalyzer;
import std.math.traits : isPowerOf2;

import api.dm.kit.media.dsp.dsp_processor : DspProcessor;
import api.dm.kit.media.dsp.equalizers.band_equalizer : BandEqualizer;
import api.dm.gui.controls.meters.levels.rect_level : RectLevel;
import api.dm.kit.media.synthesis.signal_synthesis;
import api.dm.kit.media.synthesis.synthesizers.sound_synthesizer;

import Math = api.math;

import std;

/**
 * Authors: initkfs
 */
class Audio : Control
{
    ComAudioClip clip;

    BandEqualizer equalizer;
    RectLevel level;

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

    DspProcessor!(SignalType, sampleBufferSize) dspProcessor;

    shared static
    {
        enum double sampleFreq = 44100;
        enum sampleWindowSize = 8192;
        enum sampleBufferSize = 40960;

        //pow 2 for FFT

        enum sampleBufferHalfSize = sampleBufferSize / 2;
    }

    alias Sint16 = short;
    alias Uint8 = ubyte;

    static shared Mutex sampleBufferMutex;
    static shared Mutex mutexWrite;
    static shared Mutex mutexSwap;

    bool needSwap;

    bool isRedrawLocalBuffer;

    size_t frameCount;

    double magn1 = 0;

    import api.dm.kit.media.dsp.chunks.audio_chunk : AudioChunk;

    AudioChunk!short chunk;

    short[] buffer;

    SoundSynthesizer!short synt;

    override void create()
    {
        super.create;

        sampleBufferMutex = new shared Mutex();

        dspProcessor = new typeof(dspProcessor)(sampleBufferMutex, new AnalogSignalAnalyzer, sampleFreq, sampleWindowSize, logging);
        dspProcessor.dspBuffer.lock;

        equalizer = new BandEqualizer(sampleWindowSize, (fftIndex) {
            return dspProcessor.fftBuffer[fftIndex];
        }, 50);

        level = new RectLevel((i) {
            if (i < equalizer.bandValues.length)
            {
                return equalizer.bandValues[i] * 2;
            }
            return 0;
        }, () { return 1; });
        level.levels = 50;

        equalizer.onUpdateIndexFreqStartEnd = (band, startFreq, endFreq) {
            import std.format : format;

            auto label = format("%s\n%s", Math.round(startFreq), Math.round(endFreq));
            level.labels[band].text = label;
        };

        addCreate(level);

        equalizer.onUpdateEnd = () {};

        equalizer.onUpdateStart = () {};

        equalizer.onUpdate = (signal) {};

        dspProcessor.onUpdateFTBuffer = () { equalizer.update; };

        import api.dm.gui.controls.containers.vbox : VBox;
        import api.dm.gui.controls.containers.hbox : HBox;

        auto musicContainer = new HBox;
        addCreate(musicContainer);
        musicContainer.enablePadding;
        musicContainer.isAlignY = true;

        import api.dm.gui.controls.texts.text : Text;

        // auto musicFile = new Text(
        //     "/home/user/sdl-music/November snow.mp3");
        // musicContainer.addCreate(musicFile);

        if (const err = media.mixer.mixer.setPostCallback(&typeof(dspProcessor)
                .signal_callback, cast(void*)&dspProcessor
                .dspBuffer))
        {
            throw new Exception(err.toString);
        }

        import api.dm.gui.controls.switches.buttons.button : Button;

        synt = new SoundSynthesizer!short;

        auto sineBtn = new Button("Play");
        musicContainer.addCreate(sineBtn);
        sineBtn.onPointerPress ~= (ref e) {
            dspProcessor.unlock;

            if (chunk)
            {
                chunk.dispose;
            }

            import api.dm.kit.media.music.genres.ambient;
            import api.dm.kit.media.synthesis.chord_synthesis;
            import api.dm.kit.media.synthesis.notes;

            MusicNote[] notes = [
                {Note.C4}, {Note.C4}, {Note.D4}, {Note.C4}, {Note.F4}, {Note.E4},
                {Note.C4}, {Note.C4}, {Note.D4}, {Note.C4}, {Note.G4}, {Note.F4},
            ];
            synt.sequence(notes, 44100, (short[] buff, double time) {
                chunk = media.newHeapChunk!short(time);
                chunk.data.buffer[] = buff;
            }, 120, 2);

            chunk.play;

            // chunk = media.newHeapChunk!short(200);
            // chunk.onBuffer((data, spec) { chord(data,  spec.freqHz, 1); });

            import api.dm.kit.media.dsp.formats.wav_writer: WavWriter;

            auto writer = new WavWriter;
            writer.save("/home/user/sdl-music/out.wav", chunk.data.buffer, chunk.spec);

            // chunk.play;
            ///dspProcessor.lock;
        };
    }

    void playSound()
    {

    }

    override void pause()
    {
        super.pause;
        dspProcessor.lock;
    }

    override void run()
    {
        super.run;
        dspProcessor.unlock;
    }

    override void drawContent()
    {
        super.drawContent;
    }

    override void update(double delta)
    {
        super.update(delta);

        // if (!clip)
        // {
        //     return;
        // }

        dspProcessor.step;
    }
}
