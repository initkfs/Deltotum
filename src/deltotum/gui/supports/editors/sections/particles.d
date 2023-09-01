module deltotum.gui.supports.editors.sections.particles;

import deltotum.gui.controls.control : Control;
import deltotum.phys.collision.newtonian_resolver : NewtonianResolver;
import deltotum.kit.graphics.shapes.rectangle : Rectangle;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.graphics.shapes.circle : Circle;
import deltotum.math.vector2d : Vector2d;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.phys.particles.emitter : Emitter;

import deltotum.phys.particles.particle : Particle;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.gui.containers.vbox : VBox;
import deltotum.gui.containers.hbox : HBox;
import deltotum.gui.controls.texts.text : Text;
import deltotum.gui.controls.sliders.hslider : HSlider;
import deltotum.gui.containers.container : Container;
import deltotum.gui.controls.buttons.button : Button;
import deltotum.kit.sprites.layouts.hlayout : HLayout;

import Math = deltotum.math;

import std.stdio;

/**
 * Authors: initkfs
 */
class Particles : Control
{
    this()
    {
        import deltotum.kit.sprites.layouts.hlayout : HLayout;

        layout = new HLayout(5);
        layout.isAutoResize = false;
        //isBackground = false;
        // layout.isAlignY = false;
    }

    Emitter emitter;

    override void initialize()
    {
        super.initialize;
        enablePadding;
    }

    override void create()
    {
        super.create;

        import deltotum.phys.particles.emitter : Emitter;

        auto emitter = new Emitter(false);
        emitter.x = window.width / 2;
        emitter.y = window.height / 2;
        emitter.isDrawBounds = true;

        addCreate(emitter);

        emitter.particleFactory = () {
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

            auto p = new Particle;
            p.mass = 10;
            p.width = 20;
            p.height = 20;

            p.isVisible = false;
            p.isUpdatable = false;

            build(p);

            auto pPart = new Circle(10, GraphicStyle(1, RGBA.red, true, RGBA.green));
            p.addCreate(pPart);

            //spriteForCollisions ~= p;
            return p;
        };

        auto controlContainer = new VBox(2);
        addCreate(controlContainer);

        import deltotum.gui.controls.choices.toggle_switch : ToggleSwitch;

        auto controlButtonBox = new HBox(2);
        //FIXME invalid width
        controlButtonBox.width = 180;
        controlContainer.addCreate(controlButtonBox);

        auto runButton = new Button;
        runButton.text = "Emit";
        runButton.onAction = (ref e) {
            //emitter.emit;
            emitter.isActive = !emitter.isActive;
        };
        controlButtonBox.addCreate(runButton);

        auto configButton = new Button;
        configButton.text = "JSON";
        configButton.onAction = (ref e) {
            import std.stdio;

            writeln(emitter.toConfig);
        };
        controlButtonBox.addCreate(configButton);

        auto textCount = new Text("CPF:");
        controlContainer.addCreate(textCount);

        auto cpf = new HSlider(10, 3000);
        cpf.onValue = (value) { emitter.countPerFrame = cast(int) value; };
        controlContainer.addCreate(cpf);

        auto textLifeTime = new Text("Life time:");
        controlContainer.addCreate(textLifeTime);

        auto lifetime = new HSlider(10, 1000);
        lifetime.onValue = (value) { emitter.lifetime = cast(int) value; };
        controlContainer.addCreate(lifetime);

        auto text = new Text("Min velocity X:");
        controlContainer.addCreate(text);

        auto velocityX = new HSlider(-100, 100);
        velocityX.onValue = (value) { emitter.minVelocity.x = value; };
        controlContainer.addCreate(velocityX);

        auto textVelXMax = new Text("Max velocity X:");
        controlContainer.addCreate(textVelXMax);

        auto velocityXMax = new HSlider(-100, 100);
        velocityXMax.onValue = (value) { emitter.maxVelocity.x = value; };
        controlContainer.addCreate(velocityXMax);

        auto velYText = new Text("Min velocity Y:");
        controlContainer.addCreate(velYText);

        auto velocityY = new HSlider(-100, 100);
        velocityY.onValue = (value) { emitter.minVelocity.y = value; };
        controlContainer.addCreate(velocityY);

        auto velYTextMax = new Text("Max velocity Y:");
        controlContainer.addCreate(velYTextMax);

        auto velocityYMax = new HSlider(-100, 100);
        velocityYMax.onValue = (value) { emitter.maxVelocity.y = value; };
        controlContainer.addCreate(velocityYMax);

        import deltotum.gui.containers.stack_box : StackBox;

        auto emitterContainer = new StackBox;
        emitterContainer.backgroundFactory = null;
        emitterContainer.width = 400;
        emitterContainer.height = height;
        addCreate(emitterContainer);

        emitter.width = 10;
        emitter.height = 10;
        emitterContainer.addCreate(emitter);

        auto controlContainer2 = new VBox(2);
        addCreate(controlContainer2);

        auto textAccX = new Text("Min acceleration X:");
        controlContainer2.addCreate(textAccX);

        auto accelX = new HSlider(-100, 100);
        accelX.onValue = (value) { emitter.minAcceleration.x = value; };
        controlContainer2.addCreate(accelX);

        auto textAccXMax = new Text("Max acceleration X:");
        controlContainer2.addCreate(textAccXMax);

        auto accelXMax = new HSlider(-100, 100);
        accelXMax.onValue = (value) { emitter.maxAcceleration.x = value; };
        controlContainer2.addCreate(accelXMax);

        auto textAccYMin = new Text("Min acceleration Y:");
        controlContainer2.addCreate(textAccYMin);

        auto accelYMin = new HSlider(-100, 100);
        accelYMin.onValue = (value) { emitter.minAcceleration.y = value; };
        controlContainer2.addCreate(accelYMin);

        auto textAccYMax = new Text("Max acceleration Y:");
        controlContainer2.addCreate(textAccYMax);

        auto accelYMax = new HSlider(-100, 100);
        accelYMax.onValue = (value) { emitter.maxAcceleration.y = value; };
        controlContainer2.addCreate(accelYMax);

    }
}
