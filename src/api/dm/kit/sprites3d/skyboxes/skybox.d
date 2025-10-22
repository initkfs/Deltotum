module api.dm.kit.sprites3d.skyboxes.skybox;

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
class SkyBox : Sprite3d
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

    SdlGPUPipeline skyboxPipeline;

    Cube cube;
    CubeMap cubeMap;

    string basepath;
    string ext;

    string vertexShaderName = "SkyBox.vert";
    string fragmentShaderName = "SkyBox.frag";

    this(string basepath, string ext = "jpg")
    {
        this.basepath = basepath;
        this.ext = ext;
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

        build(cube);
        cube.create;

        cubeMap = new CubeMap(basepath, ext);
        build(cubeMap);
        cubeMap.create;

        auto skyboxVert = gpu.shaderDefaultPath(vertexShaderName);
        auto skyboxFrag = gpu.shaderDefaultPath(fragmentShaderName);

        skyboxPipeline = gpu.newPipeline(skyboxVert, skyboxFrag, 0, 0, 1, 0, 1, 0, 0, 0);
    }

    void uploadStart()
    {
        assert(cube);
        cube.uploadStart;
        assert(cubeMap);
        cubeMap.uploadStart;
    }

    void uploadEnd()
    {
        assert(cube);
        cube.uploadEnd;
        assert(cubeMap);
        cubeMap.uploadEnd;
    }

    void bind(SceneTransforms* transforms = null)
    {
        assert(skyboxPipeline);
        gpu.dev.bindPipeline(skyboxPipeline);

        SceneTransforms transforms1;
        transforms1.world = cube.worldMatrix;

        if (transforms)
        {
            transforms1.camera = transforms.camera;
            transforms1.projection = transforms.projection;
            gpu.dev.pushUniformVertexData(0, &transforms1, SceneTransforms.sizeof);
        }

        gpu.dev.bindFragmentSamplers(cubeMap);

        cube.bindBuffers;
        cube.drawIndexed;
    }
}
