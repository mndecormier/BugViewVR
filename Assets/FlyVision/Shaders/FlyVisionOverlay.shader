Shader "FlyVision/Overlay"
{
    Properties
    {
        [Header(Hex Facet)]
        _HexScale         ("Hex Scale (facets across screen)", Float) = 80.0
        _EdgeWidth        ("Facet Edge Width", Range(0,0.5)) = 0.08
        _EdgeSoftness     ("Facet Edge Softness", Range(0.0001,0.5)) = 0.04
        _EdgeColor        ("Facet Edge Color", Color) = (0,0,0,1)
        _EdgeOpacity      ("Facet Edge Opacity", Range(0,1)) = 0.85

        [Header(Color Tint)]
        _TintColor        ("Tint Color (UV-ish shift)", Color) = (0.55, 0.7, 1.0, 1)
        _TintStrength     ("Tint Strength", Range(0,1)) = 0.25

        [Header(Vignette)]
        _VignetteStart    ("Vignette Start", Range(0,1)) = 0.55
        _VignetteEnd      ("Vignette End",   Range(0,1.5)) = 1.05
        _VignetteOpacity  ("Vignette Opacity", Range(0,1)) = 0.9
        _VignetteColor    ("Vignette Color", Color) = (0,0,0,1)

        [Header(Facet Jitter)]
        _FacetJitter      ("Per-Facet Brightness Jitter", Range(0,1)) = 0.15
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Overlay"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "FlyVisionOverlay"
            Cull Off
            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv          : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
                float  _HexScale;
                float  _EdgeWidth;
                float  _EdgeSoftness;
                float4 _EdgeColor;
                float  _EdgeOpacity;
                float4 _TintColor;
                float  _TintStrength;
                float  _VignetteStart;
                float  _VignetteEnd;
                float  _VignetteOpacity;
                float4 _VignetteColor;
                float  _FacetJitter;
            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            // Returns: x,y = offset to nearest hex center, z = stable id (cell index hash seed)
            float3 hexInfo(float2 p)
            {
                const float2 h = float2(1.0, 1.7320508);    // (1, sqrt(3))
                const float2 hh = h * 0.5;

                float2 a = float2(fmod(p.x,        h.x) - hh.x, fmod(p.y,        h.y) - hh.y);
                float2 b = float2(fmod(p.x + hh.x, h.x) - hh.x, fmod(p.y + hh.y, h.y) - hh.y);

                float2 gv;
                float2 cellId;
                if (dot(a,a) < dot(b,b))
                {
                    gv = a;
                    cellId = floor(p / h);
                }
                else
                {
                    gv = b;
                    cellId = floor((p + hh) / h) - 0.5;
                }
                float id = cellId.x * 374.91 + cellId.y * 91.27;
                return float3(gv, id);
            }

            // Distance from point inside a hex cell to the nearest hex edge (0 at edge, ~0.5 at center).
            float hexEdgeDist(float2 gv)
            {
                gv = abs(gv);
                // For pointy-top hex with width 1 and height sqrt(3):
                // distance to nearest edge = 0.5 - max(gv.x*sqrt(3)/2 + gv.y*0.5, gv.y) ... approximated below
                float d = 0.5 - max(gv.x * 0.8660254 + gv.y * 0.5, gv.y);
                return d;
            }

            float hash11(float n)
            {
                return frac(sin(n) * 43758.5453);
            }

            half4 frag (Varyings IN) : SV_Target
            {
                float2 uv = IN.uv;

                // Hex grid in UV space, scaled so _HexScale roughly = facets across width.
                float2 p = uv * _HexScale;
                float3 hi = hexInfo(p);
                float edgeD = hexEdgeDist(hi.xy);

                // Edge mask: 1 at hex border, 0 well inside facet.
                float edge = 1.0 - smoothstep(_EdgeWidth, _EdgeWidth + _EdgeSoftness, edgeD);

                // Per-facet brightness jitter (slight random darken per ommatidium).
                float jitter = (hash11(hi.z) - 0.5) * _FacetJitter;

                // Vignette: radial darken from screen center.
                float2 c = uv - 0.5;
                float r = length(c) * 2.0; // 0 at center, ~1 at corners
                float vig = smoothstep(_VignetteStart, _VignetteEnd, r);

                // --- Compose overlay color (premultiplied-style accumulation onto alpha) ---
                half3 col = 0;
                half  a   = 0;

                // Facet edge lines.
                col += _EdgeColor.rgb * edge * _EdgeOpacity;
                a   += edge * _EdgeOpacity;

                // Per-facet jitter darken/lighten (only inside facet -> use 1-edge weight).
                float facetMask = saturate(1.0 - edge);
                col += (jitter < 0 ? half3(0,0,0) : half3(1,1,1)) * abs(jitter) * facetMask * 0.5;
                a   += abs(jitter) * facetMask * 0.5;

                // UV-ish color tint over whole view.
                col += _TintColor.rgb * _TintStrength;
                a   += _TintStrength;

                // Vignette.
                col += _VignetteColor.rgb * vig * _VignetteOpacity;
                a   += vig * _VignetteOpacity;

                a = saturate(a);
                // Convert from accumulated (col over alpha) to standard straight alpha:
                // we built `col` already weighted, so renormalize against alpha to keep blend sane.
                col = a > 0.0001 ? col / a : col;

                return half4(col, a);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
