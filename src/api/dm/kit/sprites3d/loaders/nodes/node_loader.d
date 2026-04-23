module api.dm.kit.sprites3d.loaders.nodes.node_loader;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;
import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;

import api.math.geom3.vec3 : Vec3f;
import Math = api.math;

import std.string : toStringz, fromStringz;
import std.path : buildPath;
import api.dm.lib.assimp;

/**
 * Authors: initkfs
 */

class NodeLoader
{
    AssimpLib assimp;

    string baseDir;

    bool isFlatScene = true;

    this(AssimpLib loaderLib = null)
    {
        this.assimp = loaderLib;
    }

    Sprite3d load(string path)
    {
        if (!assimp)
        {
            assimp = new AssimpLib;
            assimp.load;
        }

        auto scene = assimp.loadScene(path);
        if (!scene)
        {
            import std.string : fromStringz;

            assert(aiGetErrorString);
            throw new Exception(aiGetErrorString().fromStringz.idup);
        }

        scope (exit)
        {
            aiReleaseImport(scene);
        }

        if (!scene.mRootNode)
        {
            throw new Exception("Not found root node in scene: " ~ path);
        }

        aiMatrix4x4 sceneMatrix;
        aiIdentityMatrix4(&sceneMatrix);

        float angle = -1.570796f; // -90 deg
        sceneMatrix.b2 = Math.cos(angle);
        sceneMatrix.b3 = -Math.sin(angle);
        sceneMatrix.c2 = Math.sin(angle);
        sceneMatrix.c3 = Math.cos(angle);

        Sprite3d root = isFlatScene ? new Sprite3d : null;
        if (root)
        {
            root.isBuildOnAdd = false;
        }

        return processNode(scene.mRootNode, scene, sceneMatrix, root);
    }

    Sprite3d processNode(const(aiNode)* node, const(aiScene)* scene, aiMatrix4x4 parentTransform, Sprite3d parent = null)
    {
        // World = ParentWorld * Local
        aiMatrix4x4 worldMatrix;
        // worldMatrix = parentMatrix * node.mTransformation
        worldMatrix = parentTransform;
        aiMultiplyMatrix4(&worldMatrix, &node.mTransformation);

        Sprite3d root = parent;
        if (!root || !isFlatScene)
        {
            root = new Sprite3d;
            root.isBuildOnAdd = false;
            if (parent)
            {
                root.parent = parent;
                parent.add(root);
            }
        }

        for (uint i = 0; i < node.mNumMeshes; i++)
        {
            uint meshIdx = node.mMeshes[i];
            const(aiMesh)* sceneMesh = scene.mMeshes[meshIdx];

            ushort[] indices;
            indices.length = sceneMesh.mNumFaces * 3;

            for (uint ii = 0; ii < sceneMesh.mNumFaces; ii++)
            {
                const(aiFace) face = sceneMesh.mFaces[ii];
                if (face.mNumIndices == 3)
                {
                    indices[ii * 3 + 0] = cast(ushort) face.mIndices[0];
                    indices[ii * 3 + 1] = cast(ushort) face.mIndices[1];
                    indices[ii * 3 + 2] = cast(ushort) face.mIndices[2];
                }
            }

            ComVertex[] vertices;
            vertices.length = sceneMesh.mNumVertices;

            for (uint iv = 0; iv < sceneMesh.mNumVertices; iv++)
            {
                vertices[iv].x = sceneMesh.mVertices[iv].x;
                vertices[iv].y = sceneMesh.mVertices[iv].y;
                vertices[iv].z = sceneMesh.mVertices[iv].z;

                if (sceneMesh.mNormals)
                {
                    vertices[iv].normals[0] = sceneMesh.mNormals[iv].x;
                    vertices[iv].normals[1] = sceneMesh.mNormals[iv].y;
                    vertices[iv].normals[2] = sceneMesh.mNormals[iv].z;
                }

                if (sceneMesh.mTextureCoords[0])
                {
                    vertices[iv].u = sceneMesh.mTextureCoords[0][iv].x;
                    vertices[iv].v = sceneMesh.mTextureCoords[0][iv].y;
                }

                // aiProcess_CalcTangentSpace )
                if (sceneMesh.mTangents)
                {
                    vertices[iv].tx = sceneMesh.mTangents[iv].x;
                    vertices[iv].ty = sceneMesh.mTangents[iv].y;
                    vertices[iv].tz = sceneMesh.mTangents[iv].z;
                }
            }

            auto material = scene.mMaterials[sceneMesh.mMaterialIndex];
            assert(material);

            auto shape = new Shape3d(vertices, indices);

            aiString path;
            auto ret = aiGetMaterialTexture(material, aiTextureType.aiTextureType_DIFFUSE, 0, &path, null, null, null, null, null, null);
            if (ret == aiReturn.aiReturn_SUCCESS)
            {
                string texturePath = path.data[0 .. path.length].idup;
                //writeln("Texture: ", texturePath);

                import std.path : buildPath;

                auto textPath = buildPath(baseDir, texturePath);
                shape.diffuseMapPath = textPath;

                shape.isCreateMaterial = true;
            }

            aiVector3D pos, scale;
            aiQuaternion rot;

            aiDecomposeMatrix(&worldMatrix, &scale, &rot, &pos);

            shape.x = pos.x;
            shape.y = pos.y;
            shape.z = pos.z;

            shape.scale = Vec3f(scale.x, scale.y, scale.z);

            import api.math.quaternion : Quaternion;

            Quaternion quat = Quaternion(rot.w, Vec3f(rot.x, rot.y, rot.z));
            auto angles = quat.toEuler;
            shape.angleX = angles.x;
            shape.angleY = angles.y;
            shape.angleZ = angles.z;

            root.add(shape);
        }

        for (uint i = 0; i < node.mNumChildren; i++)
        {
            processNode(node.mChildren[i], scene, worldMatrix, root);
        }

        return root;
    }

}
