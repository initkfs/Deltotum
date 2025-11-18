module api.dm.kit.sprites3d.pipelines.items.full_group;

import api.dm.kit.sprites3d.pipelines.items.base_lighting_group: BaseLightingGroup;

import api.math.geom2.vec3 : Vec3f;
import Math = api.math;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */

class FullGroup : BaseLightingGroup
{
    this()
    {
        super();
        vertexShaderName = "EnvFull.vert";
        fragmentShaderName = "EnvFull.frag";
    }

    override void create()
    {
        super.create;

        auto buff = pipeBuffers;
        buff.numVertexUniformBuffers += 1;
        buff.numFragSamples += 1;
        buff.numFragUniformBuffers += 1;
        createPipeline(buff);
    }
}
