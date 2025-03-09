using System;
using UnityEngine;
using UnityEngine.Serialization;


[Serializable]
[CreateAssetMenu(fileName = "Atmosphere", menuName = "AtmosphereSetings")]
public class AtmosphereSettings : ScriptableObject
{
    [FormerlySerializedAs("SeaLevel")] [SerializeField]
    public float seaLevel = 0.0f;

    [FormerlySerializedAs("PlanetRadius")] [SerializeField]
    public float planetRadius = 6360000.0f;

    [FormerlySerializedAs("AtmosphereHeight")] [SerializeField]
    public float atmosphereHeight = 60000.0f;

    [FormerlySerializedAs("SunLightIntensity")] [SerializeField]
    public float sunLightIntensity = 31.4f;

    [FormerlySerializedAs("SunLightColor")] [SerializeField]
    public Color sunLightColor = Color.white;

    [FormerlySerializedAs("SunDiskAngle")] [SerializeField]
    public float sunDiskAngle = 1.0f;

    [FormerlySerializedAs("RayleighScatteringScale")] [SerializeField]
    public float rayleighScatteringScale = 1.0f;

    [FormerlySerializedAs("RayleighScatteringScalarHeight")] [SerializeField]
    public float rayleighScatteringScalarHeight = 8000.0f;

    [FormerlySerializedAs("MieScatteringScale")] [SerializeField]
    public float mieScatteringScale = 1.0f;

    [FormerlySerializedAs("MieAnisotropy")] [SerializeField]
    public float mieAnisotropy = 0.8f;

    [FormerlySerializedAs("MieScatteringScalarHeight")] [SerializeField]
    public float mieScatteringScalarHeight = 1200.0f;

    [FormerlySerializedAs("OzoneAbsorptionScale")] [SerializeField]
    public float ozoneAbsorptionScale = 1.0f;

    [FormerlySerializedAs("OzoneLevelCenterHeight")] [SerializeField]
    public float ozoneLevelCenterHeight = 25000.0f;

    [FormerlySerializedAs("OzoneLevelWidth")] [SerializeField]
    public float ozoneLevelWidth = 15000.0f;

    [FormerlySerializedAs("AerialPerspectiveDistance")] [SerializeField]
    public float aerialPerspectiveDistance = 32000.0f;
}
