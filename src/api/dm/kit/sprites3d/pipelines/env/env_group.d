module api.dm.kit.sprites3d.pipelines.env.env_group;

import api.dm.kit.sprites3d.pipelines.pipeline_group : PipelineGroup;
import api.dm.kit.sprites3d.lightings.phongs.materials.material_data : Light, Material;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.math.geom3.vec3 : Vec3f;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.scenes.scene3d : SceneTransforms;
import api.math.matrices.matrix : Matrix4x4;
import api.dm.kit.sprites3d.lightings.lights.base_light : BaseLight;
import Math = api.math;

import api.dm.back.sdl3.externs.csdl3;

struct SceneTransforms
{
    Matrix4x4 world;
    Matrix4x4 camera;
    Matrix4x4 projection;
    Matrix4x4 normal;
}

struct SceneConfig
{
align(16):
    Vec3f cameraPos;
align(4):
    float nearPlane;
    float farPlane;
    float time;
    uint lightCount;
align(16):
    Light[4] lights;
    Material material;
align(4):
    uint isLamp;
}

/**
 * Authors: initkfs
 */

class EnvGroup : PipelineGroup
{
    bool isCreateDefaultLight = true;

    enum maxLights = 4;

    BaseLight[] lights;

    this()
    {
        super();
        id = "EnvGroup";
        vertexShaderName = "EnvFull.vert";
        fragmentShaderName = "EnvFull.frag";

        isPushUniformVertexMatrix = true;

        onBeforeDrawChildDg = (Sprite2d child) {
            if (auto sprite3d = cast(Sprite3d) child)
            {
                sprite3d.bindAll;
                //vertex, index buffers, textures
                bindAll(sprite3d);
                pushUniforms(sprite3d);
            }
        };
    }

    override void create()
    {
        super.create;

        auto buff = pipeBuffers;
        buff.numVertexUniformBuffers += 1;
        buff.numFragUniformBuffers += 1;
        buff.numFragSamples += 6;
        createPipeline(buff);

        if (isCreateDefaultLight)
        {
            import api.dm.kit.sprites3d.lightings.lights.point_light : PointLight;
            import api.dm.kit.sprites3d.lightings.lights.dir_light : DirLight;
            import api.dm.kit.graphics.colors.hsla : HSLA;
            import api.dm.kit.graphics.colors.rgba : RGBA;

            auto light = new PointLight;
            light.pos3 = Vec3f(-1, 1, 2);
            light.direction = (Vec3f(0, 0, 0).sub(light.pos3)).normalize;
            light.scale = Vec3f(0.1, 0.1, 0.1);
            light.ambient = RGBA.black;
            addCreate(light);
        }
    }

    void bindAll(Sprite3d sprite)
    {
        import api.dm.kit.sprites3d.lightings.phongs.materials.lighting_material : LightingMaterial;
        import api.dm.kit.sprites3d.textures.texture_gpu : TextureGPU;
        import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;

        LightingMaterial mat;
        if (auto shape = cast(Shape3d) sprite)
        {
            mat = shape.lightingMaterial;
        }

        auto diffuseMap = (mat && mat.diffuseMap && mat.isBindDiffuseMap) ? mat.diffuseMap
            : gpu.defaultDiffuse;
        auto specularMap = (mat && mat.specularMap && mat.isBindSpecularMap) ? mat.specularMap
            : gpu.defaultSpecular;
        auto normalMap = (mat && mat.normalMap && mat.isBindNormalMap) ? mat.normalMap
            : gpu.defaultNormal;
        auto aoMap = gpu.defaultAO;
        auto emissionMap = gpu.defaultEmission;

        auto dispMap = (mat && mat.dispMap && mat.isBindDispMap) ? mat.dispMap : gpu.defaultDisp;

        TextureGPU[6] maps = [
            diffuseMap, specularMap, normalMap, aoMap, emissionMap, dispMap
        ];
        gpu.dev.bindFragmentSamplers(maps);
    }

