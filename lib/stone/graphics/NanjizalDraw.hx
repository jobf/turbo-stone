package stone.graphics;

import peote.view.Color;
import stone.core.GraphicsAbstract;
import justPath.SvgLinePath;
import justPath.ILinePathContext;
import justPath.LinePathContextTrace;
import stone.graphics.implementation.Graphics;
import stone.graphics.Fill;
import stone.graphics.implementation.PeoteLine;

typedef QuadrilateralPos = { ax: Float, ay: Float, bx: Float, by: Float, cx: Float, cy: Float, dx: Float, dy: Float };

@:access(stone.graphics.implementation.Graphics)
class NanjizalDraw implements ILinePathContext {
    public var strokeWidth: Float;
    public var strokeColor: Color;
    public var translateX: Float;
    public var translateY: Float;
    public var scaleX: Float;
    public var scaleY: Float;
    var toggleDraw = true;
    var info: QuadrilateralPos; //{ ax: Float, ay: Float, bx: Float, by: Float, cx: Float, cy: Float, dx: Float, dy: Float };
    var oldInfo: QuadrilateralPos;
    var x0: Float = 0.;
    var y0: Float = 0.;
    var svgLinePath: SvgLinePath;
    var graphics: Graphics;
    public function new( graphics:          Graphics 
                       , strokeColor: Color  = 0xff0000ff
                       , strokeWidth        = 1.
                       , translateX         = 0.
                       , translateY         = 0.
                       , scaleX             = 1.
                       , scaleY             = 1. ){
        svgLinePath = new SvgLinePath( this );
        this.graphics = graphics;
        this.strokeWidth = strokeWidth;
        this.strokeColor = strokeColor;
        this.translateX = translateX;
        this.translateY = translateY;
        this.scaleX = scaleX;
        this.scaleY = scaleY;
    }

    inline
    function graphicsLine( x0: Float, y0: Float, x1: Float, y1: Float, thick: Float, color: Color ): QuadrilateralPos {
        var line: PeoteLine = cast graphics.make_line( x0, y0, x1, y1, cast color );
        line.thick = Std.int( thick );
        return getInfo( x0, y0, x1, y1, thick );
    }

    inline
    function getInfo(px: Float, py: Float
                    , qx: Float, qy: Float
                    , thick: Float ): QuadrilateralPos {
        var o = qy-py;
        var a = qx-px;
        var x = px;
        var y = py;
        var h = Math.pow( o*o + a*a, 0.5 );
        var theta = Math.atan2( o, a );
        var sin = Math.sin( theta );
        var cos = Math.cos( theta );
        var radius = thick/2;
        var dx = 0.1;
        var dy = radius;
        var cx = h;
        var cy = radius;
        var bx = h;
        var by = -radius;
        var ax = 0.1;
        var ay = -radius;
        var temp = 0.;
        temp = x + rotX( ax, ay, sin, cos );
        ay = y + rotY( ax, ay, sin, cos );
        ax = temp;

        temp = x + rotX( bx, by, sin, cos );
        by = y + rotY( bx, by, sin, cos );
        bx = temp;

        temp = x + rotX( cx, cy, sin, cos );
        cy = y + rotY( cx, cy, sin, cos );
        cx = temp;

        temp = x + rotX( dx, dy, sin, cos );
        dy = y + rotY( dx, dy, sin, cos ); 
        dx = temp;
        return { ax:ax, ay:ay, bx:bx, by:by, cx:cx, cy:cy, dx:dx, dy:dy };
    }
    public function drawPath( pathData: String ){
        if( pathData != '' ) svgLinePath.parse( pathData );
    }
    public
    function lineSegmentTo( x2: Float, y2: Float ){
        if( toggleDraw ){
            oldInfo = info;
            info = graphicsLine( x0*scaleX + translateX, y0*scaleY + translateY
                     , x2*scaleX + translateX, y2*scaleY + translateY 
                     , strokeWidth, strokeColor );
            if( info != null && oldInfo != null ){
                var xA = ( oldInfo.bx + oldInfo.cx )/2;
                var yA = ( oldInfo.by + oldInfo.cy )/2;
                //var yA = ( info.ax + info.dx )/2; <----!!!
                //var xB = ( oldInfo.bx + oldInfo.cx )/2;
                //var yB = ( info.ax + info.dx )/2;
                graphicsLine( xA*scaleX + translateX, yA*scaleY + translateY
                    , x0*scaleX + translateX, y0*scaleY + translateY 
                    , strokeWidth, strokeColor );
                //fillQuadrilateral( oldInfo.bx*scaleX + translateX, oldInfo.by*scaleY + translateY, info.ax*scaleX + translateX, info.ay*scaleY + translateY, info.dx*scaleX + translateX, info.dy*scaleY + translateY, oldInfo.cx*scaleX + translateX, oldInfo.cy*scaleY + translateY, strokeColor );
                
            }
        } else {
            
        }
        toggleDraw = !toggleDraw;
        x0 = x2;
        y0 = y2;
    }
    public
    function lineTo( x2: Float, y2: Float ){
        oldInfo = info;
        info = graphicsLine( x0*scaleX + translateX, y0*scaleY + translateY
                     , x2*scaleX + translateX, y2*scaleY + translateY 
                     , strokeWidth, strokeColor );
        if( info != null && oldInfo != null ){
            var xA = ( oldInfo.bx + oldInfo.cx )/2;
            var yA = ( oldInfo.by + oldInfo.cy )/2;
            // var yA = ( info.ax + info.dx )/2; <--!!
            //var xB = ( oldInfo.bx + oldInfo.cx )/2;
            //var yB = ( info.ax + info.dx )/2;
            graphicsLine( xA*scaleX + translateX, yA*scaleY + translateY
                , x0*scaleX + translateX, y0*scaleY + translateY 
                , strokeWidth, strokeColor );
            //fillQuadrilateral( oldInfo.bx*scaleX + translateX, oldInfo.by*scaleY + translateY, info.ax*scaleX + translateX, info.ay*scaleY + translateY, info.dx*scaleX + translateX, info.dy*scaleY + translateY, oldInfo.cx*scaleX + translateX, oldInfo.cy*scaleY + translateY, strokeColor );
        }
        x0 = x2;
        y0 = y2;
        toggleDraw = true;
    }
    public
    function moveTo( x1: Float, y1: Float ){
        x0 = x1;
        y0 = y1;
        info = null;
        toggleDraw = true;
    }
    public
    function quadTo( x2: Float, y2: Float, x3: Float, y3: Float ){
        svgLinePath.quadTo( x2, y2, x3, y3 );
    }
    public
    function curveTo( x2: Float, y2: Float, x3: Float, y3: Float, x4: Float, y4: Float ){
        svgLinePath.curveTo( x2, y2, x3, y3, x4, y4 );
    }
    public
    function quadThru( x2: Float, y2: Float, x3: Float, y3: Float ){
        svgLinePath.quadThru( x2, y2, x3, y3 );
    }
}
