module api.demo.demo1.scenes.start;

import api.dm.gui.scenes.gui_scene : GuiScene;
import api.dm.gui.controls.containers.vbox : VBox;
import api.dm.gui.controls.containers.hbox : HBox;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites3d.textures.cubemap : CubeMap;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.gui.controls.switches.buttons.button : Button;
import api.dm.kit.sprites3d.pipelines.skyboxes.skybox : SkyBox;
import api.dm.kit.sprites3d.lightings.lights.light_group : LightGroup;

import api.dm.kit.sprites2d.tweens;
import api.dm.kit.sprites2d.images;

import Math = api.dm.math;
import api.math.random : Random;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.vec3 : Vec3f;

import api.dm.kit.factories;

import std : writeln;

import api.dm.back.sdl3.gpu.sdl_gpu_device : SdlGPUDevice;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;
import api.dm.back.sdl3.gpu.sdl_gpu_shader : SdlGPUShader;
import api.dm.kit.sprites3d.cameras.perspective_camera : PerspectiveCamera;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;
import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;
import api.dm.kit.sprites3d.lightings.phongs.materials.phong_material : PhongMaterial;
import api.dm.kit.sprites3d.shapes.cube : Cube;
import api.dm.kit.sprites3d.shapes.sphere : Sphere;
import api.dm.kit.sprites3d.shapes.cylinder : Cylinder;
import api.dm.kit.sprites3d.textures.texture3d : Texture3d;
import api.dm.kit.sprites3d.pipelines.items.full_group: FullGroup;
import api.dm.kit.sprites3d.pipelines.items.simple_group : SimpleGroup;
import api.dm.kit.scenes.scene3d : SceneTransforms;
import api.dm.kit.sprites3d.lightings.lights.dir_light : DirLight;
import api.dm.kit.sprites3d.lightings.lights.point_light : PointLight;
import api.dm.kit.sprites3d.lightings.lights.spot_light : SpotLight;

import api.dm.back.sdl3.externs.csdl3;

import api.math.matrices.matrix;
import api.core.utils.text;
import api.dm.kit.sprites3d.lightings.phongs.materials.material;

/**
 * Authors: initkfs
 */
class Start : GuiScene
{
    SdlGPUPipeline fillPipeline;
    SdlGPUPipeline lampPipeline;

    SDL_Window* winPtr;

    SkyBox skybox;

    Cube cube;
    PointLight lamp;
    PointLight lamp2;

    FullGroup env;

    struct UniformBuffer
    {
        float time = 0;
    }

    struct FragmentBuffer
    {
        float[4] value1;
        float[4] value2;
        float[4] value3;
    }

    struct PlaneInfo
    {
        float nearPlane;
        float farPlane;
    }

    static UniformBuffer timeUniform;

    SDL_GPUBuffer* debugBuffer;
    SDL_GPUTransferBuffer* debugTransferBuffer;

    Shape3d shape;

