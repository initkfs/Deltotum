module api.sims.phys.rigids2d.collisions.contact_checker;

/**
 * Authors: initkfs
 */
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.rect2 : Rect2f;
import api.math.geom2.circle2 : Circle2f;
import api.math.geom2.polygon2 : Polygon2f;

import api.sims.phys.rigids2d.collisions.contacts;

import api.math.geom2.vec2 : Vec2f;
import Math = api.math;

bool checkAABBAndAABB(Rect2f a, Rect2f b, ref Contact2d collision)
{
    Vec2f normal = b.pos - a.pos;

    float aExtentX = a.halfWidth;
    float aExtentY = a.halfHeight;
    float bExtentX = b.halfWidth;
    float bExtentY = b.halfHeight;

    float xOverlap = aExtentX + bExtentX - Math.abs(normal.x);

    if (xOverlap > 0)
    {
        float yOverlap = aExtentY + bExtentY - Math.abs(normal.y);

        if (yOverlap > 0)
        {
            if (xOverlap < yOverlap)
            {
                collision.normal = normal.x > 0 ? Vec2f(1, 0) : Vec2f(-1, 0);
                collision.penetration = xOverlap;

                if (normal.x > 0)
                {
                    // A to B
                    float contactX = a.pos.x + aExtentX - xOverlap * 0.5f;
                    float contactY = Math.max(a.pos.y - aExtentY, b.pos.y - bExtentY) +
                        Math.min(a.pos.y + aExtentY, b.pos.y + bExtentY);
                    contactY *= 0.5f;
                    collision.pos = Vec2f(contactX, contactY);
                }
                else
                {
                    // A to B
                    float contactX = a.pos.x - aExtentX + xOverlap * 0.5f;
                    float contactY = Math.max(a.pos.y - aExtentY, b.pos.y - bExtentY) +
                        Math.min(a.pos.y + aExtentY, b.pos.y + bExtentY);
                    contactY *= 0.5f;
                    collision.pos = Vec2f(contactX, contactY);
                }

                return true;
            }
            else
            {
                collision.normal = normal.y > 0 ? Vec2f(0, 1) : Vec2f(0, -1);
                collision.penetration = yOverlap;

                if (normal.y > 0)
                {
                    // A is higher than B (if Y is pointing down)
                    float contactY = a.pos.y + aExtentY - yOverlap * 0.5f;
                    float contactX = Math.max(a.pos.x - aExtentX, b.pos.x - bExtentX) +
                        Math.min(a.pos.x + aExtentX, b.pos.x + bExtentX);
                    contactX *= 0.5f;
                    collision.pos = Vec2f(contactX, contactY);
                }
                else
                {
                    // A is lower than B (if Y is pointing down)
                    float contactY = a.pos.y - aExtentY + yOverlap * 0.5f;
                    float contactX = Math.max(a.pos.x - aExtentX, b.pos.x - bExtentX) +
                        Math.min(a.pos.x + aExtentX, b.pos.x + bExtentX);
                    contactX *= 0.5f;
                    collision.pos = Vec2f(contactX, contactY);
                }
                return true;
            }
        }
    }

    return false;
}

bool checkCircleAndCircle(Circle2f a, Circle2f b, ref Contact2d collision, float eps = 1e-7f)
{
    Vec2f normal = b.center.sub(a.center);

    float distSqr = normal.lengthSquared();
    float radiusSum = a.radius + b.radius;

    if (distSqr >= radiusSum * radiusSum)
    {
        return false;
    }

    if (distSqr < eps)
    {
        collision.penetration = a.radius;
        collision.normal = Vec2f(1.0f, 0.0f);
        collision.pos = a.center;
        return true;
    }

    float dist = Math.sqrt(distSqr);

    collision.penetration = radiusSum - dist;
    collision.normal = normal.div(dist);
    collision.pos = normal.scale(a.radius).add(a.center);
    return true;
}

//TODO reflect normal in AABBvsCircle vs CirclevsAABB
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
        {
            collision.normal = Vec2f(-1.0f, 0.0f);
            collision.pos = Vec2f(rect.pos.x - rect.halfWidth,
                Math.clamp(circle.y,
                    rect.pos.y - rect.halfHeight,
                    rect.pos.y + rect.halfHeight));
        }
        else if (Math.abs(minDist - rightDist) < 0.001f)
        {
            collision.normal = Vec2f(1.0f, 0.0f);
            collision.pos = Vec2f(rect.pos.x + rect.halfWidth,
                Math.clamp(circle.y,
                    rect.pos.y - rect.halfHeight,
                    rect.pos.y + rect.halfHeight));
        }
        else if (Math.abs(minDist - topDist) < 0.001f)
        {
            collision.normal = Vec2f(0.0f, -1.0f);
            collision.pos = Vec2f(Math.clamp(circle.x,
                    rect.pos.x - rect.halfWidth,
                    rect.pos.x + rect.halfWidth),
                rect.pos.y - rect.halfHeight);
        }
        else
        {
            collision.normal = Vec2f(0.0f, 1.0f);
            collision.pos = Vec2f(Math.clamp(circle.x,
                    rect.pos.x - rect.halfWidth,
                    rect.pos.x + rect.halfWidth),
                rect.pos.y + rect.halfHeight);
        }

        collision.penetration = circle.radius + minDist;
        return true;
    }

    float distance = Math.sqrt(distSq);
    collision.normal.x = dx / distance;
    collision.normal.y = dy / distance;
    collision.penetration = circle.radius - distance;

    return true;
}
