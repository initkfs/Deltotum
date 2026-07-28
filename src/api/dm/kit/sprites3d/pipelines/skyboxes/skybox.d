module api.dm.kit.sprites3d.pipelines.skyboxes.skybox;

import api.dm.kit.sprites3d.pipelines.pipeline_group : PipelineGroup;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites2d.sprite2d: Sprite2d;
import api.dm.sim3d.meshes.cube : Cube;
import api.dm.kit.sprites3d.textures.cubemap : CubeMap;
import api.dm.com.graphics.gpu.com_3d_types;
import api.math.matrices.matrix : Matrix4x4;

import api.dm.back.sdl3.externs.csdl3;

struct SpriteTransforms
{
    Matrix4x4 model;
    Matrix4x4 camera;
    Matrix4x4 projection;
}

/**
 * Authors: initkfs
 */
class SkyBox : PipelineGroup
{

    ComVertex[] skyboxVertices = [
        // positions          
        ComVertex(-10, -10, -10),
        ComVertex(10, -10, -10),
        ComVertex(10, 10, -10),
        ComVertex(-10, 10, -10),

        ComVertex(-10, -10, 10),
        ComVertex(10, -10, 10),
        ComVertex(10, 10, 10),
        ComVertex(-10, 10, 10),

        ComVertex(-10, -10, -10),
        ComVertex(-10, 10, -10),
        ComVertex(-10, 10, 10),
        ComVertex(-10, -10, 10),

        ComVertex(10, -10, -10),
        ComVertex(10, 10, -10),
        ComVertex(10, 10, 10),
        ComVertex(10, -10, 10),

        ComVertex(-10, -10, -10),
        ComVertex(-10, -10, 10),
        ComVertex(10, -10, 10),
        ComVertex(10, -10, -10),

        ComVertex(-10, 10, -10),
        ComVertex(-10, 10, 10),
        ComVertex(10, 10, 10),
        ComVertex(10, 10, -10)
    ];

    ushort[] skyboxIndices = [
        0, 1, 2, 0, 2, 3,
        6, 5, 4, 7, 6, 4,
        8, 9, 10, 8, 10, 11,
        14, 13, 12, 15, 14, 12,
        16, 17, 18, 16, 18, 19,
        22, 21, 20, 23, 22, 20
    ];

    Cube cube;
    CubeMap cubeMap;

    string basepath;
    string ext;

    this(string basepath, string ext = "png")
    {
        this.basepath = basepath;
        this.ext = ext;

        id = "SkyBox3d";
        //isDepth = false;

        vertexShaderName = "SkyBox.vert";
        fragmentShaderName = "SkyBox.frag";

        onBeforeDrawChildDg = (Sprite2d child) {
            if (auto sprite3d = cast(Sprite3d) child)
            {
                bindSpriteData(sprite3d);
            }
        };
    }

    override void create()
    {
        super.create;

        cube = new Cube(skyboxVertices, skyboxIndices);
        cube.id = "SkyBoxCube";
        addCreate(cube);

        cubeMap = new CubeMap(basepath, ext);
        addCreate(cubeMap);
        cubeMap.id = "SkyBoxCubeMap";

        auto buff = pipeBuffers;
        buff.numVertexUniformBuffers = 1;
        buff.numFragSamples = 1;
        createPipeline(buff);
    }

    override void bindSpriteData(Sprite3d sprite)
    {
        sprite.bindAll;

        SpriteTransforms transforms;
        transforms.model = sprite.worldMatrix;

        //TODO remove movings
        //glm::mat4 view = glm::mat4(glm::mat3(camera.GetViewMatrix()));  
        transforms.camera = camera.view;
        
        transforms.projection = camera.projection;

        gpu.dev.pushUniformVertexData(0, &transforms, SpriteTransforms.sizeof);
    }

    override SDL_GPURasterizerState createRasterizerState()
    {
        auto state = super.createRasterizerState;
        state.enable_depth_clip = false;
        return state;
    }
}
