Shader "Custom/Galaxy"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;

				float4 screenPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.screenPos = ComputeScreenPos(o.vertex);

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			float3 ObjectScale() {
				return float3(
					length(unity_ObjectToWorld._m00_m10_m20),
					length(unity_ObjectToWorld._m01_m11_m21),
					length(unity_ObjectToWorld._m02_m12_m22)
					);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float scale = length(ObjectScale());

				//float3 vertex = float3(i.xx.x + 0.5, 0, i.xx.y + 0.5);
				//float3 vertex = mul(unity_ObjectToWorld, normalize(i.vertex));

				fixed4 col = tex2D(_MainTex, i.uv);

				float med = (col.r + col.b + col.g) / 3;

				if (med - 0.7 < 0)
					return fixed4(0, 0, 0, 1);

				float3 cam = normalize(_WorldSpaceCameraPos.xyz - i.vertex);

				float lrp = length(lerp(cam, float3(0, 1, 0), med * 3));

				return col * lrp;
				
				//float3 cam = normalize(abs(_WorldSpaceCameraPos.xyz - vertex));
				//float3 dotP = dot(col.rgb, cam);

				//col = fixed4(vertex.x, 0, vertex.z, 1);

				//float3 toCam = normalize(_WorldSpaceCameraPos.xyz - vertex);

				//UNITY_APPLY_FOG(i.fogCoord, col);
				//return fixed4(dotP, 1);
			}
			ENDCG
		}
	}
}
