module deltotum.phys.phys_space;

import deltotum.phys.phys_shape: PhysShape;
import deltotum.phys.phys_body: PhysBody;

/**
 * Authors: initkfs
 */
abstract class PhysSpace {
    void step(double delta);

    void removeShape(PhysShape spape);
    void removeBody(PhysBody body);
}