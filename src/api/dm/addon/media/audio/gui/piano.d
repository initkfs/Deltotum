module api.dm.addon.media.audio.gui.piano;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.addon.media.audio.gui.synthesizer_panel : SynthesizerPanel;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsla : HSLA;

import api.dm.addon.dsp.synthesis.effect_synthesis : ADSR;
import api.dm.addon.media.audio.music_notes : Octave, MusicNote;

import Math = api.math;

class PianoKey : Control
{
    size_t index;
    string name;
    float freqHz = 0;

    bool isBlack;

    Text nameText;

    RGBA backgroundColor;

    this()
    {
        // import api.dm.kit.sprites2d.layouts.vlayout: VLayout;
        // layout = new VLayout;
        // layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        nameText = new Text(name);
        addCreate(nameText);

        setBackgroundColor;
    }

    void setBackgroundColor()
    {
        backgroundColor = !isBlack ? RGBA.white : RGBA.black;
    }

    override void drawContent()
    {
        super.drawContent;
        const bounds = boundsRect;
        nameText.x = bounds.middleX - nameText.halfWidth;
        nameText.y = bounds.bottom - nameText.height;

        //stroke
        graphic.color(RGBA.gray);
        graphic.fillRect(boundsRect);
        graphic.restoreColor;

        const fillBounds = boundsRect.withPadding(2);

        graphic.color(backgroundColor);
        graphic.fillRect(fillBounds);
        graphic.restoreColor;
    }
}

/**
 * Authors: initkfs
 */
class Piano : Control
{
    Container keyContainer;

    PianoKey[] pianoKeys;

    enum pianoKeysCount = 88; //(3 + 12 * 7 + 1)
    enum whiteKeysCount = 52;
    enum blackKeysCount = 36;

    Container controlPanel;

    SynthesizerPanel settings;
    void delegate() onUpdateSettings;

    void delegate(PianoKey, ref PointerEvent) onPianoKey;

    //foreach (noteIndex, noteCode; EnumMembers!Octave) replace with simple arrays for up ct
    static immutable string[] pianoNoteNames = ["A0","A0s","B0","C1","C1s","D1","D1s","E1","F1","F1s","G1","G1s","A1","A1s","B1","C2","C2s","D2","D2s","E2","F2","F2s","G2","G2s","A2","A2s","B2","C3","C3s","D3","D3s","E3","F3","F3s","G3","G3s","A3","A3s","B3","C4","C4s","D4","D4s","E4","F4","F4s","G4","G4s","A4","A4s","B4","C5","C5s","D5","D5s","E5","F5","F5s","G5","G5s","A5","A5s","B5","C6","C6s","D6","D6s","E6","F6","F6s","G6","G6s","A6","A6s","B6","C7","C7S","D7","D7S","E7","F7","F7S","G7","G7S","A7","A7S","B7","C8",];
    static immutable float[] pianoNoteFreq = [27.5000f,29.1352f,30.8677f,32.7032f,34.6478f,36.7081f,38.8909f,41.2034f,43.6535f,46.2493f,48.9994f,51.9131f,55.0000f,58.2705f,61.7354f,65.4064f,69.2957f,73.4162f,77.7817f,82.4069f,87.3071f,92.4986f,97.9989f,103.8260f,110.0000f,116.5410f,123.4710f,130.8130f,138.5910f,146.8320f,155.5630f,164.8140f,174.6140f,184.9970f,195.9980f,207.6520f,220.0000f,233.0820f,246.9420f,261.6260f,277.1830f,293.6650f,311.1270f,329.6280f,349.2280f,369.9940f,391.9950f,415.3050f,440.0000f,466.1640f,493.8830f,523.2510f,554.3650f,587.3300f,622.2540f,659.2550f,698.4560f,739.9890f,783.9910f,830.6090f,880.0000f,932.3280f,987.7670f,1046.5000f,1108.7300f,1174.6600f,1244.5100f,1318.5100f,1396.9100f,1479.9800f,1567.9800f,1661.2200f,1760.0000f,1864.6600f,1975.5300f,2093.0000f,2217.4600f,2349.3201f,2489.0200f,2637.0200f,2793.8301f,2959.9600f,3135.9600f,3322.4399f,3520.0000f,3729.3101f,3951.0701f,4186.0098f];

