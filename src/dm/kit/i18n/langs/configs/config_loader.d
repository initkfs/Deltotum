module dm.kit.i18n.langs.configs.config_loader;

/**
 * Authors: initkfs
 */
abstract class ConfigLoader
{
    string[string][string] load(string configText);
}
