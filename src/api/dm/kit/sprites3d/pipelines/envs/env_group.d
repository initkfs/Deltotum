module api.dm.kit.sprites3d.pipelines.envs.env_group;

import api.dm.kit.sprites3d.pipelines.pipeline_group : PipelineGroup;
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

class EnvGroup : PipelineGroup
{
    LightGroup lights;

    this()
    {
        vertexShaderName = "EnvFull.vert";
        fragmentShaderName = "EnvFull.frag";
    }

    override void create()
    {
        super.create;

        lights = new LightGroup;
        addCreate(lights);

        SDL_GPUGraphicsPipelineTargetInfo targetInfo;

        SDL_GPUColorTargetDescription[1] targetDesc;
        targetDesc[0].format = gpu.getSwapchainTextureFormat;
        targetInfo.num_color_targets = 1;
        targetInfo.color_target_descriptions = targetDesc.ptr;
        targetInfo.has_depth_stencil_target = true;
        targetInfo.depth_stencil_format = SDL_GPU_TEXTUREFORMAT_D16_UNORM;

        auto stencilState = gpu.dev.depthStencilState;
        auto rastState = gpu.dev.depthRasterizerState;

        //TODO debug storage buffer
        createPipeline(0, 0, 1, 0, 2, 0, 1, 0, &rastState, &stencilState, &targetInfo);
    }

    override void pushUniforms()
    {
        super.pushUniforms;

        struct PlaneInfo
        {
            float nearPlane;
            float farPlane;
        }

        struct Planes
        {
            PlaneInfo planeInfo;
        align(16):
            float[3] cameraPos;
            PhongData material;
            LightData light;
        }

        Planes planes = Planes();

        planes.planeInfo.nearPlane = 0.1;
        planes.planeInfo.farPlane = 100;

        planes.cameraPos = [
            camera.cameraPos.x, camera.cameraPos.y, camera.cameraPos.z
        ];

        planes.material.ambient = Vec3f(1.0f, 0.5f, 0.31f);
        planes.material.diffuse = Vec3f(1.0f, 0.5f, 0.31f);
        planes.material.specular = Vec3f(0.5f, 0.5f, 0.5f);
        planes.material.shininess = 32;
        planes.material.color = Vec3f(1.0f, 0.5f, 0.31f);

        auto lamp = lights.lights[0];

        planes.light.position = lamp.translatePos;
        planes.light.direction = camera.cameraFront;
        planes.light.ambient = Vec3f(0.2f, 0.2f, 0.2f);
        planes.light.diffuse = Vec3f(0.7f, 0.7f, 0.7f);
        planes.light.specular = Vec3f(1.0f, 1.0f, 1.0f);
        planes.light.constant = 1.0;
        planes.light.linear = 0.09f;
        planes.light.quadratic = 0;
        planes.light.type = 0;
        planes.light.cutoff = Math.cosDeg(12.5);
        planes.light.outerCutoff = Math.cosDeg(17.5);

        gpu.dev.pushUniformFragmentData(0, &planes, planes.sizeof);
    }

}
