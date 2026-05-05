module api.dm.gui.supports.debuggers.manages.env_manager;

import api.dm.gui.supports.debuggers.base_debugger_panel : BaseDebuggerPanel;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;
import api.dm.gui.controls.selects.color_pickers.color_picker : ColorPicker;
import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */

class EnvManager : BaseDebuggerPanel
{
    RegulateTextPanel envPanel;

    RegulateTextField blurRadiusField;
    RegulateTextField blurIntensityField;

    RegulateTextField[dstring] appFields;

    /*
       float baseIntensity = 2; // 1.5–2.0 Base cube strength
       float bloomIntensity = 1.0; // Halo density
       float exposure = 0.9; // Overall brightness (ACES)
       float threshold = 50.0; // At what brightness the cube begins to whiten
    */
    RegulateTextField composeExposureField;
    RegulateTextField composeThresholdField;

    RegulateTextField contrastField;
    RegulateTextField saturationField;
    RegulateTextField vignetteField;
    RegulateTextField gammaField;

    ColorPicker filterColor;
    RegulateTextField filterIntensity;

    ColorPicker flashColor;
    RegulateTextField flashIntensity;

    this(GuiScene scene)
    {
        super(scene);
        setVLayout;
    }

    override void create()
    {
        super.create;

        envPanel = new RegulateTextPanel;
        addCreate(envPanel);

        float step = 0.01;

        blurRadiusField = new RegulateTextField("BlRad", 0, 10, (v) {
            targetScene.postProc.blurUniformData.radius = v;
        });
        blurRadiusField.scrollDt = step;
        envPanel.addCreate(blurRadiusField);

        blurIntensityField = new RegulateTextField("BlInt", -5, 5, (v) {
            targetScene.postProc.blurUniformData.intensity = v;
        });
        blurIntensityField.scrollDt = step;

        envPanel.addCreate(blurIntensityField);

        blurRadiusField.value(targetScene.postProc.blurUniformData.radius, false);
        blurIntensityField.value(targetScene.postProc.blurUniformData.intensity, false);

        composeExposureField = new RegulateTextField("CoExp", 0, 50, (v) {
            targetScene.postProc.composeUniformData.exposure = v;
        });
        composeExposureField.scrollDt = step;
        envPanel.addCreate(composeExposureField);

        composeThresholdField = new RegulateTextField("CoTre", 0, 25, (v) {
            if (!targetScene.postProc.isColorEffects)
            {
                targetScene.postProc.isColorEffects = true;
            }
            targetScene.postProc.composeUniformData.threshold = v;
        });
        composeThresholdField.scrollDt = step;
        envPanel.addCreate(composeThresholdField);

        composeExposureField.value(targetScene.postProc.composeUniformData.exposure, false);
        composeThresholdField.value(targetScene.postProc.composeUniformData.threshold,false);

        contrastField = new RegulateTextField("Contr", 0, 10, (v) {
            if (!targetScene.postProc.isColorEffects)
            {
                targetScene.postProc.isColorEffects = true;
            }
            targetScene.postProc.composeUniformData.contrast = v;
        });
        contrastField.scrollDt = 0.001;
        envPanel.addCreate(contrastField);
        contrastField.value(targetScene.postProc.composeUniformData.contrast, false);

        saturationField = new RegulateTextField("Satur", 0, 2, (v) {
            if (!targetScene.postProc.isColorEffects)
            {
                targetScene.postProc.isColorEffects = true;
            }
            targetScene.postProc.composeUniformData.saturation = v;
        });
        saturationField.scrollDt = 0.01;
        envPanel.addCreate(saturationField);
        saturationField.value(targetScene.postProc.composeUniformData.saturation, false);

        vignetteField = new RegulateTextField("Vignt", 0, 5, (v) {
            if (!targetScene.postProc.isVignette)
            {
                targetScene.postProc.isVignette = true;
            }
            targetScene.postProc.composeUniformData.vignette = v;
        });
        vignetteField.scrollDt = 0.01;
        envPanel.addCreate(vignetteField);
        vignetteField.value(targetScene.postProc.composeUniformData.vignette, false);

        gammaField = new RegulateTextField("Gamma", 1, 10, (v) {
            targetScene.postProc.composeUniformData.gamma = v;
        });
        gammaField.scrollDt = 0.01;
        envPanel.addCreate(gammaField);
        gammaField.value(targetScene.postProc.composeUniformData.gamma, false);

        filterColor = new ColorPicker;
        addCreate(filterColor);
        filterColor.onChangeOldNew ~= (old, newv) {
            if (!targetScene.postProc.isColorTint)
            {
                targetScene.postProc.isColorTint = true;
            }
            targetScene.postProc.composeUniformData.colorFilterData[0 .. 3] = newv.toArrayFRGB;
        };

        filterColor.color(RGBA.fromArrayFRGB(
                targetScene.postProc.composeUniformData.colorFilterData[0 .. 3]), false);

        filterIntensity = new RegulateTextField("Fint", 0, 1, (v) {
            if (!targetScene.postProc.isColorTint)
            {
                targetScene.postProc.isColorTint = true;
            }
            targetScene.postProc.composeUniformData.colorFilterData[3] = v;
        });
        filterIntensity.scrollDt = 0.01;
        addCreate(filterIntensity);
        filterIntensity.value(targetScene.postProc.composeUniformData.colorFilterData[3], false);

        flashColor = new ColorPicker;
        addCreate(flashColor);
        flashColor.onChangeOldNew ~= (old, newv) {
            if (!targetScene.postProc.isColorTint)
            {
                targetScene.postProc.isColorTint = true;
            }
            targetScene.postProc.composeUniformData.colorFlashData[0 .. 3] = newv.toArrayFRGB;
        };
        flashColor.color(RGBA.fromArrayFRGB(
                targetScene.postProc.composeUniformData.colorFlashData[0 .. 3]), false);

        flashIntensity = new RegulateTextField("FlIn", 0, 1, (v) {
            if (!targetScene.postProc.isColorTint)
            {
                targetScene.postProc.isColorTint = true;
            }
            targetScene.postProc.composeUniformData.colorFlashData[3] = v;
        });
        flashIntensity.scrollDt = 0.01;
        addCreate(flashIntensity);
        flashIntensity.value(targetScene.postProc.composeUniformData.colorFlashData[3], false);
    }

    void setDebugField(void delegate(float) onValue, float startValue = 0, float minValue = 0, float maxValue = 1, float dt = 0.01, dstring name = "Field")
    {
        RegulateTextField field;
        if (auto fieldPtr = name in appFields)
        {
            field = *fieldPtr;
            //TODO correct setters
            return;
        }

        field = new RegulateTextField(name, minValue, maxValue, onValue);
        field.scrollDt = dt;
        addCreate(field);
        field.value(startValue, false);
        appFields[name] = field;
    }

    override void dispose()
    {
        super.dispose;
        appFields.clear;
    }
}
