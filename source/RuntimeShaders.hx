enum abstract RuntimeShaders(String) to String from String 
{
    var distort = 
    "#pragma header

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
    
        gl_FragColor = flixel_texture2D(bitmap, vec2(rx, ry));
    }
    ";    

    var chromShader = "
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
}