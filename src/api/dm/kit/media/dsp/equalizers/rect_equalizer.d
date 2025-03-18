module api.dm.kit.media.dsp.equalizers.rect_equalizer;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;

import Math = api.math;

/**
 * Authors: initkfs
 */
class RectEqualizer : Sprite2d
{
    size_t numFreqBands = 10;
    double bandWidth = 0;

    RGBA[] bandColors;

    protected
    {
        double[] bandValues;
    }

    double delegate(size_t fftIndex) amplitudeProvider;

    this(double sampleWindowSize, double delegate(size_t fftIndex) amplitudeProvider)
    {
        bandWidth = sampleWindowSize / 2 / cast(double) numFreqBands;

        assert(amplitudeProvider);
        this.amplitudeProvider = amplitudeProvider;
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
                v += amplitudeProvider(j);
            }

            //writeln(i, " ", v, " ", v, " ", bandWidth, " ", start, " ", end);
            v /= bandWidth;
        }
    }

    double ampToDb(double amp)
    {
        import std.math : log10;

        return 20 * log10(amp == 0 ? double.epsilon : amp);
    }

    override void drawContent()
    {
        super.drawContent;

        auto x = 200;
        auto y = 300;
        auto bandW = 30;

        import std.math : log10;

        foreach (i; 0 .. numFreqBands)
        {
            auto amp = bandValues[i];
            auto dBAmp = ampToDb(amp);

            graphics.changeColor(bandColors[i]);
            scope (exit)
            {
                graphics.restoreColor;
            }

            auto level = dBAmp;
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
