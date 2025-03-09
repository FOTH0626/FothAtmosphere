#ifndef SKY_VIEW_HLSL
#define SKY_VIEW_HLSL

#include "AtmosphereParams.hlsl"
#include "Helper.hlsl"
#include "Scattering.hlsl"
#include "Transmittance.hlsl"
#include "MultiScattering.hlsl"

float3 GetSkyView(in AtmosphereParams params,
                    float3 eyePos,
                    float3 viewDir,
                    float3 lightDir,
                    float maxDistance,
                    Texture2D TransmittanceLut,
                    Texture2D MultiScatteringLut,
                    SamplerState samplerLinearClamp)
{
    const int N_SAMPLE = 32;
    float3 color = float3(0,0,0);

    float distanceToAtmosphere = RayIntersectSphereLength(float3(0,0,0), params.PlanetRadius + params.AtmosphereHeight, eyePos, viewDir);
    float distanceToPlanet = RayIntersectSphereLength(float3(0,0,0), params.PlanetRadius , eyePos, viewDir);

    if (distanceToAtmosphere < 0) return color;
    //what the fuck??!!
    //    if (distanceToAtmosphere > 0) distanceToAtmosphere = min(distanceToAtmosphere, distanceToPlanet);
    if (distanceToPlanet > 0) distanceToAtmosphere = min(distanceToAtmosphere, distanceToPlanet);
    if (maxDistance > 0) distanceToAtmosphere = min(distanceToAtmosphere, maxDistance);

    float ds = distanceToAtmosphere / float(N_SAMPLE);
    float3 p = eyePos + (viewDir * ds) * 0.5;
    float3 sunLuminance = params.SunLightColor * params.SunLightIntensity;
    float3 opticalDepth = float3(0,0,0);

    for (int i = 0; i < N_SAMPLE; i++)
    {
        float height = length(p) - params.PlanetRadius;
        float3 extinction = RayleighCoefficient(params, height) + MieCoefficient(params, height) +
                            OzoneAbsorption(params, height) + MieAbsorption(params, height);
        opticalDepth += extinction * ds;

        float3 t1 = TransmittanceToAtmosphereByLut(params,p,lightDir, TransmittanceLut, samplerLinearClamp);
        float3 s = ScatteringOnPoint(params, p, lightDir,viewDir);
        float3 t2 = exp(-opticalDepth);

        float3 inScattering = t1 * s * t2 * ds * sunLuminance;
        color += inScattering;
        
        float3 multiScattering = GetMultiScattering(params, p, lightDir, MultiScatteringLut, samplerLinearClamp);
        color += multiScattering * t2 * ds * sunLuminance;

        p += viewDir * ds;
    }

    return  color;
}

#endif