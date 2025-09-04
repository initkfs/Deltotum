module api.subs.ele.circuit;

import api.dm.gui.controls.containers.base.typed_container : TypedContainer;
import api.dm.gui.controls.containers.container : Container;
import api.dm.gui.controls.control : Control;
import api.subs.ele.components;

import api.math.graphs.graph : Graph;
import api.math.geom2.vec2: Vec2d;

import api.subs.ele.components.base_component: BaseComponent;
import api.subs.ele.components.elements.base_element: BaseElement;
import api.subs.ele.components.connects.connector_two_pin: ConnectorTwoPin;

import std.stdio;

import Math = api.math;

/**
 * Authors: initkfs
 */

class Circuit : TypedContainer!BaseComponent
{
    Graph graph;

    protected
    {
        long nextId;
        Vec2d nextPos;
    }

    this()
    {
        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        layout = new ManagedLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        onItemAdd = (item) {
            if (auto vertComp = cast(BaseElement) item)
            {
                graph.addVertex(vertComp.vertex);
                vertComp.vertex.id = nextId;
                nextId++;
                vertComp.pos = pos + nextPos;
                nextPos.x += vertComp.width;
                nextPos.y += vertComp.height;
            }

            if (auto edgeComp = cast(ConnectorTwoPin) item)
            {
                graph.addEdge(edgeComp.edge);
            }
        };

        graph = new Graph;
    }

    void alignComponents()
    {
        foreach (item; items)
        {
            if (auto vertComp = cast(BaseElement) item)
            {
                vertComp.vertex.pos = vertComp.pos;
            }
        }

        import api.math.graphs.planar_drawing : fru;

        auto gridSize = Math.max(10, Math.min(window.width, window.height) / 15);
        //gridSize = lerp(30.0, 50.0, zoomLevel); 
        //gridSize = min(window.width, window.height) / 8; large cells

        fru(graph, 20, 10, 0.5, 1, gridSize);

        foreach (item; items)
        {
            if (auto vertComp = cast(BaseElement) item)
            {
                vertComp.pos = vertComp.vertex.pos;
            }

        }
    }

}
