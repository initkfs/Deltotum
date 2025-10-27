module api.dm.kit.sprites3d.pipelines.items.simple_group;

import api.dm.kit.sprites3d.pipelines.items.base_lighting_group: BaseLightingGroup;

import api.math.geom2.vec3 : Vec3f;
import Math = api.math;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */

class SimpleGroup : BaseLightingGroup
{
    this()
    {
        vertexShaderName = "EnvSimple.vert";
        fragmentShaderName = "EnvSimple.frag";
    }

    override void create()
    {
        super.create;
    }
}
