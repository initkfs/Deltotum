module api.dm.kit.sprites3d.loaders.obj.mtl_loader;

import std.string : strip, split, toLower;
import std.algorithm.iteration : splitter;
import std.algorithm.searching : startsWith;
import std.conv : to;

struct Material
{
    string name;
    float[3] ambient = [0.2, 0.2, 0.2]; // Ka
    float[3] diffuse = [0.8, 0.8, 0.8]; // Kd  
    float[3] specular = [1.0, 1.0, 1.0]; // Ks
    float shininess = 0.0; // Ns
    float alpha = 1.0; // d or Tr
    string diffuseMap; // map_Kd
    string normalMap; // map_Bump
    string specularMap; // map_Ks
    string ambientMap; // map_Ka
}

/**
 * Authors: initkfs
 */
class MtlLoader
{
    Material[string] materials;

    protected
    {
        Material currentMaterial;
    }

    void parse(string text)
    {
        materials = null;
        currentMaterial = Material();

        foreach (line; text.splitter('\n'))
        {
            string trimmedLine = line.strip();

            if (trimmedLine.length == 0 || trimmedLine.startsWith("#"))
                continue;

            auto parts = trimmedLine.split();
            if (parts.length < 2)
                continue;

            string command = parts[0].toLower();
            string[] params = parts[1 .. $];

            switch (command)
            {
                case "newmtl":
                    if (currentMaterial.name.length > 0)
                    {
                        materials[currentMaterial.name] = currentMaterial;
                    }
                    currentMaterial = Material();
                    currentMaterial.name = params[0];
                    break;

                case "ka":
                    if (params.length >= 3)
                    {
                        currentMaterial.ambient[0] = params[0].to!float;
                        currentMaterial.ambient[1] = params[1].to!float;
                        currentMaterial.ambient[2] = params[2].to!float;
                    }
                    break;

                case "kd":
                    if (params.length >= 3)
                    {
                        currentMaterial.diffuse[0] = params[0].to!float;
                        currentMaterial.diffuse[1] = params[1].to!float;
                        currentMaterial.diffuse[2] = params[2].to!float;
                    }
                    break;

                case "ks":
                    if (params.length >= 3)
                    {
                        currentMaterial.specular[0] = params[0].to!float;
                        currentMaterial.specular[1] = params[1].to!float;
                        currentMaterial.specular[2] = params[2].to!float;
                    }
                    break;

                case "ns":
                    if (params.length >= 1)
                    {
                        currentMaterial.shininess = params[0].to!float;
                    }
                    break;

                case "d":
                    if (params.length >= 1)
                    {
                        currentMaterial.alpha = params[0].to!float;
                    }
                    break;

                case "tr":
                    if (params.length >= 1)
                    {
                        // Tr - opacity (1 - d)
                        currentMaterial.alpha = 1.0 - params[0].to!float;
                    }
                    break;

                case "map_kd":
                    if (params.length >= 1)
                    {
                        currentMaterial.diffuseMap = params[0];
                    }
                    break;

                case "map_bump":
                case "bump":
                    if (params.length >= 1)
                    {
                        currentMaterial.normalMap = params[0];
                    }
                    break;

                case "map_ks":
                    if (params.length >= 1)
                    {
                        currentMaterial.specularMap = params[0];
                    }
                    break;

                case "map_ka":
                    if (params.length >= 1)
                    {
                        currentMaterial.ambientMap = params[0];
                    }
                    break;
                default:
                    break;
            }
        }

        if (currentMaterial.name.length > 0)
        {
            materials[currentMaterial.name] = currentMaterial;
        }
    }

    Material getMaterial(string name)
    {
        if (auto matPtr = name in materials)
        {
            return *matPtr;
        }
        return Material();
    }
}

unittest
{
    import std.math.operations : isClose;

    auto mtlParser = new MtlLoader();
    string mtlText = `
newmtl RedMaterial
Ka 0.2 0.0 0.0
Kd 1.0 0.0 0.0
Ks 0.5 0.5 0.5
Ns 200.0
d 0.9
map_Kd red_texture.jpg

newmtl BlueMaterial
Ka 0.0 0.0 0.2  
Kd 0.0 0.0 1.0
Ks 1.0 1.0 1.0
Ns 100.0
Tr 0.8
map_Bump blue_normal.jpg
`;

    mtlParser.parse(mtlText);

    assert(mtlParser.materials.length == 2);

    assert("RedMaterial" in mtlParser.materials);
    auto redMat = mtlParser.materials["RedMaterial"];
    assert(isClose(redMat.diffuse[], [1.0f, 0.0f, 0.0f]));
    assert(isClose(redMat.ambient[], [0.2f, 0.0f, 0.0f]));
    assert(isClose(redMat.specular[], [0.5f, 0.5f, 0.5f]));
    assert(isClose(redMat.shininess, 200.0f));
    assert(isClose(redMat.alpha, 0.9f));
    assert(redMat.diffuseMap == "red_texture.jpg");

    assert("BlueMaterial" in mtlParser.materials);
    auto blueMat = mtlParser.materials["BlueMaterial"];
    assert(isClose(blueMat.diffuse[], [0.0f, 0.0f, 1.0f]));
    assert(isClose(blueMat.alpha, 0.2f)); // Tr = 1 - d (0.8)
    assert(blueMat.normalMap == "blue_normal.jpg");
}
