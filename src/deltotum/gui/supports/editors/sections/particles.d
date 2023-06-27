module deltotum.gui.supports.editors.sections.particles;

import deltotum.gui.controls.control : Control;
import deltotum.phys.collision.newtonian_resolver : NewtonianResolver;
import deltotum.kit.graphics.shapes.rectangle : Rectangle;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.graphics.shapes.circle : Circle;
import deltotum.math.vector2d : Vector2d;
import deltotum.phys.collision.newtonian_resolver : NewtonianResolver;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.phys.particles.emitter : Emitter;

import deltotum.phys.particles.particle : Particle;
import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.gui.containers.vbox : VBox;
import deltotum.gui.containers.hbox : HBox;
import deltotum.gui.controls.texts.text : Text;
import deltotum.gui.controls.scrollbars.hscrollbar : HScrollbar;
import deltotum.gui.containers.container : Container;
import deltotum.gui.controls.buttons.button : Button;
import deltotum.kit.sprites.layouts.horizontal_layout : HorizontalLayout;

import Math = deltotum.math;

import std.stdio;

/**
 * Authors: initkfs
 */
class Particles : Control
{
    this()
    {
        import deltotum.kit.sprites.layouts.horizontal_layout : HorizontalLayout;

        layout = new HorizontalLayout(5);
        layout.isAutoResize = false;
        //isBackground = false;
        // layout.isAlignY = false;
    }

    NewtonianResolver collisionDetector;
    Emitter emitter;

    override void create()
    {
        super.create;

        collisionDetector = new NewtonianResolver;

        import deltotum.phys.particles.emitter : Emitter;

        auto emitter = new Emitter(false);
        emitter.x = window.width / 2;
        emitter.y = window.height / 2;

        addCreate(emitter);

        emitter.particleFactory = () {
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

            auto p = new Particle;
           // p.isPhysicsEnabled = true;
            p.mass = 10;
            p.width = 10;
            p.height = 10;

            build(p);

            auto pPart = new Circle(5, GraphicStyle(1, RGBA.red, true, RGBA.green));

            p.addCreate(pPart);

            //spriteForCollisions ~= p;
            return p;
        };

        // onCollision = (p1, p2){
        //     collisionDetector.resolve(p1, p2);
        // };

        auto controlContainer = new VBox(2);
        addCreate(controlContainer);

        import deltotum.gui.controls.buttons.toggle_switch : ToggleSwitch;

        auto controlButtonBox = new HBox(2);
        //FIXME invalid width
        controlButtonBox.width = 180;
        controlContainer.addCreate(controlButtonBox);

        auto runButton = new Button;
        runButton.text = "Emit";
        runButton.onAction = (e) { emitter.isActive = !emitter.isActive; };
        controlButtonBox.addCreate(runButton);

        auto configButton = new Button;
        configButton.text = "JSON";
        configButton.onAction = (e) {
            import std.stdio;

            writeln(emitter.toConfig);
        };
        controlButtonBox.addCreate(configButton);

        auto textCount = new Text("CPF:");
        controlContainer.addCreate(textCount);

        auto cpf = new HScrollbar(5, 3000);
        cpf.onValue = (value) { emitter.countPerFrame = cast(int) value; };
        controlContainer.addCreate(cpf);

        auto textLifeTime = new Text("Life time:");
        controlContainer.addCreate(textLifeTime);

        auto lifetime = new HScrollbar(1, 200);
        lifetime.onValue = (value) { emitter.lifetime = cast(int) value; };
        controlContainer.addCreate(lifetime);

        auto text = new Text("Min velocity X:");
        controlContainer.addCreate(text);

        auto velocityX = new HScrollbar(-100, 100);
        velocityX.onValue = (value) { emitter.minVelocityX = value; };
        controlContainer.addCreate(velocityX);

        auto textVelXMax = new Text("Max velocity X:");
        controlContainer.addCreate(textVelXMax);

        auto velocityXMax = new HScrollbar(-100, 100);
        velocityXMax.onValue = (value) { emitter.maxVelocityX = value; };
        controlContainer.addCreate(velocityXMax);

        auto velYText = new Text("Min velocity Y:");
        controlContainer.addCreate(velYText);

        auto velocityY = new HScrollbar(-1000, 1000);
        velocityY.onValue = (value) { emitter.minVelocityY = value; };
        controlContainer.addCreate(velocityY);

        auto velYTextMax = new Text("Max velocity Y:");
        controlContainer.addCreate(velYTextMax);

        auto velocityYMax = new HScrollbar(-1000, 1000);
        velocityYMax.onValue = (value) { emitter.maxVelocityY = value; };
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

        auto accelX = new HScrollbar(-1000, 1000);
        accelX.onValue = (value) { emitter.minAccelerationX = value; };
        controlContainer2.addCreate(accelX);

        auto textAccXMax = new Text("Max acceleration X:");
        controlContainer2.addCreate(textAccXMax);

        auto accelXMax = new HScrollbar(-1000, 1000);
        accelXMax.onValue = (value) { emitter.maxAccelerationX = value; };
        controlContainer2.addCreate(accelXMax);

        auto textAccYMin = new Text("Min acceleration Y:");
        controlContainer2.addCreate(textAccYMin);

        auto accelYMin = new HScrollbar(-1000, 1000);
        accelYMin.onValue = (value) { emitter.minAccelerationY = value; };
        controlContainer2.addCreate(accelYMin);

        auto textAccYMax = new Text("Max acceleration Y:");
        controlContainer2.addCreate(textAccYMax);

        auto accelYMax = new HScrollbar(-1000, 1000);
        accelYMax.onValue = (value) { emitter.maxAccelerationY = value; };
        controlContainer2.addCreate(accelYMax);

    }
}
