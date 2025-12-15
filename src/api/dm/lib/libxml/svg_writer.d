module api.dm.lib.libxml.svg_writer;

import api.dm.lib.libxml.native;

import std.string : toStringz, fromStringz;
import std.conv : to;
import std.format : format;

/**
 * Authors: initkfs
 */
class SvgWriter : LibXmlObject
{
    float width = 10;
    float height = 10;
    string color = "#00000";

    bool save(out string result)
    {
        xmlDoc* doc = xmlNewDoc("1.0".toXmlStr);
        if (!doc)
        {
            return false;
        }

        scope (exit)
        {
            xmlFreeDoc(doc);
        }

        xmlNode* root = xmlNewNode(null, "svg".toXmlStr);
        if (!root)
        {
            return false;
        }

        xmlDocSetRootElement(doc, root);

        xmlNewProp(root, "width".toXmlStr, width.to!string.toXmlStr);
        xmlNewProp(root, "height".toXmlStr, height.to!string.toXmlStr);
        xmlNewProp(root, "xmlns".toXmlStr, "http://www.w3.org/2000/svg".toXmlStr);

        //style="background-color: black;"
        xmlNewProp(root, "style".toXmlStr, format("background-color: %s;", color).toXmlStr);

        xmlBuffer* buffer = xmlBufferCreate();
        if (!buffer)
        {
            return false;
        }

        scope (exit)
        {
            xmlBufferFree(buffer);
        }

        xmlSaveCtxt* saveCtx = xmlSaveToBuffer(
            buffer,
            "UTF-8",
            xmlSaveOption.XML_SAVE_FORMAT | xmlSaveOption.XML_SAVE_NO_DECL
        );

        if (!saveCtx)
        {
            return false;
        }

        if (xmlSaveDoc(saveCtx, doc) != 0)
        {
            return false;
        }

        xmlSaveClose(saveCtx);

        xmlChar* content = xmlBufferContent(buffer);
        if (!content)
        {
            return false;
        }

        result = content.fromXmlStr.idup;
        return true;
    }

}

// unittest
// {
//     auto lib = new LibxmlLib;
//     lib.load;

//     auto writer = new SvgWriter;

//     string res;
//     bool isSave = writer.save(res);
//     assert(isSave);
//     assert(
//          res == (`<svg width="10" height="10" xmlns="http://www.w3.org/2000/svg" style="background-color: #00000;"/>` ~ "\n"));
// }
