package;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;
using StringTools;
typedef ShaderEffect={
    var shader:Dynamic;
  }
class ColorEffect{
    public var shader:ColorShader=new ColorShader();
    public function new(){
        shader.redMultiplier.value=[1.0];
        shader.greenMultiplier.value=[1.0];
        shader.blueMultiplier.value=[1.0];
        shader.alphaMultiplier.value=[1.0];
        shader.redOffset.value=[0.0];
        shader.greenOffset.value=[0.0];
        shader.blueOffset.value=[0.0];
        shader.alphaOffset.value=[0.0];
    }
    public function setMultiplier(redMultiplier:Float,greenMultiplier:Float,blueMultiplier:Float,alphaMultiplier:Float){
        shader.redMultiplier.value[0]=redMultiplier;
        shader.greenMultiplier.value[0]=greenMultiplier;
        shader.blueMultiplier.value[0]=blueMultiplier;
        shader.alphaMultiplier.value[0]=alphaMultiplier;
      }
    
      public function setOffset(redOffset:Float,greenOffset:Float,blueOffset:Float,alphaOffset:Float){
        shader.redOffset.value[0]=redOffset/255.0;
        shader.greenOffset.value[0]=greenOffset/255.0;
        shader.blueOffset.value[0]=blueOffset/255.0;
        shader.alphaOffset.value[0]=alphaOffset/255.0;
      }
}
class ColorShader extends FlxShader{
    @:glFragmentSource('
    #pragma header

    uniform float redMultiplier;
    uniform float greenMultiplier;
    uniform float blueMultiplier;
    uniform float alphaMultiplier;
    uniform float redOffset;
    uniform float greenOffset;
    uniform float blueOffset;
    uniform float alphaOffset;
    void main() {
        gl_FragColor = (flixel_texture2D(bitmap, openfl_TextureCoordv) * vec4(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier)) + vec4(redOffset / 255.0, greenOffset / 255.0, blueOffset / 255.0, alphaOffset / 255.0);
    }
    ')
    public function new(){super();}
}
/*
class VHS extends Effect
{
    public var shader:VHSFilter=new VHSFilter();
    public function new(){
        set_time(time);
        PlayState.instance.shaderUpdates.push(update);
	}

    public function update(elapsed:Float):Void
        {
            shader.time.value[0]+=elapsed;
        }
    function set_time(value:Float):Float{
        this.time=value;
        shader.time.value=[value];
        return this.time;
    }

}

class VHSFilter extends FlxShader {
    @:glFragmentSource('
    #pragma header

    #define PI 3.14159265
    
    uniform float time = 0;
    
    vec3 tex2D( sampler2D _tex, vec2 _p ){
      vec3 col = flixel_texture2D( _tex, _p ).xyz;
      if ( 0.5 < abs( _p.x - 0.5 ) ) {
        col = vec3( 0.1 );
      }
      return col;
    }
    
    float hash( vec2 _v ){
      return fract( sin( dot( _v, vec2( 89.44, 19.36 ) ) ) * 22189.22 );
    }
    
    float iHash( vec2 _v, vec2 _r ){
      float h00 = hash( vec2( floor( _v * _r + vec2( 0.0, 0.0 ) ) / _r ) );
      float h10 = hash( vec2( floor( _v * _r + vec2( 1.0, 0.0 ) ) / _r ) );
      float h01 = hash( vec2( floor( _v * _r + vec2( 0.0, 1.0 ) ) / _r ) );
      float h11 = hash( vec2( floor( _v * _r + vec2( 1.0, 1.0 ) ) / _r ) );
      vec2 ip = vec2( smoothstep( vec2( 0.0, 0.0 ), vec2( 1.0, 1.0 ), mod( _v*_r, 1. ) ) );
      return ( h00 * ( 1. - ip.x ) + h10 * ip.x ) * ( 1. - ip.y ) + ( h01 * ( 1. - ip.x ) + h11 * ip.x ) * ip.y;
    }
    
    float noise( vec2 _v ){
      float sum = 0.;
      for( int i=1; i<9; i++ )
      {
        sum += iHash( _v + vec2( i ), vec2( 2. * pow( 2., float( i ) ) ) ) / pow( 2., float( i ) );
      }
      return sum;
    }
    
    void main(){
      vec2 uv = openfl_TextureCoordv;
      vec2 uvn = uv;
      vec3 col = vec3( 0.0 );
    
      // tape wave
      uvn.x += ( noise( vec2( uvn.y, time ) ) - 0.5 )* 0.005;
      uvn.x += ( noise( vec2( uvn.y * 100.0, time * 10.0 ) ) - 0.5 ) * 0.01;
    
      // tape crease
      float tcPhase = clamp( ( sin( uvn.y * 8.0 - time * PI * 1.2 ) - 0.92 ) * noise( vec2( time ) ), 0.0, 0.01 ) * 10.0;
      float tcNoise = max( noise( vec2( uvn.y * 100.0, time * 10.0 ) ) - 0.5, 0.0 );
      uvn.x = uvn.x - tcNoise * tcPhase;
    
      // switching noise
      float snPhase = smoothstep( 0.03, 0.0, uvn.y );
      uvn.y += snPhase * 0.3;
      uvn.x += snPhase * ( ( noise( vec2( uv.y * 100.0, time * 10.0 ) ) - 0.5 ) * 0.2 );
        
      col = tex2D( bitmap, uvn );
      col *= 1.0 - tcPhase;
      col = mix(
        col,
        col.yzx,
        snPhase
      );
    
      // bloom
      for( float x = -4.0; x < 2.5; x += 1.0 ){
        col.xyz += vec3(
          tex2D( bitmap, uvn + vec2( x - 0.0, 0.0 ) * 7E-3 ).x,
          tex2D( bitmap, uvn + vec2( x - 2.0, 0.0 ) * 7E-3 ).y,
          tex2D( bitmap, uvn + vec2( x - 4.0, 0.0 ) * 7E-3 ).z
        ) * 0.1;
      }
      col *= 0.6;
    
      // ac beat
      col *= 1.0 + clamp( noise( vec2( 0.0, uv.y + time * 0.2 ) ) * 0.6 - 0.25, 0.0, 0.1 );
    
      gl_FragColor = vec4( col, 1.0 );
    }
      
    ')

    public function new() {
        super();
    }
}
*/

class ChromaticAberrationShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header

