module deltotum.kit.graphics.themes.icons.icon_pack;

import deltotum.kit.sprites.images.image : Image;

import std;

private
{
    const iconPack = import("resources/icons.txt");
}

/**
 * Authors: initkfs
 */
class IconPack
{
    private
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
    void load()
    {
        import std.string : splitLines;
        import std.algorithm.searching : startsWith;

        string currentIconName;
        string currentIconContent;
        enum iconPrefix = "icon:";
        foreach (line; iconPack.splitLines)
        {
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
