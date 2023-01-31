module deltotum.engine.display.padding;
/**
 * Authors: initkfs
 */
struct Padding
{
    double top = 0;
    double right = 0;
    double bottom = 0;
    double left = 0;

    this(double all)
    {
        this.top = all;
        this.bottom = all;
        this.left = all;
        this.right = all;
    }

    this(double topAndBottom, double leftAndRight)
    {
        this.top = topAndBottom;
        this.bottom = topAndBottom;
        this.left = leftAndRight;
        this.right = leftAndRight;
    }

    this(double top, double right, double bottom, double left)
    {
        this.top = top;
        this.right = right;
        this.bottom = bottom;
        this.left = left;
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
