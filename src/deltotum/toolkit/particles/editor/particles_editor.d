module deltotum.toolkit.particles.editor.particles_editor;

import deltotum.toolkit.display.display_object : DisplayObject;
import deltotum.toolkit.particles.emitter : Emitter;

import deltotum.toolkit.particles.particle : Particle;
import deltotum.toolkit.graphics.shapes.circle : Circle;
import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.toolkit.graphics.colors.rgba : RGBA;
import deltotum.ui.containers.vbox : VBox;
import deltotum.ui.containers.hbox : HBox;
import deltotum.ui.controls.texts.text : Text;
import deltotum.ui.controls.scrollbars.hscrollbar : HScrollbar;
import deltotum.ui.containers.container : Container;
import deltotum.ui.controls.buttons.button : Button;
import deltotum.toolkit.display.layouts.horizontal_layout : HorizontalLayout;

/**
 * Authors: initkfs
 */
class ParticlesEditor : Container
{
    private
    {
        Emitter emitter;
    }

    this(Emitter emitter)
    {
        this.emitter = emitter;
        layout = new HorizontalLayout;
        backgroundFactory = null;
    }

    override void create()
    {
        super.create;

        auto controlContainer = new VBox(2);
        addCreated(controlContainer);

        import deltotum.ui.controls.buttons.toggle_switch : ToggleSwitch;

        auto controlButtonBox = new HBox(2);
        //FIXME invalid width
        controlButtonBox.width = 180;
        controlContainer.addCreated(controlButtonBox);

        auto runButton = new Button;
        runButton.text = "Emit";
        runButton.onAction = (e) { emitter.isActive = !emitter.isActive; };
        controlButtonBox.addCreated(runButton);

        auto configButton = new Button;
        configButton.text = "JSON";
        configButton.onAction = (e) {
            import std.stdio;

            writeln(emitter.toConfig);
        };
        controlButtonBox.addCreated(configButton);

        auto textCount = new Text("CPF:");
        controlContainer.addCreated(textCount);

        auto cpf = new HScrollbar(5, 3000);
        cpf.onValue = (value) { emitter.countPerFrame = cast(int) value; };
        controlContainer.addCreated(cpf);

        auto textLifeTime = new Text("Life time:");
        controlContainer.addCreated(textLifeTime);

        auto lifetime = new HScrollbar(1, 200);
        lifetime.onValue = (value) { emitter.lifetime = cast(int) value; };
        controlContainer.addCreated(lifetime);

        auto text = new Text("Min velocity X:");
        controlContainer.addCreated(text);

        auto velocityX = new HScrollbar(-100, 100);
        velocityX.onValue = (value) { emitter.minVelocityX = value; };
        controlContainer.addCreated(velocityX);

        auto textVelXMax = new Text("Max velocity X:");
        controlContainer.addCreated(textVelXMax);

        auto velocityXMax = new HScrollbar(-100, 100);
        velocityXMax.onValue = (value) { emitter.maxVelocityX = value; };
        controlContainer.addCreated(velocityXMax);

        auto velYText = new Text("Min velocity Y:");
        controlContainer.addCreated(velYText);

        auto velocityY = new HScrollbar(-1000, 1000);
        velocityY.onValue = (value) { emitter.minVelocityY = value; };
        controlContainer.addCreated(velocityY);

        auto velYTextMax = new Text("Max velocity Y:");
        controlContainer.addCreated(velYTextMax);

        auto velocityYMax = new HScrollbar(-1000, 1000);
        velocityYMax.onValue = (value) { emitter.maxVelocityY = value; };
        controlContainer.addCreated(velocityYMax);

        import deltotum.ui.containers.stack_box : StackBox;

        auto emitterContainer = new StackBox;
        emitterContainer.backgroundFactory = null;
        emitterContainer.width = 400;
        emitterContainer.height = height;
        addCreated(emitterContainer);

        emitter.width = 10;
        emitter.height = 10;
        emitterContainer.addCreated(emitter);

        auto controlContainer2 = new VBox(2);
        addCreated(controlContainer2);

        auto textAccX = new Text("Min acceleration X:");
        controlContainer2.addCreated(textAccX);

        auto accelX = new HScrollbar(-1000, 1000);
        accelX.onValue = (value) { emitter.minAccelerationX = value; };
        controlContainer2.addCreated(accelX);

        auto textAccXMax = new Text("Max acceleration X:");
        controlContainer2.addCreated(textAccXMax);

        auto accelXMax = new HScrollbar(-1000, 1000);
        accelXMax.onValue = (value) { emitter.maxAccelerationX = value; };
        controlContainer2.addCreated(accelXMax);

        auto textAccYMin = new Text("Min acceleration Y:");
        controlContainer2.addCreated(textAccYMin);

        auto accelYMin = new HScrollbar(-1000, 1000);
        accelYMin.onValue = (value) { emitter.minAccelerationY = value; };
        controlContainer2.addCreated(accelYMin);

        auto textAccYMax = new Text("Max acceleration Y:");
        controlContainer2.addCreated(textAccYMax);

        auto accelYMax = new HScrollbar(-1000, 1000);
        accelYMax.onValue = (value) { emitter.maxAccelerationY = value; };
        controlContainer2.addCreated(accelYMax);
    }

    override void destroy()
    {
        super.destroy;
        this.emitter = null;
    }
}
