module api.dm.lib.libxml.svg_writer;

import api.dm.lib.libxml.native;

import std.string : toStringz, fromStringz;

/**
 * Authors: initkfs
 */
class SvgWriter
{

    void save(string file)
    {
        xmlDoc* doc = xmlNewDoc("1.0".toXmlStr);

        xmlNode* root = xmlNewNode(null, "svg".toXmlStr);

        xmlDocSetRootElement(doc, root);

        xmlNewProp(root, "width".toXmlStr, "500".toXmlStr);
        xmlNewProp(root, "height".toXmlStr, "400".toXmlStr);
        xmlNewProp(root, "viewBox".toXmlStr, "0 0 500 400".toXmlStr);
        xmlNewProp(root, "xmlns".toXmlStr, "http://www.w3.org/2000/svg".toXmlStr);

        xmlNode * circle = xmlNewChild(root, null, "circle".toXmlStr, null);
        xmlNewProp(circle, "cx".toXmlStr, "100".toXmlStr);
        xmlNewProp(circle, "cy".toXmlStr, "100".toXmlStr);
        xmlNewProp(circle, "r".toXmlStr, "50".toXmlStr);
        xmlNewProp(circle, "fill".toXmlStr, "red".toXmlStr);

        xmlNode* rect = xmlNewChild(root, null, "rect".toXmlStr, null);
        xmlNewProp(rect, "x".toXmlStr, "200".toXmlStr);
        xmlNewProp(rect, "y".toXmlStr, "50".toXmlStr);
        xmlNewProp(rect, "width".toXmlStr, "150".toXmlStr);
        xmlNewProp(rect, "height".toXmlStr, "100".toXmlStr);
        xmlNewProp(rect, "fill".toXmlStr, "blue".toXmlStr);

        xmlSaveCtxt* saveCtx = xmlSaveToFilename(
            file.toStringz,
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

        // if (xmlSaveClose(saveCtx) != 0)
        // {
        //     throw new Exception(getLastError);
        // }

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
