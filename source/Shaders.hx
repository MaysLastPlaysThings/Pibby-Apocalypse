import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import haxe.Timer;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;

typedef BlendModeShader =
{
	var uBlendColor:ShaderParameter<Float>;
}

enum WiggleEffectType
{
	DREAMY;
	WAVY;
	HEAT_WAVE_HORIZONTAL;
	HEAT_WAVE_VERTICAL;
	FLAG;
}

class WiggleEffect
{
	public var shader(default, null):WiggleShader = new WiggleShader();
	public var effectType(default, set):WiggleEffectType = DREAMY;
	public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;

	public function new():Void
	{
		shader.uTime.value = [0];
	}

	public function update(elapsed:Float):Void
	{
		shader.uTime.value[0] += elapsed;
	}

	public function setValue(value:Float):Void
	{
		shader.uTime.value[0] = value;
	}

	function set_effectType(v:WiggleEffectType):WiggleEffectType
	{
		effectType = v;
		shader.effectType.value = [WiggleEffectType.getConstructors().indexOf(Std.string(v))];
		return v;
	}

	function set_waveSpeed(v:Float):Float
	{
		waveSpeed = v;
		shader.uSpeed.value = [waveSpeed];
		return v;
	}

	function set_waveFrequency(v:Float):Float
	{
		waveFrequency = v;
		shader.uFrequency.value = [waveFrequency];
		return v;
	}

	function set_waveAmplitude(v:Float):Float
	{
		waveAmplitude = v;
		shader.uWaveAmplitude.value = [waveAmplitude];
		return v;
	}
}

class WiggleShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		//uniform float tx, ty; // x,y waves phase
		uniform float uTime;
		
		const int EFFECT_TYPE_DREAMY = 0;
		const int EFFECT_TYPE_WAVY = 1;
		const int EFFECT_TYPE_HEAT_WAVE_HORIZONTAL = 2;
		const int EFFECT_TYPE_HEAT_WAVE_VERTICAL = 3;
		const int EFFECT_TYPE_FLAG = 4;
		
		uniform int effectType;
		
		/**
		 * How fast the waves move over time
		 */
		uniform float uSpeed;
		
		/**
		 * Number of waves over time
		 */
		uniform float uFrequency;
		
		/**
		 * How much the pixels are going to stretch over the waves
		 */
		uniform float uWaveAmplitude;

		vec2 sineWave(vec2 pt)
		{
			float x = 0.0;
			float y = 0.0;
			
			if (effectType == EFFECT_TYPE_DREAMY) 
			{
				float offsetX = sin(pt.y * uFrequency + uTime * uSpeed) * uWaveAmplitude;
                pt.x += offsetX; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
			}
			else if (effectType == EFFECT_TYPE_WAVY) 
			{
				float offsetY = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
				pt.y += offsetY; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
			}
			else if (effectType == EFFECT_TYPE_HEAT_WAVE_HORIZONTAL)
			{
				x = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
			}
			else if (effectType == EFFECT_TYPE_HEAT_WAVE_VERTICAL)
			{
				y = sin(pt.y * uFrequency + uTime * uSpeed) * uWaveAmplitude;
			}
			else if (effectType == EFFECT_TYPE_FLAG)
			{
				y = sin(pt.y * uFrequency + 10.0 * pt.x + uTime * uSpeed) * uWaveAmplitude;
				x = sin(pt.x * uFrequency + 5.0 * pt.y + uTime * uSpeed) * uWaveAmplitude;
			}
			
			return vec2(pt.x + x, pt.y + y);
		}

		void main()
		{
			vec2 uv = sineWave(openfl_TextureCoordv);
			gl_FragColor = texture2D(bitmap, uv);
		}')
	public function new()
	{
		super();
	}
}

