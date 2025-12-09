module api.dm.com.graphics.gpu.com_3d_types;

import api.math.geom3.vec3 : Vec3f;

/**
 * Authors: initkfs
 */
struct ComVertex
{
    float x = 0, y = 0, z = 0; //vec3 position
    //float r = 0, g = 0, b = 0, a = 1.0; //vec4 color
    float[3] normals = 0;
    float u = 0, v = 0; //0..1

    static ComVertex fromVec(Vec3f position)
    {
        return ComVertex(position.x, position.y, position.z);
    }
}
