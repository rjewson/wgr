
package wgr.display;

import wgr.display.DisplayObject;
import wgr.display.DisplayObjectContainer;
import wgr.display.Sprite;

class Stage extends DisplayObjectContainer
{

    public var head:Sprite;
    public var tail:Sprite;
    public var count:Int;
    public var dirty:Bool;

    public function new() {
        super();
        id = "Stage";
        worldAlpha = alpha;
        stage = this;
    }

    public override function updateTransform() { 
        for (child in children) { 
            child.updateTransform();
        }
    }

    public function PreRender() {
        if (dirty==true) {
            Flatten();
            dirty=false;
        }
    }

    /*
     *   Depth-first Pre-order traversal of tree
     */
    public function Flatten() {
        head = null;
        tail = null;
        count = 0;
        Traverse(this);
        var sprite = head;
        while (sprite!=null) {
            sprite = sprite.next;
        }
        trace("Total Sprites:"+count);
    }

    public function Traverse(node:DisplayObject) {
        //This node not visible? Snip it all off...
        if (node.visible==false)
            return;
        //Is this a Sprite? If so put it in the list
        if (Std.is(node, Sprite)) {
            if (head==null) {
                head = cast node;
                head.prev = head.next = null;
            } else {
                var sprite:Sprite = cast node;
                if (tail==null) {
                    tail = sprite;
                    head.next = tail;
                    tail.prev = head;
                } else {
                    tail.next = sprite;
                    sprite.prev = tail;
                    tail = sprite;                    
                }
            }
            count++;
        }
        //Parse the other children
        if (Std.is(node, DisplayObjectContainer)) {
            var doc:DisplayObjectContainer = cast node;
            for (child in doc.children) {
                Traverse(child);
            }
        }
    }

}