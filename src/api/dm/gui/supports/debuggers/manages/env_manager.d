module api.dm.gui.supports.debuggers.manages.env_manager;

import api.dm.gui.supports.debuggers.base_debugger_panel : BaseDebuggerPanel;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;
import api.dm.gui.controls.selects.color_pickers.color_picker : ColorPicker;
import api.dm.kit.graphics.colors.rgba: RGBA;

/**
 * Authors: initkfs
 */

class EnvManager : BaseDebuggerPanel
{
    RegulateTextPanel envPanel;

    RegulateTextField brightTresholdField;
    RegulateTextField brightInsensityField;

    RegulateTextField blurRadiusField;
    RegulateTextField blurIntensityField;

    /*
       float baseIntensity = 2; // 1.5–2.0 Base cube strength
       float bloomIntensity = 1.0; // Halo density
       float exposure = 0.9; // Overall brightness (ACES)
       float threshold = 50.0; // At what brightness the cube begins to whiten
    */
    RegulateTextField composeBaseIntensityField;
    RegulateTextField composeBloomIntensityField;
    RegulateTextField composeExposureField;
    RegulateTextField composeThresholdField;

    RegulateTextField contrastField;
    RegulateTextField saturationField;
    RegulateTextField vignetteField;

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

        brightTresholdField = new RegulateTextField("BTre", -5, 5, (v) {
            targetScene.postProc.brightUniformData[0] = v;
        });
        brightTresholdField.scrollDt = step;
        envPanel.addCreate(brightTresholdField);

        brightInsensityField = new RegulateTextField("BInt", -5, 5, (v) {
            targetScene.postProc.brightUniformData[1] = v;
        });
        brightTresholdField.scrollDt = step;

        envPanel.addCreate(brightInsensityField);

        brightTresholdField.value(0, false, true);
        brightInsensityField.value = 0.2;

        blurRadiusField = new RegulateTextField("BlRa", -5, 5, (v) {
            targetScene.postProc.blurUniformData.radius = v;
        });
        blurRadiusField.scrollDt = step;
        envPanel.addCreate(blurRadiusField);

        blurIntensityField = new RegulateTextField("BlIn", -5, 5, (v) {
            targetScene.postProc.blurUniformData.intensity = v;
        });
        blurIntensityField.scrollDt = step;

        envPanel.addCreate(blurIntensityField);

        blurRadiusField.value = 1;
        blurIntensityField.value = 1;

        composeBaseIntensityField = new RegulateTextField("CoIn", -5, 5, (v) {
            targetScene.postProc.composeUniformData.baseIntensity = v;
        });
        envPanel.addCreate(composeBaseIntensityField);

        composeBloomIntensityField = new RegulateTextField("CoBI", -20, 20, (v) {
            targetScene.postProc.composeUniformData.bloomIntensity = v;
        });
        envPanel.addCreate(composeBloomIntensityField);

        composeExposureField = new RegulateTextField("CoEx", -20, 20, (v) {
            targetScene.postProc.composeUniformData.exposure = v;
        });
        envPanel.addCreate(composeExposureField);

        composeThresholdField = new RegulateTextField("CoTr", -200, 200, (v) {
            targetScene.postProc.composeUniformData.threshold = v;
        });
        composeThresholdField.scrollDt = 1;
        envPanel.addCreate(composeThresholdField);

        composeBaseIntensityField.value = targetScene.postProc.composeUniformData.baseIntensity;
        composeBloomIntensityField.value = targetScene.postProc.composeUniformData.bloomIntensity;
        composeExposureField.value = targetScene.postProc.composeUniformData.exposure;
        composeThresholdField.value = targetScene.postProc.composeUniformData.threshold;

        contrastField = new RegulateTextField("Cont", 1, 20, (v) {
            targetScene.postProc.composeUniformData.contrast = v;
        });
        composeThresholdField.scrollDt = 0.0001;
        envPanel.addCreate(contrastField);
        composeThresholdField.value = targetScene.postProc.composeUniformData.contrast;

        saturationField = new RegulateTextField("Satu", 0, 5, (v) {
            targetScene.postProc.composeUniformData.saturation = v;
        });
        saturationField.scrollDt = 0.01;
        envPanel.addCreate(saturationField);
        saturationField.value = targetScene.postProc.composeUniformData.saturation;

        vignetteField = new RegulateTextField("Vign", 0, 5, (v) {
            targetScene.postProc.composeUniformData.vignette = v;
        });
        composeThresholdField.scrollDt = 0.01;
        envPanel.addCreate(vignetteField);
        vignetteField.value = targetScene.postProc.composeUniformData.vignette;

        filterColor = new ColorPicker;
        addCreate(filterColor);
        filterColor.onChangeOldNew ~= (old, newv) {
            targetScene.postProc.composeUniformData.colorFilterData[0 .. 3] = newv.toArrayFRGB;
        };
        
        filterColor.color(RGBA.fromArrayFRGB(targetScene.postProc.composeUniformData.colorFilterData[0..3]), false);

        filterIntensity = new RegulateTextField("Fint", 0, 1, (v) {
            targetScene.postProc.composeUniformData.colorFilterData[3] = v;
        });
        filterIntensity.scrollDt = 0.01;
        addCreate(filterIntensity);
        filterIntensity.value(targetScene.postProc.composeUniformData.colorFilterData[3], false);

        flashColor = new ColorPicker;
        addCreate(flashColor);
        flashColor.onChangeOldNew ~= (old, newv) {
            targetScene.postProc.composeUniformData.colorFlashData[0 .. 3] = newv.toArrayFRGB;
        };
        flashColor.color(RGBA.fromArrayFRGB(targetScene.postProc.composeUniformData.colorFlashData[0..3]), false);

        flashIntensity = new RegulateTextField("FlIn", 0, 1, (v) {
            targetScene.postProc.composeUniformData.colorFlashData[3] = v;
        });
        flashIntensity.scrollDt = 0.01;
        addCreate(flashIntensity);
        flashIntensity.value(targetScene.postProc.composeUniformData.colorFlashData[3], false);
    }
}
