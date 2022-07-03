module deltotum.application.graphics_application;

abstract class GraphicsApplication
{

    abstract void initialize(double frameRate);
    abstract void runWait();
    abstract void quit();
    abstract bool update();

}
