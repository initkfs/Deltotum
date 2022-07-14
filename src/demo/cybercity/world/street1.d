module demo.cybercity.world.town.street1;

import deltotum.display.bitmap.sprite_sheet : SpriteSheet;
import deltotum.display.bitmap.bitmap : Bitmap;

/**
 * Authors: initkfs
 */
class Street1 : Bitmap
{
    void createEnvironment()
    {
        SpriteSheet banner1 = new SpriteSheet(48, 48, 200);
        build(banner1);
        banner1.load("cybercity/town/objects/banner-neon/banner-neon.png");
        banner1.addAnimation("idle", [0, 1, 2, 3], 0, true);
        banner1.x = 113;
        banner1.y = 137;
        banner1.isDraggable = true;
        add(banner1);

        SpriteSheet monitorFace = new SpriteSheet(21, 21, 200);
        build(monitorFace);
        monitorFace.load("cybercity/town/objects/monitorface/monitor-face.png");
        monitorFace.addAnimation("idle", [0, 1, 2, 3], 0, true);
        monitorFace.x = 380;
        monitorFace.y = 180;
        add(monitorFace);
        monitorFace.isDraggable = true;

        SpriteSheet bannerSushi = new SpriteSheet(36, 36, 200);
        build(bannerSushi);
        bannerSushi.load("cybercity/town/objects/banner-sushi/banner-sushi.png");
        bannerSushi.addAnimation("idle", [0, 1, 2], 0, true);
        bannerSushi.x = 455;
        bannerSushi.y = 250;
        add(bannerSushi);
        bannerSushi.isDraggable = true;

        SpriteSheet bannerSide = new SpriteSheet(76, 76, 200);
        build(bannerSide);
        bannerSide.load("cybercity/town/objects/banner-side/banner-side.png");
        bannerSide.addAnimation("idle", [0, 1, 2, 3], 0, true);
        bannerSide.x = 532;
        bannerSide.y = 232;
        add(bannerSide);
        bannerSide.isDraggable = true;

        SpriteSheet bannerE = new SpriteSheet(38, 38, 200);
        build(bannerE);
        bannerE.load("cybercity/town/objects/banner-e/banner-e.png");
        bannerE.addAnimation("idle", [0, 1, 2, 3], 0, true);
        bannerE.x = 95;
        bannerE.y = 295;
        add(bannerE);
        bannerE.isDraggable = true;

        SpriteSheet bannerD = new SpriteSheet(43, 43, 200);
        build(bannerD);
        bannerD.load("cybercity/town/objects/banner-d/banner-d.png");
        bannerD.addAnimation("idle", [0, 1, 2, 3], 0, true);
        bannerD.x = 459;
        bannerD.y = 75;
        add(bannerD);
        bannerD.isDraggable = true;

        SpriteSheet bannerB = new SpriteSheet(60, 60, 200);
        build(bannerB);
        bannerB.load("cybercity/town/objects/banner-b/banner-b.png");
        bannerB.addAnimation("idle", [0, 1, 2, 3], 0, true);
        bannerB.x = 5;
        bannerB.y = 140;
        add(bannerB);
        bannerB.isDraggable = true;

        SpriteSheet bannerBig = new SpriteSheet(92, 92, 200);
        build(bannerBig);
        bannerBig.load("cybercity/town/objects/banner-big/banner-big.png");
        bannerBig.addAnimation("idle", [0, 1, 2, 3], 0, true);
        bannerBig.x = 345;
        bannerBig.y = 80;
        add(bannerBig);
        bannerBig.isDraggable = true;
    }

    override void create()
    {
        super.create;
        load("cybercity/town/town_foreground.png", window.getWidth, window.getHeight);
        createEnvironment;
    }
}
