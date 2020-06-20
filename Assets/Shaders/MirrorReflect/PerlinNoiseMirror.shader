// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PerlinNoiseMirror"
{
    Properties
    {
		[NoScaleOffset] _MainTex ("MainTex", 2D) = "white" {}
		[NoScaleOffset] _NoiseTex("NoiseTex",2D)="white"{}
		_NoiseScaleX("NoiseScaleX",Range(0,1))=0.1
		_NoiseScaleY("NoiseScaleY",Range(0,1))=0.1
		_NoiseSpeedX("NoiseSpeedX",Range(0,10))=1
		_NoiseSpeedY("NoiseSpeedY",Range(0,10))=1
		_NoiseBrightOffset("NoiseBrightOffset",Range(0,0.9))=0.25
		_NoiseFalloff("NoiseFalloff",Range(0,1))=1

		_MirrorRange("MirrorRange",Range(0,3))=1
		_MirrorAlpha("MirrorAlpha",Range(0,1))=1
		_MirrorFadeAlpha("_MirrorFadeAlpha",Range(0,1))=0.5
    }
	CGINCLUDE
	#include "UnityCG.cginc"
	#include "Lighting.cginc"
	#include "AutoLight.cginc"
	struct appdata
    {
		float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
		float3 normal : NORMAL;
    };
	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
		float3 wPos : TEXCOORD1;
	};
	struct v2f_m{
		float4 vertex : SV_POSITION;
		float2 uv : TEXCOORD0;
		float4 normal : TEXCOORD1;
		float4 wPos : TEXCOORD2;
	};

	sampler2D _MainTex;
	sampler2D _NoiseTex;
	fixed _NoiseScaleX,_NoiseScaleY;
	fixed _NoiseSpeedX,_NoiseSpeedY;
	fixed _NoiseBrightOffset;
	fixed _NoiseFalloff;

	float _MirrorRange,_MirrorAlpha,_MirrorFadeAlpha;
	float3 n,p;//镜面法线 镜面任意点

	v2f vert_normal(appdata v){
		v2f o;
		o.uv=v.uv;
		o.vertex=UnityObjectToClipPos(v.vertex);
		o.wPos=mul(unity_ObjectToWorld,v.vertex).xyz;
		return o;
	}

	fixed4 frag_normal(v2f i):SV_Target{
		float3 dir=i.wPos.xyz-p;
		half d=dot(dir,n);
		if(d<0) discard;
		return tex2D(_MainTex,i.uv);
	}

	v2f_m vert_mirror(appdata v){
		v2f_m o;
		o.wPos=mul(unity_ObjectToWorld,v.vertex);

		float3 nn=-n;
		float3 dp=o.wPos.xyz-p;
		half nd=dot(n,dp);
		o.wPos.xyz+=nn*(nd*2);
		o.vertex=mul(unity_MatrixVP,o.wPos);
		o.normal.xyz=UnityObjectToWorldNormal(v.normal);
		fixed t=nd/_MirrorRange;
		fixed a=lerp(_MirrorAlpha,_MirrorAlpha*_MirrorFadeAlpha,t);
		o.normal.w=a;
		o.wPos.w=nd;
		o.uv=v.uv;
		return o;
	}

	fixed4 frag_mirror(v2f_m i):SV_Target{
		if(i.wPos.w>_MirrorRange) discard;
		if(i.normal.w<=0) discard;

		float3 dir=i.wPos.xyz-p;
		half d=dot(dir,n);
		if(d>0) discard;

		fixed2 ouvxy=fixed2(tex2D(_NoiseTex,i.uv + fixed2(_Time.x*_NoiseSpeedX,0)).r,
		tex2D(_NoiseTex,i.uv+fixed2(0,_Time.x*_NoiseSpeedY)).r);
		ouvxy-=_NoiseBrightOffset;
		ouvxy*=fixed2(_NoiseScaleX,_NoiseScaleY);

		float scale=i.wPos.w/_MirrorRange;
		scale = lerp(scale,1,(1-_NoiseFalloff));
		ouvxy*=scale;

		fixed4 col =tex2D(_MainTex,i.uv+ouvxy);
		return fixed4(col.rgb,i.normal.w);
	}

	ENDCG
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry+2"}

        Pass
        {
			Cull front
			ZTest Always
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Stencil{
				Ref 1
				Comp Equal
			}
            CGPROGRAM
            #pragma vertex vert_mirror
            #pragma fragment frag_mirror
            ENDCG
        }
		Pass{
			CGPROGRAM
			#pragma vertex vert_normal
			#pragma fragment frag_normal
			ENDCG
		}
    }
}
