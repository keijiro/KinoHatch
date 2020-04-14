Shader "Hidden/Kino/PostProcess/Hatch"
{
    HLSLINCLUDE

    // -- Post processing boilerplate code --

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"

    struct Attributes
    {
        uint vertexID : SV_VertexID;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float2 texcoord   : TEXCOORD0;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    Varyings Vertex(Attributes input)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
        output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
        output.texcoord = GetFullScreenTriangleTexCoord(input.vertexID);
        return output;
    }

    // -- End of boilerplate --

    #include "SimplexNoise2D.hlsl"

    float _Repeat;
    float _Waviness;
    float _Displacement;
    float _Thickness;
    float _Seed;
    float _Opacity;

    TEXTURE2D_X(_InputTexture);

    // Remap range [a, b] -> [0, 1]
    float Range01(float x, float a, float b)
    {
        return saturate((x - a) / (b - a));
    }

    float Hatching(float2 uv, float2 dir, float thresh)
    {
        // Potential (before adding wave)
        float p1 = dot(uv, dir) * _Repeat;

        // Wave noise sample point
        float2 nsp = float2(
          dot(uv, dir.xy * float2(1, -1)),
          floor(p1) * 11.4729 / _Repeat + _Seed
        );

        // Displacement by noise
        float disp = snoise(nsp * _Repeat * _Waviness * 2);
        disp *= 0.2 * _Displacement / _Repeat;

        // Potential (wave added)
        float p2 = dot(uv + dir * disp, dir) * _Repeat;

        // Distance from p=0.5
        float d = abs(1 - 2 * frac(p2));

        // Fill if (distance - thickness) < threshold.
        return saturate((thresh - _Thickness + d) * 400 / _Repeat);
    }

    float4 Fragment(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        // Input sample
        float2 uv = input.texcoord;
        float4 src = LOAD_TEXTURE2D_X(_InputTexture, uv * _ScreenSize.xy);

        // Linear -> sRGB
        src.rgb = LinearToSRGB(src.rgb);

        // Hatching
        float lm = Luminance(src.rgb);
        float bw1 = Hatching(uv, float2(1,  1), Range01(lm, 0.4, 1));
        float bw2 = Hatching(uv, float2(1, -1), Range01(lm, 0.1, 0.7));

        // Opacity
        src.rgb = lerp(src.rgb, min(bw1, bw2), _Opacity);

        // sRGB -> Linear
        src.rgb = SRGBToLinear(src.rgb);

        return src;
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Cull Off ZWrite Off ZTest Always
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDHLSL
        }
    }
    Fallback Off
}
