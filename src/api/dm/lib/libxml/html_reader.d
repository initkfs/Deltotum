module api.dm.lib.libxml.html_reader;

import api.dm.lib.libxml.native;

import std.stdio: writefln, writeln;
import std.string: fromStringz, toStringz;


/**
 * Authors: initkfs
 */

class HtmlReader
{

    void load(string file)
    {

        import std.string : toStringz;
        import std: readText;

        auto htmlText = readText(file);

        xmlDoc* docPtr = htmlReadMemory(htmlText.toStringz, cast(int) htmlText.length, null, null, htmlParserOption.HTML_PARSE_NOERROR | htmlParserOption
                .HTML_PARSE_NOWARNING | htmlParserOption
                .HTML_PARSE_HTML5);

         assert(docPtr);

        xmlNode* root = xmlDocGetRootElement(docPtr);
        assert(root);

        xmlNode* node = root;
        while (node)
        {
            xmlNode* child = xmlFirstElementChild(node);
            while (child)
            {
                const xmlChar* content = xmlNodeGetContent(child);
                if (content)
                {
                    auto name = child.name;
                    writefln("Тег: <%s>, Текст: %s\n", (cast(char*)name).fromStringz, (cast(char*) content)
                            .fromStringz);
                }
                else
                {
                    writeln("Тег: <%s>\n", (cast(char*)child.name).fromStringz);
                }

                child = xmlNextElementSibling(child);
            }

            node = xmlNextElementSibling(node);
        }

        xmlFreeDoc(docPtr);
        xmlCleanupParser();
    }

}
