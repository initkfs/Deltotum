module api.sims.phys.heats.thermal_material;

/**
 * Authors: initkfs
 */

struct ThermalMaterial
{
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
