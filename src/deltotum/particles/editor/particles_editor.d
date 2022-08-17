module deltotum.particles.editor.particles_editor;

import deltotum.display.display_object : DisplayObject;
import deltotum.particles.emitter : Emitter;

import deltotum.particles.particle : Particle;
import deltotum.graphics.shapes.circle : Circle;
import deltotum.graphics.styles.graphic_style : GraphicStyle;
import deltotum.graphics.colors.color : Color;
import deltotum.ui.containers.vbox : VBox;
import deltotum.ui.controls.text : Text;
import deltotum.ui.controls.slider : Slider;
import deltotum.ui.controls.button: Button;

/**
 * Authors: initkfs
 */
class ParticlesEditor : DisplayObject
{
    private
    {
        Emitter emitter;
    }

    this(Emitter emitter)
    {
        this.emitter = emitter;
        isManaged = false;
    }

    override void create()
    {
        super.create;

        auto controlContainer = new VBox(0);
        controlContainer.isManaged = false;
        controlContainer.width = window.getWidth;
        controlContainer.height = window.getHeight;
        controlContainer.x = 10;
        build(controlContainer);

        auto configButton = new Button(100, 40, "Config");
        configButton.onAction = (e){
            import std.stdio;
            writefln("Config. cpf: %s, lf: %s, minVX: %s, maxVX: %s, minVY: %s, maxVY:%s\n", emitter.countPerFrame, emitter.lifetime, emitter.minVelocityX, emitter.maxVelocityX, emitter.minVelocityY, emitter.maxVelocityY);
        };
        controlContainer.addCreated(configButton);

        auto textCount = new Text("CPF:");
        controlContainer.addCreated(textCount);

        auto cpf = new Slider(5, 1000);
        cpf.onValue = (value) { emitter.countPerFrame = cast(int) value; };
        controlContainer.addCreated(cpf);

        auto textLifeTime = new Text("Life time:");
        controlContainer.addCreated(textLifeTime);

        auto lifetime = new Slider(1, 200);
        lifetime.onValue = (value) { emitter.lifetime = cast(int) value; };
        controlContainer.addCreated(lifetime);

        auto text = new Text("Min velocity X:");
        controlContainer.addCreated(text);

        auto velocityX = new Slider(-100, 100);
        velocityX.onValue = (value) { emitter.minVelocityX = value; };
        controlContainer.addCreated(velocityX);

        auto textVelXMax = new Text("Max velocity X:");
        controlContainer.addCreated(textVelXMax);

        auto velocityXMax = new Slider(-100, 100);
        velocityXMax.onValue = (value) { emitter.maxVelocityX = value; };
        controlContainer.addCreated(velocityXMax);

        auto velYText = new Text("Min velocity Y:");
        controlContainer.addCreated(velYText);

        auto velocityY = new Slider(-1000, 1000);
        velocityY.onValue = (value) { emitter.minVelocityY = value; };
        controlContainer.addCreated(velocityY);

        auto velYTextMax = new Text("Max velocity Y:");
        controlContainer.addCreated(velYTextMax);

        auto velocityYMax = new Slider(-1000, 1000);
        velocityYMax.onValue = (value) { emitter.maxVelocityY = value; };
        controlContainer.addCreated(velocityYMax);

        controlContainer.create;
        add(controlContainer);

        auto controlContainer2 = new VBox(0);
        controlContainer2.isManaged = false;
        //TODO padding
        controlContainer2.x = window.getWidth - 130;
        controlContainer2.width = window.getWidth;
        controlContainer2.height = window.getHeight;
        build(controlContainer2);

        auto textAccX = new Text("Min acceleration X:");
        controlContainer2.addCreated(textAccX);

        auto accelX = new Slider(-1000, 1000);
        accelX.onValue = (value) { emitter.minAccelerationX = value; };
        controlContainer2.addCreated(accelX);

        auto textAccXMax = new Text("Max acceleration X:");
        controlContainer2.addCreated(textAccXMax);

        auto accelXMax = new Slider(-1000, 1000);
        accelXMax.onValue = (value) { emitter.maxAccelerationX = value; };
        controlContainer2.addCreated(accelXMax);

        auto textAccYMin = new Text("Min acceleration Y:");
        controlContainer2.addCreated(textAccYMin);

        auto accelYMin = new Slider(-1000, 1000);
        accelYMin.onValue = (value) { emitter.minAccelerationY = value; };
        controlContainer2.addCreated(accelYMin);

        auto textAccYMax = new Text("Max acceleration Y:");
        controlContainer2.addCreated(textAccYMax);

        auto accelYMax = new Slider(-1000, 1000);
        accelYMax.onValue = (value) { emitter.maxAccelerationY = value; };
        controlContainer2.addCreated(accelYMax);

        controlContainer2.create;
        add(controlContainer2);
    }

    override void destroy()
    {
        super.destroy;
        this.emitter = null;
    }
}
