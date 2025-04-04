module api.dm.gui.controls.audio.piano;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.containers.container : Container;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.graphics.colors.hsla : HSLA;

import api.dm.kit.media.synthesis.music_notes : Octave, MusicNote;

import Math = api.math;

class PianoKey : Control
{
    size_t index;
    string name;
    double freqHz = 0;

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
        graphics.changeColor(RGBA.gray);
        graphics.fillRect(boundsRect);
        graphics.restoreColor;

        const fillBounds = boundsRect.withPadding(2);

        graphics.changeColor(backgroundColor);
        graphics.fillRect(fillBounds);
        graphics.restoreColor;
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

    void delegate(PianoKey) onPianoKey;

    this()
    {
        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        layout = new CenterLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

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

        import std.traits : EnumMembers;
        import std.conv : to;

        foreach (noteIndex, noteCode; EnumMembers!Octave)
        {
            auto pkey = new PianoKey;

            pkey.index = noteIndex;
            pkey.name = noteCode.to!string;

            auto octaveNum = pkey.name[1];
            auto keyNum = pkey.name[0];
            if (octaveNum == '0')
            {
                if (keyNum != 'A' && keyNum != 'B')
                {
                    continue;
                }
            }
            else if (octaveNum == '8')
            {
                if (pkey.name != "C8")
                {
                    //TODO break
                    continue;
                }
            }

            pkey.isBlack = pkey.name.length == 3;
            pkey.freqHz = cast(double) noteCode;

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
                key.backgroundColor = RGBA.lightgrey;
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

                if (onPianoKey)
                {
                    onPianoKey(key);
                }
            };
        }(ii);
    }

    protected bool isForBlackKey(double x, double y)
    {
        foreach (PianoKey key; pianoKeys)
        {
            if (!key.isBlack)
            {
                continue;
            }
            if (key.boundsRect.contains(x, y))
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

        double nextX = keyContainer.x;
        double nextY = keyContainer.y;
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
