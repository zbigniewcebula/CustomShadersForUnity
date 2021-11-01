Shader "Custom/Circle_07"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)

		_Radius("Radius", Float) = 1
		_Thickness("Thickness", Float) = 0.75
	}
	SubShader
	{
		Tags {
			"RenderType"="Transparent"
			"Queue" = "Transparent"
		}
		LOD 100
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#pragma multi_compile_fog
			#pragma multi_compile_instancing
			
			#pragma target 3.0
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				//UNITY_FOG_COORDS(1)
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

			v2f vert (appdata v)
			{
				v2f o;

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				//UNITY_TRANSFER_FOG(o, o.vertex);
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
				UNITY_SETUP_INSTANCE_ID(i);
				fixed4 color = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
				float radius = UNITY_ACCESS_INSTANCED_PROP(Props, _Radius);
				float thickness = UNITY_ACCESS_INSTANCED_PROP(Props, _Thickness);

				float2 uv = i.uv;
				uv.x -= 0.5;
				uv.y -= 0.5;

				float sqr = sqrt(uv.x * uv.x + uv.y * uv.y) * 2;
				
				clip(radius - sqr);

				float width = radius - thickness;
				float transformScale = length(ObjectScale());

				width = width / transformScale;

				clip(sqr - (radius - width));

				float4 tex = tex2D(_MainTex, i.uv) * color;
				//UNITY_APPLY_FOG(i.fogCoord, color);
				return tex;
			}
			ENDCG
		}
	}
}
