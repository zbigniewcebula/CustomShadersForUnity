Shader "Custom/CircleProjection"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)

		_Radius("Radius", Float) = 1
		_Thickness("Thickness", Float) = 0.75

		_WidthToTransformScale("Width to Transform scale relativity", Range(0.0, 1.0)) = 0
	}
		SubShader
		{
			Tags { "RenderType" = "Transparent-1" }
			LOD 100
			ZWrite Off
			AlphaTest Greater 0
			ColorMask RGB

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
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					float4 uv : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					float4 vertex : SV_POSITION;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				UNITY_INSTANCING_BUFFER_START(Props)
					UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
					UNITY_DEFINE_INSTANCED_PROP(float, _Radius)
					UNITY_DEFINE_INSTANCED_PROP(float, _Thickness)
					UNITY_DEFINE_INSTANCED_PROP(float, _WidthToTransformScale)
				UNITY_INSTANCING_BUFFER_END(Props)

				sampler2D _MainTex;
				float4 _MainTex_ST;

				uniform float4x4 unity_Projector;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = mul(unity_Projector, v.vertex);

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

				fixed4 frag(v2f i) : SV_Target
				{
					clip(i.uv.w);

					UNITY_SETUP_INSTANCE_ID(i);
					fixed4 color = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
					float radius = UNITY_ACCESS_INSTANCED_PROP(Props, _Radius);
					float thickness = UNITY_ACCESS_INSTANCED_PROP(Props, _Thickness);

					float2 uv = i.uv.xy / i.uv.w;
					fixed4 col = tex2D(_MainTex, uv);

					uv.x -= 0.5;
					uv.y -= 0.5;
					float sqr = sqrt(uv.x * uv.x + uv.y * uv.y) * 2;

					clip(radius - sqr);

					float transformScale = length(ObjectScale());
					float width = radius - thickness;

					width = width / lerp(1, transformScale, _WidthToTransformScale);

					clip(sqr - (radius - width));

					UNITY_APPLY_FOG(i.fogCoord, col* color);
					return col;
				}
				ENDCG
			}
		}
}
