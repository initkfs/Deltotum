module api.dm.sim3d.geo.sun;

/**
 * Authors: initkfs
 */
import api.math.geom3.vec3 : Vec3f;
import std.datetime.date : DateTime;
import Math = api.math;

//TODO remove
Vec3f sunDirDate(DateTime dateUtc, float latDeg, float lonDeg)
{
    float dayFraction = (dateUtc.hour + (dateUtc.minute / 60.0f) + (dateUtc.second / 3600.0f)) / 24.0f;
    float localDayFraction = dayFraction + (lonDeg / 360.0f);
    float H = (localDayFraction - 0.5f) * 2.0f * Math.PI;
    float dayOfYear = (dateUtc.month - 1) * 30.5f + dateUtc.day;
    float maxDeclination = 23.44f * Math.PI / 180.0f;
    float declination = maxDeclination * Math.cos((dayOfYear - 172.0f) / 365.25f * 2.0f * Math.PI);
    float lat = latDeg * Math.PI / 180.0f;
    float sin_Alt = Math.sin(lat) * Math.sin(declination) + Math.cos(lat) * Math.cos(declination) * Math.cos(H);
    if (sin_Alt > 1.0f)
        sin_Alt = 1.0f;
    if (sin_Alt < -1.0f)
        sin_Alt = -1.0f;
    float altitude = Math.asin(sin_Alt);

    float cos_Az = (Math.sin(declination) - Math.sin(lat) * sin_Alt) / (Math.cos(lat) * Math.cos(altitude) + 1e-6f);
    float sin_Az = -(Math.cos(declination) * Math.sin(H)) / (Math.cos(altitude) + 1e-6f);
    float azimuth = Math.atan2(sin_Az, cos_Az);

    float x = Math.cos(altitude) * Math.sin(azimuth);
    float y = Math.sin(altitude);
    float z = Math.cos(altitude) * Math.cos(azimuth);

    return Vec3f(x, y, z);
}

/*
auto sunNoon    = calculateSunDir(180.0f, 45.0f);  // y = 0.707)
auto sunHorizon = calculateSunDir(180.0f, 0.0f);   // (y = 0.0)
auto sunSunset  = calculateSunDir(180.0f, -0.5f);  // (y = -0.0087)
auto sunNight   = calculateSunDir(180.0f, -45.0f); // y = -0.707)
*/
Vec3f calcSunDir(float azimuthDegrees, float elevationDegrees) {
    float angleA = azimuthDegrees * Math.PI / 180.0f;
    float angleE = elevationDegrees * Math.PI / 180.0f;
    
    float x = Math.cos(angleE) * Math.sin(angleA);
    float y = Math.sin(angleE);
    float z = Math.cos(angleE) * Math.cos(angleA);
    
    return Vec3f(x, y, z).normalize; 
}

Vec3f goldHour() => Vec3f(0.9994f, -0.0349f, 0.0000f);
Vec3f sunsetHour() => Vec3f(-0.9996f, -0.0262f, 0.0000f);

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
