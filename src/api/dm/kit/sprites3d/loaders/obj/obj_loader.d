module api.dm.kit.sprites3d.loaders.obj.obj_loader;

import api.dm.com.graphics.gpu.com_3d_types : ComVertex;
import std.algorithm.iteration : splitter;
import std.algorithm.searching : startsWith;
import std.algorithm : filter;
import std.array : array;
import std.string: strip;
import std.conv : to;

/**
 * Authors: initkfs
 * 
   # comment
   v  x y z          # vertex
   vt u v            # texture coords 
   vn x y z          # normals
   f v1/vt1/vn1      # poly face
 */

struct Coord3f
{
    float x = 0, y = 0, z = 0;
}

struct Coord2f
{
    float u = 0, v = 0;
}

struct Mesh
{
    string name; // g or o
    string material; // usemtl
    ushort[] indices;
    uint vertexCount;
    uint indexOffset; // offsets in vertex buffer
    uint indexCount;
}

class ObjLoader
{
    string commentStart = "#";
    string vertexStart = "v ";
    string normalStart = "vn";
    string faceStart = "f ";
    string texCoordStart = "vt";
    char fieldSeparator = ' ';

    Coord3f[] vertCoords;
    Coord3f[] normalsCoords;
    Coord2f[] texCoords;

    ComVertex[] uniqueVertices;
    ushort[] indices;

    Mesh[] meshes;
    string mtlLib; // mtllib
    private Mesh currentMesh;

    string groupStart = "g ";
    string objectStart = "o ";
    string useMtlStart = "usemtl ";
    string mtlLibStart = "mtllib ";

    protected
    {
        ushort[ComVertex] vertexCache;
    }

    const(char)[] extractLine(string command, const(char)[] line)
    {

        import std.string : strip, lastIndexOf;

        auto newLine = line[command.length .. $].strip;

        ptrdiff_t lastCommentPos = newLine.lastIndexOf(commentStart);
        if (lastCommentPos != -1 && lastCommentPos > 0)
        {
            newLine = newLine[0 .. lastCommentPos].strip;
        }
        return newLine;
    }

    void parse(string text, char lineSep = '\n', bool isIndices = true)
    {
        //TODO reuse
        meshes = null;
        mtlLib = null;
        vertexCache = null;
        indices = null;
        uniqueVertices = null;
        normalsCoords = null;
        vertCoords = null;
        texCoords = null;

        foreach (line; text.splitter(lineSep))
        {
            if (line.startsWith("#"))
            {
                continue;
            }

            if (line.startsWith(vertexStart))
            {
                Coord3f vertex = parseCoord3d(extractLine(vertexStart, line));
                vertCoords ~= vertex;
                continue;
            }

            if (line.startsWith(normalStart))
            {
                Coord3f normal = parseCoord3d(extractLine(normalStart, line));
                normalsCoords ~= normal;
                continue;
            }

            if (line.startsWith(texCoordStart))
            {
                Coord2f texCoord = parseCoord2d(extractLine(texCoordStart, line));
                texCoords ~= texCoord;
                continue;
            }

            if (line.startsWith(faceStart))
            {
                if (isIndices)
                {
                    parseFaceWithIndices(extractLine(faceStart, line));
                }
                else
                {
                    parseFace(extractLine(faceStart, line));
                }
                continue;
            }

            if (line.startsWith(mtlLibStart))
            {
                //TODO last comments
                mtlLib = line[mtlLibStart.length .. $].strip();
                continue;
            }

            if (line.startsWith(useMtlStart))
            {
                string materialName = line[useMtlStart.length .. $].strip();
                if (currentMesh.material.length > 0 || currentMesh.name.length > 0)
                {
                    startNewMesh;
                }

                currentMesh.material = materialName;
                continue;
            }

            if (line.startsWith(groupStart) || line.startsWith(objectStart))
            {
                string name = line[line.startsWith(groupStart) ? groupStart.length: objectStart.length .. $].strip();
                if (currentMesh.name.length > 0 || currentMesh.material.length > 0)
                {
                    startNewMesh;
                }

                currentMesh.name = name;
                continue;
            }

        }

        finalizeCurrentMesh;
    }

