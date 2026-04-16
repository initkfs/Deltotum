module api.dm.lib.assimp.binddynamic;

/**
 * Authors: initkfs
 */
import api.core.contexts.libs.dynamics.dynamic_loader : DynamicLoader;
import api.dm.lib.assimp.types;

extern (C) nothrow
{
    const(aiScene)* function(const char* pFile, uint pFlags) aiImportFile;
    void function(const(aiScene)* pScene) aiReleaseImport;
    //const(aiTexture)*  function(const aiScene *pIn, const(char)*filename) aiGetEmbeddedTexture;
    
    const(char)* function() aiGetErrorString;

    void function(const aiLogStream *stream) aiAttachLogStream;
    void function(aiBool d) aiEnableVerboseLogging;

    uint function(const aiMaterial *pMat, aiTextureType type) aiGetMaterialTextureCount;

    aiReturn function(const aiMaterial *mat, aiTextureType type, uint index, aiString *path, void* mapping /*= NULL*/,
        uint *uvindex /*= NULL*/,
        void* blend /*= NULL*/,
        void *op /*= NULL*/,
        void *mapmode /*= NULL*/,
        void *flags /*= NULL*/) aiGetMaterialTexture;
    
     void function(const aiMatrix4x4 *mat, aiVector3D *scaling, aiQuaternion *rotation, aiVector3D *position) aiDecomposeMatrix;
     void function(aiMatrix4x4 *dst, const aiMatrix4x4 *src) aiMultiplyMatrix4;
     void function(aiMatrix4x4 *mat) aiIdentityMatrix4;
}

class AssimpLib : DynamicLoader
{
    protected
    {

    }

    override void bindAll()
    {
        bind(&aiImportFile, "aiImportFile");
        bind(&aiReleaseImport, "aiReleaseImport");
        //bind(&aiGetEmbeddedTexture, "aiGetEmbeddedTexture");

        bind(&aiGetErrorString, "aiGetErrorString");

        bind(&aiAttachLogStream, "aiAttachLogStream");
        bind(&aiEnableVerboseLogging, "aiEnableVerboseLogging");

        bind(&aiGetMaterialTextureCount, "aiGetMaterialTextureCount");
        bind(&aiGetMaterialTexture, "aiGetMaterialTexture");

        bind(&aiGetMaterialTexture, "aiGetMaterialTexture");

        bind(&aiDecomposeMatrix, "aiDecomposeMatrix");
        bind(&aiMultiplyMatrix4, "aiMultiplyMatrix4");
        bind(&aiIdentityMatrix4, "aiIdentityMatrix4");
    }

    version (Windows)
    {
        string[1] paths = [
            "libassimp.dll"
        ];
    }
    else version (OSX)
    {
        string[1] paths = [
            "libassimp.dylib"
        ];
    }
    else version (Posix)
    {
        string[1] paths = [
            "libassimp.so"
        ];
    }
    else
    {
        string[] paths;
    }

    override string[] libPaths()
    {
        return paths;
    }

    const(aiScene)* loadScene(string path)
    {
        assert(aiImportFile);

        import std.string : toStringz;

        //| aiPostProcessSteps.aiProcess_PreTransformVertices
        return aiImportFile(path.toStringz, aiPostProcessSteps.aiProcess_Triangulate | aiPostProcessSteps
                .aiProcess_CalcTangentSpace );
    }
}
