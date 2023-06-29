module deltotum.sys.chipmunk.base.chipm_object_wrapper;

import deltotum.com.platforms.objects.com_ptr_manager : ComPtrManager;

import deltotum.math.vector2d : Vector2d;

import std.exception : enforce;

import chipmunk;

/**
 * Authors: initkfs
 */
abstract class ChipmObjectWrapper(T)
{
    mixin ComPtrManager!T;

    static cpVect fromVec(Vector2d vec)
    {
        return cpv(vec.x, vec.y);
    }

    static Vector2d toVec(cpVect v)
    {
        return Vector2d(v.x, v.y);
    }
}
