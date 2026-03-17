module api.sims.phys.heats.heat_transfer;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.domains.phys.therm : Therm;

import Math = api.math;

/**
 * Authors: initkfs
 */

void addHeat(float joules, Sprite2d sprite)
{
    if (!sprite.hasDomains || !sprite.domains.hasTherm)
    {
        throw new Exception("No therm in sprite");
    }

    sprite.domains.therm.heatContent += joules;

}

// void temp(float newTemp)
// {
//     _temp = newTemp;
//     heatContent = mass * specificHeat * _temp;
// }

void transfer(Sprite2d aTarget, Sprite2d bTarget, float contactArea = 1, float dt = 1, float eps = 0.001)
{
    Therm a = aTarget.domains.therm;
    Therm b = aTarget.domains.therm;

    if (a.temp == b.temp)
    {
        return;
    }

    //float conductivity = (a.thermalConductivity + b.thermalConductivity) / 2.0;
    //float conductivity = 2.0 / (
    //    1.0 / a.thermalConductivity + 1.0 / b.thermalConductivity
    //);
    float conductivity = Math.min(a.thermalConductivity, b.thermalConductivity);

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

    updateTemp(aTarget);
    updateTemp(bTarget);
}

void updateTemp(Sprite2d target)
{
    Therm therm = target.domains.therm;

    therm.temp = therm.heatContent / (target.mass * therm.specificHeat);
    //if (newTemp >= therm.meltingPoint)
    //{
    //startMelting;
    //}

    //if (newTemp >= therm.boilingPoint)
    //{
    //startBoiling;
    //}

    //restitution = thermMat.elasticityVsTemp(temp);
    //friction = thermMat.frictionVsTemp(temp);
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