    private void startNewMesh(string nameOrMaterial = null)
    {
        finalizeCurrentMesh;

        currentMesh = Mesh();
        if (nameOrMaterial.length > 0)
        {
            currentMesh.name = nameOrMaterial;
        }

        currentMesh.indexOffset = cast(uint) indices.length;
    }

    private void finalizeCurrentMesh()
    {
        if (currentMesh.name.length > 0 || currentMesh.material.length > 0)
        {
            currentMesh.indexCount = cast(uint) indices.length - currentMesh.indexOffset;
            currentMesh.vertexCount = cast(uint) uniqueVertices.length;
            meshes ~= currentMesh;
        }
    }

    void parseFace(const(char[]) line)
    {
        auto vertexComponents = line.splitter(fieldSeparator)
            .filter!(comp => comp.length > 0)
            .array;

        if (vertexComponents.length < 3)
            return;

        ComVertex[] polygonVertices;
        foreach (vertexDesc; vertexComponents)
        {
            // v/vt/vn
            auto parts = vertexDesc.splitter('/').array;

            // v/vt/vn, v//vn, v/vt, v
            if (parts.length < 1)
            {
                continue;
            }

            int vertexIndex = parts[0].to!int - 1;
            int texCoordIndex = -1;
            int normalIndex = -1;

            if (parts.length >= 2 && parts[1].length > 0)
            {
                texCoordIndex = parts[1].to!int - 1;
            }

            if (parts.length >= 3 && parts[2].length > 0)
            {
                normalIndex = parts[2].to!int - 1;
            }

            if (vertexIndex < 0 || vertexIndex >= vertCoords.length)
                continue;

            ComVertex vertex;
            vertex.x = vertCoords[vertexIndex].x;
            vertex.y = vertCoords[vertexIndex].y;
            vertex.z = vertCoords[vertexIndex].z;

            if (normalIndex >= 0 && normalIndex < normalsCoords.length)
            {
                vertex.normals[0] = normalsCoords[normalIndex].x;
                vertex.normals[1] = normalsCoords[normalIndex].y;
                vertex.normals[2] = normalsCoords[normalIndex].z;
            }

            if (texCoordIndex >= 0 && texCoordIndex < texCoords.length)
            {
                vertex.u = texCoords[texCoordIndex].u;
                vertex.v = texCoords[texCoordIndex].v;
            }

            polygonVertices ~= vertex;
        }

        triangulate(polygonVertices);
    }

    void parseFaceWithIndices(const(char[]) line)
    {
        auto vertexComponents = line.splitter(fieldSeparator)
            .filter!(comp => comp.length > 0)
            .array;

        if (vertexComponents.length < 3)
            return;

        ushort[] faceIndices;
        foreach (vertexDesc; vertexComponents)
        {
            auto parts = vertexDesc.splitter('/').array;

            if (parts.length < 1)
                continue;

            int vertexIndex = parts[0].to!int - 1;
            int texCoordIndex = -1;
            int normalIndex = -1;

            if (parts.length >= 2 && parts[1].length > 0)
                texCoordIndex = parts[1].to!int - 1;
            if (parts.length >= 3 && parts[2].length > 0)
                normalIndex = parts[2].to!int - 1;

            if (vertexIndex < 0 || vertexIndex >= vertCoords.length)
                continue;

            ComVertex vertex;
            vertex.x = vertCoords[vertexIndex].x;
            vertex.y = vertCoords[vertexIndex].y;
            vertex.z = vertCoords[vertexIndex].z;

            if (normalIndex >= 0 && normalIndex < normalsCoords.length)
            {
                vertex.normals[0] = normalsCoords[normalIndex].x;
                vertex.normals[1] = normalsCoords[normalIndex].y;
                vertex.normals[2] = normalsCoords[normalIndex].z;
            }

            if (texCoordIndex >= 0 && texCoordIndex < texCoords.length)
            {
                vertex.u = texCoords[texCoordIndex].u;
                vertex.v = texCoords[texCoordIndex].v;
            }

            ushort index = getOrCreateVertexIndex(vertex);
            faceIndices ~= index;
        }

        triangulateIndices(faceIndices);
    }

