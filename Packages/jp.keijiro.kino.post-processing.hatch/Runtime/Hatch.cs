using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace Kino.PostProcessing
{
    [System.Serializable, VolumeComponentMenu("Post-processing/Kino/Hatch")]
    public sealed class Hatch
      : CustomPostProcessVolumeComponent, IPostProcessComponent
    {
        #region Exposed parameters

        public ClampedFloatParameter repeat
          = new ClampedFloatParameter(100, 0, 200);

        public ClampedFloatParameter waviness
          = new ClampedFloatParameter(0.25f, 0, 1);

        public ClampedFloatParameter displacement
          = new ClampedFloatParameter(0.1f, 0, 1);

        public ClampedFloatParameter thickness
          = new ClampedFloatParameter(0.6f, 0, 1);

        public ClampedFloatParameter opacity
          = new ClampedFloatParameter(0, 0, 1);

        #endregion

        #region Private members

        static class IDs
        {
            internal static readonly int InputTexture
              = Shader.PropertyToID("_InputTexture");

            internal static readonly int Repeat
              = Shader.PropertyToID("_Repeat");

            internal static readonly int Waviness
              = Shader.PropertyToID("_Waviness");

            internal static readonly int Displacement
              = Shader.PropertyToID("_Displacement");

            internal static readonly int Thickness
              = Shader.PropertyToID("_Thickness");

            internal static readonly int Seed
              = Shader.PropertyToID("_Seed");

            internal static readonly int Opacity
              = Shader.PropertyToID("_Opacity");
        }

        Material _material;

        static uint JenkinsHash(uint x)
        {
            x += (x << 10); x ^= (x >>  6);
            x += (x <<  3); x ^= (x >> 11);
            return x + (x << 15);
        }

        #endregion

        #region Postprocess effect implementation

        public bool IsActive() => _material != null && opacity.value > 0;

        public override CustomPostProcessInjectionPoint injectionPoint
          => CustomPostProcessInjectionPoint.AfterPostProcess;

        public override void Setup()
          => _material = CoreUtils.CreateEngineMaterial
               ("Hidden/Kino/PostProcess/Hatch");

        public override void Render
          (CommandBuffer cmd, HDCamera camera, RTHandle srcRT, RTHandle destRT)
        {
            if (_material == null) return;

            var seed = (JenkinsHash((uint)Time.frameCount) & 0xffff) * 0.001f;

            _material.SetFloat(IDs.Repeat, repeat.value);
            _material.SetFloat(IDs.Waviness, waviness.value);
            _material.SetFloat(IDs.Displacement, displacement.value);
            _material.SetFloat(IDs.Thickness, thickness.value / 2);
            _material.SetFloat(IDs.Opacity, opacity.value);
            _material.SetFloat(IDs.Seed, seed);

            _material.SetTexture(IDs.InputTexture, srcRT);
            HDUtils.DrawFullScreen(cmd, _material, destRT);
        }

        public override void Cleanup()
          => CoreUtils.Destroy(_material);

        #endregion
    }
}
