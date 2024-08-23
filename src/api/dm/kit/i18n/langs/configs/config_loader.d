module api.dm.kit.i18n.langs.configs.config_loader;

/**
 * Authors: initkfs
 */
abstract class ConfigLoader
{
    dstring[string][string] load(string configText);
}
