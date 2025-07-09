module api.subs.ele.simulator;

import api.dm.gui.controls.containers.container : Container;
import api.subs.ele.circuit;
import api.subs.ele.components;

import api.math.graphs.graph;
import api.math.graphs.vertex : Vertex;
import api.math.graphs.edge : Edge;

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
        auto resistor = new Resistor(500.0, "R1");
        auto ground = new Ground;

        circuit.addCreateItem(battery);
        circuit.addCreateItem(resistor);
        circuit.addCreateItem(ground);

        auto wire1 = new Wire(battery.p, resistor.p, battery, resistor);
        auto wire2 = new Wire(resistor.n, ground.p, resistor, ground);
        auto wire3 = new Wire(ground.p, battery.n, ground, battery);

        circuit.addCreateItem(wire1);
        circuit.addCreateItem(wire2);
        circuit.addCreateItem(wire3);

        circuit.onPointerPress ~= (ref e) { circuit.alignComponents; };

        /*foreach (node; nodes) {
        assert(node.pins.map!(p => p.current).sum.approxEqual(0.0));
        }*/
        //assert(abs(GND.pin.currentIn - battery.currentOut) < 1e-9);


    }

}
