Shader "Custom/Geometry/ExtrudeWithNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Factor ("Base Extrusion", Range(0., 2.)) = 0.2

        _Factor1 ("Noise Factor 1", float) = 12.9898
        _Factor2 ("Noise Factor 2", float) = 78.233
        _Factor3 ("Noise Factor 3", float) = 43758.5453
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Factor;
            float _Factor1;
            float _Factor2;
            float _Factor3;

            struct v2g
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 col : COLOR;
            };

            // Pseudo-random noise function
            float noise(float2 uv)
            {
                // Uncomment for animated noise:
                //uv += _Time.y;

                return frac(sin(dot(uv, float2(_Factor1, _Factor2))) * _Factor3);
            }

            v2g vert(appdata_base v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.normal = v.normal;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            [maxvertexcount(24)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> tristream)
            {
                g2f o;

                float3 edgeA = IN[1].vertex.xyz - IN[0].vertex.xyz;
                float3 edgeB = IN[2].vertex.xyz - IN[0].vertex.xyz;
                float3 normalFace = normalize(cross(edgeA, edgeB));

                // Use triangle center for stable per-face noise
                float2 uvCenter = (IN[0].uv + IN[1].uv + IN[2].uv) / 3.0;
                float n = noise(uvCenter);

                float extrusion = _Factor * n;

                // Side faces
                for (int i = 0; i < 3; i++)
                {
                    int inext = (i + 1) % 3;

                    float4 v0 = IN[i].vertex;
                    float4 v1 = IN[inext].vertex;
                    float4 v0e = v0 + float4(normalFace * extrusion, 0);
                    float4 v1e = v1 + float4(normalFace * extrusion, 0);

                    // First triangle
                    o.pos = UnityObjectToClipPos(v0);
                    o.uv = IN[i].uv;
                    o.col = fixed4(1,1,1,1);
                    tristream.Append(o);

                    o.pos = UnityObjectToClipPos(v0e);
                    tristream.Append(o);

                    o.pos = UnityObjectToClipPos(v1);
                    o.uv = IN[inext].uv;
                    tristream.Append(o);

                    tristream.RestartStrip();

                    // Second triangle
                    o.pos = UnityObjectToClipPos(v0e);
                    tristream.Append(o);

                    o.pos = UnityObjectToClipPos(v1);
                    tristream.Append(o);

                    o.pos = UnityObjectToClipPos(v1e);
                    tristream.Append(o);

                    tristream.RestartStrip();
                }

                // Top face (extruded)
                for (int i = 0; i < 3; i++)
                {
                    float4 v = IN[i].vertex + float4(normalFace * extrusion, 0);

                    o.pos = UnityObjectToClipPos(v);
                    o.uv = IN[i].uv;
                    o.col = fixed4(1,1,1,1);
                    tristream.Append(o);
                }
                tristream.RestartStrip();

                // Bottom face (original)
                for (int i = 0; i < 3; i++)
                {
                    o.pos = UnityObjectToClipPos(IN[i].vertex);
                    o.uv = IN[i].uv;
                    o.col = fixed4(1,1,1,1);
                    tristream.Append(o);
                }
                tristream.RestartStrip();
            }

            fixed4 frag(g2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.col;
                return col;
            }

            ENDCG
        }
    }
}