    ushort getOrCreateVertexIndex(ComVertex vertex)
    {
        if (auto existing = vertex in vertexCache)
        {
            return *existing;
        }

        ushort newIndex = cast(ushort) uniqueVertices.length;
        uniqueVertices ~= vertex;
        vertexCache[vertex] = newIndex;
        return newIndex;
    }

    void triangulateIndices(ushort[] faceIndices)
    {
        if (faceIndices.length == 3)
        {
            indices ~= faceIndices[0];
            indices ~= faceIndices[1];
            indices ~= faceIndices[2];
        }
        else if (faceIndices.length == 4)
        {
            indices ~= faceIndices[0];
            indices ~= faceIndices[1];
            indices ~= faceIndices[2];

            indices ~= faceIndices[0];
            indices ~= faceIndices[2];
            indices ~= faceIndices[3];
        }
        else if (faceIndices.length > 4)
        {
            for (int i = 1; i < faceIndices.length - 1; i++)
            {
                indices ~= faceIndices[0];
                indices ~= faceIndices[i];
                indices ~= faceIndices[i + 1];
            }
        }
    }

    void triangulate(ComVertex[] polygon)
    {
        if (polygon.length == 3)
        {
            uniqueVertices ~= polygon;
            return;
        }

        //split 2 triangles
        if (polygon.length == 4)
        {
            //1: v0 -> v1 -> v2
            uniqueVertices ~= polygon[0];
            uniqueVertices ~= polygon[1];
            uniqueVertices ~= polygon[2];

            //2: v0 -> v2 -> v3
            uniqueVertices ~= polygon[0];
            uniqueVertices ~= polygon[2];
            uniqueVertices ~= polygon[3];

            return;
        }

        //(N > 4)
        if (polygon.length > 4)
        {
            for (int i = 1; i < polygon.length - 1; i++)
            {
                uniqueVertices ~= polygon[0];
                uniqueVertices ~= polygon[i];
                uniqueVertices ~= polygon[i + 1];
            }

            return;
        }

        import std.conv : text;

        throw new Exception(text("Invalid polygon received: ", polygon));
    }

    Coord3f parseCoord3d(const(char[]) line)
    {

        Coord3f coord;
        size_t ci;
        foreach (coordPart; line.splitter(fieldSeparator))
        {
            if (coordPart.length == 0)
            {
                continue;
            }

            float value = coordPart.to!float;
            switch (ci)
            {
                case 0:
                    coord.x = value;
                    break;
                case 1:
                    coord.y = value;
                    break;
                case 2:
                    coord.z = value;
                    break;
                default:
                    break;
            }
            ci++;
        }

        return coord;
    }

    Coord2f parseCoord2d(const(char[]) line)
    {
        Coord2f coord;
        size_t ci;
        foreach (coordPart; line.splitter(fieldSeparator))
        {
            if (coordPart.length == 0)
                continue;

            float value = coordPart.to!float;
            switch (ci)
            {
                case 0:
                    coord.u = value;
                    break;
                case 1:
                    coord.v = value;
                    break;
                default:
                    break;
            }
            ci++;
        }
        return coord;
    }

    ushort[] getMeshIndices(uint meshIndex)
    {
        if (meshIndex >= meshes.length)
            return null;

        auto mesh = meshes[meshIndex];
        return indices[mesh.indexOffset .. mesh.indexOffset + mesh.indexCount];
    }

    ComVertex[] getVertices() => uniqueVertices;
    ushort[] getIndices() => indices;

}

