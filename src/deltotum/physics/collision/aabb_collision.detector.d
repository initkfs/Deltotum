module deltotum.physics.collision.aabb_collision.detector;

import deltotum.math.rect : Rect;
import deltotum.math.vector2d : Vector2D;

/**
 * Authors: initkfs
 */

//Axis-Aligned Bounding Box
class AABBCollisionDetector
{
    bool intersect(Rect a, Rect b)
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
