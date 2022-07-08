module deltotum.math.rect;

import deltotum.math.vector2d: Vector2D;
/**
 * Authors: initkfs
 */
struct Rect
{
    double x = 0;
    double y = 0;
    double width = 0;
    double height = 0;

    bool overlaps(Rect other){
        auto isOverlaps = (other.right > x) && (other.x < right) && (other.bottom > y) && (other.y < bottom);
        return isOverlaps;
    }

    bool contains(double x, double y)
	{
		return x >= this.x && y >= this.y && x < right && y < bottom;
	}

    double right(){
        return x + width;
    }

    double bottom(){
        return y + height;
    }

    Vector2D minPoint(){
        Vector2D minXPos = {x, y};
        return minXPos;
    }

    Vector2D maxPoint(){
        Vector2D maxYPos = {right, bottom};
        return maxYPos;
    }

}