class ReflectionShader extends FlxShader
{
  @:glFragmentSource('
  
    #pragma header

    uniform float reflectionY = 0.36;


    vec4 color = vec4(1.0);
    void main()
    {
      vec2 uv = openfl_TextureCoordv.xy / iResolution.xy;
      if(uv.y <= reflectionY)
      {
        float oy = uv.y;
        uv.y = 2.0 * reflectionY - uv.y;
        color = vec4(0.7, 0.85, 1.0, 1.0);
      }

        gl_FragColor = flixel_texture2D(bitmap, uv) * Color;
    }
  
  ')

  public function new()
  {
    super();
    reflectionY.value = [0.36];
  }
}


//I'll find another shader soon
class Pibbified extends FlxShader
{
    @:glFragmentSource('
    
    #pragma header

    uniform float uTime;
    uniform float iMouseX;
    uniform int NUM_SAMPLES;
    uniform float glitchMultiply;
    
    float sat( float t ) {
        return clamp( t, 0.0, 1.0 );
    }
    
    vec2 sat( vec2 t ) {
        return clamp( t, 0.0, 1.0 );
    }
    
    //remaps inteval [a;b] to [0;1]
    float remap  ( float t, float a, float b ) {
        return sat( (t - a) / (b - a) );
    }
    
    //note: /\\ t=[0;0.5;1], y=[0;1;0]
    float linterp( float t ) {
        return sat( 1.0 - abs( 2.0*t - 1.0 ) );
    }
    
    vec3 spectrum_offset( float t ) {
        float t0 = 3.0 * t - 1.5;
        return clamp( vec3( -t0, 1.0-abs(t0), t0), 0.0, 1.0);
        /*
        vec3 ret;
        float lo = step(t,0.5);
        float hi = 1.0-lo;
        float w = linterp( remap( t, 1.0/6.0, 5.0/6.0 ) );
        float neg_w = 1.0-w;
        ret = vec3(lo,1.0,hi) * vec3(neg_w, w, neg_w);
        return pow( ret, vec3(1.0/2.2) );
    */
    }
    
    //note: [0;1]
    float rand( vec2 n ) {
      return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
    }
    
    //note: [-1;1]
    float srand( vec2 n ) {
        return rand(n) * 2.0 - 1.0;
    }
    
    float mytrunc( float x, float num_levels )
    {
        return floor(x*num_levels) / num_levels;
    }
    vec2 mytrunc( vec2 x, float num_levels )
    {
        return floor(x*num_levels) / num_levels;
    }

    void main()
    {
        float aspect = openfl_TextureSize.x / openfl_TextureSize.y;
        vec2 uv = openfl_TextureCoordv;
        // uv.y = 1.0 - uv.y;
        
        float time = mod(uTime, 32.0); // + modelmat[0].x + modelmat[0].z;
    
        float GLITCH = (0.1 + iMouseX / openfl_TextureSize.x) * glitchMultiply;
        
        //float rdist = length( (uv - vec2(0.5,0.5))*vec2(aspect, 1.0) )/1.4;
        //GLITCH *= rdist;
        
        float gnm = sat( GLITCH );
        float rnd0 = rand( mytrunc( vec2(time, time), 6.0 ) );
        float r0 = sat((1.0-gnm)*0.7 + rnd0);
        float rnd1 = rand( vec2(mytrunc( uv.x, 10.0*r0 ), time) ); //horz
        //float r1 = 1.0f - sat( (1.0f-gnm)*0.5f + rnd1 );
        float r1 = 0.5 - 0.5 * gnm + rnd1;
        r1 = 1.0 - max( 0.0, ((r1<1.0) ? r1 : 0.9999999) ); //note: weird ass bug on old drivers
        float rnd2 = rand( vec2(mytrunc( uv.y, 40.0*r1 ), time) ); //vert
        float r2 = sat( rnd2 );
    
        float rnd3 = rand( vec2(mytrunc( uv.y, 10.0*r0 ), time) );
        float r3 = (1.0-sat(rnd3+0.8)) - 0.1;
    
        float pxrnd = rand( uv + time );
    
        float ofs = 0.05 * r2 * GLITCH * ( rnd0 > 0.5 ? 1.0 : -1.0 );
        ofs += 0.5 * pxrnd * ofs;
    
        uv.y += 0.1 * r3 * GLITCH;
    
        // const int NUM_SAMPLES = 10;
        // const float RCP_NUM_SAMPLES_F = 1.0 / float(NUM_SAMPLES);
        float RCP_NUM_SAMPLES_F = 1.0 / float(NUM_SAMPLES);
        
        vec4 sum = vec4(0.0);
        vec3 wsum = vec3(0.0);
        for( int i=0; i<NUM_SAMPLES; ++i )
        {
            float t = float(i) * RCP_NUM_SAMPLES_F;
            uv.x = sat( uv.x + ofs * t );
            vec4 samplecol = texture2D( bitmap, uv );
            vec3 s = spectrum_offset( t );
            samplecol.rgb = samplecol.rgb * s;
            sum += samplecol;
            wsum += s;
        }
        sum.rgb /= wsum;
        sum.a *= RCP_NUM_SAMPLES_F;
    
        //gl_FragColor = vec4( sum.bbb, 1.0 ); return;
        
        gl_FragColor.a = sum.a;
        gl_FragColor.rgb = sum.rgb; // * outcol0.a;
    }

    ')

    public function new()
    {
        super();
        uTime.value = [];
        glitchMultiply.value = [];
        NUM_SAMPLES.value = [3];
        iMouseX.value = [500];
    }
}

// Credits to Andromeda Engine (NebulaTheZoura) for porting from shadertoy!

class ChromShader extends FlxShader
{
  @:glFragmentSource('
  #pragma header
  /*
  https://www.shadertoy.com/view/wtt3z2
  */
  
  uniform float aberration = 0.0;
  uniform float effectTime = 0.0;
  
  vec3 tex2D(sampler2D _tex,vec2 _p)
  {
      vec3 col=texture2D(_tex,_p).xyz;
      if(.5<abs(_p.x-.5)){
          col=vec3(.1);
      }
      return col;
  }
  
  void main() {
      vec2 uv = openfl_TextureCoordv; //openfl_TextureCoordv.xy*2. / openfl_TextureSize.xy-vec2(1.);
      vec2 ndcPos = uv * 2.0 - 1.0;
      float aspect = openfl_TextureSize.x / openfl_TextureSize.y;
      
      //float u_angle = -2.4;
      
      float u_angle = 0;
      
      float eye_angle = abs(u_angle);
      float half_angle = eye_angle/2.0;
      float half_dist = tan(half_angle);
  
      vec2  vp_scale = vec2(aspect, 1.0);
      vec2  P = ndcPos * vp_scale; 
      
      float vp_dia = length(vp_scale);
      vec2  rel_P = normalize(P) / normalize(vp_scale);
  
      vec2 pos_prj = ndcPos;
  
      float beta = abs(atan((length(P) / vp_dia) * half_dist) * -abs(cos(effectTime - 0.25 + 0.5)));
      pos_prj = rel_P * beta / half_angle;
  
      vec2 uv_prj = (pos_prj * 0.5 + 0.5);
  
      vec2 trueAberration = aberration * pow((uv - 0.5), vec2(3.0, 3.0));
      // vec4 texColor = tex2D(bitmap, uv_prj.st);
      gl_FragColor = vec4(
          texture2D(bitmap, uv + trueAberration).r, 
          texture2D(bitmap, uv).g, 
          texture2D(bitmap, uv - trueAberration).b, 
          flixel_texture2D(bitmap,uv).a
      );
  }
  ')
  public function new() {
    super();
    aberration.value = [];
  }
}

class VCRDistortionShader extends FlxShader // https://www.shadertoy.com/view/ldjGzV and https://www.shadertoy.com/view/Ms23DR and https://www.shadertoy.com/view/MsXGD4 and https://www.shadertoy.com/view/Xtccz4
{

