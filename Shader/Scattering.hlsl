#ifndef __SCATTERING_HLSL__
#define __SCATTERING_HLSL__
    
#include "AtmosphereParams.hlsl"


float3 RayleighCoefficient(in AtmosphereParams params, float height)
{
    const float3 sigma = float3(5.802, 13.558, 33.1) * 1e-6;
    float scalarHeight = params.RayleighScatteringScalarHeight;
    float rho_h = exp(-(height / scalarHeight));
    return sigma * rho_h;
}

float RayleighPhase(float cos_theta)
{
    return (3.0 / (16.0 * PI)) * (1.0 + cos_theta * cos_theta);
}

float3 MieCoefficient(in AtmosphereParams params, float height)
{
    const float3 sigma = (3.996 * 1e-6).xxx;
    float scalarHeight = params.MieScatteringScalarHeight;
    float rho_h = exp(-(height/scalarHeight));
    return sigma * rho_h;
}

float MiePhase(in AtmosphereParams param, float cos_theta)
{
    float g = param.MieAnisotropy;

    float a = 3.0/(8.0 * PI);
    float b = (1-g*g)/(2+g*g);
    float c = 1.0 + cos_theta * cos_theta;
    float d = pow(1.0 + g*g - 2*g*cos_theta, 1.5);

    return a * b * c / d ;
}

float3 ScatteringOnPoint(in AtmosphereParams params, float3 position, float3 inDirection, float3 outDirection)
{

    float cos_theta = dot(normalize(inDirection), normalize(outDirection));

    float height = length(position) - params.PlanetRadius;
    float3 rayleigh = RayleighCoefficient(params, height) * RayleighPhase(cos_theta);
    float3 mie = MieCoefficient(params, height) * MiePhase(params, cos_theta);

    return  rayleigh + mie;
    
}

float3 MieAbsorption(in AtmosphereParams param, float height)
{
    const float3 sigma = (4.4 * 1e-6).xxx;
    float H_M = param.MieScatteringScalarHeight;
    float rho_h = exp(-(height / H_M));
    return sigma * rho_h;
}

float3 OzoneAbsorption(in AtmosphereParams param, float height)
{
    const float3 sigma_ozone = (float3(0.650f, 1.881f, 0.085f)) * 1e-6;
    float center = param.OzoneLevelCenterHeight;
    float width = param.OzoneLevelWidth;
    float rho = max(0, 1.0 - (abs(height - center) / width));
    return sigma_ozone * rho;
}



#endif