module deltotum.math.rect;

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
        auto isOverlaps = (other.right > x) && (other.x < right) && (other.bottom > y) && (other.y < botton);
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

}
