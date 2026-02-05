module api.dm.kit.assets.svg.svg_parser;

import api.dm.kit.assets.xml.xml_elements : XmlAttr, XmlElement, XmlException;
import api.dm.kit.assets.xml.xml_dom_parser : DomParser;

import api.math.geom2.vec2 : Vec2f;
import std.conv: to;

/**
 * Authors: initkfs
 */

class SvgParser : DomParser
{
    XmlElement parseSvg(string svgContent)
    {
        auto root = parse(svgContent);

        if (root.name != "svg")
        {
            throw new XmlException("Root element must be 'svg' for SVG documents");
        }

        if (!root.hasAttr("xmlns") && !root.hasAttr("xmlns:svg"))
        {
            root.setAttr("xmlns", "http://www.w3.org/2000/svg");
        }

        return root;
    }

    Vec2f dims(XmlElement svgRoot)
    {
        import std.array : split;

        float width = 0;
        float height = 0;

        string viewBox = svgRoot.getAttr("viewBox");
        if (viewBox.length != 0)
        {
            string[] parts = viewBox.split;
            if (parts.length >= 4)
            {
                width = parts[2].to!float;
                height = parts[3].to!float;
                return Vec2f.zero;
            }
        }

        width = svgRoot.getAttrT!float("width");
        height = svgRoot.getAttrT!float("height");

        return Vec2f(width, height);
    }
}

unittest
{

    string simpleSvg = `
        <svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
            <circle id="myCircle" cx="50" cy="50" r="40" fill="red"/>
            <rect x="10" y="10" width="80" height="80" fill="blue"/>
        </svg>
    `;

    auto parser = new SvgParser();
    auto svgDoc = parser.parse(simpleSvg);

    auto circle = svgDoc.elementById("myCircle");
    assert(circle);
    assert(circle.getAttr("fill") == "red");

    auto allCircles = svgDoc.elementsByName("circle");
    assert(allCircles.length == 1);
}
