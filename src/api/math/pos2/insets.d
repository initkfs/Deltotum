module api.math.pos2.insets;

/**
 * Authors: initkfs
 */
struct Insets
{
    float top = 0, right = 0, bottom = 0, left = 0;

    this(float top, float right, float bottom, float left) pure
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

    this(float value) pure
    {
        this(value, value, value, value);
    }

    this(float topAndBottom, float leftAndRight) pure
    {
        this(topAndBottom, leftAndRight, topAndBottom, leftAndRight);
    }

    float width()
    {
        return left + right;
    }

    float height()
    {
        return top + bottom;
    }
}
