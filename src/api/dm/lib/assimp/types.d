module api.dm.lib.assimp.types;
/**
 * Authors: initkfs
 */

struct aiTexture;
struct aiBone;
struct aiMaterial;

alias aiBool = int;
enum AI_FALSE = 0;
enum AI_TRUE = 1;

alias ai_real = float;

alias aiLogStreamCallback = void function(const char* message, char* user);

struct aiLogStream {
    aiLogStreamCallback callback;
    char *userData;
}

enum aiReturn {
    aiReturn_SUCCESS = 0x0,
    aiReturn_FAILURE = -0x1,
    aiReturn_OUTOFMEMORY = -0x3,
    _AI_ENFORCE_ENUM_SIZE = 0x7fffffff
}

enum aiPostProcessSteps
{
    aiProcess_CalcTangentSpace = 0x1,
    aiProcess_JoinIdenticalVertices = 0x2,
    aiProcess_MakeLeftHanded = 0x4,
    aiProcess_Triangulate = 0x8,
    aiProcess_RemoveComponent = 0x10,
    aiProcess_GenNormals = 0x20,
    aiProcess_GenSmoothNormals = 0x40,
    aiProcess_SplitLargeMeshes = 0x80,
    aiProcess_PreTransformVertices = 0x100,
    aiProcess_LimitBoneWeights = 0x200,
    aiProcess_ValidateDataStructure = 0x400,
    aiProcess_ImproveCacheLocality = 0x800,
    aiProcess_RemoveRedundantMaterials = 0x1000,
    aiProcess_FixInfacingNormals = 0x2000,
    aiProcess_PopulateArmatureData = 0x4000,
    aiProcess_SortByPType = 0x8000,
    aiProcess_FindDegenerates = 0x10000,
    aiProcess_FindInvalidData = 0x20000,
    aiProcess_GenUVCoords = 0x40000,
    aiProcess_TransformUVCoords = 0x80000,
    aiProcess_FindInstances = 0x100000,
    aiProcess_OptimizeMeshes = 0x200000,
    aiProcess_OptimizeGraph = 0x400000,
    aiProcess_FlipUVs = 0x800000,
    aiProcess_FlipWindingOrder = 0x1000000,
    aiProcess_SplitByBoneCount = 0x2000000,
    aiProcess_Debone = 0x4000000,
    aiProcess_GlobalScale = 0x8000000,
    aiProcess_EmbedTextures = 0x10000000,
    aiProcess_ForceGenNormals = 0x20000000,
    aiProcess_DropNormals = 0x40000000,
    aiProcess_GenBoundingBoxes = 0x80000000
}

enum aiTextureType {
    aiTextureType_NONE = 0,
    aiTextureType_DIFFUSE = 1,
    aiTextureType_SPECULAR = 2,
    aiTextureType_AMBIENT = 3,
    aiTextureType_EMISSIVE = 4,
    aiTextureType_HEIGHT = 5,
    aiTextureType_NORMALS = 6,
    aiTextureType_SHININESS = 7,
    aiTextureType_OPACITY = 8,
    aiTextureType_DISPLACEMENT = 9,
    aiTextureType_LIGHTMAP = 10,
    aiTextureType_REFLECTION = 11,
    aiTextureType_BASE_COLOR = 12,
    aiTextureType_NORMAL_CAMERA = 13,
    aiTextureType_EMISSION_COLOR = 14,
    aiTextureType_METALNESS = 15,
    aiTextureType_DIFFUSE_ROUGHNESS = 16,
    aiTextureType_AMBIENT_OCCLUSION = 17,
    aiTextureType_SHEEN = 19,
    aiTextureType_CLEARCOAT = 20,
    aiTextureType_TRANSMISSION = 21,
    aiTextureType_UNKNOWN = 18,
}

struct aiVector3D
{
    ai_real x = 0, y = 0, z = 0;
}

struct aiColor4D
{
    ai_real r = 0, g = 0, b = 0, a = 0;
}

struct aiMatrix4x4
{
    ai_real a1 = 0, a2 = 0, a3 = 0, a4 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, c1 = 0, c2 = 0, c3 = 0, c4 = 0, d1 = 0, d2 = 0, d3 = 0, d4 = 0;
}

struct aiQuaternion {
    ai_real w = 0, x = 0, y = 0, z = 0;
};

struct aiString
{
    uint length;
    char[1024] data;
}

enum AI_MAX_NUMBER_OF_COLOR_SETS = 8;

struct aiMesh
{
    uint mPrimitiveTypes;
    uint mNumVertices;
    uint mNumFaces;
    aiVector3D* mVertices;
    aiVector3D* mNormals;
    aiVector3D* mTangents;
    aiVector3D* mBitangents;
    aiColor4D*[8] mColors;
    aiVector3D*[8] mTextureCoords;
    uint[8] mNumUVComponents;
    aiFace* mFaces;
    uint mNumBones;
    aiBone** mBones;
    uint mMaterialIndex;
    aiString mName;
    //TODO all
}

struct aiFace
{
    uint mNumIndices;
    uint* mIndices;
}

struct aiNode
{
    aiString mName;
    aiMatrix4x4 mTransformation;
    aiNode* mParent;
    uint mNumChildren;
    aiNode** mChildren;
    uint mNumMeshes;
    uint* mMeshes;
    void* mMetaData;
}

struct aiScene
{
    uint mFlags;
    aiNode* mRootNode;
   
    uint mNumMeshes;
    aiMesh** mMeshes;
   
    uint mNumMaterials;
    aiMaterial** mMaterials;
   
    uint mNumAnimations;
    void** mAnimations;
    
    uint mNumTextures;
    void** mTextures;
   
    uint mNumLights;
    void** mLights;
    uint mNumCameras;
    
    void** mCameras;
    void* mMetaData;
    //TODO metadata and name
}
