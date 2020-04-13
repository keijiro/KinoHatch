using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace Kino.PostProcessing
{
    [System.Serializable, VolumeComponentMenu("Post-processing/Kino/Hatch")]
    public sealed class Hatch : CustomPostProcessVolumeComponent, IPostProcessComponent
    {
        #region Exposed parameters

        public ClampedFloatParameter opacity = new ClampedFloatParameter(0, 0, 1);

        #endregion

        #region Private variables

        static class IDs
        {
            internal static readonly int InputTexture = Shader.PropertyToID("_InputTexture");
            internal static readonly int Opacity = Shader.PropertyToID("_Opacity");
        }

        Material _material;

        #endregion

        #region Postprocess effect implementation

        public bool IsActive() => _material != null && opacity.value > 0;

        public override CustomPostProcessInjectionPoint injectionPoint =>
            CustomPostProcessInjectionPoint.AfterPostProcess;

        public override void Setup()
        {
            _material = CoreUtils.CreateEngineMaterial("Hidden/Kino/PostProcess/Hatch");
        }

        public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle srcRT, RTHandle destRT)
        {
            if (_material == null) return;

            _material.SetFloat(IDs.Opacity, opacity.value);

            _material.SetTexture(IDs.InputTexture, srcRT);
            HDUtils.DrawFullScreen(cmd, _material, destRT);
        }

        public override void Cleanup()
        {
            CoreUtils.Destroy(_material);
        }

        #endregion
    }
}