unittest
{
    auto parser = new ObjLoader;

    auto objText = "
v 0.0 0.0 0.0
v 0.0 1.0 0.0
v 1.0 1.0 0.0
v 1.0 0.0 0.0
v 0.0 0.0 1.0
v 0.0 1.0 1.0
v 1.0 1.0 1.0
v 1.0 0.0 1.0

vn  1.0  0.0  0.0
vn -1.0  0.0  0.0
vn  0.0  1.0  0.0
vn  0.0 -1.0  0.0
vn  0.0  0.0  1.0
vn  0.0  0.0 -1.0

f 3//1 7//1 8//1
f 3//1 8//1 4//1
f 1//2 5//2 6//2
f 1//2 6//2 2//2
f 7//3 3//3 2//3
f 7//3 2//3 6//3
f 4//4 8//4 5//4
f 4//4 5//4 1//4
f 8//5 7//5 6//5
f 8//5 6//5 5//5
f 3//6 4//6 1//6
f 3//6 1//6 2//6
    ";

    parser.parse(objText, '\n', isIndices:
        false);
    assert(parser.vertCoords.length == 8);
    assert(parser.vertCoords == [
        Coord3f(),
        Coord3f(0.0, 1.0),
        Coord3f(1.0, 1.0),
        Coord3f(1.0),
        Coord3f(0.0, 0.0, 1.0),
        Coord3f(0.0, 1.0, 1.0),
        Coord3f(1.0, 1.0, 1.0),
        Coord3f(1.0, 0.0, 1.0),
    ]);

    assert(parser.normalsCoords.length == 6);
    assert(parser.normalsCoords == [
        Coord3f(1.0),
        Coord3f(-1.0),
        Coord3f(0.0, 1.0),
        Coord3f(0.0, -1.0),
        Coord3f(0.0, 0.0, 1.0),
        Coord3f(0.0, 0.0, -1.0),
    ]);

    assert(parser.uniqueVertices == [
        //1: f 3//1 7//1 8//1
        ComVertex(1.0, 1.0, 0.0, [1.0, 0.0, 0.0], 0, 0), // v3 vn1
        ComVertex(1.0, 1.0, 1.0, [1.0, 0.0, 0.0], 0, 0), // v7 vn1  
        ComVertex(1.0, 0.0, 1.0, [1.0, 0.0, 0.0], 0, 0), // v8 vn1

        //2: f 3//1 8//1 4//1
        ComVertex(1.0, 1.0, 0.0, [1.0, 0.0, 0.0], 0, 0), // v3 vn1
        ComVertex(1.0, 0.0, 1.0, [1.0, 0.0, 0.0], 0, 0), // v8 vn1
        ComVertex(1.0, 0.0, 0.0, [1.0, 0.0, 0.0], 0, 0), // v4 vn1

        //3: f 1//2 5//2 6//2
        ComVertex(0.0, 0.0, 0.0, [-1.0, 0.0, 0.0], 0, 0), // v1 vn2
        ComVertex(0.0, 0.0, 1.0, [-1.0, 0.0, 0.0], 0, 0), // v5 vn2
        ComVertex(0.0, 1.0, 1.0, [-1.0, 0.0, 0.0], 0, 0), // v6 vn2

        //4: f 1//2 6//2 2//2
        ComVertex(0.0, 0.0, 0.0, [-1.0, 0.0, 0.0], 0, 0), // v1 vn2
        ComVertex(0.0, 1.0, 1.0, [-1.0, 0.0, 0.0], 0, 0), // v6 vn2
        ComVertex(0.0, 1.0, 0.0, [-1.0, 0.0, 0.0], 0, 0), // v2 vn2

        //5: f 7//3 3//3 2//3
        ComVertex(1.0, 1.0, 1.0, [0.0, 1.0, 0.0], 0, 0), // v7 vn3
        ComVertex(1.0, 1.0, 0.0, [0.0, 1.0, 0.0], 0, 0), // v3 vn3
        ComVertex(0.0, 1.0, 0.0, [0.0, 1.0, 0.0], 0, 0), // v2 vn3

        //6: f 7//3 2//3 6//3
        ComVertex(1.0, 1.0, 1.0, [0.0, 1.0, 0.0], 0, 0), // v7 vn3
        ComVertex(0.0, 1.0, 0.0, [0.0, 1.0, 0.0], 0, 0), // v2 vn3
        ComVertex(0.0, 1.0, 1.0, [0.0, 1.0, 0.0], 0, 0), // v6 vn3

        //7: f 4//4 8//4 5//4
        ComVertex(1.0, 0.0, 0.0, [0.0, -1.0, 0.0], 0, 0), // v4 vn4
        ComVertex(1.0, 0.0, 1.0, [0.0, -1.0, 0.0], 0, 0), // v8 vn4
        ComVertex(0.0, 0.0, 1.0, [0.0, -1.0, 0.0], 0, 0), // v5 vn4

        //8: f 4//4 5//4 1//4
        ComVertex(1.0, 0.0, 0.0, [0.0, -1.0, 0.0], 0, 0), // v4 vn4
        ComVertex(0.0, 0.0, 1.0, [0.0, -1.0, 0.0], 0, 0), // v5 vn4
        ComVertex(0.0, 0.0, 0.0, [0.0, -1.0, 0.0], 0, 0), // v1 vn4

        //9: f 8//5 7//5 6//5
        ComVertex(1.0, 0.0, 1.0, [0.0, 0.0, 1.0], 0, 0), // v8 vn5
        ComVertex(1.0, 1.0, 1.0, [0.0, 0.0, 1.0], 0, 0), // v7 vn5
        ComVertex(0.0, 1.0, 1.0, [0.0, 0.0, 1.0], 0, 0), // v6 vn5

        //10: f 8//5 6//5 5//5
        ComVertex(1.0, 0.0, 1.0, [0.0, 0.0, 1.0], 0, 0), // v8 vn5
        ComVertex(0.0, 1.0, 1.0, [0.0, 0.0, 1.0], 0, 0), // v6 vn5
        ComVertex(0.0, 0.0, 1.0, [0.0, 0.0, 1.0], 0, 0), // v5 vn5

        //11: f 3//6 4//6 1//6
        ComVertex(1.0, 1.0, 0.0, [0.0, 0.0, -1.0], 0, 0), // v3 vn6
        ComVertex(1.0, 0.0, 0.0, [0.0, 0.0, -1.0], 0, 0), // v4 vn6
        ComVertex(0.0, 0.0, 0.0, [0.0, 0.0, -1.0], 0, 0), // v1 vn6

        //12: f 3//6 1//6 2//6
        ComVertex(1.0, 1.0, 0.0, [0.0, 0.0, -1.0], 0, 0), // v3 vn6
        ComVertex(0.0, 0.0, 0.0, [0.0, 0.0, -1.0], 0, 0), // v1 vn6
        ComVertex(0.0, 1.0, 0.0, [0.0, 0.0, -1.0], 0, 0) //  v2 vn6
    ]);

    parser.parse(objText, '\n', isIndices:
        true);

    assert(parser.vertCoords.length == 8);
    assert(parser.vertCoords == [
        Coord3f(),
        Coord3f(0.0, 1.0),
        Coord3f(1.0, 1.0),
        Coord3f(1.0, 0.0),
        Coord3f(0.0, 0.0, 1.0),
        Coord3f(0.0, 1.0, 1.0),
        Coord3f(1.0, 1.0, 1.0),
        Coord3f(1.0, 0.0, 1.0),
    ]);

    assert(parser.normalsCoords.length == 6);
    assert(parser.normalsCoords == [
        Coord3f(1.0),
        Coord3f(-1.0),
        Coord3f(0.0, 1.0),
        Coord3f(0.0, -1.0),
        Coord3f(0.0, 0.0, 1.0),
        Coord3f(0.0, 0.0, -1.0),
    ]);

    import std.format : format;

    assert(parser.uniqueVertices.length == 24, format("Expected 24 unique vertices, got %s", parser
            .uniqueVertices.length));

    assert(parser.indices.length == 36, format("Expected 36 indices, got %s", parser.indices.length));

    assert(parser.indices[0 .. 3] == [0, 1, 2]); // First triangle
    assert(parser.indices[3 .. 6] == [0, 2, 3]); // Second triangle

    foreach (idx; parser.indices)
    {
        assert(idx < parser.uniqueVertices.length,
            format("Invalid index %s, max is %s", idx, parser.uniqueVertices.length - 1));
    }

    bool foundRightNormal = false;
    bool foundLeftNormal = false;
    bool foundTopNormal = false;
    bool foundBottomNormal = false;
    bool foundFrontNormal = false;
    bool foundBackNormal = false;

    foreach (vertex; parser.uniqueVertices)
    {
        if (vertex.normals[0] == 1.0 && vertex.normals[1] == 0.0 && vertex.normals[2] == 0.0)
            foundRightNormal = true;
        if (vertex.normals[0] == -1.0 && vertex.normals[1] == 0.0 && vertex.normals[2] == 0.0)
            foundLeftNormal = true;
        if (vertex.normals[0] == 0.0 && vertex.normals[1] == 1.0 && vertex.normals[2] == 0.0)
            foundTopNormal = true;
        if (vertex.normals[0] == 0.0 && vertex.normals[1] == -1.0 && vertex.normals[2] == 0.0)
            foundBottomNormal = true;
        if (vertex.normals[0] == 0.0 && vertex.normals[1] == 0.0 && vertex.normals[2] == 1.0)
            foundFrontNormal = true;
        if (vertex.normals[0] == 0.0 && vertex.normals[1] == 0.0 && vertex.normals[2] == -1.0)
            foundBackNormal = true;
    }

    assert(foundRightNormal, "Should have vertices with right normal");
    assert(foundLeftNormal, "Should have vertices with left normal");
    assert(foundTopNormal, "Should have vertices with top normal");
    assert(foundBottomNormal, "Should have vertices with bottom normal");
    assert(foundFrontNormal, "Should have vertices with front normal");
    assert(foundBackNormal, "Should have vertices with back normal");

    assert(parser.indices.length % 3 == 0, "Indices should form complete triangles");
    assert(parser.indices.length / 3 == 12, "Should have exactly 12 triangles");
}

