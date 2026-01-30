module api.sims.phys.heats.heat_transfer;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import Math = api.math;

/**
 * Authors: initkfs
 */

void transfer(Sprite2d a, Sprite2d b, float contactArea = 1, float dt = 1, float eps = 0.001)
{
    if (a.temp == b.temp)
    {
        return;
    }

    //float conductivity = (a.thermMat.thermalConductivity + b.thermMat.thermalConductivity) / 2.0;
    //float conductivity = 2.0 / (
    //    1.0 / a.thermMat.thermalConductivity + 1.0 / b.thermMat.thermalConductivity
    //);
    float conductivity = Math.min(a.thermMat.thermalConductivity, b.thermMat.thermalConductivity);

    //b.temp - a.temp > 0 == heatFlow > 0
    //b.temp - a.temp < 0 == heatFlow < 0
    float deltaTemp = b.temp - a.temp;
    if (Math.abs(deltaTemp) < eps)
    {
        return;
    }

    float heatFlow = contactArea * conductivity * deltaTemp * dt;

    if (heatFlow > 0)
    {
        //b to a
        float maxFlowFromB = b.heatContent * 0.1f; // 10% on frame
        heatFlow = Math.min(heatFlow, maxFlowFromB);
    }
    else
    {
        // a to b
        float maxFlowFromA = a.heatContent * 0.1;
        heatFlow = Math.max(heatFlow, -maxFlowFromA);
    }

    a.heatContent += heatFlow;
    b.heatContent -= heatFlow;

    a.updateTemp;
    b.updateTemp;
}

unittest
{

    import api.sims.phys.heats.thermal_material : ThermalMaterial;
    import api.dm.kit.sprites2d.sprite2d : Sprite2d;

    auto steel = ThermalMaterial(specificHeat : 500, thermalConductivity:
        50);
    auto ice = ThermalMaterial(specificHeat : 2100, thermalConductivity:
        2.2);

    auto hot = new Sprite2d;
    hot.thermMat = steel;
    auto cold = new Sprite2d;
    cold.thermMat = ice;

    hot.temp(100);
    cold.temp(0);

    assert(hot.temp > cold.temp);
    float hotBefore = hot.heatContent;
    float coldBefore = cold.heatContent;

    hot.transfer(cold, 1.0, 1.0);

    assert(hot.heatContent < hotBefore);
    assert(cold.heatContent > coldBefore);
    assert(hot.temp > cold.temp);
}
