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
import api.dm.kit.sprites3d.textures.compute_tex : ComputeTex;
import api.dm.back.sdl3.externs.csdl3;
import api.dm.kit.sprites3d.textures.tex3d : Tex3d;

import Math = api.math;

//TODO remove native api
import api.dm.back.sdl3.externs.csdl3;

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

    SDL_GPUComputePipeline* optPipeline;
    SDL_GPUComputePipeline* skyPipeline;

    ComputeTex optTexture;
    ComputeTex skyTexture;

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

        scene3d.cmdBufferDgs ~= () => calcAtm;

        auto buff = pipeBuffers;
        //buff.numVertexUniformBuffers = 1;
        buff.numFragUniformBuffers = 1;
        buff.numFragSamples = 1;
        createPipeline(buff);

        skyConfig.planetRadius = 6371000.0;
        skyConfig.atmHeight = 80000;

        //(1/lambda^4)
        skyConfig.rayleighScat = Vec3f(0.0000058, 0.000010, 0.000033); //less yellow

        skyConfig.sunIntensity = Vec3f(20.0, 20.0, 19.0);
        skyConfig.camHeight = 1;
        skyConfig.aspectRatio = 1;
        skyConfig.sunDir = Vec3f(0.01, 0.99, 0).normalize;

        //skyConfig.mieScat = Vec3f(4e-6, 4e-6, 4e-6);
        skyConfig.mieScat = Vec3f(2e-6, 2e-6, 2e-6); //fog 4e-4
        skyConfig.mieHeight = 1200;
        skyConfig.mieG = 0.8; // 0.76 - 0.85

        optTexture = new ComputeTex();
        buildInit(optTexture);
        //256×128 or 512×256
        optTexture.createCompute(256, 128);
        optTexture.createSampler;

        skyTexture = new ComputeTex();
        buildInit(skyTexture);
        skyTexture.createCompute(256, 256);
        skyTexture.createSampler;

        import api.dm.com.graphics.gpu.com_pipeline : ComComputeBuffers;

        ComComputeBuffers buffs;
        buffs.numRWTextures = 1;
        buffs.numUniforms = 1;
        buffs.threadcount_x = 16;
        buffs.threadcount_y = 16;
        buffs.threadcount_z = 1;

        import std.path : buildPath;

        auto compShaderPath = buildPath(context.app.dataDir, "shaders", "out", "spirv", "Sky.comp.spv");
        optPipeline = gpu.dev.createComputePipelineSPIRV(compShaderPath, buffs);

        ComComputeBuffers skyBuffs;
        skyBuffs.numRWTextures = 1;
        skyBuffs.numRTextures = 1;
        skyBuffs.numUniforms = 1;
        skyBuffs.threadcount_x = 16;
        skyBuffs.threadcount_y = 16;
        skyBuffs.threadcount_z = 1;

        import std.path : buildPath;

        compShaderPath = buildPath(context.app.dataDir, "shaders", "out", "spirv", "SkyAtm.comp.spv");
        skyPipeline = gpu.dev.createComputePipelineSPIRV(compShaderPath, skyBuffs);
    }

    override void bindAll(){
        super.bindAll;
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

        gpu.dev.bindFragmentSamplers(skyTexture);

        return true;
    }

    void calcAtm()
    {
        SDL_GPUStorageTextureReadWriteBinding rwBinding;
        rwBinding.texture = optTexture.texture;
        rwBinding.mip_level = 0;
        rwBinding.layer = 0;
        rwBinding.cycle = true;

        gpu.dev.startComputePass(&rwBinding, null, 1, 0);
        gpu.dev.bindComputePipeline(optPipeline);

        gpu.dev.pushComputeUniform(&skyConfig, skyConfig.sizeof, 0);

        assert(optTexture.w > 0);
        assert(optTexture.h > 0);

        uint groupx = (optTexture.widthu + 15) / 16;
        uint groupy = (optTexture.heightu + 15) / 16;

        gpu.dev.dispatchCompute(groupx, groupy, 1);
        gpu.dev.endComputePass;

        SDL_GPUStorageTextureReadWriteBinding skyBinding;
        skyBinding.texture = skyTexture.texture;
        skyBinding.mip_level = 0;
        skyBinding.layer = 0;
        skyBinding.cycle = true;

        gpu.dev.startComputePass(&skyBinding, null, 1, 0);
        gpu.dev.bindComputePipeline(skyPipeline);

        auto outTex = optTexture.texture;
        gpu.dev.bindComputeStorageTextures(&outTex);

        gpu.dev.pushComputeUniform(&skyConfig, skyConfig.sizeof, 0);

        assert(skyTexture.w > 0);
        assert(skyTexture.h > 0);
        groupx = (skyTexture.widthu + 15) / 16;
        groupy = (skyTexture.heightu + 15) / 16;
        gpu.dev.dispatchCompute(groupx, groupy, 1);
        gpu.dev.endComputePass;
    }

    override bool draw(float a)
    {
        super.draw(a);
        gpu.dev.drawQuad;
        return true;
    }

    override void dispose()
    {
        super.dispose;
        if (optTexture)
        {
            optTexture.dispose;
        }

        if (skyTexture)
        {
            skyTexture.dispose;
        }

        if (optPipeline)
        {
            gpu.dev.deletePipeline(optPipeline);
        }

        if (skyPipeline)
        {
            gpu.dev.deletePipeline(skyPipeline);
        }
    }
}
