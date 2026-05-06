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
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.back.sdl3.externs.csdl3;

import Math = api.math;

/**
 * Authors: initkfs
 */

struct SkyConfig
{
    float[4] topColor;
    float[4] horizonColor;
    float[4] groundColor;
    Vec3f camForward;
    float aspectRatio = 1; // screenWidth / screenHeight
    Vec3f camRight;
    float fovTan = 0; // tan(fov / 2)
    Vec3f camUp;
    float topBlend = 1.5;
align(4):
    float groundBlend = 1;
}

class SkyDraw : PipelineGroup
{
    SkyConfig skyConfig;

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

        skyConfig.topColor = RGBA.blueviolet.toArrayRGBAf;
        skyConfig.horizonColor = RGBA.blue.toArrayRGBAf;
        skyConfig.groundColor = RGBA.brown.toArrayRGBAf;

        window.showingTasks ~= (float dt) {
            if (scene3d.hasDebugger)
            {
                scene3d.setDebugColor((color) {
                    skyConfig.topColor = color.toArrayRGBAf;
                }, RGBA.fromArrayFRGBA(skyConfig.topColor), "SkyTop");
                scene3d.setDebugColor((color) {
                    skyConfig.horizonColor = color.toArrayRGBAf;
                }, RGBA.fromArrayFRGBA(skyConfig.horizonColor), "SkyHor");
                scene3d.setDebugColor((color) {
                    skyConfig.groundColor = color.toArrayRGBAf;
                }, RGBA.fromArrayFRGBA(skyConfig.groundColor), "SkyGrn");

                scene3d.setDebugField((v) { skyConfig.topBlend = v; }, skyConfig.topBlend, 0, 10, 0.01, "TopBln");
                scene3d.setDebugField((v) { skyConfig.groundBlend = v; }, skyConfig.groundBlend, 0, 10, 0.01, "GrnBln");
            }
        };
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
