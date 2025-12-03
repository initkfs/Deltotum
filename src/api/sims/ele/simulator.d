module api.sims.ele.simulator;

import api.dm.gui.controls.containers.container : Container;

import api.sims.ele.lib.ngspice.workers.ngspice_worker : NGSpiceWorker;

import api.sims.ele.lib.ngspice;

import api.dm.lib.libxml.native;
import std.string : toStringz;
import core.sync.mutex : Mutex;
import core.sync.condition : Condition;

import api.sims.ele.circuit;
import api.sims.ele.components;

import api.dm.gui.controls.switches.buttons.button : Button;

import api.math.graphs.graph;
import api.math.graphs.vertex : Vertex;
import api.math.graphs.edge : Edge;
import api.math.geom2.vec2 : Vec2d;

import api.dm.lib.libxml.native;

import std.concurrency;

struct NetlistElement
{
    string name;
    string inPin;
    string outPin;
    string value;
}

struct Netlist
{
    NetlistElement[string] elements;

    private
    {
        char** lastPtrs;
    }

    string formatElement(string id, NetlistElement ele)
    {
        import std.format : format;

        return format("%s %s %s %s\n", id, ele.inPin, ele.outPin, ele.value);
    }

    string toString()
    {
        string result = "\n";
        foreach (k, ref v; elements)
        {
            result ~= formatElement(k, v);
        }
        result ~= ".end\n";
        return result;
    }

    char** toPtrString()
    {
        import std.string : toStringz;

        char*[] ptrs;
        //ptrs ~= "spice\n\0".dup.ptr;
        ptrs ~= ".option numdgt=6\n\0".dup.ptr;

        foreach (k, ref v; elements)
        {
            ptrs ~= (formatElement(k, v).dup ~ ['\0']).ptr;
        }

        ptrs ~= ".control\n\0".dup.ptr;
        ptrs ~= ".probe alli\n\0".dup.ptr;
        //ptrs ~= "op\n\0".dup.ptr;
        //ptrs ~= "print i(r1)\n\0".dup.ptr;
        ptrs ~= ".endc\n\0".dup.ptr;

        ptrs ~= ".end\n\0".dup.ptr;
        ptrs ~= null;

        lastPtrs = ptrs.ptr;

        return ptrs.ptr;
    }
}

/**
 * Authors: initkfs
 */
class Simulator : Container
{
    NGSpiceWorker ngWorker;

    Circuit circuit;

    Button loadButton;
    Button saveButton;

    Netlist netlist;

    bool isRunSim;

    this()
    {
        import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;

        layout = new ManagedLayout;
        layout.isAutoResize = true;
    }

    override void create()
    {
        super.create;

        ngWorker = new NGSpiceWorker(logger);
        ngWorker.start;

        static char*[] circuit_netlist = [
            cast(char*) "Simple DC Circuit".ptr,
            cast(char*) "V1 in 0 DC 5".ptr,
            cast(char*) "R1 in 0 1k".ptr,
            cast(char*) ".end".ptr,
            null  // NULL terminator for the array
        ];

        import api.dm.gui.controls.containers.hbox : HBox;

        auto panel = new HBox;

        loadButton = new Button("Load");
        saveButton = new Button("Save");

        circuit = new Circuit;
        addCreate(circuit);
        circuit.toCenter;

        addCreate(panel);
        panel.addCreate([loadButton, saveButton]);

        saveButton.onAction ~= (ref e) {
            auto userDir = context.app.userDir;
            auto file = userDir ~ "/test2.svg";
            save(file);
        };

        loadButton.onAction ~= (ref e) {
            auto userDir = context.app.userDir;
            auto file = userDir ~ "/test2.svg";
            load(file, circuit);
        };

        auto userDir = context.app.userDir;
        auto file = userDir ~ "/test2.svg";
        load(file, circuit);
    }

