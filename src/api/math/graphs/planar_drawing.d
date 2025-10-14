module api.math.graphs.planar_drawing;

import api.math.graphs.vertex : Vertex;
import api.math.graphs.edge : Edge;
import api.math.graphs.graph : Graph;

import api.math.geom2.vec2 : Vec2d;

import Math = api.math;

/**
 * Authors: initkfs
 */

//Fruchterman-Reingold
void fru(Graph g, size_t iterations = 10, double repulsion = 10, double stiffness = 0.5, double damping = 0.2, double gridSize = 100, double gridStrength = 5)
{
    assert(g, "Graph must not be null");

    //O(N² + E)
    foreach (i; 0 .. iterations)
    {
        //O(N²)
        g.onVertex((v, edges) {

            v.force = Vec2d(0, 0);

            g.onVertex((u, edges2) {
                if (u !is v)
                {
                    auto dir = v.pos - u.pos;
                    if (dir.isZero)
                    {
                        dir = Vec2d(1, 1);
                    }
                    auto magnSqr = dir.lengthSquared;

                    double minDistanceSqr = 1;
                    if (magnSqr < minDistanceSqr)
                    {
                        magnSqr = minDistanceSqr;
                    }

                    v.force += dir.normalize.scale(repulsion / magnSqr);
                }
                return true;
            });

            return true;
        });

        g.onVertex((v, edges) {
            v.force = Vec2d(0, 0);
            foreach (Edge e; (*edges)[])
            {
                e.isVisited = false;
            }
            return true;
        });

        //O(E)
        g.onVertex((v, edges) {
            foreach (Edge e; (*edges)[])
            {
                if (e.src is v && !e.isVisited)
                {
                    //double stretch = dir.length - edge.desiredLength;
                    //auto springForce = dir.normalize.scale(stretch * stiffness);
                    auto springForce = (e.dest.pos - e.src.pos).scale(stiffness);
                    e.src.force += springForce;
                    e.dest.force -= springForce;
                    e.isVisited = true;
                }
            }

            return true;
        });

        bool isBreak;

        //O(N)
        g.onVertex(
            (v, edges) {
            auto gridX = Math.round(v.pos.x / gridSize) * gridSize;
            auto gridY = Math.round(v.pos.y / gridSize) * gridSize;
            auto gridTarget = Vec2d(gridX, gridY);

            auto gridForce = (gridTarget - v.pos).scale(gridStrength);
            v.force += gridForce;

            auto newPos = v.force.scale(damping);
            const dt = v.pos - newPos;
            if (dt.length <= 0.001)
            {
                isBreak = true;
                return false;
            }

            v.pos += newPos;
            return true;
        });

        if (isBreak)
        {
            break;
        }
    }
}