    override void create()
    {
        super.create;
        
        //camera.fov = 90;

        assert(camera);

        env = new FullGroup;
        env.isCreateDataBuffer = true;
        addCreate(env);
        assert(env.hasCamera);

        // auto diffusePath = context.app.userDir ~ "/container2.png";
        // auto specularPath = context.app.userDir ~ "/container2_specular.png";

        // cube = new Cube(1, 1, 1);
        // cube.lightingMaterial = new PhongMaterial(diffusePath, specularPath);
        // cube.rotation.y = 1;
        // cube.angle = 45;
        // cube.scale = Vec3f(0.5, 0.5, 0.5);
        // env.addCreate(cube);

        import api.dm.kit.sprites3d.loaders.obj.model_loader : ModelLoader;

        auto modelLoader = new ModelLoader;
        auto modelPath = context.app.userDir ~ "/guardians-of-the-galaxy/GotG Warbird complete.obj";
        modelLoader.parseFile(modelPath, context.app.userDir ~ "/guardians-of-the-galaxy");

        auto verts = modelLoader.objLoader.getVertices;
        auto idx = modelLoader.objLoader.getIndices;

        auto diffMap = context.app.userDir ~ "/guardians-of-the-galaxy/GotG Warbird Rocket.png";

        shape = new Shape3d(verts, idx, diffMap);
        shape.isCreateLightingMaterial = true;

        shape.scale = Vec3f(0.15, 0.15, 0.15);
        //shape.x = -0.8;
        //shape.y = -0.5;
        shape.isCalcInverseWorldMatrix = true;

        env.addCreate(shape);

        lamp = new PointLight;
        lamp.diffuse = RGBA.web("#2EDCA3").toVec3Norm;
        lamp.ambient = Vec3f(0.3, 0.3, 0.3);
        env.lights.addCreate(lamp);
        lamp.pos = Vec3f(0, 2, 0);
        lamp.mesh.isVisible = false;
        lamp.isManaged = false;
        lamp.isRotateAroundPivot = true;
        lamp.rotateRadius = 2;
        lamp.rotatePivot = Vec3f();

        lamp2 = new PointLight;

        lamp2.diffuse = RGBA.web("#00909C").toVec3Norm;
        lamp2.isManaged = false;
        env.lights.addCreate(lamp2);
        lamp2.mesh.isVisible = false;
        lamp2.pos = Vec3f(0, -1, 0);
        lamp2.ambient = Vec3f(0.2, 0.2, 0.2);
        lamp2.lightDirection = Vec3f(0, 1, 0);

        lamp2.isRotateAroundPivot = true;
        lamp2.rotateRadius = 1;
        lamp2.rotatePivot = Vec3f();

        auto skyBoxPath = context.app.userDir ~ "/nebula/";
        skybox = new SkyBox(skyBoxPath, "png");
        addCreate(skybox);

        // //TODO remove test
        // import std.file : read;

        // auto vertShaderFile = context.app.userDir ~ "/shaders/TexturedBox.vert.spv";
        // auto fragShaderFile = context.app.userDir ~ "/shaders/TexturedBox.frag.spv";

        // SDL_GPUGraphicsPipelineTargetInfo targetInfo;

        // SDL_GPUColorTargetDescription[1] targetDesc;
        // targetDesc[0].format = gpu.getSwapchainTextureFormat;
        // targetInfo.num_color_targets = 1;
        // targetInfo.color_target_descriptions = targetDesc.ptr;
        // targetInfo.has_depth_stencil_target = true;
        // targetInfo.depth_stencil_format = SDL_GPU_TEXTUREFORMAT_D16_UNORM;

        // auto stencilState = gpu.dev.depthStencilState;
        // auto rastState = gpu.dev.depthRasterizerState;

        // fillPipeline = gpu.newPipeline(vertShaderFile, fragShaderFile, 0, 0, 1, 0, 2, 1, 1, 0, &rastState, &stencilState, &targetInfo);

        // auto fragLampFile = context.app.userDir ~ "/shaders/Lamp.frag.spv";

        // lampPipeline = gpu.newPipeline(vertShaderFile, fragLampFile, 0, 0, 1, 0, 1, 1, 1, 0, &rastState, &stencilState, &targetInfo);

        // debugBuffer = gpu.dev.newGPUBuffer(SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ, FragmentBuffer
        //         .sizeof);
        // debugTransferBuffer = gpu.dev.newTransferDownloadBuffer(FragmentBuffer.sizeof);

        // import api.dm.back.sdl3.images.sdl_image : SdlImage;

        //lamp.isVisible = false;

        // onJoystickAxis ~= (ref e) {
        //     const int deadzone = 4000;
        //     const int maxValue = 32767;
        //     if (e.axisValue > -deadzone && e.axisValue < deadzone)
        //     {
        //         return;
        //     }

        //     float normalizedValue = 0.0f;
        //     if (e.axisValue != 0)
        //     {
        //         if (e.axisValue > 0)
        //         {
        //             normalizedValue = cast(float)(e.axisValue - deadzone) / (maxValue - deadzone);
        //         }
        //         else
        //         {
        //             normalizedValue = cast(float)(e.axisValue + deadzone) / (maxValue - deadzone);
        //         }
        //     }

        //     const double speed = 1;
        //     if (e.axis == 1)
        //     {
        //         if (normalizedValue > 0)
        //         {
        //             moveUp(speed * normalizedValue);
        //         }
        //         else
        //         {
        //             moveDown(speed * (-normalizedValue));
        //         }

        //     }
        //     else if (e.axis == 1)
        //     {
        //         // if (normalizedValue > 0)
        //         // {
        //         //     moveLeft(speed * normalizedValue, speed * normalizedValue);
        //         // }
        //         // else
        //         // {
        //         //     moveRight(speed * normalizedValue, speed * normalizedValue);
        //         // }
        //     }

        // };

        camera.cameraTarget = shape.translatePos;
        camera.isOrbital = true;
        camera.isRecalcPos = true;
    }