    void pushUniforms(Sprite3d sprite)
    {
        if (isPushUniformVertexMatrix)
        {
            SceneTransforms transforms;
            transforms.world = sprite.worldMatrix;
            transforms.camera = sprite.camera.view;
            transforms.projection = sprite.camera.projection;
            transforms.normal = sprite.worldMatrixInverse;

            gpu.dev.pushUniformVertexData(0, &transforms, SceneTransforms.sizeof);
        }

        uint lightCount = cast(uint) lights.length;
        if (lightCount > maxLights)
        {
            logger.errorf("Max lights: %d, but in scene: %d", maxLights, lightCount);
            lightCount = maxLights;
        }

        SceneConfig config;
        config.cameraPos = camera.cameraPos;
        config.nearPlane = camera.nearPlane;
        config.farPlane = camera.farPlane;
        //TODO time > 100000 
        config.time = platform.timer.ticksMs / 1000.0;
        config.lightCount = lightCount;

        auto isLamp = (cast(BaseLight) sprite) !is null;

        foreach (li; 0 .. lightCount)
        {
            auto lamp = lights[li];

            if (!lamp.isVisible && config.lightCount >= 0)
            {
                config.lightCount--;
                continue;
            }

            Light lightData;

            lightData.position = lamp.pos3;
            lightData.lightType = 0;
            //lightData.direction = camera.cameraFront;
            lightData.direction = lamp.direction;
            lightData.linearCoeff = 0.09f;
            //lightData.lightDirection;
            lightData.constantCoeff = 1.0;
            lightData.ambient = lamp.ambient.toArrayFRGB;
            lightData.quadraticCoeff = 0;
            lightData.diffuse = lamp.diffuse.toArrayFRGB;
            lightData.cutoff = Math.cosDeg(12.5);
            lightData.specular = lamp.specular.toArrayFRGB;
            lightData.outerCutoff = Math.cosDeg(17.5);

            uint type;
            import api.dm.kit.sprites3d.lightings.lights.dir_light : DirLight;
            import api.dm.kit.sprites3d.lightings.lights.spot_light : SpotLight;
            import api.dm.kit.sprites3d.lightings.lights.point_light : PointLight;

            if (cast(DirLight) lamp)
            {
                type = 0;
            }
            else if (cast(SpotLight) lamp)
            {
                lightData.direction = lamp.direction;
                type = 2;
            }
            else if (cast(PointLight) lamp)
            {
                type = 1;
            }

            lightData.lightType = type;

            config.lights[li] = lightData;
        }

        Material mat;
        mat.albedo = sprite.albedo.toArrayRGBAf;
        mat.ambient = RGBA.white.toArrayRGBAf;
        mat.diffuse = RGBA.white.toArrayRGBAf;
        mat.specular = RGBA.white.toArrayRGBAf;
        mat.shininess = 32;
        mat.intensity = sprite.albedoIntensity;

        if (mat.intensity != 1)
        {
            foreach (ref v; mat.albedo)
            {
                v *= mat.intensity;
            }
        }

        config.material = mat;

        //TODO lamp pipeline
        config.isLamp = isLamp;

        gpu.dev.pushUniformFragmentData(0, &config, config.sizeof);
    }

    override bool add(Sprite2d object, long index = -1)
    {
        if (!super.add(object, index))
        {
            return false;
        }

        if (auto light = cast(BaseLight) object)
        {
            foreach (oldLight; lights)
            {
                if (oldLight is light)
                {
                    return true;
                }
            }

            lights ~= light;
        }

        return true;
    }

    BaseLight lamp(size_t lampIndex = 0)
    {
        if (lights.length == 0)
        {
            throw new Exception("Not found any lamp");
        }

        if (lampIndex >= lights.length)
        {
            throw new Exception("Out of bounds lamp index");
        }

        return lights[lampIndex];
    }
}
