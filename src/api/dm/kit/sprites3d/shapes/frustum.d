module api.dm.kit.sprites3d.shapes.frustum;

import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;

import api.math.geom3.frustum3 : Frustum3;
import api.math.geom3.plane : Plane;
import api.math.geom2.vec3 : Vec3f;

import Math = api.math;

/**
 * Authors: initkfs
 */

class Frustum : Shape3d
{
    protected
    {
        Frustum3 frustum;
    }

    this(Vec3f cameraPos, Vec3f cameraFront, Vec3f cameraUp, Vec3f cameraRight,
        float fovYRad, float aspectRatio, float nearDist, float farDist)
    {
        this.frustum = Frustum3(cameraPos, cameraFront, cameraUp, cameraRight,
            Math.degToRad(fovYRad), aspectRatio, nearDist, farDist);
    }

    this(Frustum3 frustum)
    {
        this.frustum = frustum;
    }

    override void createMesh()
    {
        vertices = new ComVertex[8];

        Plane near = frustum.getPlane(0);
        Plane far = frustum.getPlane(1);
        Plane left = frustum.getPlane(2);
        Plane right = frustum.getPlane(3);
        Plane top = frustum.getPlane(4);
        Plane bottom = frustum.getPlane(5);

        // Near plane corners
        vertices[0] = intersectThreePlanes(near, top, left); // Near-top-left
        vertices[1] = intersectThreePlanes(near, top, right); // Near-top-right  
        vertices[2] = intersectThreePlanes(near, bottom, right); // Near-bottom-right
        vertices[3] = intersectThreePlanes(near, bottom, left); // Near-bottom-left

        // Far plane corners
        vertices[4] = intersectThreePlanes(far, top, left); // Far-top-left
        vertices[5] = intersectThreePlanes(far, top, right); // Far-top-right
        vertices[6] = intersectThreePlanes(far, bottom, right); // Far-bottom-right
        vertices[7] = intersectThreePlanes(far, bottom, left); // Far-bottom-left

        indices = [
            // Near plane
            0, 1, // top
            1, 2, // right  
            2, 3, // bottom
            3, 0, // left

            // Far plane  
            4, 5, // top
            5, 6, // right
            6, 7, // bottom
            7, 4, // left

            // Connecting lines
            0, 4, // left-top
            1, 5, // right-top
            2, 6, // right-bottom
            3,
            7 // left-bottom
        ];
    }

    ComVertex intersectThreePlanes(Plane p1, Plane p2, Plane p3)
    {
        Vec3f n1 = p1.normal;
        Vec3f n2 = p2.normal;
        Vec3f n3 = p3.normal;

        float d1 = -p1.distance;
        float d2 = -p2.distance;
        float d3 = -p3.distance;

        Vec3f point;
        Vec3f cross23 = n2.cross(n3);
        Vec3f cross31 = n3.cross(n1);
        Vec3f cross12 = n1.cross(n2);

        float denominator = n1.dot(cross23);

        if (Math.abs(denominator) > 1e-8f)
        {
            point = (cross23.scale(d1) +
                    cross31.scale(d2) +
                    cross12.scale(d3)) / denominator;
        }
        else
        {
            point = Vec3f(0, 0, 0);
        }

        return ComVertex.fromVec(point);
    }
}