    uniform vec2 rOffset;
    uniform vec2 gOffset;
    uniform vec2 bOffset;

    vec4 offsetColor(vec2 offset)
    {
      return texture2D(bitmap, openfl_TextureCoordv.st - offset);
    }

    void main()
    {
      vec4 base = texture2D(bitmap, openfl_TextureCoordv);
      base.r = offsetColor(rOffset).r;
      base.g = offsetColor(gOffset).g;
      base.b = offsetColor(bOffset).b;

      gl_FragColor = base * openfl_Alphav;
}')
    public function new()
    {
        super();

        this.rOffset.value=[0,0];
        this.gOffset.value=[0,0];
        this.bOffset.value=[0,0];
    }
}

class ThreeDEffect extends Effect{
	
	public var shader:ThreeDShader=new ThreeDShader();
	public function new(xrot:Float=0,yrot:Float=0,zrot:Float=0,depth:Float=0){
		shader.xrot.value=[xrot];
		shader.yrot.value=[yrot];
		shader.zrot.value=[zrot];
		shader.dept.value=[depth];
	}
}
class ThreeDShader extends FlxShader{
	@:glFragmentSource('
	#pragma header
	uniform float xrot = 0.0;
	uniform float yrot = 0.0;
	uniform float zrot = 0.0;
	uniform float dept = 0.0;
	float alph = 0;
float plane( in vec3 norm, in vec3 po, in vec3 ro, in vec3 rd ) {
    float de = dot(norm, rd);
    de = sign(de)*max( abs(de), 0.001);
    return dot(norm, po-ro)/de;
}

vec2 raytraceTexturedQuad(in vec3 rayOrigin, in vec3 rayDirection, in vec3 quadCenter, in vec3 quadRotation, in vec2 quadDimensions) {
    //Rotations ------------------
    float a = sin(quadRotation.x); float b = cos(quadRotation.x); 
    float c = sin(quadRotation.y); float d = cos(quadRotation.y); 
    float e = sin(quadRotation.z); float f = cos(quadRotation.z); 
    float ac = a*c;   float bc = b*c;
	
	mat3 RotationMatrix  = 
			mat3(	  d*f,      d*e,  -c,
                 ac*f-b*e, ac*e+b*f, a*d,
                 bc*f+a*e, bc*e-a*f, b*d );
    //--------------------------------------
    
    vec3 right = RotationMatrix * vec3(quadDimensions.x, 0.0, 0.0);
    vec3 up = RotationMatrix * vec3(0, quadDimensions.y, 0);
    vec3 normal = cross(right, up);
    normal /= length(normal);
    
    //Find the plane hit point in space
    vec3 pos = (rayDirection * plane(normal, quadCenter, rayOrigin, rayDirection)) - quadCenter;
    
    //Find the texture UV by projecting the hit point along the plane dirs
    return vec2(dot(pos, right) / dot(right, right),
                dot(pos, up)    / dot(up,    up)) + 0.5;
}

void main() {
	vec4 texColor = texture2D(bitmap, openfl_TextureCoordv);
    //Screen UV goes from 0 - 1 along each axis
    vec2 screenUV = openfl_TextureCoordv;
    vec2 p = (2.0 * screenUV) - 1.0;
    float screenAspect = 1280/720;
    p.x *= screenAspect;
    
    //Normalized Ray Dir
    vec3 dir = vec3(p.x, p.y, 1.0);
    dir /= length(dir);
    
    //Define the plane
    vec3 planePosition = vec3(0.0, 0.0, dept);
    vec3 planeRotation = vec3(xrot, yrot, zrot);//this the shit you needa change
    vec2 planeDimension = vec2(-screenAspect, 1.0);
    
    vec2 uv = raytraceTexturedQuad(vec3(0), dir, planePosition, planeRotation, planeDimension);
	
    //If we hit the rectangle, sample the texture
    if (abs(uv.x - 0.5) < 0.5 && abs(uv.y - 0.5) < 0.5) {
		
		vec3 tex = flixel_texture2D(bitmap, uv).xyz;
		float bitch = 1.0;
		if (tex.z == 0.0){
			bitch = 0.0;
		}
		
	  gl_FragColor = vec4(flixel_texture2D(bitmap, uv).xyz, bitch);
    }
}


	')
	
	public function new(){super();}
	
}
class Effect {
	public function setValue(shader:FlxShader,variable:String,value:Float){
		Reflect.setProperty(Reflect.getProperty(shader,'variable'),'value',[value]);
	}
	
}