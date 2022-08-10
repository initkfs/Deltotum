module deltotum.physics.collision.aabb_collision.detector;

import deltotum.math.shapes.rect2d : Rect2d;
import deltotum.math.vector2d : Vector2d;

/**
 * Authors: initkfs
 */

//Axis-Aligned Bounding Box
class AABBCollisionDetector
{
    bool intersect(Rect2d a, Rect2d b)
    {
        if (a.maxPoint.x < b.minPoint.x || a.minPoint.x > b.maxPoint.x)
        {
            return false;
        }
        if (a.maxPoint.y < b.minPoint.y || a.minPoint.y > b.maxPoint.y)
        {
            return false;
        }

        return true;
    }
}
