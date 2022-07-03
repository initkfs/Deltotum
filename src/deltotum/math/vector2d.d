module deltotum.math.vector2d;

//TODO fast sqrt?
import std.math.algebraic : sqrt;
import std.math.operations : isClose;

//TODO template types, operator overloads
immutable struct Vector2D
{
    double x;
    double y;

    immutable this(double x = 0, double y = 0)
    {
        this.x = x;
        this.y = y;
    }

    Vector2D add(Vector2D other)
    {
        return Vector2D(x + other.x, y + other.y);
    }

    Vector2D subtract(Vector2D other)
    {
        return Vector2D(x - other.x, y - other.y);
    }

    Vector2D normalize()
    {
        const double length = magnitude;
        double normX = x;
        double normY = y;
        if (!isClose(length, 0.0))
        {
            normX /= length;
            normY /= length;
        }

        return Vector2D(normX, normY);
    }

    Vector2D clone()
    {
        return Vector2D(x, y);
    }

    double magnitude()
    {
        return magnitudeXY(x, y);
    }

    double magnitudeSquared()
    {
        return magnitudeSquaredXY(x, y);
    }

    double magnitudeSquaredXY(double x, double y)
    {
        return x * x + y * y;
    }

    double magnitudeXY(double x, double y)
    {
        return sqrt(magnitudeSquaredXY(x, y));
    }

    double distanceTo(Vector2D other)
    {
        const double deltaX = other.x - x;
        const double deltaY = other.y - y;
        return magnitudeXY(deltaX, deltaY);
    }

    Vector2D scale(double factor)
    {
        return Vector2D(x * factor, y * factor);
    }

    Vector2D project(double factor)
    {
        return Vector2D(x / factor, y / factor);
    }

    double dotProduct(Vector2D other)
    {
        return x * other.x + y * other.y;
    }

    string toString() immutable
    {
        import std.format : format;

        return format("x:%s,y:%s", x, y);
    }

}