    this()
    {
        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        controlPanel = new HBox;
        controlPanel.isAlignY = true;
        addCreate(controlPanel);

        settings = new SynthesizerPanel;

        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        settings.layout = new HLayout;
        settings.layout.isAlignY = true;
        settings.layout.isAutoResize = true;

        controlPanel.addCreate(settings);

        if (settings.fmContainer)
        {
            settings.fmContainer.layout = new HLayout;
            settings.fmContainer.layout.isAlignY = true;
            settings.fmContainer.layout.isAutoResize = true;
        }

        settings.onUpdatePattern = () {
            if (onUpdateSettings)
            {
                onUpdateSettings();
            }
        };

        keyContainer = new Container;
        keyContainer.resize(width, height);
        keyContainer.isResizedByParent = true;
        addCreate(keyContainer);

        const pianoKeyWidth = Math.trunc(keyContainer.width / whiteKeysCount);
        const pianoKeyHeight = keyContainer.height;

        assert(pianoKeyWidth > 0);
        assert(pianoKeyHeight > 0);

        PianoKey[blackKeysCount] blackKeysCountArr;
        size_t blackKeysCountIndex;

        PianoKey[whiteKeysCount] whiteKeysCountArr;
        size_t whiteKeysCountIndex;

        import std.conv : to;

        assert(pianoNoteNames.length == pianoNoteFreq.length);

        foreach (noteIndex, noteName; pianoNoteNames)
        {
            auto pkey = new PianoKey;

            pkey.index = noteIndex;
            pkey.name = noteName;

            pkey.isBlack = pkey.name.length == 3;
            pkey.freqHz = pianoNoteFreq[noteIndex];

            pkey.isLayoutManaged = false;
            pkey.width = pianoKeyWidth;
            pkey.height = !pkey.isBlack ? pianoKeyHeight : pianoKeyHeight / 2;

            if (!pkey.isBlack)
            {
                whiteKeysCountArr[whiteKeysCountIndex] = pkey;
                whiteKeysCountIndex++;
            }
            else
            {
                blackKeysCountArr[blackKeysCountIndex] = pkey;
                blackKeysCountIndex++;
            }
            pianoKeys ~= pkey;
        }

        if (blackKeysCountIndex != blackKeysCount)
        {
            import std.format : format;

            throw new Exception(format("Expected %s black keys, but created %s", blackKeysCount, blackKeysCountIndex));
        }

        if (whiteKeysCountIndex != whiteKeysCount)
        {
            import std.format : format;

            throw new Exception(format("Expected %s white keys, but created %s", whiteKeysCount, whiteKeysCountIndex));
        }

        foreach (wk; whiteKeysCountArr)
        {
            keyContainer.addCreate(wk);
        }

        foreach (bk; blackKeysCountArr)
        {
            keyContainer.addCreate(bk);
        }

        foreach (ii; 0 .. pianoKeys.length)
            (i) {
            auto key = pianoKeys[i];
            key.onPointerEnter ~= (ref e) {

                //TODO optimization
                if (!key.isBlack)
                {
                    if (isForBlackKey(e.x, e.y))
                    {
                        return;
                    }
                }
                else
                {
                    resetWhiteKeys;
                }
                key.backgroundColor = RGBA.lightgrey;
            };

            key.onPointerExit ~= (ref e) {
                resetWhiteKeys;
            };

            key.onPointerExit ~= (ref e) { key.setBackgroundColor; };

            key.onPointerPress ~= (ref e) {
                if (!key.isBlack)
                {
                    if (isForBlackKey(e.x, e.y))
                    {
                        return;
                    }
                }

                if (settings)
                {
                    settings.fc(key.freqHz, isTriggerListeners:
                        false);
                }

                if (onPianoKey)
                {
                    onPianoKey(key, e);
                }
            };
        }(ii);
    }

    protected void resetWhiteKeys()
    {
        foreach (k; pianoKeys)
        {
            if (!k.isBlack && k.isMouseOver)
            {
                k.isMouseOver = false;
                k.setBackgroundColor;
            }
        }
    }

    protected bool isForBlackKey(float x, float y)
    {
        foreach (PianoKey key; pianoKeys)
        {
            if (!key.isBlack)
            {
                continue;
            }
            if (key.boundsRect.contains(x, y) && key.isMouseOver)
            {
                return true;
            }
        }
        return false;
    }

    override void drawContent()
    {
        super.drawContent;

        if (!keyContainer)
        {
            return;
        }

        float nextX = keyContainer.x;
        float nextY = keyContainer.y;
        foreach (i, PianoKey key; pianoKeys)
        {
            if (key.isBlack)
            {
                key.x = nextX - key.halfWidth;
                key.y = nextY;
                continue;
            }

            key.x = nextX;
            key.y = nextY;

            nextX += key.width;
        }
    }

}
