#ifndef TRANSMITTANCE_HLSL
#define TRANSMITTANCE_HLSL


#include "Scattering.hlsl"
#include "Helper.hlsl"


//Transmittance from position1 to position2
float3 Transmittance( in AtmosphereParams params, float3 position1, float3 position2 )
{
    const int N_SAMPLE = 32;

    float3 direction = normalize(position2 - position1);
    float distance = length(position2 - position1);

    float delta_s = distance / N_SAMPLE;

    float3 sum = 0.0;

    float3 sample_distance = direction * delta_s;
    float3 sample_position = position1 +  sample_distance * 0.5;

    for ( int i = 0; i < N_SAMPLE; i++)
    {
        float height = length(sample_position) - params.PlanetRadius;

        float3 scattering = RayleighCoefficient(params, height) + MieCoefficient(params, height);
        float3 absorption = MieAbsorption(params, height) + OzoneAbsorption(params, height);

        float3 extinction = scattering + absorption;

        sum += extinction * delta_s;
        sample_position += sample_distance;
    }

    return exp(-sum);
}

float3 TransmittanceToAtmosphereByLut(in AtmosphereParams params, float3 position, float3 direction, Texture2D lut, SamplerState spl)
{
    float bottomRadius = params.PlanetRadius;
    float topRadius = params.PlanetRadius + params.AtmosphereHeight;

    float3 upVector = normalize(position);
    float cos_theta = dot(upVector, direction);
    float r = length(position);

    float2 uv = GetTransmittanceLutUvFromParams(bottomRadius, topRadius, cos_theta, r);
    return lut.SampleLevel(spl, uv, 0).rgb;
}

#endif