  @:glFragmentSource('
    #pragma header

    uniform float iTime;
    uniform bool vignetteOn;
    uniform bool perspectiveOn;
    uniform bool distortionOn;
    uniform bool vignetteMoving;
    uniform sampler2D noiseTex;
    uniform float glitchModifier;
    uniform vec3 iResolution;

    float onOff(float a, float b, float c)
    {
    	return step(c, sin(iTime + a*cos(iTime*b)));
    }

    float ramp(float y, float start, float end)
    {
    	float inside = step(start,y) - step(end,y);
    	float fact = (y-start)/(end-start)*inside;
    	return (1.-fact) * inside;

    }

    vec2 distortUV(vec2 look){
      if(distortionOn){
        float window = 1./(1.+20.*(look.y-mod(iTime/4.,1.))*(look.y-mod(iTime/4.,1.)));
        look.x = look.x + (sin(look.y*10. + iTime)/50.*onOff(4.,4.,.3)*(1.+cos(iTime*80.))*window)*(glitchModifier*2.);
        float vShift = 0.4*onOff(2.,3.,.9)*(sin(iTime)*sin(iTime*20.) +
                           (0.5 + 0.1*sin(iTime*200.)*cos(iTime)));

        float cum = mod(look.y + (vShift*glitchModifier), 1.);
        if(abs(vShift*glitchModifier) > 0.01){
          look.y = cum;
        }
      }
      return look;
    }
    vec4 getVideo(vec2 uv)
      {
      	vec2 look = uv;
      	vec4 video = flixel_texture2D(bitmap,look);

      	return video;
      }

    vec2 screenDistort(vec2 uv)
    {
      if(perspectiveOn){
        uv = (uv - 0.5) * 2.0;
      	uv *= 1.1;
      	uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
      	uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
      	uv  = (uv / 2.0) + 0.5;
      	uv =  uv *0.92 + 0.04;
      	return uv;
      }
    	return uv;
    }
    float random(vec2 uv)
    {
     	return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.03));
    }

