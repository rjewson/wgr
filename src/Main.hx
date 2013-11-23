
package ;

import engine.core.signals.Signal1;
import engine.map.TileMapMap;
import engine.map.tmx.TmxMap;
import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.Element;
import utils.Base64;
import wgr.display.Camera;
import wgr.display.DisplayListIter;
import wgr.display.DisplayObject;
import wgr.display.DisplayObjectContainer;
import wgr.display.Sprite;
import wgr.display.Stage;
import wgr.geom.Matrix3;
import wgr.geom.Point;
import wgr.geom.Rectangle;
import wgr.particle.PointSpriteParticleEngine;
import wgr.renderers.canvas.CanvasDebugView;
import wgr.renderers.webgl.PointSpriteRenderer;
import wgr.renderers.webgl.SpriteRenderer;
import wgr.renderers.webgl.WebGLBatch;
import wgr.renderers.webgl.WebGLRenderer;
import wgr.texture.Texture;
import wgr.renderers.webgl.TileMap;

class Main 
{

	public static function main() {

        function splat(str:String) {
            trace(str);
        }

        var s1 = new Signal1(splat);
        s1.emit("splat");

        var entity = new engine.core.Entity();

        var dog = new game.Dog();
        entity.add(dog);
        var cat = new game.Cat();
        entity.add(cat);

        var p = entity.firstComponent;
        while (p != null) {
            p.onUpdate(16);
            p = p.next;
        }

        var assets = new utils.AssetLoader();

        assets.addEventListener("loaded", function(event){

            var tmxMap = new TmxMap(assets.assets.get("data/testMap.tmx"));
            tmxMap.tilesets[0].set_image(assets.assets.get("data/spelunky-tiles.png"));
            var mapData = engine.map.tmx.TmxLayer.layerToCoordTexture(tmxMap.getLayer("Tile Layer 1"));

            var stage = new Stage();
            var camera = new Camera();
            camera.worldExtentsAABB = new wgr.geom.AABB(0,2000,2000,0);
            stage.addChild(camera);

            var canvasView:CanvasElement = cast(Browser.document.getElementById("view"),CanvasElement);
            var renderer = new WebGLRenderer(stage,camera,canvasView,800,600);

            var debugView:CanvasElement = cast(Browser.document.getElementById("viewDebug"),CanvasElement);
            var debug = new CanvasDebugView(debugView,800,600);

            var tm  = new wgr.texture.TextureManager(renderer.gl);
            var basetexture1up = tm.AddTexture("mushroom",assets.assets.get("data/1up.png"));
            var texture1up = new Texture(basetexture1up,new Rectangle(0,0,256,256));

            var basetexturechar = tm.AddTexture("char",assets.assets.get("data/characters.png"));
            var texturechar1 = new Texture(basetexturechar,new Rectangle(0,0,50,75));

            camera.Resize(renderer.width,renderer.height);

            function createSprite(id:String,x:Float,y:Float,px:Float,py:Float,t:Texture) {
                var s = new Sprite();
                s.id = id;
                s.texture = t;
                s.position.x = x;
                s.position.y = y;
                s.pivot.x = px;
                s.pivot.y = py;
                return s;
            }

            var itemContainer = new DisplayObjectContainer();
            itemContainer.id = "itemContainer";
            camera.addChild(itemContainer);

            //var pengine = new SpriteParticleEngine(2000,60);
            //camera.addChild(pengine.canvas);
            var shrooms = false;
            var spr1 = createSprite("spr1",128,128,128,128,texture1up);
            spr1.alpha=1;
            if (shrooms) itemContainer.addChild(spr1);

            var spr2 = createSprite("spr2",228,228,128,128,texture1up);
            if (shrooms) itemContainer.addChild(spr2);

            var spr21 = createSprite("spr21",328,328,128,128,texture1up);
            spr21.alpha = 0.9;
            if (shrooms) spr2.addChild(spr21);

            var spr3 = createSprite("character",400,380,0,0,texturechar1);
            spr3.scale.x = -1;
            itemContainer.addChild(spr3);

            var sprArray = new Array<Sprite>();
            var xpos = 0, ypos = 0;
            for (i in 0...100) {
                var newSpr = new Sprite();
                newSpr.id="newSpr"+i;
                newSpr.texture = texturechar1;
                xpos++;
                if (xpos>99) {
                    xpos=0;
                    ypos++;
                }
                newSpr.position.x = 100 + xpos*20;
                newSpr.position.y = 100 + ypos*20;
                newSpr.pivot.x = 50/2;
                newSpr.pivot.y = 75/2;
                itemContainer.addChild(newSpr);
                sprArray.push(newSpr);
            }

            //itemContainer.debug();

            // var itr = new DisplayListIter(stage);
            // for (item in itr) {
            //     trace(item.id);
            // }

            var tileMap = new TileMap();
            renderer.AddRenderer(tileMap);
            tileMap.SetSpriteSheet(assets.assets.get("data/spelunky-tiles.png"));
            //tileMap.SetTileLayer(assets.assets[2],"base",1,1);
            tileMap.SetTileLayerFromData(mapData,"base",1,1);
            tileMap.SetTileLayer(assets.assets.get("data/spelunky1.png"),"bg",0.6,0.6);
            tileMap.tileSize = 16;
            tileMap.TileScale(2);

            var spriteRender = new SpriteRenderer();
            spriteRender.AddStage(stage);
            renderer.AddRenderer(spriteRender);

            var pointParticleEngine = new PointSpriteParticleEngine(3000,1000/60);
            pointParticleEngine.renderer.SetSpriteSheet(tileMap.spriteSheet,16,8,8);
            renderer.AddRenderer(pointParticleEngine.renderer);

            var startTime = Date.now().getTime();
            var stop = false;
            var debugSwitch = false;

            var gameLoop = new engine.GameLoop();
            var cameraX = 300, cameraY = 300 , cameraDelta = 6;
            function tick() {
                spr1.rotation += 0.01;
                spr2.rotation -= 0.02;
                spr21.rotation += 0.04;

                for (spr in sprArray) {
                    spr.rotation+=0.04;
                    //spr.alpha+=0.001;
                    //if(spr.alpha>1)spr.alpha=0;
                }

                // for (pCount in 0...100) {
                //     var vX = Std.random(600)-300;
                //     var vY = Std.random(600)-300;
                //     var ttl = Std.random(3000)+500;
                //     var type = 2;//validTiles[Std.random(validTiles.length)];
                //     pointParticleEngine.EmitParticle(400,300,vX,vY,0,0,ttl,0.99,true,true,null,type,32,0xFFFFFFFF);                    
                //     //pointParticleEngine.EmitParticle(400,300,vX,vY,0,0,ttl,0.99,true,true,null,type,8,0xFFFFFFFF);                    

                // }
                // pointParticleEngine.Update();

                // var elapsed = Date.now().getTime() - startTime;
                // var xp = (Math.sin(elapsed / 2000) * 0.5 + 0.5) * 528;
                // var yp = (Math.sin(elapsed / 5000) * 0.5 + 0.5) * 570;
                // //xp =yp =0; //Remove camera
                // camera.Focus(xp,yp);
                // renderer.Render(camera.viewPortAABB);
                camera.Focus(spr3.position.x,spr3.position.y);
                renderer.Render(camera.viewPortAABB);

                if (debugSwitch) {
                    debug.Clear(camera);
                    debug.DrawAABB(spr1.subTreeAABB);
                    debug.DrawAABB(spr2.subTreeAABB);                    
                }

                if (gameLoop.keyboard.Pressed(65)) {
                    spr3.position.x-=cameraDelta;
                }
                if (gameLoop.keyboard.Pressed(68)) {
                    spr3.position.x+=cameraDelta;
                }
                if (gameLoop.keyboard.Pressed(87)) {
                    spr3.position.y-=cameraDelta;
                }
                if (gameLoop.keyboard.Pressed(83)) {
                    spr3.position.y+=cameraDelta;
                }
            }

            gameLoop.updateFunc = tick;
            gameLoop.start();

            Browser.document.getElementById("stopbutton").addEventListener("click",function(event){
                gameLoop.stop();
            });
            Browser.document.getElementById("startbutton").addEventListener("click",function(event){
                gameLoop.start();
            });
            Browser.document.getElementById("debugbutton").addEventListener("click",function(event){
                debugSwitch = !debugSwitch;
                debug.Clear(camera);
            });
            Browser.document.getElementById("action1").addEventListener("click",function(event){
                var child = itemContainer.removeChildAt(3);
                itemContainer.addChildAt(child,4);
            });
            Browser.document.getElementById("action2").addEventListener("click",function(event){
                spr2.visible = !spr2.visible;
            });


        } );

        assets.SetImagesToLoad( ["data/testMap.tmx","data/1up.png","data/spelunky-tiles.png","data/spelunky0.png","data/spelunky1.png","data/characters.png"] );
        assets.Load();
        // var pengine = new physics.PhysicsEngine(60,60,new physics.collision.narrowphase.sat.SAT());
        //var pengine = new physics.collision.broadphase.managedgrid.ManagedGrid(60,60,new physics.collision.narrowphase.sat.SAT(),16,16,16);

        // var m = physics.dynamics.Material.DEFAULTMATERIAL();

    }	
    
}