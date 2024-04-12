module dm.kit.i18n.langs.configs.simple_config_loader;

import dm.kit.i18n.langs.configs.config_loader : ConfigLoader;

/**
 * Authors: initkfs
 */
class SimpleConfigLoader : ConfigLoader
{
    string separator = ",";
    string[] allowedLangs;

    string[string][string] loadFile(string configFile)
    {
        import std.file : exists, readText, isFile;

        if (configFile.length == 0)
        {
            throw new Exception("Config file path is empty");
        }

        if (!configFile.exists || !configFile.isFile)
        {
            throw new Exception("Config file is not a file: " ~ configFile);
        }

        auto configText = configFile.readText;
        return load(configText);
    }

    override string[string][string] load(string configText)
    {

        import std.string : lineSplitter, strip;
        import std.algorithm.iteration : splitter;
        import std.algorithm.searching : canFind;
        import std.array : split;

        typeof(return) messageMap;
        string[] messageKeys;

        size_t lineNumber;
        foreach (nextLine; configText.lineSplitter)
        {
            auto line = nextLine.strip;
            if (line.length == 0)
            {
                continue;
            }

            if (lineNumber == 0)
            {
                foreach (headCol; line.splitter(separator))
                {
                    import std.algorithm.searching : canFind;

                    auto messageKey = headCol.idup;
                    if (messageKeys.canFind(messageKey))
                    {
                        import std.format : format;

                        throw new Exception(format("Message key is duplicated: '%s'", messageKey));
                    }
                    messageKeys ~= messageKey;
                }

                lineNumber++;
                continue;
            }

            auto messageLine = line.strip.split(separator);

            if (messageLine.length != messageKeys.length)
            {
                import std.format : format;

                throw new Exception(format("Invalid line, expected length %d, but received %d: %s", messageKeys.length, messageLine
                        .length, messageLine));
            }

            auto messageBaseKey = messageLine[0];

            if (messageBaseKey !in messageMap)
            {
                messageMap[messageBaseKey] = null;
            }

            foreach (i, message; messageLine)
            {
                auto messageKey = messageKeys[i];
                auto messageValue = message;

                if (messageValue.length == 0)
                {
                    throw new Exception("Message is empty in line: " ~ line.idup);
                }

                import std.string : startsWith, endsWith;

                enum quoteSymbol = "\"";
                if (messageValue.startsWith(quoteSymbol))
                {
                    if (!messageValue.endsWith(quoteSymbol))
                    {
                        throw new Exception("Message without double quotes: " ~ message);
                    }
                    messageValue = messageValue.strip(quoteSymbol);
                }

                if (i != 0 && allowedLangs.length > 0 && !allowedLangs.canFind(messageKey))
                {
                    continue;
                }

                messageMap[messageBaseKey][messageKey] = messageValue;
            }

            lineNumber++;
        }

        return messageMap;
    }
}

unittest
{
    import std.conv : to;

    auto loader = new SimpleConfigLoader;

    auto config = "

key,lang1,lang2,lang3

messageKey,message1,message2,\"message 3\"
messageKey2,message12,message22,\"message 32\"
    ";
    auto messages = loader.load(config);

    assert(messages.length == 2, messages.length.to!string);
    assert(messages["messageKey"]["key"] == "messageKey");
    assert(messages["messageKey"]["lang1"] == "message1");
    assert(messages["messageKey"]["lang2"] == "message2");
    assert(messages["messageKey"]["lang3"] == "message 3");

    assert(messages["messageKey2"]["key"] == "messageKey2");
    assert(messages["messageKey2"]["lang1"] == "message12");
    assert(messages["messageKey2"]["lang2"] == "message22");
    assert(messages["messageKey2"]["lang3"] == "message 32");
}
