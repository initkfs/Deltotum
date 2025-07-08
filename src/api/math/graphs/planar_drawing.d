module api.math.graphs.planar_drawing;

import api.math.graphs.vertex : Vertex;
import api.math.graphs.edge : Edge;
import api.math.graphs.graph : Graph;

import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */

//Fruchterman-Reingold
void fru(Graph g, size_t iterations = 10, double repulsion = 100, double stiffness = 10, double damping = 10)
{
    foreach (i; 0 .. iterations)
    {
        g.onVertex((v, edges) {
            v.force = Vec2d(0, 0);

            g.onVertex((u, edges2) {
                if (u !is v)
                {
                    auto dir = v.pos - u.pos;
                    v.force += dir.normalize.scale(repulsion / dir.magnitudeSquared);
                }
                return true;
            });

            return true;
        });

        g.onVertex((v, edges) {
            foreach (Edge e; (*edges)[])
            {
                if (e.src is v)
                {
                    auto springForce = (e.dest.pos - e.src.pos).scale(stiffness);
                    e.src.force += springForce;
                    e.dest.force -= springForce;
                    break;
                }
            }

            return true;
        });

        g.onVertex(
            (v, edges) { v.pos += v.force.scale(damping); return true; });
    }
}
