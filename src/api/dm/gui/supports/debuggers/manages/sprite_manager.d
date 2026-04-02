module api.dm.gui.supports.debuggers.manages.sprite_manager;

import api.dm.gui.supports.debuggers.base_debugger_panel : BaseDebuggerPanel;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.texts.text_field : TextField;
import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.gui.controls.meters.spinners.spinner : Spinner, FracSpinner;

/**
 * Authors: initkfs
 */

class SpriteManager : BaseDebuggerPanel
{
    protected
    {
        Sprite2d _currentSprite;
    }

    FracSpinner xField;
    FracSpinner yField;
    FracSpinner zField;

    FracSpinner xRotateField;
    FracSpinner yRotateField;
    FracSpinner zRotateField;

    dstring initNumField = "0";

    this(Scene2d scene)
    {
        super(scene);
        setVLayout;
    }

    override void create()
    {
        super.create;

        auto transformBox = new HBox(2);
        addCreate(transformBox);
        transformBox.isAlignY = true;

        xField = createNumericField((v) { _currentSprite.x = v; });
        yField = createNumericField((v) { _currentSprite.y = v; });
        zField = createNumericField((v) {
            if (auto sprite3d = cast(Sprite3d) _currentSprite)
            {
                sprite3d.z = v;
            }
        });

        transformBox.addCreate([
            new Text("x:"), xField, new Text("y:"), yField, new Text("z:"), zField
        ]);

        xRotateField = createNumericField((v) {
            callOn3dSprite((sprite) { sprite.angleX = v; });
        }, 1);
        yRotateField = createNumericField((v) {
            callOn3dSprite((sprite) { sprite.angleY = v; });
        }, 1);
        zRotateField = createNumericField((v) { _currentSprite.angle = v; }, 1);

        auto rotateBox = new HBox(2);
        addCreate(rotateBox);
        rotateBox.isAlignY = true;

        rotateBox.addCreate([
            new Text("X:"), xRotateField, new Text("Y:"), yRotateField,
            new Text("Z:"), zRotateField
        ]);

    }

    void callOnSprite(void delegate(Sprite2d) onSprite)
    {
        if (_currentSprite)
        {
            onSprite(_currentSprite);
        }
    }

    void callOn3dSprite(void delegate(Sprite3d) onSprite)
    {
        if (auto sprite3d = cast(Sprite3d) _currentSprite)
        {
            onSprite(sprite3d);
        }
    }

    FracSpinner createNumericField(void delegate(float value) onFieldValue, float dtValue = 0.1)
    {
        auto field = new FracSpinner(-float.max, float.max);
        field.incValue = dtValue;
        field.decValue = dtValue;
        setNumericField(field, onFieldValue);
        return field;
    }

    void setNumericField(FracSpinner field, void delegate(float value) onFieldValue)
    {
        //field.isCreateIncDec = true;
        buildInitCreate(field);

        field.onValueProvider = (v) {
            import Math = api.math;
            import std.math.operations : isClose;

            if (isClose(v, 0, 0, 0.001))
            {
                return 0;
            }

            enum factor = 10.0 ^^ 2;
            return Math.round(v * factor) / factor;
        };

        field.onChangeOldNew ~= (oldv, newv) {

            if (!_currentSprite)
            {
                return;
            }

            onFieldValue(newv);
        };
    }

    dstring toStringField(float v)
    {
        import std.format : format;
        import std.conv : to;

        return format("%.2g", v).to!dstring;
    }

    void currentSprite(Sprite2d sprite)
    {
        _currentSprite = sprite;

        //TODO reset oldValue
        xField.valueLabel.text = toStringField(sprite.x);
        yField.valueLabel.text = toStringField(sprite.y);
        if (auto sprite3 = cast(Sprite3d) sprite)
        {
            zField.valueLabel.text = toStringField(sprite3.z);
        }

    }

    Sprite2d currentSprite() => _currentSprite;

}
