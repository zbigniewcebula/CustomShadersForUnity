Shader "Custom/Circle_00"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)

		_Radius("Radius", Float) = 1
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

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 uv = i.uv;

				//r^2 = x ^ 2 + y ^ 2
				//r = sqrt(x * x + y * y)
				float sqr = sqrt(uv.x * uv.x + uv.y * uv.y);
				
				clip(_Radius - sqr);
				return _Color;
			}
			ENDCG
		}
	}
}
