
package wgr.renderers.webgl;

import js.html.ArrayBuffer;
import js.html.Float32Array;
import js.html.Uint8ClampedArray;
import js.html.webgl.Buffer;
import js.html.webgl.RenderingContext;
import js.html.webgl.Texture;
import wgr.display.Camera;
import wgr.display.Stage;
import wgr.geom.Point;
import wgr.geom.AABB;
import wgr.renderers.webgl.ShaderWrapper;

class PointSpriteLightMapRenderer implements IRenderer
{

    public var gl:RenderingContext;

    public var projection:Point;

    public var pointSpriteShader:ShaderWrapper;
    
    public var dataBuffer:Buffer;
    private var arrayBuffer:ArrayBuffer;
    public var data:Float32Array;
    public var data8:Uint8ClampedArray;

    public var stage:Stage;
    public var camera:Camera;
    public var texture:Texture;

    public var indexRun:Int;

    public function new() {
    }

    public function Init(gl:RenderingContext,camera:Camera) {
        this.gl = gl;
        this.camera = camera;
        projection = new Point();
        pointSpriteShader = new ShaderWrapper(gl, WebGLShaders.CompileProgram(gl,SPRITE_VERTEX_SHADER,SPRITE_FRAGMENT_SHADER));
        dataBuffer =  gl.createBuffer();
    }

    public function ResizeBatch(size:Int) {
        arrayBuffer = new ArrayBuffer(20*4*size);
        data = new Float32Array(arrayBuffer);
        data8 = new Uint8ClampedArray(arrayBuffer);
        ResetBatch();
    }

    public function Resize(width:Int,height:Int) {
        projection.x = width/2;
        projection.y = height/2;
    }

    public function AddStage(stage:Stage) {
        this.stage = stage;
    }

    public function ResetBatch() {
        indexRun=0;
    }

    public function AddSpriteToBatch(x:Float,y:Float,size:Int,alpha:Int,red:Int,green:Int,blue:Int) {
        var index = indexRun * 4;
        data[index+0] = Std.int(x + camera.position.x);
        data[index+1] = Std.int(y + camera.position.y);   
        data[index+2] = size;
        index *= 4;
        data8[index+12] = red;
        data8[index+13] = blue;
        data8[index+14] = green;
        data8[index+15] = alpha;
        indexRun++;
    }

    public function Render(clip:AABB) {
        gl.enable(RenderingContext.BLEND);
        gl.blendFunc(RenderingContext.SRC_ALPHA, RenderingContext.ONE_MINUS_SRC_ALPHA);

        gl.useProgram(pointSpriteShader.program);
        gl.bindBuffer(RenderingContext.ARRAY_BUFFER,dataBuffer);
        gl.bufferData(RenderingContext.ARRAY_BUFFER,data,RenderingContext.DYNAMIC_DRAW);    

        gl.enableVertexAttribArray(untyped pointSpriteShader.attribute.position);
        gl.enableVertexAttribArray(untyped pointSpriteShader.attribute.size);
        gl.enableVertexAttribArray(untyped pointSpriteShader.attribute.colour);

        gl.vertexAttribPointer(untyped pointSpriteShader.attribute.position, 2, RenderingContext.FLOAT, false, 16, 0);
        gl.vertexAttribPointer(untyped pointSpriteShader.attribute.size, 1, RenderingContext.FLOAT, false, 16, 8);        
        gl.vertexAttribPointer(untyped pointSpriteShader.attribute.colour, 4, RenderingContext.UNSIGNED_BYTE, true, 16, 12);

        gl.uniform2f(untyped pointSpriteShader.uniform.projectionVector,projection.x,projection.y);

        gl.drawArrays(RenderingContext.POINTS,0,indexRun);
    }

    public static var SPRITE_VERTEX_SHADER:Array<String> = [
        "precision mediump float;",
        "uniform vec2 projectionVector;",

        "attribute vec2 position;",
        "attribute float size;",
        "attribute vec4 colour;",
        "varying vec4 vColor;",
        "void main() {",
            "gl_PointSize = size;",
            "vColor = colour;",
            "gl_Position = vec4( position.x / projectionVector.x -1.0, position.y / -projectionVector.y + 1.0 , 0.0, 1.0);",            
        "}",
    ];

    public static var SPRITE_FRAGMENT_SHADER:Array<String> = [
        "precision mediump float;",

        "varying vec4 vColor;",
        "void main() {",
            "gl_FragColor = vColor;",
        "}"
    ];

}   