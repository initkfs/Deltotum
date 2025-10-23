module api.dm.kit.sprites3d.pipelines.skyboxes.skybox;

import api.dm.kit.sprites3d.pipelines.pipeline_group : PipelineGroup;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.shapes.cube : Cube;
import api.dm.kit.sprites3d.textures.cubemap : CubeMap;
import api.dm.com.gpu.com_3d_types;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;
import api.dm.kit.sprites3d.cameras.perspective_camera : PerspectiveCamera;
import api.dm.kit.scenes.scene3d : SceneTransforms;

import api.dm.back.sdl3.externs.csdl3;

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

    this(string basepath, string ext = "jpg")
    {
        this.basepath = basepath;
        this.ext = ext;
        isPushUniformVertexMatrix = false;

        id = "SkyBox3d";

        vertexShaderName = "SkyBox.vert";
        fragmentShaderName = "SkyBox.frag";
    }

    override void create()
    {
        super.create;

        cube = new class Cube
        {
            override void createMesh()
            {
                vertices = skyboxVertices;
                indices = skyboxIndices;
            }
        };
        cube.id = "SkyBoxCube";
        cube.isCreateLightingMaterial = false;

        addCreate(cube);

        cubeMap = new CubeMap(basepath, ext);
        addCreate(cubeMap);
        cubeMap.id = "SkyBoxCubeMap";

        createPipeline(0, 0, 1, 0, 1, 0, 0, 0);
    }
}
