module api.dm.gui.supports.debuggers.manages.env_manager;

import api.dm.gui.supports.debuggers.base_debugger_panel : BaseDebuggerPanel;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.gui.controls.forms.regulates.regulate_text_panel : RegulateTextPanel;
import api.dm.gui.controls.forms.regulates.regulate_text_field : RegulateTextField;

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
            targetScene.brightUniformData[0] = v;
        });
        brightTresholdField.scrollDt = step;
        envPanel.addCreate(brightTresholdField);

        brightInsensityField = new RegulateTextField("BInt", -5, 5, (v) {
            targetScene.brightUniformData[1] = v;
        });
        brightTresholdField.scrollDt = step;

        envPanel.addCreate(brightInsensityField);

        brightTresholdField.value(0, false, true);
        brightInsensityField.value = 0.2;

        blurRadiusField = new RegulateTextField("BlRa", -5, 5, (v) {
            targetScene.blurUniformData.radius = v;
        });
        blurRadiusField.scrollDt = step;
        envPanel.addCreate(blurRadiusField);

        blurIntensityField = new RegulateTextField("BlIn", -5, 5, (v) {
            targetScene.blurUniformData.intensity = v;
        });
        blurIntensityField.scrollDt = step;

        envPanel.addCreate(blurIntensityField);

        blurRadiusField.value = 1;
        blurIntensityField.value = 1;

        composeBaseIntensityField = new RegulateTextField("CoIn", -5, 5, (v) {
            targetScene.composeUniformData[0] = v;
        });
        envPanel.addCreate(composeBaseIntensityField);

        composeBloomIntensityField = new RegulateTextField("CoBI", -20, 20, (v) {
            targetScene.composeUniformData[1] = v;
        });
        envPanel.addCreate(composeBloomIntensityField);

        composeExposureField = new RegulateTextField("CoEx", -20, 20, (v) {
            targetScene.composeUniformData[2] = v;
        });
        envPanel.addCreate(composeExposureField);

        composeThresholdField = new RegulateTextField("CoTr", -200, 200, (v) {
            targetScene.composeUniformData[3] = v;
        });
        composeThresholdField.scrollDt = 1;
        envPanel.addCreate(composeThresholdField);

        composeBaseIntensityField.value = 2;
        composeBloomIntensityField.value = 1;
        composeExposureField.value = 0.9;
        composeThresholdField.value = 50;
    }
}
