module api.dm.kit.media.dsp.equalizers.rect_equalizer;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.meters.scales.dynamics.vscale_dynamic : VScaleDynamic;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.kit.graphics.colors.rgba : RGBA;

import Math = api.math;

/**
 * Authors: initkfs
 */
class RectEqualizer : Control
{
    Text[] labels;

    size_t numFreqBands = 30;
    double bandWidth = 0;

    RGBA[] bandColors;

    protected
    {
        double[] bandValues;
    }

    double delegate(size_t fftIndex) magnitudeProvider;
    double delegate(size_t fftIndex) freqProvider;

    this(double sampleWindowSize, double delegate(size_t fftIndex) magnitudeProvider, double delegate(
            size_t fftIndex) freqProvider)
    {
        bandWidth = (sampleWindowSize / 2) / cast(double) numFreqBands;

        assert(magnitudeProvider);
        this.magnitudeProvider = magnitudeProvider;

        assert(freqProvider);
        this.freqProvider = freqProvider;
    }

    void loadRectEqualizerTheme()
    {
        foreach (ref bandColor; bandColors)
        {
            auto color = RGBA.random.toHSLA;
            color.l = 0.8;
            color.s = 0.6;
            bandColor = color.toRGBA;
        }
    }

    override void create()
    {
        super.create;

        if (bandColors.length == 0)
        {
            bandColors = new RGBA[](numFreqBands);
            loadRectEqualizerTheme;
        }

        bandValues = new double[](numFreqBands);
        bandValues[] = 0;

        assert(freqProvider);

        foreach (i, ref double v; bandValues)
        {
            auto text = new Text("");
            text.setSmallSize;
            text.isLayoutManaged = false;
            addCreate(text);
            labels ~= text;
        }

    }

    void updateBands()
    {
        bandValues[] = 0;

        foreach (i, ref double v; bandValues)
        {
            size_t start = cast(size_t)(i * bandWidth);
            size_t end = cast(size_t)((i + 1) * bandWidth);

            foreach (j; start .. end)
            {
                auto magn = magnitudeProvider(j);
                v += magn;
            }

            import std.format : format;
            import Math = api.math;

            auto startFreq = freqProvider(start);
            auto endFreq = freqProvider(end);
            auto label = labels[i];
            label.text = format("%s\n%s", Math.round(startFreq), Math.round(endFreq));

            //writeln(i, " ", v, " ", v, " ", bandWidth, " ", start, " ", end);
            v /= bandWidth;
            // import std;
            // writeln(v);
            //v = Math.clamp(v, 0, 1.0);
        }

        // foreach (i, ref double v; bandValues)
        // {
        //     v /= ampMax;
        // }
    }

    double ampToDb(double amp)
    {
        import std.math : log10;

        return 20 * log10(amp == 0 ? double.epsilon : amp);
    }

    override void drawContent()
    {
        super.drawContent;

        auto x = 0;
        auto y = 300;
        auto bandW = 40;
        auto bandH = 100;

        import std.math : log10;

        foreach (i; 0 .. numFreqBands)
        {
            auto level = bandValues[i] * bandH;

            graphics.changeColor(bandColors[i]);
            scope (exit)
            {
                graphics.restoreColor;
            }

            auto label = labels[i];
            label.x = x + bandW / 2 - label.halfWidth;
            label.y = y;

            graphics.fillRect(x, y - level, bandW, level);
            x += bandW;

            //printf("\n");
        }
    }

    override void update(double delta)
    {
        super.update(delta);
    }
}
