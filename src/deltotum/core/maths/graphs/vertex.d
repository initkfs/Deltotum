module deltotum.core.maths.graphs.vertex;

import deltotum.core.utils.canonical : Canonical;

/**
 * Authors: initkfs
 */
class Vertex
{
    mixin Canonical;

    string id;

    this(string id)
    {
        this.id = id;
    }
}
