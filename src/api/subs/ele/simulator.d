module api.subs.ele.simulator;

import api.dm.gui.controls.containers.container : Container;
import api.subs.ele.circuit;
import api.subs.ele.components;

import api.math.graphs.graph;
import api.math.graphs.vertex : Vertex;
import api.math.graphs.edge : Edge;

import api.dm.lib.libxml.native;

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

        auto battery = new VoltageSource(12.0, "V1 12V");
        auto resistor = new Resistor(100, "R1 100");
        auto resistor2 = new Resistor(100, "R2 100");

        auto resistor11 = new Resistor(50, "R11 50");
        auto resistor21 = new Resistor(25, "R22 25");

        circuit.addCreateItem(battery);
        circuit.addCreateItem(resistor);
        circuit.addCreateItem(resistor2);

        circuit.addCreateItem(resistor11);
        circuit.addCreateItem(resistor21);

        auto wire1 = new Wire(battery.p, resistor.p, battery, resistor);
        auto wire2 = new Wire(resistor.n, resistor2.p, resistor, resistor2);

        auto wire21 = new Wire(resistor.p, resistor11.p, resistor, resistor11);
        auto wire31 = new Wire(resistor11.n, resistor21.p, resistor11, resistor21);
        auto wire41 = new Wire(resistor21.n, resistor2.n, resistor21, resistor2);

        auto wire3 = new Wire(resistor2.n, battery.n, resistor2, battery);

        circuit.addCreateItem(wire1);
        circuit.addCreateItem(wire2);

        circuit.addCreateItem(wire21);
        circuit.addCreateItem(wire31);
        circuit.addCreateItem(wire41);

        circuit.addCreateItem(wire3);

        //circuit.onPointerPress ~= (ref e) { circuit.alignComponents; };

        /*foreach (node; nodes) {
        assert(node.pins.map!(p => p.current).sum.approxEqual(0.0));
        }*/
        //assert(abs(GND.pin.currentIn - battery.currentOut) < 1e-9);

        save(null);
    }

    void save(string path)
    {
        import std.string : toStringz;
        import std.conv : to;
        import std.format : format;

        import Math = api.math;

        auto userDir = context.app.userDir;

        xmlDoc* doc = xmlNewDoc("1.0".toXmlStr);

        xmlNode* root = xmlNewNode(null, "svg".toXmlStr);

        xmlDocSetRootElement(doc, root);

        const windowWidth = window.width;
        const windowHeight = window.height;

        xmlNewProp(root, "width".toXmlStr, windowWidth.to!string.toXmlStr);
        xmlNewProp(root, "height".toXmlStr, windowHeight.to!string.toXmlStr);
        xmlNewProp(root, "xmlns".toXmlStr, "http://www.w3.org/2000/svg".toXmlStr);

        foreach (item; circuit.items)
        {
            xmlNode* elemNode;

            if (auto element = cast(Element) item)
            {
                if (auto resistor = cast(Resistor) element)
                {
                    auto svgText = resistor.createSVG;
                    if (svgText.length == 0)
                    {
                        elemNode = xmlNewChild(root, null, "rect".toXmlStr, null);
                    }
                    else
                    {
                        import std.string : toStringz;

                        xmlDoc* drawSvgPtr = xmlReadMemory(
                            svgText.toStringz,
                            cast(int) svgText.length,
                            null,
                            null,
                            xmlParserOption.XML_PARSE_NOERROR | xmlParserOption.XML_PARSE_NOWARNING
                        );

                        scope (exit)
                        {
                            if (drawSvgPtr)
                            {
                                xmlFreeDoc(drawSvgPtr);
                            }
                        }

                        if (drawSvgPtr)
                        {
                            auto rootNode = xmlDocGetRootElement(drawSvgPtr);
                            if (rootNode)
                            {
                                auto firstChild = xmlFirstElementChild(rootNode);
                                //xmlNode* copy = xmlCopyNode(svgRoot, 1); // 1 = deep copy
                                //xmlAddChild(elemNode, copy);
                                if (firstChild)
                                {
                                    elemNode = xmlCopyNode(firstChild, 1);
                                    xmlAddChild(root, elemNode);

                                    //TODO with xmlAttr structure
                                    xmlSetProp(elemNode, "transform".toXmlStr, format("translate(%d, %d)", cast(
                                            int) element.x, cast(int) element.y).toXmlStr);

                                    import api.dm.kit.sprites2d.sprite2d : Sprite2d;

                                    if (auto sprite = cast(Sprite2d) item)
                                    {
                                        const x = sprite.x;
                                        const y = sprite.y;

                                        xmlNewProp(elemNode, "data-x".toXmlStr, x
                                                .to!string.toXmlStr);
                                        xmlNewProp(elemNode, "data-y".toXmlStr, y
                                                .to!string.toXmlStr);
                                    }

                                    if (elemNode)
                                    {
                                        const bounds = element.boundsRect;
                                        xmlNewProp(elemNode, "data-width".toXmlStr, bounds
                                                .width.to!string.toXmlStr);
                                        xmlNewProp(elemNode, "data-height".toXmlStr, bounds
                                                .height.to!string.toXmlStr);
                                    }
                                }
                            }
                        }
                    }

                    xmlNewProp(elemNode, "data-type".toXmlStr, "resistor".toXmlStr);
                    xmlNewProp(elemNode, "data-resistance".toXmlStr, resistor
                            .resistance.to!string.toXmlStr);
                }
            }

            if (!elemNode)
            {
                continue;
            }

        }

        xmlSaveCtxt* saveCtx = xmlSaveToFilename(
            (userDir ~ "/test2.svg").toStringz,
            "UTF-8",
            xmlSaveOption.XML_SAVE_FORMAT | xmlSaveOption.XML_SAVE_NO_DECL
        );

        assert(saveCtx);
        scope (exit)
        {
            xmlSaveClose(saveCtx);
        }

        if (xmlSaveDoc(saveCtx, doc) != 0)
        {
            throw new Exception("Error to saving");
        }

        xmlFreeDoc(doc);
    }

    string getLastError()
    {
        xmlError* errorPtr = xmlGetLastError();
        if (!errorPtr)
        {
            return "Error is empty";
        }

        import std.format : format;
        import std.string : fromStringz;

        return format("File: %s, line: %s. Message: %s", errorPtr.file.fromStringz, errorPtr.line, errorPtr
                .message.fromStringz);
    }

}
