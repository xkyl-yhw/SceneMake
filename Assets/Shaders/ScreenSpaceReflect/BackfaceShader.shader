Shader "Custom/BackfaceShader"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
		Cull Front

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 position : POSITION;
				float4 linearDepth : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.linearDepth = float4(0.0,0.0,COMPUTE_DEPTH_01,0.0);
                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {
                return float4(i.linearDepth.z,0.0,0.0,0.0);
            }
            ENDCG
        }
    }
}
