module deltotum.math.geom.insets;

/**
 * Authors: initkfs
 */
struct Insets
{
    double top = 0, right = 0, bottom = 0, left = 0;

    this(double top, double right, double bottom, double left) pure
    {
        assert(top >= 0);
        assert(right >= 0);
        assert(bottom >= 0);
        assert(left >= 0);

        this.top = top;
        this.right = right;
        this.bottom = bottom;
        this.left = left;
    }

    this(double value) pure
    {
        this(value, value, value, value);
    }

    this(double topAndBottom, double leftAndRight) pure
    {
        this(topAndBottom, leftAndRight, topAndBottom, leftAndRight);
    }

    double width()
    {
        return left + right;
    }

    double height()
    {
        return top + bottom;
    }
}
