module api.dm.kit.graphics.themes.icons.icon_pack;

import api.dm.kit.sprites.images.image : Image;

/**
 * Authors: initkfs
 */
class IconPack
{
    protected
    {
        string[string] iconData;
    }

    string icon(string iconName)
    {
        if (iconName !in iconData)
        {
            throw new Exception("Not found icon: " ~ iconName);
        }
        string iconContent = iconData[iconName];
        return iconContent;
    }

    //TODO optimizations
    void load(string iconPath)
    {
        import std.stdio: File;
        import std.file : isFile, exists;
        import std.string : splitLines;
        import std.algorithm.searching : startsWith;

        if (!iconPath.exists || !iconPath.isFile)
        {
            throw new Exception("Icon path is not a file: " ~ iconPath);
        }

        string currentIconName;
        string currentIconContent;
        enum iconPrefix = "icon:";
        foreach (lineBuff; File(iconPath).byLine)
        {
            auto line = lineBuff.idup;
            if (line.startsWith(iconPrefix))
            {
                if (currentIconContent)
                {
                    iconData[currentIconName] = currentIconContent;
                    currentIconContent = null;
                }

                currentIconName = line[iconPrefix.length .. $];
                continue;
            }

            if (currentIconName)
            {
                currentIconContent ~= line;
            }
        }
    }
}
