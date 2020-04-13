Shader "Hidden/Kino/PostProcess/Hatch"
{
    HLSLINCLUDE

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "SimplexNoise2D.hlsl"

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

    float _Opacity;

    TEXTURE2D_X(_InputTexture);

    float4 Fragment(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        // Input sample
        float2 pss = input.texcoord * _ScreenSize.xy;
        float4 col = LOAD_TEXTURE2D_X(_InputTexture, pss);

        float2 uv = input.texcoord.xy;
        uv += snoise(uv * 60 + 29.2783 * floor(dot(uv, 100))) * float2(1, 1) * 0.0005;
        float bw = abs(1 - 2 * frac(dot(uv, 100)));

        bw = saturate(bw * 4 + lerp(-4.0, 1, dot(col, 1.0 / 3)));


        uv = input.texcoord.xy;
        uv += snoise(uv * 60 + 29.2783 * floor(dot(uv, float2(-1, 1) * 100))) * float2(-1, 1) * 0.0005;
        float bw2 = abs(1 - 2 * frac(dot(uv, float2(-1, 1) * 100)));

        bw2 = saturate(bw2 * 4 + lerp(-4.0, 3, dot(col, 1.0 / 3)));

        bw = min(bw, bw2);

        // Linear -> sRGB
        col.rgb = LinearToSRGB(col.rgb);

        // Opacity
        col.rgb = lerp(col.rgb, bw, _Opacity);

        // sRGB -> Linear
        col.rgb = SRGBToLinear(col.rgb);

        return col;
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
