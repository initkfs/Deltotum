module deltotum.core.applications.graphic_application;

import deltotum.core.applications.application_exit: ApplicationExit;
import deltotum.core.applications.cli_application : CliApplication;
import deltotum.toolkit.applications.components.graphics_component : GraphicsComponent;
import deltotum.core.applications.components.uni.uni_component : UniComponent;

/**
 * Authors: initkfs
 */
abstract class GraphicApplication : CliApplication
{
    double frameRate = 60;

    private
    {
        GraphicsComponent _graphicServices;
    }

    abstract
    {
        void runWait();
        bool update();
    }

    override ApplicationExit initialize(string[] args)
    {
        if(auto isExit = super.initialize(args)){
            return isExit;
        }

        _graphicServices = new GraphicsComponent;

        super.build(_graphicServices);
        
        return ApplicationExit();
    }

    override void build(UniComponent component)
    {
        return super.build(component);
    }

    void build(GraphicsComponent component)
    {
        gservices.build(component);
    }

    GraphicsComponent gservices() @nogc nothrow pure @safe
    out (_graphicServices; _graphicServices !is null)
    {
        return _graphicServices;
    }

    void gservices(GraphicsComponent services) pure @safe
    {
        import std.exception : enforce;

        enforce(services !is null, "Graphics services must not be null");
        _graphicServices = services;
    }
}
