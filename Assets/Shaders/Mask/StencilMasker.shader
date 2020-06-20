Shader "Unlit/StencilMasker"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Luma("Luma",Range(0,3))=1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry-1"}
        LOD 100

        Pass
        {
			ColorMask 0
			ZWrite off
			ZTest always
			Stencil{
				Ref 1
				Comp always
				Pass replace
			}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _Luma;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				fixed luma=dot(col.xyz,1);
				if(luma<=_Luma) discard;
                return col;
            }
            ENDCG
        }
    }
}
