module api.dm.kit.sprites3d.pipelines.skydraws.skydraw;

/**
 * Authors: initkfs
 */

import api.dm.kit.sprites3d.pipelines.pipeline_group : PipelineGroup;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.meshes.cube : Cube;
import api.dm.kit.sprites3d.textures.cubemap : CubeMap;
import api.dm.com.graphics.gpu.com_3d_types;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;
import api.math.geom3.vec3 : Vec3f;
import api.dm.back.sdl3.externs.csdl3;

import Math = api.math;

/**
 * Authors: initkfs
 */

struct SkyConfig
{
    Vec3f camForward;
    float  aspectRatio; // screenWidth / screenHeight
    Vec3f camRight;
    float  fovTan;      // tan(fov / 2)
    Vec3f camUp;
}

class SkyDraw : PipelineGroup
{

    this()
    {
        isPushUniformVertexMatrix = false;
        isBindForEmptyChildren = true;
        isUseVertex = false;

        id = "SkyBox3d";

        vertexShaderName = "SkyDraw.vert";
        fragmentShaderName = "SkyDraw.frag";
    }

    override void create()
    {
        super.create;

        auto buff = pipeBuffers;
        //buff.numVertexUniformBuffers = 1;
        buff.numFragUniformBuffers = 1;
        createPipeline(buff);
    }

    override bool bindPipeline()
    {
        super.bindPipeline;

        SkyConfig config;
        config.camForward = camera.cameraFront;
        config.camRight = camera.cameraRight;
        config.camUp = camera.cameraUp;
        config.fovTan = Math.tanDeg(camera.fov);
        config.aspectRatio = window.width / window.height;

        gpu.dev.pushUniformFragmentData(0, &config, SkyConfig.sizeof);
        return true;
    }

    override bool draw(float a)
    {
        super.draw(a);
        gpu.dev.drawQuad;
        return true;
    }
}
