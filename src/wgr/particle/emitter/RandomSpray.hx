
package wgr.particle.emitter;

import physics.geometry.Vector2D;
import wgr.particle.IParticleEngine;

class RandomSpray implements IParticleEmitter
{

    public var rate:Int;
    public var speed:Float;

    public function new(rate:Int,speed:Float) {
        this.rate = rate;
        this.speed = speed;
    }

    public function update(time:Float, position:Vector2D, engine:IParticleEngine):Void {
        var angle = utils.Random.RandomFloat(0,2*Math.PI);
        var vx = Math.cos(angle) * speed;
        var vy = Math.sin(angle) * speed;
        engine.EmitParticle(position.x,position.y,vx,vy,0,0,800,0.99,true,true,null,4,255,255,255,255);
    }

}