    void load(string path, Circuit circuit)
    {
        import std.string : toStringz;
        import std.conv : to;
        import std.format : format;

        import Math = api.math;

        import std : readText;

        auto text = readText(path);

        circuit.removeAll;

        xmlDoc* docPtr = xmlReadMemory(text.toStringz, cast(int) text.length, null, null, xmlParserOption
                .XML_PARSE_NOERROR | xmlParserOption
                .XML_PARSE_NOWARNING);

        assert(docPtr);
        scope (exit)
        {
            xmlFreeDoc(docPtr);
        }

        xmlNode* root = xmlDocGetRootElement(docPtr);
        assert(root);

        //TODO remove
        long nextWireId;
        long nextNodeId;

        xmlNode* node = root;
        while (node)
        {
            xmlNode* child = xmlFirstElementChild(node);
            while (child)
            {
                string id;

                auto idAttr = xmlGetProp(child, "data-id".toXmlStr);
                if (idAttr)
                {
                    id = idAttr.fromXmlStr.idup;
                    xmlFreeF(idAttr);
                }

                auto typeAttr = xmlGetProp(child, "data-type".toXmlStr);
                if (!typeAttr)
                {
                    throw new Exception("Not found type: " ~ dump(docPtr, child));
                }

                scope (exit)
                {
                    xmlFreeF(typeAttr);
                }

                import api.dm.kit.sprites2d.sprite2d : Sprite2d;

                BaseComponent spriteNode;

                if (typeAttr)
                {
                    auto type = typeAttr.fromXmlStr;
                    switch (type)
                    {
                        case "resistor":
                            auto resValueAttr = xmlGetProp(child, "data-resistance".toXmlStr);
                            assert(resValueAttr);
                            double resistance = resValueAttr.fromXmlStr.to!double;
                            scope (exit)
                            {
                                xmlFreeF(resValueAttr);
                            }

                            spriteNode = new Resistor(resistance, id);

                            netlist.elements[id] = NetlistElement(id, null, null, resValueAttr
                                    .fromXmlStr.dup);

                            break;
                        case "capacitor":
                            auto valueAttr = xmlGetProp(child, "data-capacitance".toXmlStr);
                            assert(valueAttr);
                            double cap = valueAttr.fromXmlStr.to!double;
                            scope (exit)
                            {
                                xmlFreeF(valueAttr);
                            }

                            spriteNode = new Capacitor(cap, id);

                            netlist.elements[id] = NetlistElement(id, null, null, valueAttr
                                    .fromXmlStr.dup);

                            break;
                        case "voltage-source":
                            auto valueAttr = xmlGetProp(child, "data-voltage".toXmlStr);
                            assert(valueAttr);
                            scope (exit)
                            {
                                xmlFreeF(valueAttr);
                            }

                            double voltage = valueAttr.fromXmlStr.to!double;

                            auto source = new VoltageSource(voltage, id);
                            spriteNode = source;

                            buildInitCreate(source);
                            source.p.id = "in";
                            source.n.id = "0";

                            import std.conv : text;

                            netlist.elements[id] = NetlistElement(id, "in", "0", text("DC ", valueAttr
                                    .fromXmlStr));

                            break;

                        case "wire":
                            auto dataSrcAttr = xmlGetProp(child, "data-src".toXmlStr);
                            assert(dataSrcAttr);
                            scope (exit)
                            {
                                xmlFreeF(dataSrcAttr);
                            }

                            auto srcId = dataSrcAttr.fromXmlStr;
                            BaseTwoPinElement src = cast(BaseTwoPinElement) circuit.findItemUnsafe(
                                srcId);
                            if (!src)
                            {
                                throw new Exception("Source not found for wire: " ~ dump(docPtr, child));
                            }

                            auto dataDstAttr = xmlGetProp(child, "data-dst".toXmlStr);
                            assert(dataDstAttr);
                            scope (exit)
                            {
                                xmlFreeF(dataDstAttr);
                            }

                            auto dstId = dataDstAttr.fromXmlStr;
                            BaseTwoPinElement dst = cast(BaseTwoPinElement) circuit.findItemUnsafe(
                                dstId);
                            if (!dst)
                            {
                                throw new Exception("Dest not found for wire: " ~ dump(docPtr, child));
                            }

                            auto dataPinFromAttr = xmlGetProp(child, "data-pin-from".toXmlStr);
                            assert(dataPinFromAttr);
                            scope (exit)
                            {
                                xmlFreeF(dataPinFromAttr);
                            }

                            auto sourcePinType = dataPinFromAttr.fromXmlStr;

                            auto dataPinToAttr = xmlGetProp(child, "data-pin-to".toXmlStr);
                            assert(dataPinToAttr);
                            scope (exit)
                            {
                                xmlFreeF(dataPinToAttr);
                            }

                            auto destPinType = dataPinToAttr.fromXmlStr;

                            if (sourcePinType == "n" && destPinType == "n")
                            {
                                spriteNode = new WireNN(src, dst);

                                if (src.n.id.length > 0 && dst.n.id.length == 0)
                                {
                                    dst.n.id = src.n.id;
                                }
                            }
                            else if (sourcePinType == "p" && destPinType == "n")
                            {
                                spriteNode = new WirePN(src, dst);

                                if (src.p.id.length == 0)
                                {
                                    import std.conv : text;
                                    import std.uni : toLower;

                                    src.p.id = text(src.id.toLower, "p");
                                }

                                if (dst.n.id.length == 0)
                                {
                                    dst.n.id = src.p.id;
                                }
                            }
                            else if (sourcePinType == "n" && destPinType == "p")
                            {
                                spriteNode = new WireNP(src, dst);

                                if (src.n.id.length == 0)
                                {
                                    import std.conv : text;
                                    import std.uni : toLower;

                                    src.n.id = text(src.id.toLower, "n");
                                }

                                if (dst.p.id.length == 0)
                                {
                                    dst.p.id = src.n.id;
                                }
                            }
                            else if (sourcePinType == "p" && destPinType == "p")
                            {
                                spriteNode = new WirePP(src, dst);

                                if (src.p.id.length > 0 && dst.p.id.length == 0)
                                {
                                    dst.p.id = src.p.id;
                                }
                            }
                            else
                            {
                                import std.format : format;

                                throw new Exception(format("Not supported wire pins: %s, %s", sourcePinType, destPinType));
                            }

                            if (spriteNode.id.length == 0)
                            {
                                import std.conv : text;

                                spriteNode.id = text("wire", nextWireId);
                                nextWireId++;
                            }

                            break;
                        default:
                            break;
                    }
                }

                if (auto comp = cast(BaseElement) spriteNode)
                {
                    auto wValueAttr = xmlGetProp(child, "data-width".toXmlStr);
                    if (wValueAttr)
                    {
                        spriteNode.width = wValueAttr.fromXmlStr.to!double;
                        xmlFreeF(wValueAttr);
                    }

                    auto hValueAttr = xmlGetProp(child, "data-height".toXmlStr);
                    if (hValueAttr)
                    {
                        spriteNode.height = hValueAttr.fromXmlStr.to!double;
                        xmlFreeF(hValueAttr);
                    }
                }

                circuit.addCreateItem(spriteNode);

                if (auto comp = cast(BaseElement) spriteNode)
                {
                    auto xValueAttr = xmlGetProp(child, "data-x".toXmlStr);
                    if (xValueAttr)
                    {
                        spriteNode.x = xValueAttr.fromXmlStr.to!double;
                        xmlFreeF(xValueAttr);
                    }

                    auto yValueAttr = xmlGetProp(child, "data-y".toXmlStr);
                    if (yValueAttr)
                    {
                        spriteNode.y = yValueAttr.fromXmlStr.to!double;
                        xmlFreeF(yValueAttr);
                    }
                }

                child = xmlNextElementSibling(child);
            }

            node = xmlNextElementSibling(node);
        }

        foreach_reverse (ch; circuit.children)
        {
            auto wire = cast(Wire) ch;
            if (!wire)
            {
                continue;
            }

            auto src = wire.src;
            auto dst = wire.dst;

            if (auto pp = cast(WirePP) wire)
            {
                if (dst.p.id.length > 0 && src.p.id.length == 0)
                {
                    src.p.id = dst.p.id;
                }
            }
            else if (auto nn = cast(WireNN) wire)
            {
                if (dst.n.id.length > 0 && src.n.id.length == 0)
                {
                    src.n.id = dst.n.id;
                }
            }
        }

        foreach (ch; circuit.children)
        {
            if (auto wire = cast(ConnectorTwoPin) ch)
            {
                auto src = wire.src;
                auto dst = wire.dst;

                assert(src.p.id.length > 0);
                assert(dst.p.id.length > 0);

                netlist.elements[src.id].inPin = src.p.id;
                netlist.elements[src.id].outPin = src.n.id;

            }
        }
    }

