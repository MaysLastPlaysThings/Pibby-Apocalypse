// what the fuck why not just make these normal shaders :sob:
// 

enum abstract RuntimeShaders(String) to String from String 
{
    var distort = 
    "#pragma header

    uniform float binaryIntensity = 1000.0;
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
    
        vec4 color = flixel_texture2D(bitmap, vec2(rx, ry));
    
        gl_FragColor = mix(color, vec4(1.0 - color.r, 1.0 - color.g, 1.0 - color.b, color.a) * color.a, negativity);
    }
    ";
    
    var glowy = "
    //SHADERTOY PORT FIX
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    uniform float Size;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    const float blurSize = 1.0/512.0;
    const float intensity = 0.85;

    void mainImage()
    {
       vec4 sum = vec4(0);
       vec2 texcoord = fragCoord.xy/iResolution.xy;
       int j;
       int i;
    
       sum += texture(iChannel0, vec2(texcoord.x - 4.0*blurSize, texcoord.y)) * 0.05;
       sum += texture(iChannel0, vec2(texcoord.x - 3.0*blurSize, texcoord.y)) * 0.09;
       sum += texture(iChannel0, vec2(texcoord.x - 2.0*blurSize, texcoord.y)) * 0.12;
       sum += texture(iChannel0, vec2(texcoord.x - blurSize, texcoord.y)) * 0.15;
       sum += texture(iChannel0, vec2(texcoord.x, texcoord.y)) * 0.16;
       sum += texture(iChannel0, vec2(texcoord.x + blurSize, texcoord.y)) * 0.15;
       sum += texture(iChannel0, vec2(texcoord.x + 2.0*blurSize, texcoord.y)) * 0.12;
       sum += texture(iChannel0, vec2(texcoord.x + 3.0*blurSize, texcoord.y)) * 0.09;
       sum += texture(iChannel0, vec2(texcoord.x + 4.0*blurSize, texcoord.y)) * 0.05;
        
       sum += texture(iChannel0, vec2(texcoord.x, texcoord.y - 4.0*blurSize)) * 0.05;
       sum += texture(iChannel0, vec2(texcoord.x, texcoord.y - 3.0*blurSize)) * 0.09;
       sum += texture(iChannel0, vec2(texcoord.x, texcoord.y - 2.0*blurSize)) * 0.12;
       sum += texture(iChannel0, vec2(texcoord.x, texcoord.y - blurSize)) * 0.15;
       sum += texture(iChannel0, vec2(texcoord.x, texcoord.y)) * 0.16;
       sum += texture(iChannel0, vec2(texcoord.x, texcoord.y + blurSize)) * 0.15;
       sum += texture(iChannel0, vec2(texcoord.x, texcoord.y + 2.0*blurSize)) * 0.12;
       sum += texture(iChannel0, vec2(texcoord.x, texcoord.y + 3.0*blurSize)) * 0.09;
       sum += texture(iChannel0, vec2(texcoord.x, texcoord.y + 4.0*blurSize)) * 0.05;
    
       fragColor = sum*intensity + texture(iChannel0, texcoord); 
    }
    ";

    // Credits to Andromeda Engine (NebulaTheZoura) for porting from shadertoy!
    var chromShader = "
    #pragma header
    /*
    https://www.shadertoy.com/view/wtt3z2
    */
    
    uniform float aberration;
    
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
        
        vec2 trueAberration = aberration * pow((uv - 0.5), vec2(3.0, 3.0));
        // vec4 texColor = tex2D(bitmap, uv_prj.st);
        gl_FragColor = vec4(
            texture2D(bitmap, uv + trueAberration).r, 
            texture2D(bitmap, uv).g, 
            texture2D(bitmap, uv - trueAberration).b, 
            flixel_texture2D(bitmap,uv).a
        );
    }";

    var monitor = "
    #pragma header

    float zoom = 1;
    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        uv = (uv-.5)*2.;
        uv *= zoom;
        
        uv.x *= 1. + pow(abs(uv.y/2.),3.);
        uv.y *= 1. + pow(abs(uv.x/2.),3.);
        uv = (uv + 1.)*.5;
        
        vec4 tex = vec4( 
            texture2D(bitmap, uv+.001).r,
            texture2D(bitmap, uv).g,
            texture2D(bitmap, uv-.001).b, 
            flixel_texture2D(bitmap, uv).a
        );
        
        tex *= smoothstep(uv.x,uv.x+0.01,1.)*smoothstep(uv.y,uv.y+0.01,1.)*smoothstep(-0.01,0.,uv.x)*smoothstep(-0.01,0.,uv.y);
        
        float avg = (tex.r+tex.g+tex.b)/3.;
        gl_FragColor = tex + pow(avg,3.);
    }";

    // sylinpix / forteni made a joke of the shader and i decided to make it reality lmao
    var dayybloomshader = "
    #pragma header

    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define iChannel1 bitmap
    #define iChannel2 bitmap
    #define iChannelResolution bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main
    uniform float uTime;
    uniform vec4 iMouse;

    const float amount = 1;

    float dim = 2;
    float Directions = 17.0;
    float Quality = 20.0; 
    float Size = 22.0; 
    vec2 Radius = Size/openfl_TextureSize.xy;

    void mainImage()
    { 
        vec2 uv = openfl_TextureCoordv.xy ;

    float Pi = 6.28318530718; // Pi*2
        
    vec4 Color = texture2D( bitmap, uv);
    
    for( float d=0.0; d<Pi; d+=Pi/Directions){
    for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality){
    float ex = (cos(d)*Size*i)/openfl_TextureSize.x;
    float why = (sin(d)*Size*i)/openfl_TextureSize.y;

    Color += flixel_texture2D( bitmap, uv+vec2(ex,why));	
        }
    }
        
    Color /= (dim * Quality) * Directions - 15.0;
    vec4 bloom =  (flixel_texture2D( bitmap, uv)/ dim)+Color;

    gl_FragColor = bloom;

    }";

    // idfk why but using Shaders.hx gives null attacks *sobs
    var blurZoom = "
    #pragma header

    #define round(a) floor(a + 0.5)
    #define texture flixel_texture2D
    #define iResolution openfl_TextureSize
    uniform float iTime;
    #define iChannel0 bitmap

    uniform float posX; // from 0.0 to 1.0
    uniform float posY; // from 0.0 to 1.0
    uniform float focusPower; // 10.0

    #define focusDetail 7.0
    void mainImage( out vec4 fragColor, in vec2 fragCoord )
    {
        vec2 uv = fragCoord.xy / iResolution.xy;
        vec2 pos = vec2(posX, posY);
        vec2 focus = uv - pos;

        vec4 outColor = vec4(0.0);

        for (int i=0; i< int(focusDetail); i++) {
            float power = 1.0 - focusPower * (1.0/iResolution.x) * float(i);
            outColor += texture(iChannel0, focus * power + pos);
        }
        
        outColor *= 1.0 / focusDetail;

        fragColor = outColor;
    }

    void main() {
        mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
    }";

    var fwGlitch = "
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    // https://www.shadertoy.com/view/MltBzf

    float rand(vec2 p)
    {
        float t = floor(iTime * 20.) / 10.;
        return fract(sin(dot(p, vec2(t * 12.9898, t * 78.233))) * 43758.5453);
    }

    float noise(vec2 uv, float blockiness)
    {   
        vec2 lv = fract(uv);
        vec2 id = floor(uv);
        
        float n1 = rand(id);
        float n2 = rand(id+vec2(1,0));
        float n3 = rand(id+vec2(0,1));
        float n4 = rand(id+vec2(1,1));
        
        vec2 u = smoothstep(0.0, 1.0 + blockiness, lv);

        return mix(mix(n1, n2, u.x), mix(n3, n4, u.x), u.y);
    }

    float fbm(vec2 uv, int count, float blockiness, float complexity)
    {
        float val = 0.0;
        float amp = 0.5;
        
        while(count != 0)
        {
            val += amp * noise(uv, blockiness);
            amp *= 0.5;
            uv *= complexity;    
            count--;
        }
        
        return val;
    }

    const float glitchAmplitude = 0.2; // increase this
    const float glitchNarrowness = 4.0;
    const float glitchBlockiness = 2.0;
    const float glitchMinimizer = 5.0; // decrease this

    void mainImage()
    {
        // Normalized pixel coordinates (from 0 to 1)
        vec2 uv = fragCoord/iResolution.xy;
        vec2 a = vec2(uv.x * (iResolution.x / iResolution.y), uv.y);
        vec2 uv2 = vec2(a.x / iResolution.x, exp(a.y));
        vec2 id = floor(uv * 8.0);
        //id.x /= floor(texture(iChannel0, vec2(id / 8.0)).r * 8.0);

        // Generate shift amplitude
        float shift = glitchAmplitude * pow(fbm(uv2, int(rand(id) * 6.), glitchBlockiness, glitchNarrowness), glitchMinimizer);
        
        // Create a scanline effect
        float scanline = abs(cos(uv.y * 400.));
        scanline = smoothstep(0.0, 2.0, scanline);
        shift = smoothstep(0.00001, 0.2, shift);
        
        // Apply glitch and RGB shift
        float colR = texture(iChannel0, vec2(uv.x + shift, uv.y)).r * (1. - shift) ;
        float colG = texture(iChannel0, vec2(uv.x - shift, uv.y)).g * (1. - shift) + rand(id) * shift;
        float colB = texture(iChannel0, vec2(uv.x - shift, uv.y)).b * (1. - shift);
        // Mix with the scanline effect
        vec3 f = vec3(colR, colG, colB) - (0.1 * scanline);
        
        // Output to screen
        fragColor = vec4(f, 1.0);
    gl_FragColor.a = flixel_texture2D(bitmap, openfl_TextureCoordv).a;
    }
    ";

    var file = "
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define iChannel1 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    // https://www.shadertoy.com/view/NtGfWw

    float noise(vec2 p)
    {
        float s = texture(iChannel1,vec2(1.,2.*cos(iTime))*iTime*8. + p*1.).x;
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
        
        float noi = noise(uv*vec2(0.5,1.) + vec2(1.,3.));
        return ramp(mod(uv.y*4. + iTime/2.+sin(iTime + sin(iTime*0.63)),1.),0.5,0.6)*noi;
    }

    vec3 getVideo(vec2 uv)
    {
        vec2 look = uv;
        float window = 1./(1.+20.*(look.y-mod(iTime/4.,1.))*(look.y-mod(iTime/4.,1.)));
        look.x = look.x + sin(look.y*10. + iTime)/50.*onOff(4.,4.,.3)*(1.+cos(iTime*80.))*window;
        float vShift = 0.4*onOff(2.,3.,.9)*(sin(iTime)*sin(iTime*20.) + 
                                            (0.5 + 0.1*sin(iTime*200.)*cos(iTime)));
        look.y = mod(look.y + vShift, 1.);
        vec3 video = vec3(texture2D(iChannel0,look));
        return video;
    }

    vec2 screenDistort(vec2 uv)
    {
        uv -= vec2(.5,.5);
        uv = uv*1.2*(1./1.2+2.*uv.x*uv.x*uv.y*uv.y);
        uv += vec2(.5,.5);
        return uv;
    }

    void main()
    {
    vec2 fragCoord = openfl_TextureCoordv * iResolution;
        vec2 uv = fragCoord.xy / iResolution.xy;
        uv = screenDistort(uv);
        vec3 video = getVideo(uv);
        float vigAmt = 3.+.3*sin(iTime + 5.*cos(iTime*5.));
        float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));
        
        video += stripes(uv);
        video += noise(uv*2.)/2.;
        video *= vignette;
        video *= (12.+mod(uv.y*30.+iTime,1.))/13.;
        
        gl_FragColor = vec4(video,1.0);
    gl_FragColor.a = flixel_texture2D(bitmap, openfl_TextureCoordv).a;
    }";

    var pixel = 
    "#pragma header
	vec2 uv = openfl_TextureCoordv.xy;
	vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
	vec2 iResolution = openfl_TextureSize;
	uniform float iTime;
	#define iChannel0 bitmap
	#define texture flixel_texture2D
	#define fragColor gl_FragColor
	#define mainImage main

	uniform float size = 5.0;

	void mainImage() {
		vec2 coordinates = fragCoord.xy/iResolution.xy;
		vec2 pixelSize = vec2(size/iResolution.x, size/iResolution.y);
		vec2 position = floor(coordinates/pixelSize)*pixelSize;
		vec4 finalColor = texture(iChannel0, position);
		fragColor = finalColor;
	}";
}