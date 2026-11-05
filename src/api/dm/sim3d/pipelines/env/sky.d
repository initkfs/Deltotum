module api.dm.sim3d.pipelines.env.sky;

/**
 * Authors: initkfs
 */

import api.dm.kit.sprites3d.pipelines.pipeline_group : PipelineGroup;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.sim3d.meshes.cube : Cube;
import api.dm.kit.sprites3d.textures.cubemap : CubeMap;
import api.dm.com.graphics.gpu.com_3d_types;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;
import api.math.geom3.vec3 : Vec3f;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.back.sdl3.externs.csdl3;

import Math = api.math;

/**
 * Authors: initkfs
 */

struct SkyConfig
{
    Vec3f camForward;
    float aspectRatio = 1; // screenWidth / screenHeight
    Vec3f camRight;
    float fovTan = 0; // tan(fov / 2)
    Vec3f camUp;
    float reserve;
    Vec3f sunDir; //normalized
    float planetRadius = 0; // 6371000.0
    Vec3f rayleighScat; // R, G, B, float3(5.8e-6, 1.35e-5, 3.31e-5))
    float atmHeight; // 80000.0km
    Vec3f sunIntensity; // float3(20.0, 20.0, 19.0))
    float camHeight; // 1meter

    Vec3f mieScat; // float3(4e-6, 4e-6, 4e-6)
    float mieHeight = 0; //1200.0m
    float mieG = 0; // 0.76 - 0.85
    float reserve11;
    float reserve22;
    float reserve33;
}

struct MiePreset
{
    Vec3f mieScat;
    float mieHeight;
    float mieG;

    MiePreset sunday() => MiePreset(Vec3f(1e-6f, 1e-6f, 1e-6f), 1000.0f, 0.85f);
    MiePreset smog() => MiePreset(Vec3f(1.5e-5f, 1.5e-5f, 1.5e-5f), 500.0f, 0.70f);
    MiePreset fog() => MiePreset(Vec3f(2e-4f, 2e-4f, 2e-4f), 300.0f, 0.76f);
}

class Sky : PipelineGroup
{
    SkyConfig skyConfig;

    this()
    {
        isPushUniformVertexMatrix = false;
        isBindForEmptyChildren = true;
        isUseVertex = false;

        id = "Sky3d";

        vertexShaderName = "Sky.vert";
        fragmentShaderName = "Sky.frag";
    }

    override void create()
    {
        super.create;

        auto buff = pipeBuffers;
        //buff.numVertexUniformBuffers = 1;
        buff.numFragUniformBuffers = 1;
        createPipeline(buff);

        skyConfig.planetRadius = 6371000.0;
        skyConfig.atmHeight = 80000;
        //skyConfig.rayleighScat = Vec3f(5.8e-6, 1.35e-5, 3.31e-5); yellow
        skyConfig.rayleighScat = Vec3f(5.8e-6f, 1.05e-5f, 3.31e-5f); //less yellow
        skyConfig.sunIntensity = Vec3f(20.0, 20.0, 19.0);
        skyConfig.camHeight = 1;
        skyConfig.aspectRatio = 1;
        skyConfig.sunDir = Vec3f(0.5, 0.5, 0.0).normalize;

        //skyConfig.mieScat = Vec3f(4e-6, 4e-6, 4e-6);
        skyConfig.mieScat = Vec3f(2e-6, 2e-6, 2e-6); //fog 4e-4
        skyConfig.mieHeight = 1200;
        skyConfig.mieG = 0.8; // 0.76 - 0.85
    }

    override bool bindPipeline()
    {
        super.bindPipeline;

        skyConfig.camForward = camera.cameraFront;
        skyConfig.camRight = camera.cameraRight;
        skyConfig.camUp = camera.cameraUp;
        skyConfig.fovTan = Math.tanDeg(camera.fov);
        skyConfig.aspectRatio = window.width / window.height;

        gpu.dev.pushUniformFragmentData(0, &skyConfig, skyConfig.sizeof);
        return true;
    }

    override bool draw(float a)
    {
        super.draw(a);
        gpu.dev.drawQuad;
        return true;
    }
}
