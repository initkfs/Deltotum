module deltotum.maths.geometry.insets;

/**
 * Authors: initkfs
 */
struct Insets
{
    const double top = 0, right = 0, bottom = 0, left = 0;

    invariant
    {
        assert(top >= 0);
        assert(right >= 0);
        assert(bottom >= 0);
        assert(left >= 0);
    }
}
