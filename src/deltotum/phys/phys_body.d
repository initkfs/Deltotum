module deltotum.phys.phys_body;

import deltotum.phys.phys_shape: PhysShape;

import deltotum.math.vector2d: Vector2d;

/**
 * Authors: initkfs
 */
abstract class PhysBody {

    PhysShape shape;

    Vector2d getVelocity();
    Vector2d getPosition();
    double angleDeg();
    void dispose();
}