Shader "FothAtmosphere/Skybox"
{
    Properties
    {
        _SourceHdrTexture("Source HDR Texture", 2D) = "white"{}
    }
    
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Off
        
        Pass
        {
            HLSLPROGRAM

            #pragma  vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #include "Transmittance.hlsl"
            #include "Helper.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0 ;
                
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : SEMANTIC_HELLO_WORLD;
            };

            v2f vert(appdata input )
            {
                v2f o ;
                o.vertex = TransformObjectToHClip(input.vertex);
                o.worldPos = TransformObjectToWorld(input.vertex.xyz);
                return o;
            }

            SAMPLER(sampler_LinearClamp);
            Texture2D _skyViewLut;
            Texture2D _transmittanceLut;

            float3 GetSunDisk(in AtmosphereParams params, float3 eyePos, float3 viewDir, float3 lightDir)
            {
                float cosine_theta = dot(viewDir, -lightDir);
                float theta = acos(cosine_theta) * (180.0 / PI);
                float3 sunLuminance = params.SunLightColor * params.SunLightIntensity;

                // 判断光线是否被星球阻挡
                float disToPlanet = RayIntersectSphereLength(float3(0,0,0), params.PlanetRadius, eyePos, viewDir);
                if(disToPlanet >= 0) return float3(0,0,0);

                // 和大气层求交
                float disToAtmosphere = RayIntersectSphereLength(float3(0,0,0), params.PlanetRadius + params.AtmosphereHeight, eyePos, viewDir);
                if(disToAtmosphere < 0) return float3(0,0,0);

                // 计算衰减
                //float3 hitPoint = eyePos + viewDir * disToAtmosphere;
                //sunLuminance *= Transmittance(param, hitPoint, eyePos);
                sunLuminance *= TransmittanceToAtmosphereByLut(params, eyePos, viewDir, _transmittanceLut, sampler_LinearClamp);

                if(theta < params.SunDiskAngle) return sunLuminance;
                return float3(0,0,0);
            }

            float4 frag (v2f i ) :SV_Target
            {
                AtmosphereParams params = GetAtmosphereParameter();

                float3 color = float3(0,0,0);
                float3 viewDir = normalize(i.worldPos);

                Light mainLight = GetMainLight();

                float3 lightDir = -mainLight.direction;

                float h = _WorldSpaceCameraPos.y - params.SeaLevel + params.PlanetRadius;
                float3 eyePos = float3(0, h, 0);

                color += SAMPLE_TEXTURE2D_X(_skyViewLut, sampler_LinearClamp, ViewDirToUV(viewDir)).rgb;
                color += GetSunDisk(params, eyePos, viewDir,lightDir);

                return float4(color,1);
            }
            
            ENDHLSL
        }
    }
}