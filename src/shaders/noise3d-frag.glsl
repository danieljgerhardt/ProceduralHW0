#version 300 es

precision highp float;

uniform vec4 u_Color;

in vec4 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col; 

vec3 random3(vec3 p) {
    return fract(sin(vec3(dot(p, vec3(127.1, 311.7, 1237.3)),
                          dot(p, vec3(269.5, 183.3, 96732.2)),
                          dot(p, vec3(420.6, 631.2, 4545.2))
                    )) * 43758.5453);
}

float worley3d(vec3 p) {
    p *= 0.5;
    vec3 pInt = floor(p);
    vec3 pFract = fract(p);
    float minDist = 1.0;
    for (int z = -1; z <= 1; ++z) {
        for (int y = -1; y <= 1; ++y) {
            for (int x = -1; x <= 1; ++x) {
                vec3 neighbor = vec3(float(x), float(y), float(z));
                vec3 point = random3(pInt + neighbor);
                vec3 diff = neighbor + point - pFract;
                float dist = length(diff);
                minDist = min(minDist, dist);
            }
        }
    }
    
    return minDist;
}

float interpNoise3D(float x, float y, float z) {
    vec3 p = floor(vec3(x, y, z));
	vec3 f = fract(vec3(x, y, z));
	f = f * f * (3.0 - 2.0 * f);
	
	return mix(	mix(mix( worley3d(p+vec3(0,0,0)), 
						worley3d(p+vec3(1,0,0)),f.x),
					mix( worley3d(p+vec3(0,1,0)), 
						worley3d(p+vec3(1,1,0)),f.x),f.y),
				mix(mix( worley3d(p+vec3(0,0,1)), 
						worley3d(p+vec3(1,0,1)),f.x),
					mix( worley3d(p+vec3(0,1,1)), 
						worley3d(p+vec3(1,1,1)),f.x),f.y),f.z);
}

float fbm(float x, float y, float z) {
    float total = 0.f;
    float persistence = 0.75f;
    int octaves = 8;
    float freq = 2.f;
    float amp = 0.5f;
    for(int i = 1; i <= octaves; i++) {
        total += interpNoise3D(x * freq,
                               y * freq,
                               z * freq) * amp;

        freq *= 2.f;
        amp *= persistence;
    }
    return total;
}

void main()
{
    float noise = fbm(fs_Pos.x, fs_Pos.y, fs_Pos.z);

    vec4 diffuseColor = vec4(pow(noise, 4.f) * 0.6f, noise * 0.05f, noise * 0.1f, 1.0);

    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));

    float ambientTerm = 0.2;

    float lightIntensity = diffuseTerm + ambientTerm;

    out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
