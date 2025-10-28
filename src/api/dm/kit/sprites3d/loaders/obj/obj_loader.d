module api.dm.kit.sprites3d.loaders.obj.obj_loader;

import api.dm.com.gpu.com_3d_types : ComVertex;
import std.algorithm.iteration : splitter;
import std.algorithm.searching : startsWith;
import std.algorithm : filter;
import std.array : array;
import std.conv : to;

import std;

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

class ObjLoader
{
    string vertexStart = "v ";
    string normalStart = "vn";
    string faceStart = "f ";
    string texCoordStart = "vt";
    char fieldSeparator = ' ';

    Coord3f[] vertCoords;
    Coord3f[] normalsCoords;
    Coord2f[] texCoords;

    ComVertex[] verts;

    void parse(string text, char lineSep = '\n')
    {
        //TODO reuse
        verts = null;
        normalsCoords = null;
        vertCoords = null;
        texCoords = null;

        foreach (line; text.splitter(lineSep))
        {
            if (line.startsWith(vertexStart))
            {
                Coord3f vertex = parseCoord3d(line[vertexStart.length .. $]);
                vertCoords ~= vertex;
                continue;
            }

            if (line.startsWith(normalStart))
            {
                Coord3f normal = parseCoord3d(line[normalStart.length .. $]);
                normalsCoords ~= normal;
                continue;
            }

            if (line.startsWith(texCoordStart))
            {
                Coord2f texCoord = parseCoord2d(line[texCoordStart.length .. $]);
                texCoords ~= texCoord;
                continue;
            }

            if (line.startsWith(faceStart))
            {
                parseFace(line[faceStart.length .. $]);
                continue;
            }
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

    void triangulate(ComVertex[] polygon)
    {
        if (polygon.length == 3)
        {
            verts ~= polygon;
            return;
        }

        //split 2 triangles
        if (polygon.length == 4)
        {
            //1: v0 -> v1 -> v2
            verts ~= polygon[0];
            verts ~= polygon[1];
            verts ~= polygon[2];

            //2: v0 -> v2 -> v3
            verts ~= polygon[0];
            verts ~= polygon[2];
            verts ~= polygon[3];

            return;
        }

        //(N > 4)
        if (polygon.length > 4)
        {
            for (int i = 1; i < polygon.length - 1; i++)
            {
                verts ~= polygon[0];
                verts ~= polygon[i];
                verts ~= polygon[i + 1];
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

    parser.parse(objText);
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

    assert(parser.verts == [
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

}
