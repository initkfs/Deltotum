module api.dm.kit.sprites3d.loaders.obj.model_loader;

import api.dm.kit.sprites3d.loaders.obj.obj_loader : ObjLoader;
import api.dm.kit.sprites3d.loaders.obj.mtl_loader : MtlLoader;

/**
 * Authors: initkfs
 */
class ModelLoader
{
    ObjLoader objLoader;
    MtlLoader mtlLoader;

    this()
    {
        objLoader = new ObjLoader;
        mtlLoader = new MtlLoader;
    }

    void parseFile(string objFile, string basePath = null)
    {
        import std.file : readText;

        auto fileText = objFile.readText;
        parse(fileText, null, basePath);
    }

    void parse(string objFile, string mtlFile = null, string basePath = null)
    {
        objLoader.parse(objFile);

        if (mtlFile.length > 0)
        {
            mtlLoader.parse(mtlFile);
            return;
        }

        if (objLoader.mtlLib)
        {

            import std.file : readText;

            auto mtlPath = objLoader.mtlLib;
            if (basePath.length > 0)
            {
                import std.path : buildPath;

                mtlPath = buildPath(basePath, mtlPath);
            }

            auto mtlText = mtlPath.readText;
            mtlLoader.parse(mtlText);
        }
    }
}

unittest
{
    auto modelLoader = new ModelLoader();

    string objText = `
mtllib test.mtl
v 0.0 0.0 0.0
v 1.0 0.0 0.0
v 1.0 1.0 0.0
usemtl RedMaterial
f 1 2 3
usemtl BlueMaterial  
f 1 3 4
`;

    string mtlText = `
newmtl RedMaterial
Kd 1.0 0.0 0.0
newmtl BlueMaterial
Kd 0.0 0.0 1.0
`;

    modelLoader.parse(objText, mtlText);

    assert(modelLoader.objLoader.meshes.length == 2);
    assert(modelLoader.objLoader.meshes[0].material == "RedMaterial");
    assert(modelLoader.objLoader.meshes[1].material == "BlueMaterial");

    assert("RedMaterial" in modelLoader.mtlLoader.materials);
    assert("BlueMaterial" in modelLoader.mtlLoader.materials);
}
