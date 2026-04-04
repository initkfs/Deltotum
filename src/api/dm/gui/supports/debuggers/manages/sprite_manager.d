module api.dm.gui.supports.debuggers.manages.sprite_manager;

import api.dm.gui.supports.debuggers.base_debugger_panel : BaseDebuggerPanel;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.texts.text_field : TextField;
import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.gui.controls.meters.spinners.spinner : Spinner, FracSpinner;
import api.dm.gui.controls.selects.color_pickers.color_picker : ColorPicker;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;

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

    ColorPicker albedo;

    RegulateTextField albedoIntensity;

    dstring initNumField = "0";

    this(GuiScene scene)
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

        albedo = new ColorPicker;
        addCreate(albedo);

        albedo.onChangeOldNew ~= (old, newv) {
            if (_currentSprite)
            {
                if (auto sprite3d = cast(Sprite3d) _currentSprite)
                {
                    sprite3d.albedo = newv;
                    return;
                }
            }
        };

        albedoIntensity = new RegulateTextField("Int", 1, 400, (v) {
            if (auto sprite3d = cast(Sprite3d) _currentSprite)
            {
                sprite3d.albedoIntensity = v;
            }
        });
        albedoIntensity.scrollDt = 0.1;
        addCreate(albedoIntensity);
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

    override FracSpinner createNumericField(void delegate(float value) onFieldValue, float dtValue = 0.1)
    {
        auto field = super.createNumericField((v) {
            if (_currentSprite)
            {
                onFieldValue(v);
            }
        }, dtValue);
        return field;
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
            albedo.color(sprite3.albedo, false);
            albedoIntensity.value(sprite3.albedoIntensity, false);
        }

    }

    Sprite2d currentSprite() => _currentSprite;
}
