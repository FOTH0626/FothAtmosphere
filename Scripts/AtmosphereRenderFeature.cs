using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class AtmosphereRenderFeature : ScriptableRendererFeature
{
    class CustomRenderPass : ScriptableRenderPass
    {
        private RenderTexture m_skyViewLut;
        private RenderTexture m_transmittanceLut;
        RenderTexture m_multiScatteringLut;
        

        public Material transmittanceLutMaterial;
        public Material skyViewLutMaterial;
        public Material multiScatteringLutMaterial;

        public AtmosphereSettings AtmosphereSettings;
        
        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in a performant manner.
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            m_skyViewLut = RenderTexture.GetTemporary(256, 128, 0, RenderTextureFormat.ARGBFloat);
            m_transmittanceLut = RenderTexture.GetTemporary(256, 64, 0, RenderTextureFormat.ARGBFloat);
            m_multiScatteringLut = RenderTexture.GetTemporary(32, 32, 0, RenderTextureFormat.ARGBFloat);
        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get();
            
            cmd.SetGlobalTexture("_skyViewLut", m_skyViewLut);
            cmd.SetGlobalTexture("_transmittanceLut", m_transmittanceLut);

            cmd.SetGlobalTexture("_multiScatteringLut", m_multiScatteringLut);

            
            cmd.SetGlobalFloat("_SeaLevel", AtmosphereSettings.seaLevel);
            cmd.SetGlobalFloat("_PlanetRadius", AtmosphereSettings.planetRadius);
            cmd.SetGlobalFloat("_AtmosphereHeight", AtmosphereSettings.atmosphereHeight);
            cmd.SetGlobalFloat("_SunLightIntensity", AtmosphereSettings.sunLightIntensity);
            cmd.SetGlobalColor("_SunLightColor", AtmosphereSettings.sunLightColor);
            cmd.SetGlobalFloat("_SunDiskAngle", AtmosphereSettings.sunDiskAngle);
            cmd.SetGlobalFloat("_RayleighScatteringScale", AtmosphereSettings.rayleighScatteringScale);
            cmd.SetGlobalFloat("_RayleighScatteringScalarHeight", AtmosphereSettings.rayleighScatteringScalarHeight);
            cmd.SetGlobalFloat("_MieScatteringScale", AtmosphereSettings.mieScatteringScale);
            cmd.SetGlobalFloat("_MieAnisotropy", AtmosphereSettings.mieAnisotropy);
            cmd.SetGlobalFloat("_MieScatteringScalarHeight", AtmosphereSettings.mieScatteringScalarHeight);
            cmd.SetGlobalFloat("_OzoneAbsorptionScale", AtmosphereSettings.ozoneAbsorptionScale);
            cmd.SetGlobalFloat("_OzoneLevelCenterHeight", AtmosphereSettings.ozoneLevelCenterHeight);
            cmd.SetGlobalFloat("_OzoneLevelWidth", AtmosphereSettings.ozoneLevelWidth);
            
            
            cmd.SetGlobalFloat("_AerialPerspectiveDistance", AtmosphereSettings.aerialPerspectiveDistance);
            
            cmd.Blit(null, m_transmittanceLut, transmittanceLutMaterial);
            cmd.Blit(null,m_multiScatteringLut, multiScatteringLutMaterial);
            cmd.Blit(null, m_skyViewLut, skyViewLutMaterial);
            
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            CommandBufferPool.Release(cmd);
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            RenderTexture.ReleaseTemporary(m_skyViewLut);
            RenderTexture.ReleaseTemporary(m_transmittanceLut);
            RenderTexture.ReleaseTemporary(m_multiScatteringLut);
        }
    }

    CustomRenderPass m_ScriptablePass;

    public Material transmittanceLutMaterial;
    public Material skyViewLutMaterial;
    public Material multiScatteringLutMaterial;

    public AtmosphereSettings atmosphereSettings;
    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass();

        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = RenderPassEvent.BeforeRendering;
        
        m_ScriptablePass.transmittanceLutMaterial = transmittanceLutMaterial;
        m_ScriptablePass.skyViewLutMaterial = skyViewLutMaterial;
        m_ScriptablePass.multiScatteringLutMaterial = multiScatteringLutMaterial;

        m_ScriptablePass.AtmosphereSettings = atmosphereSettings;

    }
    
    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


