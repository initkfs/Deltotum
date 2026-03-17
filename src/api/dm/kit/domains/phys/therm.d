module api.dm.kit.domains.phys.therm;

import api.dm.kit.domains.base_domain : BaseDomain;

/*
 * Authors: initkfs
 */

class Therm : BaseDomain
{
    float temp = 0;
    //amount of thermal energy
    float heatContent = 0;

    // Теплоёмкость. Heat capacity (Joules/(kg·К)), amount of heat energy required to raise the temperature of a unit mass
    float specificHeat = 1;
    //Теплопроводность. (Watt/(м·К)), rate of heat flow per unit area per unit temperature gradient
    float thermalConductivity = 1;

    float meltingPoint = 0;
    float boilingPoint = 0;

    float density = 1; // (kg/m³)

    float frictionFromTemp(float temp, float baseFriction = 1)
    {
        return baseFriction * (1.0f + 0.01 * (temp - 293));
    }
}