unittest
{
    import std.format : format;

    auto parser = new ObjLoader;

    auto objText = "
v 0.0 0.0 0.0
v 1.0 0.0 0.0
v 1.0 1.0 0.0
v 0.0 1.0 0.0

vt 0.0 0.0
vt 1.0 0.0
vt 1.0 1.0
vt 0.0 1.0

vn 0.0 0.0 1.0
vn 0.0 0.0 -1.0

f 1/1/1 2/2/1 3/3/1
f 1//1 4//1 3//1
f 1/1 2/2 4/4
f 1 2 4
";
    parser.parse(objText);

    assert(parser.vertCoords.length == 4);
    assert(parser.vertCoords == [
        Coord3f(),
        Coord3f(1.0),
        Coord3f(1.0, 1.0),
        Coord3f(0.0, 1.0),
    ]);

    assert(parser.texCoords.length == 4);
    assert(parser.texCoords == [
        Coord2f(),
        Coord2f(1.0),
        Coord2f(1.0, 1.0),
        Coord2f(0.0, 1.0),
    ]);

    assert(parser.normalsCoords.length == 2);
    assert(parser.normalsCoords == [
        Coord3f(0.0, 0.0, 1.0),
        Coord3f(0.0, 0.0, -1.0),
    ]);

    assert(parser.uniqueVertices.length > 0, "Should have unique vertices");
    assert(parser.indices.length == 12, format("Expected 12 indices for 4 triangles, got %s", parser
            .indices.length));

    // 1. v/vt/vn: f 1/1/1 2/2/1 3/3/1
    bool foundFullFormat = false;
    foreach (vertex; parser.uniqueVertices)
    {
        // (1.0, 1.0) and normal (0,0,1)
        if (vertex.u == 1.0 && vertex.v == 1.0 &&
            vertex.normals[0] == 0.0 && vertex.normals[1] == 0.0 && vertex.normals[2] == 1.0)
        {
            foundFullFormat = true;
            break;
        }
    }
    assert(foundFullFormat, "Should have vertices from full format v/vt/vn");

    // 2. v//vn: f 1//1 4//1 3//1
    bool foundNoTexture = false;
    foreach (vertex; parser.uniqueVertices)
    {
        // null coords and normal (0,0,1)
        if (vertex.u == 0.0 && vertex.v == 0.0 &&
            vertex.normals[0] == 0.0 && vertex.normals[1] == 0.0 && vertex.normals[2] == 1.0)
        {
            foundNoTexture = true;
            break;
        }
    }
    assert(foundNoTexture, "Should have vertices from format v//vn");

    // 3. v/vt: f 1/1 2/2 4/4
    bool foundNoNormal = false;
    foreach (vertex; parser.uniqueVertices)
    {
        if (vertex.u == 1.0 && vertex.v == 0.0 &&
            vertex.normals[0] == 0.0 && vertex.normals[1] == 0.0 && vertex.normals[2] == 0.0)
        {
            foundNoNormal = true;
            break;
        }
    }
    assert(foundNoNormal, "Should have vertices from format v/vt");

    // 4. v: f 1 2 4
    bool foundVertexOnly = false;
    foreach (vertex; parser.uniqueVertices)
    {
        // vertex (1,0,0)
        if (vertex.x == 1.0 && vertex.y == 0.0 && vertex.z == 0.0 &&
            vertex.normals[0] == 0.0 && vertex.normals[1] == 0.0 && vertex.normals[2] == 0.0 &&
            vertex.u == 0.0 && vertex.v == 0.0)
        {
            foundVertexOnly = true;
            break;
        }
    }
    assert(foundVertexOnly, "Should have vertices from format v only");

    foreach (idx; parser.indices)
    {
        assert(idx < parser.uniqueVertices.length,
            format("Invalid index %s, max is %s", idx, parser.uniqueVertices.length - 1));
    }

    // 4 triangles
    assert(parser.indices.length % 3 == 0, "Indices should form complete triangles");
    assert(parser.indices.length / 3 == 4, "Should have exactly 4 triangles");
}

