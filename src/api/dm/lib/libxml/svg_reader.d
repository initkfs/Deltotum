module api.dm.lib.libxml.svg_reader;

import api.dm.lib.libxml.native;

import std.string : fromStringz, toStringz;
import std.conv : to;
import std.format : format;

/**
 * Authors: initkfs
 */

class SvgReader : LibXmlObject
{
    bool load(string text)
    {
        xmlDoc* docPtr = xmlReadMemory(text.toStringz, cast(int) text.length, null, null, xmlParserOption
                .XML_PARSE_NOERROR | xmlParserOption
                .XML_PARSE_NOWARNING);

        if (!docPtr)
        {
            return false;
        }

        scope (exit)
        {
            xmlFreeDoc(docPtr);
        }

        xmlNode* root = xmlDocGetRootElement(docPtr);
        if (!root)
        {
            return false;
        }

        iterate(root);

        return true;
    }

    void iterate(xmlNode* node, size_t depth = 0)
    {
        xmlNode* current;

        for (current = node; current; current = current.next)
        {
            switch (current.type) with (xmlElementType)
            {
                case XML_ELEMENT_NODE:
                    if (current.properties)
                    {
                        xmlAttr* attr = current.properties;
                        while (attr)
                        {
                            xmlChar* value = xmlNodeListGetString(current.doc,
                                attr.children, 1);
                            if (value)
                            {
                                _xmlFree(value);
                            }
                            attr = attr.next;
                        }
                    }
                    break;

                case XML_TEXT_NODE:
                    if (!xmlIsBlankNode(current))
                    {
                        char* text = cast(char*) xmlNodeGetContent(current);
                        if (text)
                        {
                            _xmlFree(text);
                        }
                    }
                    break;
                case XML_COMMENT_NODE:
                    break;
                case XML_CDATA_SECTION_NODE:
                    //[CDATA] <![CDATA[%s]]> current.content
                    break;
                default:
                    break;
            }

            if (current.children)
            {
                iterate(current.children, depth + 1);
            }
        }
    }
}

// unittest
// {
//     auto lib = new LibxmlLib;
//     lib.load;

//     auto svg = "
// <svg width=\"300\" height=\"130\" xmlns=\"http://www.w3.org/2000/svg\">
// <rect width=\"200\" height=\"100\" x=\"10\" y=\"10\" rx=\"20\" ry=\"20\" fill=\"blue\" /> 
// <node>text</node>
// </svg>
// ";
//     auto parser = new SvgReader;
//     parser.load(svg);
// }
