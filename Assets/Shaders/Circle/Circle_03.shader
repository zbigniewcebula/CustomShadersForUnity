Shader "Custom/Circle_03"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)

		_Radius("Radius", Float) = 1
		_Thickness("Thickness", Float) = 0.75
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
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

			float4 _Color;
			float _Radius;
			float _Thickness;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			float3 ObjectScale() {
				return float3(
					length(unity_ObjectToWorld._m00_m10_m20),
					length(unity_ObjectToWorld._m01_m11_m21),
					length(unity_ObjectToWorld._m02_m12_m22)
				);
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 uv = i.uv;
				uv.x -= 0.5;
				uv.y -= 0.5;

				float sqr = sqrt(uv.x * uv.x + uv.y * uv.y) * 2;
				
				clip(_Radius - sqr);

				float width = _Radius - _Thickness;
				float transformScale = length(ObjectScale());

				width = width / transformScale;

				clip(sqr - (_Radius - width));
				return _Color;
			}
			ENDCG
		}
	}
}
