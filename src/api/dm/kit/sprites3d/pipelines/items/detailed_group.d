module api.dm.kit.sprites3d.pipelines.items.detailed_group;

import api.dm.kit.sprites3d.pipelines.items.base_lighting_group: BaseLightingGroup;
import api.dm.kit.sprites3d.lightings.lighting_material : LightingMaterial;
import api.dm.kit.sprites3d.lightings.lights.base_light : BaseLight;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.lightings.phongs.materials.material : PhongData, LightData;
import api.dm.kit.sprites3d.lightings.lights.light_group : LightGroup;

import api.math.geom2.vec3 : Vec3f;
import Math = api.math;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */

class DetailedGroup : BaseLightingGroup
{
    this()
    {
        vertexShaderName = "EnvFull.vert";
        fragmentShaderName = "EnvFull.frag";
    }

    override void create()
    {
        super.create;

        auto buff = pipeBuffers;
        buff.numVertexUniformBuffers = 1;
        buff.numFragSamples = 2;
        buff.numFragUniformBuffers = 1;
        createPipeline(buff);
        //createPipeline(0, 0, 1, 0, 2, 0, 1, 0);
    }
}