    float rand(vec2 co){
      return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
    }



    float noise(vec2 uv)
    {
     	vec2 i = floor(uv);
        vec2 f = fract(uv);

        float a = random(i);
        float b = random(i + vec2(1.,0.));
    	float c = random(i + vec2(0., 1.));
        float d = random(i + vec2(1.));

        vec2 u = smoothstep(0., 1., f);

        return mix(a,b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;

    }


    vec2 scandistort(vec2 uv) {
    	float scan1 = clamp(cos(uv.y * 2.0 + iTime), 0.0, 1.0);
    	float scan2 = clamp(cos(uv.y * 2.0 + iTime + 4.0) * 10.0, 0.0, 1.0) ;
    	float amount = scan1 * scan2 * uv.x;

    	uv.x -= 0.05 * mix(flixel_texture2D(noiseTex, vec2(uv.x, amount)).r * amount, amount, 0.9);

    	return uv;

    }
    void main()
    {
    	vec2 uv = openfl_TextureCoordv;
      vec2 tvWow = screenDistort(uv);
      if(distortionOn){
        uv.x += rand(vec2(0, (uv.y/125.0) + iTime))/256.;
        uv.y += rand(vec2(0, (uv.x/125.0) + iTime))/256.;
      }
      vec2 curUV = screenDistort(distortUV(uv));
    	uv = scandistort(curUV);
    	vec4 video = getVideo(uv);
      float vigAmt = 1.0;
      float x =  0.;


      video.r = getVideo(vec2(x+uv.x+0.001,uv.y+0.001)- vec2(0.005,0.004)).x+0.05;
      video.g = getVideo(vec2(x+uv.x+0.000,uv.y-0.002)).y+0.05;
      video.b = getVideo(vec2(x+uv.x-0.002,uv.y+0.000)+ vec2(0.005,0.004)).z+0.05;
      video.r += 0.08*getVideo(0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
      video.g += 0.05*getVideo(0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
      video.b += 0.08*getVideo(0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;

      video = clamp(video*0.6+0.4*video*video*1.0,0.0,1.0);


      if(vignetteMoving)
    	  vigAmt = 3.+.3*sin(iTime + 5.*cos(iTime*5.));

    	float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));

      if(vignetteOn)
    	 video *= vignette;


      gl_FragColor = video;

      if(tvWow.x<0. || tvWow.x>1. || tvWow.y<0. || tvWow.y>1.){
        gl_FragColor = vec4(0,0,0,0);
      }

    }
  ')
  public function new() {
    super();
    iTime.value = [Timer.stamp()];
  }

  public function update(elapsed:Float) {
    iTime.value[0] += elapsed;
  }
}

class BlendModeEffect
{
	public var shader(default, null):BlendModeShader;

	@:isVar
	public var color(default, set):FlxColor;

	public function new(shader:BlendModeShader, color:FlxColor):Void
	{
		shader.uBlendColor.value = [];
		this.shader = shader;
		this.color = color;
	}

	function set_color(color:FlxColor):FlxColor
	{
		shader.uBlendColor.value[0] = color.redFloat;
		shader.uBlendColor.value[1] = color.greenFloat;
		shader.uBlendColor.value[2] = color.blueFloat;
		shader.uBlendColor.value[3] = color.alphaFloat;

		return this.color = color;
	}
}

class PincushionShader extends FlxShader
{
  @:glFragmentSource('    
  #pragma header

  vec2 uv = openfl_TextureCoordv.xy;
  vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
  vec2 iResolution = openfl_TextureSize;
  uniform float iTime;
  uniform float Size;
  #define iChannel0 bitmap
  #define texture flixel_texture2D
  #define fragColor gl_FragColor

  #define amount -0.3 // negative : anti fish eye. positive = fisheye

  //Inspired by http://stackoverflow.com/questions/6030814/add-fisheye-effect-to-images-at-runtime-using-opengl-es
  void main()
  {
      vec2 p = fragCoord.xy / iResolution.x;//normalized coords with some cheat
                                                               //(assume 1:1 prop)
      float prop = iResolution.x / iResolution.y;//screen proroption
      vec2 m = vec2(0.5, 0.5 / prop);//center coords
      vec2 d = p - m;//vector from center to current fragment
      float r = sqrt(dot(d, d)); // distance of pixel from center
  
      float power = amount;
  
      float bind;//radius of 1:1 effect
      if (power > 0.0) 
          bind = sqrt(dot(m, m));//stick to corners
      else {if (prop < 1.0) 
          bind = m.x; 
      else 
          bind = m.y;}//stick to borders
  
      //Weird formulas
      vec2 uv;
      if (power > 0.0)//fisheye
          uv = m + normalize(d) * tan(r * power) * bind / tan( bind * power);
      else if (power < 0.0)//antifisheye
          uv = m + normalize(d) * atan(r * -power * 10.0) * bind / atan(-power * bind * 10.0);
      else uv = p;//no effect for power = 1.0
          
      uv.y *= prop;
  
      vec3 col = texture(iChannel0, uv).rgb;
      
      // inverted
      //vec3 col = texture(iChannel0, vec2(uv.x, 1.0 - uv.y)).rgb;//Second part of cheat
                                                        //for round effect, not elliptical
      fragColor = vec4(col, 1.0);
    }
   ')
   public function new()
    {
      super();
    }
}

class BlurShader extends FlxShader
{
    @:glFragmentSource('

#pragma header

uniform float iTime;

vec2 iResolution = openfl_TextureSize;

uniform float amount = 0.5;

const float pi = radians(180.);
const int samples = 20;
const float sigma = float(samples) * 0.25;

const float sigma2 = 2. * sigma * sigma;
const float pisigma2 = pi * sigma2;

float gaussian(vec2 i) {
    float top = exp(-((i.x * i.x) + (i.y * i.y)) / sigma2);
    float bot = pisigma2;
    return top / bot;
}

vec3 blur(sampler2D sp, vec2 uv, vec2 scale) {
    vec2 offset;
    float weight = gaussian(offset);
    vec3 col = texture2D(sp, uv).rgb * weight;
    float accum = weight * amount;
    
    // we need to use x <= samples / 2
    // to ensure symmetry
    for (int x = 0; x <= samples / 2; ++x) {
        for (int y = 1; y <= samples / 2; ++y) {
            offset = vec2(x, y);
            weight = gaussian(offset);
            col += texture2D(sp, uv + scale * offset).rgb * weight;
            accum += weight;

            // since values are symmetrical
            // we can re-use the "weight" value, saving 3 function calls

            col += texture2D(sp, uv - scale * offset).rgb * weight;
            accum += weight;

            offset = vec2(-y, x);
            col += texture2D(sp, uv + scale * offset).rgb * weight;
            accum += weight;

            col += texture2D(sp, uv - scale * offset).rgb * weight;
            accum += weight;
        }
    }
    
    return col / accum;
}

void main() {
    vec2 fragCoord = openfl_TextureCoordv * iResolution;

    vec2 ps = vec2(1.0) / iResolution.xy;
    vec2 uv = fragCoord * ps;

    gl_FragColor = vec4(blur(bitmap, uv, ps * amount), texture2D(bitmap,uv).a);
}
')

public function new()
    {
        super();
        amount.value = [0];
    }
}

class InvertShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header
    
    void main()
    {
        vec2 p = openfl_TextureCoordv*openfl_TextureSize.xy/openfl_TextureSize.xy;
        
        vec4 col = flixel_texture2D(bitmap, p);
        
        col = vec4(1.) - col; // invert the color
        
        col.a = 1.0 - col.a; // invert the alpha value
        
        col.rgb *= col.a; // multiply color by alpha
        
        gl_FragColor = col;
    }
    ')
  
    public function new()
	{
		super();
	}
}

class OldTVShader extends FlxShader
{
    @:glFragmentSource('
        #pragma header
        #define id vec2(0.,1.)
        #define k 1103515245U
        #define PI 3.141592653
        #define TAU PI * 2.

        uniform float iTime;

        //prng func, from https://stackoverflow.com/a/52207531
        vec3 hash(uvec3 x) {
            x = ((x>>8U)^x.yzx)*k;
            x = ((x>>8U)^x.yzx)*k;
            x = ((x>>8U)^x.yzx)*k;         
            return vec3(x)*(1.0/float(0xffffffffU));
        }

        void main() {
            bool flag = false;
            bool flag2 = false;

            vec2 uv = openfl_TextureCoordv;
            
            //picture offset
            float time = 2.0;
            float timeMod = 2.5;
            float repeatTime = 1.25;
            float lineSize = 50.0;
            float offsetMul = 0.01;
            float updateRate2 = 50.0;
            float uvyMul = 100.0;
            
            float realSize = lineSize / openfl_TextureSize.y / 2.0;
            float position = mod(iTime, timeMod) / time;
            float position2 = 99.;
            if (iTime > repeatTime) {
                position2 = mod(iTime - repeatTime, timeMod) / time;
            }
            if (!(uv.y - position > realSize || uv.y - position < -realSize)) {
                uv.x -= hash(uvec3(0., uv.y * uvyMul, iTime * updateRate2)).x * offsetMul;
                flag = true;
            } else if (position2 != 99.) {
                if (!(uv.y - position2 > realSize || uv.y - position2 < -realSize)) {
                    uv.x -= hash(uvec3(0., uv.y * uvyMul, iTime * updateRate2)).x * offsetMul;
                    flag = true;
                }
            }
            
            vec4 col = flixel_texture2D(bitmap, uv);
            
            //blur, from https://www.shadertoy.com/view/Xltfzj
            float directions = 16.0;
            float quality = 3.0;
            float size = 4.0;

            vec2 radius = size / openfl_TextureSize;
            for(float d = 0.0; d < TAU; d += TAU / directions) {
                for(float i= 1.0 / quality; i <= 1.0; i += 1.0 / quality) {
                    col += flixel_texture2D(bitmap, uv + vec2(cos(d), sin(d)) * radius * i);	
                }
            }
            col /= quality * directions - 14.0;
            
            //for the black on the left
            if (uv.x < 0.) {
                col = id.xxxy;
                flag = false;
                flag2 = true;
            }
            
            //randomized black shit and sploches
            float updateRate4 = 100.0;
            float uvyMul3 = 100.0;
            float cutoff2 = 0.92;
            float valMul2 = 0.007;
            
            float val2 = hash(uvec3(uv.y * uvyMul3, 0., iTime * updateRate4)).x;
            if (val2 > cutoff2) {
                float adjVal2 = (val2 - cutoff2) * valMul2 * (1. / (1. - cutoff2));
                if (uv.x < adjVal2) {
                    col = id.xxxy;
                    flag2 = true;
                } else {
                    flag = true;
                }
            }

            //static
            if (!flag2) {
                float updateRate = 100.0;
                float mixPercent = 0.05; 
                col = mix(col, vec4(hash(uvec3(uv * openfl_TextureSize, iTime * updateRate)).rrr, 1.), mixPercent);
            }
            
            //white sploches
            float updateRate3 = 75.0;
            float uvyMul2 = 400.0;
            float uvxMul = 20.0;
            float cutoff = 0.95;
            float valMul = 0.7;
            float falloffMul = 0.7;
            
            if (flag) {
                float val = hash(uvec3(uv.x * uvxMul, uv.y * uvyMul2, iTime * updateRate3)).x;
                if (val > cutoff) {
                    float offset = hash(uvec3(uv.y * uvyMul2, uv.x * uvxMul, iTime * updateRate3)).x;
                    float adjVal = (val - cutoff) * valMul * (1. / (1. - cutoff));
                    adjVal -= abs((uv.x * uvxMul - (floor(uv.x * uvxMul) + offset)) * falloffMul);
                    adjVal = clamp(adjVal, 0., 1.);
                    col = vec4(mix(col.rgb, id.yyy, adjVal), col.a);
                }
            }
            
            gl_FragColor = col;
        }
    ')

    public function new() {
        super();
        iTime.value = [Timer.stamp()];
    }

    public function update(elapsed:Float) {
        iTime.value[0] += elapsed;
    }
}

class GlitchMissingNo extends FlxShader
{
    @:glFragmentSource('
    #pragma header

    uniform float binaryIntensity = 1000;
    
    void main() {
        vec2 uv = openfl_TextureCoordv.xy;
        
        // get snapped position
        float psize = 0.04 * binaryIntensity;
        float psq = 1.0 / psize;
    
        float px = floor(uv.x * psq + 0.5) * psize;
        float py = floor(uv.y * psq + 0.5) * psize;
        
        vec4 colSnap = texture2D(bitmap, vec2(px, py));
        
        float lum = pow(1.0 - (colSnap.r + colSnap.g + colSnap.b) / 3.0, binaryIntensity);
        
        float qsize = psize * lum;
        float qsq = 1.0 / qsize;
    
        float qx = floor(uv.x * qsq + 0.5) * qsize;
        float qy = floor(uv.y * qsq + 0.5) * qsize;
    
        float rx = (px - qx) * lum + uv.x;
        float ry = (py - qy) * lum + uv.y;
    
        gl_FragColor = texture2D(bitmap, vec2(rx, ry));
    }
    ')

    public function new() {
        super();
        binaryIntensity.value = [1000];
    }
}