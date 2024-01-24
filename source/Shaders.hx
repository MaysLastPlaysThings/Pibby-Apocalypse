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

// https://www.shadertoy.com/view/llBGWc
class GreenReplacementShader extends FlxShader { // green screen and replaces the green w/ a different colour
    @:isVar
    public var colour(default, set):FlxColor = FlxColor.GREEN;

    @:glFragmentSource('
    #pragma header
    const float threshold = 0.5;
    const float padding = 0.05;

    uniform vec3 replacementColour;

    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        
        vec4 greenScreen = vec4(0.,1.,0.,1.);
        vec3 color = texture2D(bitmap, uv).rgb;
        float alpha = texture2D(bitmap, uv).a;
        
        vec3 diff = color.xyz - greenScreen.xyz;
        float fac = smoothstep(threshold-padding,threshold+padding, dot(diff,diff));
        
        color = mix(color, replacementColour, 1.-fac);
        gl_FragColor = vec4(color.rgb * alpha, alpha);
    }
')
    public function new(){
        super();
        replacementColour.value = [colour.redFloat, colour.greenFloat, colour.blueFloat];
    }

    public function set_colour(clr:FlxColor){
		replacementColour.value = [clr.redFloat, clr.greenFloat, clr.blueFloat];
	    return colour = clr;
    }
    
}
class MAWVHS extends FlxShader {
    @:glFragmentSource('
    #pragma header
    vec2 uv;
    vec2 fragCoord;
    vec2 iResolution;
    uniform float iTime;
    #define iChannel0 bitmap
    #define iChannel1 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main
    
    // https://www.shadertoy.com/view/NtGfWw
    
    float noise(vec2 p)
    {
        float s = texture2D(iChannel1,vec2(1.0,2.0*cos(iTime))*iTime*8.0 + p*1.0).x;
        s *= s;
        return s;
    }
    
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
    
    float stripes(vec2 uv)
    {
        
        float noi = noise(uv*vec2(0.5,1.0) + vec2(1.0,3.0));
        return ramp(mod(uv.y*4.0 + iTime/2.0+sin(iTime + sin(iTime*0.63)),1.0),0.5,0.6)*noi;
    }
    
    vec3 getVideo(vec2 uv)
    {
        vec2 look = uv;
        float window = 1.0/(1.0+20.0*(look.y-mod(iTime/4.,1.0))*(look.y-mod(iTime/4.0,1.0)));
        look.x = look.x + sin(look.y*10.0 + iTime)/50.0*onOff(4.0,4.0,0.3)*(1.0+cos(iTime*80.0))*window;
        float vShift = 0.4*onOff(2.0,3.0,0.9)*(sin(iTime)*sin(iTime*20.0) + 
                                             (0.5 + 0.1*sin(iTime*200.0)*cos(iTime)));
        look.y = mod(look.y + vShift, 1.0);
        vec3 video = vec3(texture2D(iChannel0,look));
        return video;
    }
    
    vec2 screenDistort(vec2 uv)
    {
        uv -= vec2(0.5);
        uv = uv*1.2*(1.0/1.2+2.0*uv.x*uv.x*uv.y*uv.y);
        uv += vec2(0.5);
        return uv;
    }
    
    void main()
    {
    uv = openfl_TextureCoordv.xy;
    fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    iResolution = openfl_TextureSize;

    vec2 fragCoord = openfl_TextureCoordv * iResolution;
        vec2 uv = fragCoord.xy / iResolution.xy;
        uv = screenDistort(uv);
        vec3 video = getVideo(uv);
        float vigAmt = 3.0+0.3*sin(iTime + 5.0*cos(iTime*5.0));
        float vignette = (1.0-vigAmt*(uv.y-0.5)*(uv.y-0.5))*(1.0-vigAmt*(uv.x-0.5)*(uv.x-0.5));
        
        video += stripes(uv);
        video += noise(uv*2.0)/2.0;
        video *= vignette;
        video *= (12.0+mod(uv.y*30.0+iTime,1.0))/13.0;
        
    gl_FragColor = vec4(video,1.0);
    gl_FragColor.a = texture2D(bitmap, openfl_TextureCoordv).a;
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

//funkscop ntsc shader (yes the actual one im not joking visploo gave it to me)
class NtscShader extends FlxShader {
	@:glFragmentSource('
#pragma header

#pragma format R8G8B8A8_SRGB

#define NTSC_CRT_GAMMA 2.5
#define NTSC_MONITOR_GAMMA 2.0

#define TWO_PHASE
#define COMPOSITE
//#define THREE_PHASE
// #define SVIDEO

// begin params
#define PI 3.14159265

#if defined(TWO_PHASE)
	#define CHROMA_MOD_FREQ (4.0 * PI / 15.0)
#elif defined(THREE_PHASE)
	#define CHROMA_MOD_FREQ (PI / 3.0)
#endif

#if defined(COMPOSITE)
	#define SATURATION 1.0
	#define BRIGHTNESS 1.0
	#define ARTIFACTING 1.0
	#define FRINGING 1.0
#elif defined(SVIDEO)
	#define SATURATION 1.0
	#define BRIGHTNESS 1.0
	#define ARTIFACTING 0.0
	#define FRINGING 0.0
#endif
// end params

uniform int uFrame;
uniform float uInterlace;

// fragment compatibility #defines

#if defined(COMPOSITE) || defined(SVIDEO)
mat3 mix_mat = mat3(
	BRIGHTNESS, FRINGING, FRINGING,
	ARTIFACTING, 2.0 * SATURATION, 0.0,
	ARTIFACTING, 0.0, 2.0 * SATURATION
);
#endif

// begin ntsc-rgbyuv
const mat3 yiq2rgb_mat = mat3(
	1.0, 0.956, 0.6210,
	1.0, -0.2720, -0.6474,
	1.0, -1.1060, 1.7046);

vec3 yiq2rgb(vec3 yiq)
{
	return yiq * yiq2rgb_mat;
}

const mat3 yiq_mat = mat3(
	0.2989, 0.5870, 0.1140,
	0.5959, -0.2744, -0.3216,
	0.2115, -0.5229, 0.3114
);

vec3 rgb2yiq(vec3 col)
{
	return col * yiq_mat;
}
// end ntsc-rgbyuv

#define TAPS 32
const float luma_filter[TAPS + 1] = float[TAPS + 1](
	-0.000174844,
	-0.000205844,
	-0.000149453,
	-0.000051693,
	0.000000000,
	-0.000066171,
	-0.000245058,
	-0.000432928,
	-0.000472644,
	-0.000252236,
	0.000198929,
	0.000687058,
	0.000944112,
	0.000803467,
	0.000363199,
	0.000013422,
	0.000253402,
	0.001339461,
	0.002932972,
	0.003983485,
	0.003026683,
	-0.001102056,
	-0.008373026,
	-0.016897700,
	-0.022914480,
	-0.021642347,
	-0.008863273,
	0.017271957,
	0.054921920,
	0.098342579,
	0.139044281,
	0.168055832,
	0.178571429);

const float chroma_filter[TAPS + 1] = float[TAPS + 1](
	0.001384762,
	0.001678312,
	0.002021715,
	0.002420562,
	0.002880460,
	0.003406879,
	0.004004985,
	0.004679445,
	0.005434218,
	0.006272332,
	0.007195654,
	0.008204665,
	0.009298238,
	0.010473450,
	0.011725413,
	0.013047155,
	0.014429548,
	0.015861306,
	0.017329037,
	0.018817382,
	0.020309220,
	0.021785952,
	0.023227857,
	0.024614500,
	0.025925203,
	0.027139546,
	0.028237893,
	0.029201910,
	0.030015081,
	0.030663170,
	0.031134640,
	0.031420995,
	0.031517031);

// #define fetch_offset(offset, one_x) \\
// 	pass1(uv - vec2(0.5 / openfl_TextureSize.x, 0.0) + vec2((offset) * (one_x), 0.0)).xyzw

#define fetch_offset(offset, one_x) \\
	pass1(uv + vec2((offset - 0.5) * one_x, 0.0)).xyzw

vec4 pass1(vec2 uv)
{
	vec2 fragCoord = uv * openfl_TextureSize;

	vec4 cola = texture2D(bitmap, uv).rgba;
	vec3 yiq = rgb2yiq(cola.rgb);

	#if defined(TWO_PHASE)
		float chroma_phase = PI * (mod(fragCoord.y, 2.0) + float(uFrame));
	#elif defined(THREE_PHASE)
		float chroma_phase = 0.6667 * PI * (mod(fragCoord.y, 3.0) + float(uFrame));
	#endif

	float mod_phase = chroma_phase + fragCoord.x * CHROMA_MOD_FREQ;

	float i_mod = cos(mod_phase);
	float q_mod = sin(mod_phase);

	if(uInterlace == 1.0) {
		yiq.yz *= vec2(i_mod, q_mod); // Modulate.
		yiq *= mix_mat; // Cross-talk.
		yiq.yz *= vec2(i_mod, q_mod); // Demodulate.
	}
	return vec4(yiq, cola.a);
}

void main()
{
	vec2 uv = openfl_TextureCoordv;
	vec2 fragCoord = uv * openfl_TextureSize;

	float one_x = 1.0 / openfl_TextureSize.x;
	vec4 signal = vec4(0.0);

	for (int i = 0; i < TAPS; i++)
	{
		float offset = float(i);

		vec4 sums = fetch_offset(offset - float(TAPS), one_x) +
			fetch_offset(float(TAPS) - offset, one_x);

		signal += sums * vec4(luma_filter[i], chroma_filter[i], chroma_filter[i], 1.0);
	}
	signal += pass1(uv - vec2(0.5 / openfl_TextureSize.x, 0.0)).xyzw *
		vec4(luma_filter[TAPS], chroma_filter[TAPS], chroma_filter[TAPS], 1.0);

	vec3 rgb = yiq2rgb(signal.xyz);
	float alpha = signal.a/(TAPS+1);
	vec4 color = vec4(pow(rgb, vec3(NTSC_CRT_GAMMA / NTSC_MONITOR_GAMMA)), texture2D(bitmap, uv).a);
	gl_FragColor = color;
}
')

	var topPrefix:String = "";

	public function new() {
		topPrefix = "";
		__glSourceDirty = true;

		super();

		this.uFrame.value = [0];
		this.uInterlace.value = [1];
	}

	public var interlace(get, set):Bool;

	function get_interlace() {
		return this.uInterlace.value[0] == 1.0;
	}
	function set_interlace(val:Bool) {
		this.uInterlace.value[0] = val ? 1.0 : 0.0;
		return val;
	}

	override function __updateGL() {
		//this.uFrame.value[0]++;
		this.uFrame.value[0] = (this.uFrame.value[0] + 1) % 2;

		super.__updateGL();
	}

	@:noCompletion private override function __initGL():Void
	{
		if (__glSourceDirty || __paramBool == null)
		{
			__glSourceDirty = false;
			program = null;

			__inputBitmapData = new Array();
			__paramBool = new Array();
			__paramFloat = new Array();
			__paramInt = new Array();

			__processGLData(glVertexSource, "attribute");
			__processGLData(glVertexSource, "uniform");
			__processGLData(glFragmentSource, "uniform");
		}

		@:privateAccess if (__context != null && program == null)
		{
			var gl = __context.gl;

			#if (js && html5)
			var prefix = (precisionHint == FULL ? "precision mediump float;\n" : "precision lowp float;\n");
			#else
			var prefix = "#ifdef GL_ES\n"
				+ (precisionHint == FULL ? "#ifdef GL_FRAGMENT_PRECISION_HIGH\n"
					+ "precision highp float;\n"
					+ "#else\n"
					+ "precision mediump float;\n"
					+ "#endif\n" : "precision lowp float;\n")
				+ "#endif\n\n";
			#end

			var vertex = prefix + glVertexSource;
			var fragment = prefix + glFragmentSource;

			var id = vertex + fragment;

			if (__context.__programs.exists(id))
			{
				program = __context.__programs.get(id);
			}
			else
			{
				program = __context.createProgram(GLSL);

				// TODO
				// program.uploadSources (vertex, fragment);
				program.__glProgram = __createGLProgram(vertex, fragment);

				__context.__programs.set(id, program);
			}

			if (program != null)
			{
				glProgram = program.__glProgram;

				for (input in __inputBitmapData)
				{
					if (input.__isUniform)
					{
						input.index = gl.getUniformLocation(glProgram, input.name);
					}
					else
					{
						input.index = gl.getAttribLocation(glProgram, input.name);
					}
				}

				for (parameter in __paramBool)
				{
					if (parameter.__isUniform)
					{
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}

				for (parameter in __paramFloat)
				{
					if (parameter.__isUniform)
					{
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}

				for (parameter in __paramInt)
				{
					if (parameter.__isUniform)
					{
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}
			}
		}
	}
}

class ReflectionShader extends FlxShader
{
  @:glFragmentSource('
  
    #pragma header

    uniform float reflectionY;


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

        gl_FragColor = texture2D(bitmap, uv) * Color;
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
    
    float sat(float t) {
        return clamp(t, 0.0, 1.0);
    }
    
    vec2 sat(vec2 t) {
        return clamp(t, 0.0, 1.0);
    }
    
    //remaps inteval [a;b] to [0;1]
    float remap(float t, float a, float b) {
        return sat((t - a) / (b - a));
    }
    
    //note: /\\ t=[0;0.5;1], y=[0;1;0]
    float linterp(float t) {
        return sat(1.0 - abs(2.0*t - 1.0));
    }
    
    vec3 spectrum_offset(float t) {
        float t0 = 3.0 * t - 1.5;
        return clamp(vec3(-t0, 1.0-abs(t0), t0), 0.0, 1.0);
        /*
        vec3 ret;
        float lo = step(t,0.5);
        float hi = 1.0-lo;
        float w = linterp(remap(t, 1.0/6.0, 5.0/6.0));
        float neg_w = 1.0-w;
        ret = vec3(lo,1.0,hi) * vec3(neg_w, w, neg_w);
        return pow(ret, vec3(1.0/2.2));
    */
    }
    
    //note: [0;1]
    float rand(vec2 n) {
      return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
    }
    
    //note: [-1;1]
    float srand(vec2 n) {
        return rand(n) * 2.0 - 1.0;
    }
    
    float mytrunc(float x, float num_levels)
    {
        return floor(x*num_levels) / num_levels;
    }
    vec2 mytrunc(vec2 x, float num_levels)
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
        
        float gnm = sat(GLITCH);
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
        for(int i=0; i<NUM_SAMPLES; ++i )
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
    
        //gl_FragColor = vec4(sum.bbb, 1.0); return;
        
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
      	vec4 video = texture2D(bitmap,look);

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

    	uv.x -= 0.05 * mix(texture2D(noiseTex, vec2(uv.x, amount)).r * amount, amount, 0.9);

    	return uv;
    }

    void main()
    {
    	vec2 uv = openfl_TextureCoordv;
      vec2 tvWow = screenDistort(uv);
      if(distortionOn){
        uv.x += rand(vec2(0., (uv.y/125.0) + iTime))/256.;
        uv.y += rand(vec2(0., (uv.x/125.0) + iTime))/256.;
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
        gl_FragColor = vec4(0.,0.,0.,0.);
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
  
      vec3 col = texture2D(iChannel0, uv).rgb;
      
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

uniform float amount;

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

    uniform float binaryIntensity;
    uniform float negativity;
    
    void main(){
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
    
        vec4 mierdaColor = texture2D(bitmap, vec2(rx, ry));

        gl_FragColor = mix(mierdaColor, vec4(1.0 - mierdaColor.r, 1.0 - mierdaColor.g, 1.0 - mierdaColor.b, mierdaColor.a) * mierdaColor.a, negativity);
    }
    ')
  
    public function new()
	{
                //binaryIntensity.value = [1000.0];

		super();
	}
}

class OldTVShader extends FlxShader {
	@:glFragmentSource('
		#pragma header
		
		#define id vec2(0.0,1.0)
		//#define k 1103515245.0  //1103515245U
		#define PI 3.141592653
		#define TAU (PI * 2.0)
		
		uniform float iTime;
		
		//prng func, from https://stackoverflow.com/a/52207531
		
		vec3 hash(vec3 p) {
			p = fract(p * 0.1031);
			p += dot(p, p.yzx + 33.33);
			return fract(vec3((p.x + p.y) * p.z, (p.y + p.z) * p.x, (p.z + p.x) * p.y));
		} //different hash, yea
		
		/*vec3 hash(uvec3 x) {
			x = ((x>>8U)^x.yzx)*k;
			x = ((x>>8U)^x.yzx)*k;
			x = ((x>>8U)^x.yzx)*k;
			return vec3(x)*(1.0/float(0xffffffffU));
		}*/
		
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
			float position2 = 99.0;
			
			if (iTime > repeatTime) {
				position2 = mod(iTime - repeatTime, timeMod) / time;
			}
			if (!(uv.y - position > realSize || uv.y - position < -realSize)) {
				uv.x -= hash(vec3(0.0, uv.y * uvyMul, iTime * updateRate2)).x * offsetMul;
				flag = true;
			} else if (position2 != 99.0) {
				if (!(uv.y - position2 > realSize || uv.y - position2 < -realSize)) {
					uv.x -= hash(vec3(0.0, uv.y * uvyMul, iTime * updateRate2)).x * offsetMul;
					flag = true;
				}
			}
			
			vec4 col = texture2D(bitmap, uv);
			
			//blur, from https://www.shadertoy.com/view/Xltfzj
			float directions = 16.0;
			float quality = 3.0;
			float size = 4.0;
			
			vec2 radius = size / openfl_TextureSize;
			for(float d = 0.0; d < TAU; d += TAU / directions) {
				for(float i = 1.0 / quality; i <= 1.0; i += 1.0 / quality) {
					col += texture2D(bitmap, uv + vec2(cos(d), sin(d)) * radius * i);
				}
			}
			col /= quality * directions - 14.0;
			
			//for the black on the left
			if (uv.x < 0.0) {
				col = id.xxxy;
				flag = false;
				flag2 = true;
			}
			
			//randomized black shit and sploches
			float updateRate4 = 100.0;
			float uvyMul3 = 100.0;
			float cutoff2 = 0.92;
			float valMul2 = 0.007;
			
			float val2 = hash(vec3(uv.y * uvyMul3, 0.0, iTime * updateRate4)).x;
			if (val2 > cutoff2) {
				float adjVal2 = (val2 - cutoff2) * valMul2 * (1.0 / (1.0 - cutoff2));
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
				col = mix(col, vec4(hash(vec3(uv * openfl_TextureSize, iTime * updateRate)).rrr, 1.0), mixPercent);
			}
			
			//white sploches
			float updateRate3 = 75.0;
			float uvyMul2 = 400.0;
			float uvxMul = 20.0;
			float cutoff = 0.95;
			float valMul = 0.7;
			float falloffMul = 0.7;
			
			if (flag) {
				float val = hash(vec3(uv.x * uvxMul, uv.y * uvyMul2, iTime * updateRate3)).x;
				if (val > cutoff) {
					float offset = hash(vec3(uv.y * uvyMul2, uv.x * uvxMul, iTime * updateRate3)).x;
					float adjVal = (val - cutoff) * valMul * (1.0 / (1.0 - cutoff));
					adjVal -= abs((uv.x * uvxMul - (floor(uv.x * uvxMul) + offset)) * falloffMul);
					adjVal = clamp(adjVal, 0.0, 1.0);
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
