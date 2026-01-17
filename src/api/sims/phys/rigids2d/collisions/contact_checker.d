module api.sims.phys.rigids2d.collisions.contact_checker;

/**
 * Authors: initkfs
 */
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.circle2 : Circle2f;

import api.sims.phys.rigids2d.collisions.contacts;

import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

bool checkAABBAndAABB(Rect2f a, Rect2f b, ref Contact2d collision)
{
    Vec2f normal = b.pos - a.pos;

    float aExtent = a.halfWidth;
    float bExtent = b.halfWidth;

    float xOverlap = aExtent + bExtent - Math.abs(normal.x);

    if (xOverlap > 0)
    {
        float yOverlap = aExtent + bExtent - Math.abs(normal.y);

        if (yOverlap > 0)
        {
            if (xOverlap < yOverlap)
            {
                collision.normal = normal.x > 0 ? Vec2f(1, 0) : Vec2f(-1, 0);
                collision.penetration = xOverlap;
                return true;
            }
            else
            {
                collision.normal = normal.y > 0 ? Vec2f(0, 1) : Vec2f(0, -1);
                collision.penetration = yOverlap;
                return true;
            }
        }
    }

    return false;
}

bool checkCircleAndCircle(Circle2f a, Circle2f b, ref Contact2d collision)
{
    float dx = b.x - a.x;
    float dy = b.y - a.y;

    float radiusSum = a.radius + b.radius;

    float distSq = dx * dx + dy * dy;

    if (distSq > radiusSum * radiusSum)
        return false;

    if (distSq < 0.0001f)
    {
        collision.normal = Vec2f(1.0f, 0.0f);
        collision.penetration = radiusSum;
        return true;
    }

    float distance = Math.sqrt(distSq);

    collision.normal.x = dx / distance;
    collision.normal.y = dy / distance;

    collision.penetration = radiusSum - distance;

    return true;
}

bool checkCircleAndAABB(Circle2f circle, Rect2f rect, ref Contact2d collision)
{
    float closestX = Math.clamp(circle.x,
        rect.pos.x - rect.halfWidth,
        rect.pos.x + rect.halfWidth);
    float closestY = Math.clamp(circle.y,
        rect.pos.y - rect.halfHeight,
        rect.pos.y + rect.halfHeight);

    float dx = circle.x - closestX;
    float dy = circle.y - closestY;
    float distSq = dx * dx + dy * dy;

    if (distSq > circle.radius * circle.radius)
        return false;

    if (distSq < 0.0001f)
    {

        float leftDist = circle.x - (rect.pos.x - rect.halfWidth);
        float rightDist = (rect.pos.x + rect.halfWidth) - circle.x;
        float topDist = circle.y - (rect.pos.y - rect.halfHeight);
        float bottomDist = (rect.pos.y + rect.halfHeight) - circle.y;

        float minDist = Math.min(Math.min(leftDist, rightDist),
            Math.min(topDist, bottomDist));

        if (Math.abs(minDist - leftDist) < 0.001f)
            collision.normal = Vec2f(-1.0f, 0.0f);
        else if (Math.abs(minDist - rightDist) < 0.001f)
            collision.normal = Vec2f(1.0f, 0.0f);
        else if (Math.abs(minDist - topDist) < 0.001f)
            collision.normal = Vec2f(0.0f, -1.0f);
        else
            collision.normal = Vec2f(0.0f, 1.0f);

        collision.penetration = circle.radius + minDist;
        return true;
    }

    float distance = Math.sqrt(distSq);
    collision.normal.x = dx / distance;
    collision.normal.y = dy / distance;
    collision.penetration = circle.radius - distance;

    return true;
}
