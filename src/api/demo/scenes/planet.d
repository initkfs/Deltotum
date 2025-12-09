module api.demo.scenes.planet;

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
import api.dm.kit.sprites3d.pipelines.items.full_group : FullGroup;
import api.dm.kit.sprites3d.pipelines.items.simple_group : SimpleGroup;
import api.dm.kit.scenes.scene3d : SceneTransforms;
import api.dm.kit.sprites3d.lightings.lights.dir_light : DirLight;
import api.dm.kit.sprites3d.lightings.lights.point_light : PointLight;
import api.dm.kit.sprites3d.lightings.lights.spot_light : SpotLight;
import api.dm.kit.sprites3d.shapes.frustum: Frustum;

import api.dm.back.sdl3.externs.csdl3;

import api.math.matrices.matrix;
import api.core.utils.text;
import api.dm.kit.sprites3d.lightings.phongs.materials.material;
import api.math.matrices.affine2;

/**
 * Authors: initkfs
 */
class Planet : GuiScene
{

    SDL_Window* winPtr;

    SkyBox skybox;

    Cube cube;
    PointLight lamp;

    SimpleGroup env;
    SimpleGroup senv;

    Shape3d shape;

    override void create()
    {
        super.create;

        //camera.fov = 90;

        assert(camera);

        env = new SimpleGroup;
        //env.isCreateDataBuffer = true;
        addCreate(env);
        assert(env.hasCamera);

        auto diffusePath = context.app.userDir ~ "/container2.png";
        auto specularPath = context.app.userDir ~ "/container2_specular.png";

        shape = new Cube(1, 1, 1);
        //shape.lightingMaterial = new PhongMaterial(diffusePath, null);
        //shape.isCalcInverseWorldMatrix = true;

        camera.recalcView;

        //shape = new Frustum(camera.cameraPos, camera.cameraFront, camera.cameraUp, camera.cameraRight, camera.//fov, window.width / window.height, camera.nearPlane, camera.farPlane);

        env.addCreate(shape);

        // lamp = new PointLight;
        // lamp.diffuse = RGBA.web("#2EDCA3").toVec3Norm;
        // lamp.ambient = Vec3f(0.3, 0.3, 0.3);
        // env.lights.addCreate(lamp);
        // lamp.pos = Vec3f(0, 2, 0);
        // lamp.mesh.isVisible = true;
        // lamp.isManaged = true;

        auto skyBoxPath = context.app.userDir ~ "/nebula/";
        skybox = new SkyBox(skyBoxPath, "png");
        addCreate(skybox);

    }

    override void update(double dt)
    {
        super.update(dt);       
    }

    override void draw()
    {
        super.draw;
    }

    override void dispose()
    {
        super.dispose;
        //gpu.dev.deletePipeline(fillPipeline);
    }
}
