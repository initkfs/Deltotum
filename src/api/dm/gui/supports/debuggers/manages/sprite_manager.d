module api.dm.gui.supports.debuggers.manages.sprite_manager;

import api.dm.gui.supports.debuggers.base_debugger_panel : BaseDebuggerPanel;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.texts.text_field : TextField;
import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.gui.controls.meters.spinners.spinner : Spinner, FracSpinner;
import api.dm.gui.controls.selects.color_pickers.color_picker : ColorPicker;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;
import api.dm.kit.sprites3d.lightings.lights.base_light : BaseLight;
import api.dm.gui.controls.switches.checks.check : Check;

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

    FracSpinner xScaleField;
    FracSpinner yScaleField;
    FracSpinner zScaleField;

    FracSpinner xRotateField;
    FracSpinner yRotateField;
    FracSpinner zRotateField;

    ColorPicker albedo;
    RegulateTextField albedoIntensity;

    dstring initNumField = "0";

    LightPanel lightPanel;
    MaterialPanel matPanel;

    Check isVisibleField;

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

        xScaleField = createNumericField((v) {
            callOn3dSprite((sprite) { sprite.scaleX = v; });
        });
        yScaleField = createNumericField((v) {
            callOn3dSprite((sprite) { sprite.scaleY = v; });
        });
        zScaleField = createNumericField((v) {
            callOn3dSprite((sprite) { sprite.scaleZ = v; });
        });

        auto scaleBox = new HBox(2);
        addCreate(scaleBox);
        scaleBox.isAlignY = true;

        scaleBox.addCreate([
            new Text("sx"), xScaleField, new Text("sy"), yScaleField,
            new Text("sz"), zScaleField
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
            new Text("rx"), xRotateField, new Text("ry"), yRotateField,
            new Text("rz"), zRotateField
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

        isVisibleField = new Check("Vis:");
        addCreate(isVisibleField);
        isVisibleField.onChangeOldNew ~= (oldv, newv) {
            if (_currentSprite)
            {
                _currentSprite.isVisible = newv;
            }
        };

        lightPanel = new LightPanel;
        addCreate(lightPanel);
        enablePanel(lightPanel, false);

        matPanel = new MaterialPanel;
        addCreate(matPanel);
        enablePanel(matPanel, false);
    }

    void enablePanel(Control panel, bool value)
    {
        panel.isVisible = value;
        panel.isLayoutManaged = value;
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

    override FracSpinner createNumericField(void delegate(float value) onFieldValue, float dtValue = 0.1, float min = -float
            .max, float max = float.max)
    {
        auto field = super.createNumericField((v) {
            if (_currentSprite)
            {
                onFieldValue(v);
            }
        }, dtValue, min, max);
        return field;
    }

    void currentSprite(Sprite2d sprite)
    {
        _currentSprite = sprite;

        //TODO reset oldValue
        xField.value(sprite.x, false);
        yField.value(sprite.y, false);
        if (auto sprite3 = cast(Sprite3d) sprite)
        {
            zField.value(sprite3.z, false);
            albedo.color(sprite3.albedo, false);
            albedoIntensity.value(sprite3.albedoIntensity, false);

            xScaleField.value(sprite3.scaleX, false);
            yScaleField.value(sprite3.scaleY, false);
            zScaleField.value(sprite3.scaleZ, false);

            xRotateField.value(sprite3.angleX, false);
            yRotateField.value(sprite3.angleY, false);
            zRotateField.value(sprite3.angle, false);
        }

        import api.dm.kit.sprites3d.materials.material : Material;

        if (auto mat = cast(Material) sprite)
        {
            assert(mat);
            enablePanel(matPanel, true);
            matPanel.mat = mat;
            matPanel.fill;
        }
        else
        {
            enablePanel(matPanel, false);
            matPanel.mat = null;
        }

        if (auto lamp = cast(BaseLight) sprite)
        {
            enablePanel(lightPanel, true);
            lightPanel.lamp = lamp;
            lightPanel.ambientField.color(lamp.ambient, false);
            lightPanel.diffuseField.color(lamp.diffuse, false);
            lightPanel.specularField.color(lamp.specular, false);

            lightPanel.linearCoeff.value(lamp.linearCoeff, false);
            lightPanel.quadraticCoeff.value(lamp.quadraticCoeff, false);
        }
        else
        {
            enablePanel(lightPanel, false);
            lightPanel.lamp = null;
        }

        isVisibleField.isOn(sprite.isVisible, false);
    }

    Sprite2d currentSprite() => _currentSprite;
}

class MaterialPanel : Control
{
    ColorPicker ambient;
    ColorPicker specular;
    RegulateTextField glossField;

    import api.dm.kit.sprites3d.materials.material;

    Material mat;

    this()
    {
        setVLayout;
    }

    override void create()
    {
        super.create;

        ambient = new ColorPicker;
        addCreate(ambient);

        ambient.onChangeOldNew ~= (old, newv) {
            if (mat)
            {
                mat.ambient = newv;
            }
        };

        specular = new ColorPicker;
        addCreate(specular);

        specular.onChangeOldNew ~= (old, newv) {
            if (mat)
            {
                mat.specular = newv;
            }
        };

        glossField = new RegulateTextField("Gls", 0, 1, (v) {
            if (mat)
            {
                mat.gloss = v;
            }
        });
        glossField.scrollDt = 0.01;
        addCreate(glossField);
    }

    void fill()
    {
        assert(mat);
        ambient.color(mat.ambient, false);
        specular.color(mat.specular, false);
        glossField.value(mat.gloss, false);
    }
}

class LightPanel : Control
{
    ColorPicker ambientField;
    ColorPicker diffuseField;
    ColorPicker specularField;

    RegulateTextField linearCoeff;
    RegulateTextField quadraticCoeff;

    BaseLight lamp;

    this()
    {
        setVLayout;
    }

    override void create()
    {
        super.create;

        ambientField = new ColorPicker;
        addCreate(ambientField);
        ambientField.onChangeOldNew ~= (old, newv) {
            if (lamp)
            {
                lamp.ambient = newv;
            }
        };

        diffuseField = new ColorPicker;
        addCreate(diffuseField);
        diffuseField.onChangeOldNew ~= (old, newv) {
            if (lamp)
            {
                lamp.diffuse = newv;
            }
        };

        specularField = new ColorPicker;
        addCreate(specularField);
        specularField.onChangeOldNew ~= (old, newv) {
            if (lamp)
            {
                lamp.specular = newv;
            }
        };

        linearCoeff = new RegulateTextField("Lin", 0, 1, (v) {
            lamp.linearCoeff = v;
        });
        linearCoeff.scrollDt = 0.01;
        addCreate(linearCoeff);

        quadraticCoeff = new RegulateTextField("Qua", 0, 3, (v) {
            lamp.quadraticCoeff = v;
        });
        quadraticCoeff.scrollDt = 0.01;
        addCreate(quadraticCoeff);

    }
}