    float time;

    float currentPitchX = 0.0f;
    float currentRollZ = 0.0f;

    void moveDown(double speed)
    {
        shape.angleX = Math.wrapAngle(shape.angleX - speed, -360, 360);
        auto dist = shape.translatePos.sub(camera.cameraPos).length;
        camera.targetDistance = dist;
        camera.cameraTarget = shape.translatePos;
        camera.angleX = shape.angleX;
        camera.isRecalcPos = true;

        lamp.z = lamp.z + 0.1;
        lamp2.z = lamp2.z - 0.1;
    }

    void moveUp(double speed)
    {
        shape.angleX = Math.wrapAngle(shape.angleX + speed, -360, 360);
        auto dist = shape.translatePos.sub(camera.cameraPos).length;
        camera.targetDistance = dist;
        camera.cameraTarget = shape.translatePos;
        camera.angleX = shape.angleX;
        camera.isRecalcPos = true;

        lamp.z = lamp.z - 0.1;
        lamp2.z = lamp2.z + 0.1;
    }

    void moveLeft(double speedShape, double speedCamera)
    {
        shape.angleY = shape.angleY - speedShape;
        //shape.angle = shape.angle - speedShape / 3;
        auto dist = shape.translatePos.sub(camera.cameraPos).length;
        camera.targetDistance = dist;
        camera.cameraTarget = shape.translatePos;
        camera.angleY = -shape.angleY;
        camera.isRecalcPos = true;

        lamp.x = lamp.x+ 0.1;
        lamp2.x = lamp2.x - 0.1;

    }

    void moveRight(double speedShape, double speedCamera)
    {
        shape.angleY = shape.angleY + speedShape;
        //shape.angle = shape.angle + speedShape / 3;
        auto dist = shape.translatePos.sub(camera.cameraPos).length;
        camera.targetDistance = dist;
        camera.cameraTarget = shape.translatePos;
        camera.angleY = -shape.angleY;
        camera.isRecalcPos = true;

        lamp.x = lamp.x - 0.1;
        lamp2.x = lamp2.x + 0.1;
    }

    override void update(double dt)
    {
        super.update(dt);

        import api.math.matrices.affine3;

        const int deadzone = 4000;
        const double speed = 2;
        const double cameraSpeed = 0.5;
        const int upDownAxis = 1;
        const int leftRightAxis = 0;
        if (const udV = input.isJoystickAxisNorm01(upDownAxis, deadzone))
        {
            if (udV > 0)
            {
                moveUp(speed * udV);
            }
            else
            {
                moveDown(speed * (-udV));
            }
        }

        if (const lrV = input.isJoystickAxisNorm01(leftRightAxis, deadzone))
        {
            if (lrV > 0)
            {
                moveLeft(speed * (lrV), cameraSpeed * (lrV));
            }
            else
            {
                moveRight(speed * (-lrV), cameraSpeed * (-lrV));
            }
        }

        import api.dm.com.inputs.com_keyboard : ComKeyName;

        if (input.isPressedKey(ComKeyName.key_down))
        {
            moveDown(1);
        }

        if (input.isPressedKey(ComKeyName.key_up))
        {
            moveUp(1);
        }

        if (input.isPressedKey(ComKeyName.key_left))
        {
            moveLeft(1, 0.5);
        }

        if (input.isPressedKey(ComKeyName.key_right))
        {
            moveRight(1, 0.5);
        }

        // static double anglev = 0;
        // if(anglev >= 360){
        //     anglev = 0;
        // }

        // //0, -0.5, 0

        // camera.moveAroundTarget(shape.translatePos, anglev, 0, 3);
        // anglev++;

        //shape.angle = shape.angle + 1;

        //time = SDL_GetTicks / 1000.0;

        //lamp.angle = lamp.angle + 1;

        //float radius = 1.0f;

        //sin(t) 0 on t = π/2 + πk
        //cons(t) 0 on t = πk
        // static float currentAngle = 0.0f;

        // currentAngle += 1;

        // if (currentAngle > 360)
        // {
        //     currentAngle = 0;
        // }

        // float eps = 0.000000001;

        // float lampX = Math.sinDeg(currentAngle) * radius;
        // if(Math.abs(lampX) < eps){
        //     lampX =0;
        // }
        // float lampZ = Math.cosDeg(currentAngle) * radius;
        //  if(Math.abs(lampZ) < eps){
        //      lampZ = 0;
        //  }
        // auto lampPosition = Vec3f(lampX, 0, lampZ);
        // lamp.x = lampPosition.x;
        // lamp.y = lampPosition.y;
        // lamp.z = lampPosition.z;

        //import std;
        //writeln(env.downloadData.value1);
    }