unittest
{
    import std.format : format;

    auto parser = new ObjLoader;

    auto objText = "
v 0.0 0.0 0.0
v 2.0 0.0 0.0
v 2.0 2.0 0.0
v 0.0 2.0 0.0

vn 0.0 0.0 1.0

f 1//1 2//1 3//1 4//1
";
    parser.parse(objText);

    assert(parser.vertCoords.length == 4);

    assert(parser.indices.length == 6, format("Quad should produce 6 indices, got %s", parser
            .indices.length));
    assert(parser.indices.length / 3 == 2, "Quad should produce 2 triangles");

    //
    // 1-2-3, 1-3-4
    ushort v1 = 0, v2 = 1, v3 = 2, v4 = 3; // vertex indices (0-based)

    // First triangle: 1-2-3
    assert(parser.indices[0] == v1);
    assert(parser.indices[1] == v2);
    assert(parser.indices[2] == v3);

    // Second triangle: 1-3-4
    assert(parser.indices[3] == v1);
    assert(parser.indices[4] == v3);
    assert(parser.indices[5] == v4);
}

unittest
{
    import std.format : format;

    auto parser = new ObjLoader();
    string objText = `
mtllib materials.mtl
v 0.0 0.0 0.0
v 1.0 0.0 0.0
v 1.0 1.0 0.0
v 0.0 1.0 0.0

usemtl RedMaterial
f 1 2 3
f 1 3 4
 
usemtl BlueMaterial
f 1 2 4
`;

    parser.parse(objText);

    assert(parser.mtlLib == "materials.mtl");

    assert(parser.meshes.length == 2, format("Expected 2 meshes, got %s", parser.meshes.length));

    assert(parser.meshes[0].material == "RedMaterial",
        format("Expected mesh 0 material 'RedMaterial', got '%s'", parser.meshes[0].material));
    assert(parser.meshes[0].indexCount == 6,
        format("Expected mesh 0 index count 6, got %s", parser.meshes[0].indexCount));

    assert(parser.meshes[1].material == "BlueMaterial",
        format("Expected mesh 1 material 'BlueMaterial', got '%s'", parser.meshes[1].material));
    assert(parser.meshes[1].indexCount == 3,
        format("Expected mesh 1 index count 3, got %s", parser.meshes[1].indexCount));

    assert(parser.vertCoords.length == 4,
        format("Expected 4 vertices, got %s", parser.vertCoords.length));
    assert(parser.indices.length == 9,
        format("Expected 9 total indices, got %s", parser.indices.length));

    auto mesh1Indices = parser.getMeshIndices(0);
    auto mesh2Indices = parser.getMeshIndices(1);

    assert(mesh1Indices.length == 6,
        format("Expected mesh 1 indices length 6, got %s", mesh1Indices.length));
    assert(mesh2Indices.length == 3,
        format("Expected mesh 2 indices length 3, got %s", mesh2Indices.length));

    assert(parser.meshes[0].indexOffset == 0,
        format("Expected mesh 0 offset 0, got %s", parser.meshes[0].indexOffset));
    assert(parser.meshes[1].indexOffset == 6,
        format("Expected mesh 1 offset 6, got %s", parser.meshes[1].indexOffset));
}
