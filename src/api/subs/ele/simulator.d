module api.subs.ele.simulator;

import api.dm.gui.controls.containers.container : Container;
import api.subs.ele.circuit;
import api.subs.ele.components;

import api.math.graphs.graph;
import api.math.graphs.vertex: Vertex;
import api.math.graphs.edge: Edge;

/**
 * Authors: initkfs
 */
class Simulator : Container
{
    Circuit circuit;

    this()
    {
        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        layout = new ManagedLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        circuit = new Circuit;
        addCreate(circuit);
        circuit.toCenter;

        auto battery = new VoltageSource(12.0);
        auto resistor = new Resistor(4.0, "R1");

        auto wire1 = new Wire(battery.p, resistor.p);
        auto wire2 = new Wire(resistor.n, battery.n);

        circuit.addCreate(battery);
        circuit.addCreate(resistor);
        circuit.addCreate(wire1);
        circuit.addCreate(wire2);
    }

}