    void runSim()
    {
        logger.trace("Run simulator");

        if (ngWorker.addCircuit(netlist.toPtrString))
        {
            logger.trace("Send netlist to ngspice: ", netlist.toString);
        }
        else
        {
            logger.error("Netlist error: ", netlist.toString);
        }

        ngWorker.addCommand("op");
        ngWorker.addCommand("echo startcalc");
        string command = "print ";
        foreach (ch; circuit.children)
        {
            if (auto ele = cast(BaseElement) ch)
            {
                import std.conv : text;

                assert(ele.id.length > 0);
                command ~= text("i(", ele.id, "), ");
            }
        }

        ngWorker.addCommand(command);

        ngWorker.addCommand("echo endcalc");

        // if (res.isFail)
        // {
        //     logger.error(res);
        // }

    }

    override void update(double dt)
    {
        super.update(dt);

        if (!isRunSim && ngWorker.tryLoad)
        {
            runSim;
            isRunSim = true;
        }

        if (ngWorker.tryIsSimEnd)
        {
            auto res = ngWorker.outBuffer.readSyncAll((elements, rest) @safe {

                import core.memory : pureMalloc, pureFree;

                char[] makeBuffer(size_t size) @trusted
                {
                    char[] buff = (cast(char*) pureMalloc(size))[0 .. size];
                    assert(buff.length > 0);
                    return buff;
                }

                void freeBuffer(void* ptr) @trusted
                {
                    pureFree(ptr);
                }

                import core.memory : pureMalloc, pureFree;

                const size_t size = elements.length + rest.length;
                char[] buff = makeBuffer(size);
                scope (exit)
                {
                    freeBuffer(&buff[0]);
                }

                buff[0 .. elements.length][] = elements;
                buff[elements.length .. size][] = rest;

                import std.string: indexOf;

                string startCalcTag = "startcalc";
                string endCalcTag = "endcalc";

                ptrdiff_t bufferStart = buff.indexOf(startCalcTag);
                assert(bufferStart > 0);

                ptrdiff_t bufferEnd = buff.indexOf(endCalcTag);
                assert(bufferEnd > 0);
                assert(bufferStart < bufferEnd);

                char[] calcBuff = buff[(bufferStart + startCalcTag.length) .. bufferEnd];

                import std.algorithm.iteration: splitter;
                import std.string: strip, startsWith, endsWith;
                import std.range: front;
                import std.conv: to;

                foreach(data; calcBuff.splitter("\n")){
                    if(data.length == 0){
                        continue;
                    }

                    auto keyValue = data.splitter("=");
                    if(keyValue.empty){
                        continue;
                    }

                    auto key = keyValue.front.strip;
                    keyValue.popFront;
                    if(keyValue.empty){
                        continue;
                    }

                    if(key.startsWith("i")){
                        key = key[1..$];
                    }
                    if(key.startsWith("(") && key.endsWith(")")){
                        key = key[1..($ - 1)];
                    }

                    import std.uni: toUpper;
                    key = key.toUpper;

                    double currValue = keyValue.front.strip.to!double;
                    
                    import std;


                    write("|", key, "<>", currValue, "|");
                }
            });

            ngWorker.isSimEnd = false;
        }

    }