    override void draw()
    {
        super.draw;

        // gpu.dev.bindPipeline(fillPipeline);

        // cube.bindTextures;

        // gpu.dev.bindFragmentStorageBuffer(debugBuffer);

        // static assert((SceneTransforms.sizeof % 16) == 0, "Buffer size must be 16-byte aligned");

        // SceneTransforms transforms;
        // transforms.world = cube.mesh.worldMatrix;
        // transforms.camera = camera.view;
        // transforms.projection = camera.projection;
        // transforms.normal = cube.mesh.worldMatrixInverse;

        // gpu.startRenderPass;

        // skybox.bind(&transforms);

        // gpu.dev.endRenderPass;
        //timeUniform.time = SDL_GetTicks() / 250.0;
        // gpu.dev.pushUniformVertexData(0, &transforms, SceneTransforms.sizeof);

        // import api.dm.kit.sprites3d.lightings.phongs.materials.material;

        // struct Planes
        // {
        //     PlaneInfo planeInfo;
        // align(16):
        //     float[3] cameraPos;
        //     PhongMaterial material;
        //     Light light;
        // }

        // float[8] planes = [
        //     10, 1000, 1, 0.5, 0.31, 1, 1, 1
        // ];
        // Planes planes = Planes(10, 1000, [1.0f, 0.5f, 0.31f], [
        //     lamp.translatePos.x, lamp.translatePos.y, lamp.translatePos.z
        // ], [camera.cameraPos.x, camera.cameraPos.y, camera.cameraPos.z]);

        // Planes planes = Planes();

        // planes.planeInfo.nearPlane = 10;
        // planes.planeInfo.farPlane = 1000;

        // planes.cameraPos = [
        //     camera.cameraPos.x, camera.cameraPos.y, camera.cameraPos.z
        // ];

        // planes.material.ambient = Vec3f(1.0f, 0.5f, 0.31f);
        // planes.material.diffuse = Vec3f(1.0f, 0.5f, 0.31f);
        // planes.material.specular = Vec3f(0.5f, 0.5f, 0.5f);
        // planes.material.shininess = 32;
        // planes.material.color = Vec3f(1.0f, 0.5f, 0.31f);

        // planes.light.position = lamp.translatePos;
        // planes.light.direction = camera.cameraFront;
        // planes.light.ambient = Vec3f(0.2f, 0.2f, 0.2f);
        // planes.light.diffuse = Vec3f(0.7f, 0.7f, 0.7f);
        // planes.light.specular = Vec3f(1.0f, 1.0f, 1.0f);
        // planes.light.constant = 1.0;
        // planes.light.linear = 0.09f;
        // planes.light.quadratic = 0;
        // planes.light.type = 1;
        // planes.light.cutoff = Math.cosDeg(12.5);
        // planes.light.outerCutoff = Math.cosDeg(17.5);

        // gpu.dev.pushUniformFragmentData(0, &planes, planes.sizeof);

        // cube.bindBuffers;
        // cube.drawIndexed;

        // transforms.world = lamp.worldMatrix;

        // gpu.dev.bindPipeline(lampPipeline);
        // gpu.dev.pushUniformVertexData(0, &transforms, SceneTransforms.sizeof);

        // gpu.dev.bindFragmentStorageBuffer(debugBuffer);

        // lamp.bindBuffers;
        // lamp.drawIndexed;

        // gpu.dev.bindFragmentStorageBuffer(debugBuffer);

        // lamp.bindBuffers;
        // lamp.drawIndexed;

        //assert(gpu.dev.endRenderPass);

        // gpu.dev.startCopyPass;
        // gpu.dev.downloadBuffer(debugBuffer, debugTransferBuffer, FragmentBuffer.sizeof);
        // gpu.dev.endCopyPass(true);
        // auto fragBuf = cast(FragmentBuffer*) gpu.dev.mapTransferBuffer(
        //     debugTransferBuffer);
        // import std;
        // writeln(*fragBuf);
        // gpu.dev.unmapTransferBuffer(debugTransferBuffer);

    }

    override void dispose()
    {
        super.dispose;
        //gpu.dev.deletePipeline(fillPipeline);
    }
}
