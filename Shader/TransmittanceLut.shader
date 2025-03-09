Shader "FothAtmosphere/TransmittanceLut"
{
    Properties {}
    
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always
        
        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma  fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Transmittance.hlsl"
            #include "Helper.hlsl"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct  v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata input )
            {
                v2f output;
                output.uv = input.uv;
                output.vertex = TransformObjectToHClip(input.vertex);
                return output;
            }

            float4 frag ( v2f input ): SV_Target
            {
                AtmosphereParams params = GetAtmosphereParameter();

                float4 color = float4(0,0,0,1);
                float2 uv = input.uv;

                float bottomRadius = params.PlanetRadius;
                float topRadius = params.PlanetRadius + params.AtmosphereHeight;

                float cos_theta = 0.0;
                float r = 0.0;
                GetTransmittanceLutParamsFromUV(bottomRadius, topRadius, uv, cos_theta, r);

                float sin_theta = sqrt(1 -cos_theta * cos_theta);
                float3 viewDir = float3(sin_theta, cos_theta ,0);
                float3 eyePos = float3(0, r, 0);

                float distance = RayIntersectSphereLength(float3(0,0,0),params.PlanetRadius + params.AtmosphereHeight, eyePos, viewDir);

                float3 hitPoint = eyePos + distance * viewDir;

                color.rgb = Transmittance(params, eyePos,hitPoint);

                
                return  color;
            }    
            
            ENDHLSL
        }
    }
}