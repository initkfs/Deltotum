module api.dm.gui.controls.audio.sound_pattern_item;

import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.gui.controls.texts.text : Text;

import api.dm.kit.media.synthesis.sound_pattern: SoundPattern;
import api.dm.kit.media.synthesis.effect_synthesis : ADSR;
import api.dm.kit.media.synthesis.music_notes;

/**
 * Authors: initkfs
 */
class SoundPatternItem : BaseBiswitch
{
    SoundPattern pattern;

    Text text;
    Button deleteThis;
    Button insertNext;

    void delegate() onDelete;
    void delegate() onInsertNext;

    Button play;
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

        deleteThis = new Button("-");
        deleteThis.width = theme.checkMarkerWidth;
        deleteThis.height = theme.checkMarkerHeight;
        addCreate(deleteThis);
        deleteThis.onAction ~= (ref e) {
            if (onDelete)
            {
                onDelete();
            }
        };

        text = new Text("(0)");
        addCreate(text);

        onOldNewValue ~= (oldv, newv) { isDrawBounds = newv; };

        onPointerPress ~= (ref e) { toggle; };

        play = new Button("Play");
        addCreate(play);
        play.onAction ~= (ref e) {
            if (onPlay)
            {
                onPlay();
            }
            e.isConsumed = true;
        };

        insertNext = new Button(">");
        addCreate(insertNext);
        insertNext.width = theme.checkMarkerWidth;
        insertNext.height = theme.checkMarkerHeight;
        insertNext.onAction ~= (ref e) {
            if (onInsertNext)
            {
                onInsertNext();
            }
        };



    }

    void updateData()
    {
        assert(text);
        text.text = toString;
    }

    override string toString()
    {
        import std.format : format;

        return format("%d(%.0f,%.0f,%.0f)", cast(int) pattern.noteType, pattern.freqHz, pattern.fmHz, pattern.fmIndex);
    }

}