    void save(string path)
    {
        import std.string : toStringz;
        import std.conv : to;
        import std.format : format;

        import Math = api.math;

        xmlDoc* doc = xmlNewDoc("1.0".toXmlStr);

        xmlNode* root = xmlNewNode(null, "svg".toXmlStr);

        xmlDocSetRootElement(doc, root);

        const windowWidth = window.width;
        const windowHeight = window.height;

        xmlNewProp(root, "width".toXmlStr, windowWidth.to!string.toXmlStr);
        xmlNewProp(root, "height".toXmlStr, windowHeight.to!string.toXmlStr);
        xmlNewProp(root, "xmlns".toXmlStr, "http://www.w3.org/2000/svg".toXmlStr);

        import std.format : format;

        string colorStr = graphic.screenColor.toWebHex;
        //style="background-color: black;"
        xmlNewProp(root, "style".toXmlStr, format("background-color: %s;", colorStr).toXmlStr);

        foreach (item; circuit.children)
        {
            xmlNode* elemNode;

            if (auto element = cast(BaseElement) item)
            {
                Vec2d translateOffset = Vec2d.zero;
                if (element.content)
                {
                    translateOffset = element.content.pos;
                }

                auto svgText = element.createSVG;
                if (svgText.length > 0)
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

                                xmlSetProp(elemNode, "transform".toXmlStr, format("translate(%d, %d)",
                                        cast(int) translateOffset.x, cast(int) translateOffset
                                        .y)
                                        .toXmlStr);

                            }
                        }
                    }
                }

                if (!elemNode)
                {
                    elemNode = xmlNewChild(root, null, "rect".toXmlStr, null);
                }

                if (auto resistor = cast(Resistor) element)
                {
                    xmlNewProp(elemNode, "data-type".toXmlStr, "resistor".toXmlStr);
                    xmlNewProp(elemNode, "data-resistance".toXmlStr, resistor
                            .resistance.to!string.toXmlStr);
                }
                else if (auto voltageSource = cast(VoltageSource) element)
                {
                    xmlNewProp(elemNode, "data-type".toXmlStr, "voltage-source".toXmlStr);
                    xmlNewProp(elemNode, "data-voltage".toXmlStr, voltageSource
                            .voltage.to!string.toXmlStr);
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
            else if (auto wire = cast(Wire) item)
            {
                elemNode = xmlNewChild(root, null, "line".toXmlStr, null);
                auto src = wire.src;
                auto dst = wire.dst;

                auto x1 = wire.startLine.x;
                auto y1 = wire.startLine.y;

                auto x2 = wire.endLine.x;
                auto y2 = wire.endLine.y;

                xmlNewProp(elemNode, "data-type".toXmlStr, "wire".toXmlStr);

                xmlNewProp(elemNode, "data-src".toXmlStr, src.id.toXmlStr);
                xmlNewProp(elemNode, "data-dst".toXmlStr, dst.id.toXmlStr);

                xmlNewProp(elemNode, "x1".toXmlStr, x1.to!string.toXmlStr);
                xmlNewProp(elemNode, "y1".toXmlStr, y1.to!string.toXmlStr);
                xmlNewProp(elemNode, "x2".toXmlStr, x2.to!string.toXmlStr);
                xmlNewProp(elemNode, "y2".toXmlStr, y2.to!string.toXmlStr);

                xmlNewProp(elemNode, "stroke".toXmlStr, "red".toXmlStr);
                xmlNewProp(elemNode, "stroke-width".toXmlStr, "2".toXmlStr);

                string fromPin, toPin;
                if (cast(WirePP) wire)
                {
                    fromPin = "p";
                    toPin = "p";
                }
                else if (cast(WireNN) wire)
                {
                    fromPin = "n";
                    toPin = "n";
                }
                else if (cast(WirePN) wire)
                {
                    fromPin = "p";
                    toPin = "n";
                }
                else if (cast(WireNP) wire)
                {
                    fromPin = "n";
                    toPin = "p";
                }

                xmlNewProp(elemNode, "data-pin-from".toXmlStr, fromPin.toXmlStr);
                xmlNewProp(elemNode, "data-pin-to".toXmlStr, toPin.toXmlStr);
            }

            if (!elemNode)
            {
                continue;
            }

            import api.dm.kit.sprites2d.sprite2d : Sprite2d;

            if (auto sprite = cast(Sprite2d) item)
            {
                const x = sprite.x;
                const y = sprite.y;

                xmlNewProp(elemNode, "data-x".toXmlStr, x
                        .to!string.toXmlStr);
                xmlNewProp(elemNode, "data-y".toXmlStr, y
                        .to!string.toXmlStr);

                if (sprite.id.length > 0)
                {
                    auto idPropName = "data-id".toXmlStr;
                    xmlNewProp(elemNode, idPropName, sprite.id.toXmlStr);
                }
            }

        }

        xmlSaveCtxt* saveCtx = xmlSaveToFilename(
            (path).toStringz,
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

    string dump(xmlDoc* docPtr, xmlNode* child, int level = 1, int format = 1)
    {
        auto buff = xmlBufferCreate();
        assert(buff);
        scope (exit)
        {
            xmlBufferFree(buff);
        }

        xmlNodeDump(buff, docPtr, child, level, format);

        auto buffStr = xmlBufferContent(buff);
        string nodeXml = !buffStr ? "null" : buffStr.fromXmlStr.idup;
        return nodeXml;
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
