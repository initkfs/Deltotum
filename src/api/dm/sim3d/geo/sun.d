module api.dm.sim3d.geo.sun;

/**
 * Authors: initkfs
 */
import api.math.geom3.vec3 : Vec3f;
import Math = api.math;

Vec3f correctDir(Vec3f sunDir)
{
    if (Math.abs(sunDir.x) < 0.0001f && Math.abs(sunDir.z) < 0.0001f)
    {
        return Vec3f(0.01f, 0.99999f, 0.0000f).normalize;
    }
    return sunDir;
}

// Vec3f calcSunDir(float timeInHours, float latDeg, float dayOfYear)
// {
//     float declination = Math.degToRad(23.45f) * Math.sin(
//         Math.degToRad(360.0f / 365.0f * (dayOfYear - 172.0f)));

//     float hourAngle = Math.degToRad((timeInHours - 12.0f) * 15.0f);
//     float lat = Math.degToRad(latDeg);

//     float zenCos = Math.sin(lat) * Math.sin(declination) + Math.cos(
//         lat) * Math.cos(declination) * Math.cos(hourAngle);
//     return sunDir;
// }
