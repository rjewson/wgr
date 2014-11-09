
package wgr.texture;

import js.html.Float32Array;
import js.html.webgl.RenderingContext;
import js.html.webgl.Texture;
import wgr.geom.Point;
import wgr.geom.Rectangle;
import wgr.texture.BaseTexture;

class Texture 
{
    public var baseTexture:BaseTexture;
    public var frame:Rectangle;
    public var trim:Point;
    public var pivot:Point;
    public var noFrame:Bool;
    public var uvs:Float32Array;

    public function new(baseTexture:BaseTexture,frame:Rectangle,pivot:Point = null) {
        noFrame = false;
        this.baseTexture = baseTexture;

        if (frame==null) {
            noFrame = true;
            this.frame = new Rectangle(0,0,1,1);
        } else {
            this.frame = frame;
        }
        this.trim = new Point();
        this.pivot = pivot==null ? new Point() : pivot;
        this.uvs = new Float32Array(8);
        updateUVS();
    }

    public function updateUVS() {

        var tw = baseTexture.width;
        var th = baseTexture.height;

        uvs[0] = frame.x / tw;
        uvs[1] = frame.y / th;

        uvs[2] = (frame.x + frame.width) / tw;
        uvs[3] = frame.y / th;

        uvs[4] = (frame.x + frame.width) / tw;
        uvs[5] = (frame.y + frame.height) / th;

        uvs[6] = frame.x / tw;
        uvs[7] = (frame.y + frame.height) / th;
    }

}