module api.sims.phys2d.libs.box2d.phys;

/**
 * Authors: initkfs
 */

/** 
 Box2D has been tuned with moving shapes between 0.1 and 10 meters. 
 Static shapes may be up to 50 meters. 
 Box2D works best with world sizes less than 12 kilometers.
 Box2D uses radians for angles
 */
class Phys
{
    bool isCreated;
    
    float pixelPerMeter = 50;

    float toPixels(float meters) => meters * pixelPerMeter;
    float toMeters(float pixels) => pixels / pixelPerMeter;
}
