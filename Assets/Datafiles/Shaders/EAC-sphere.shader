Shader "Custom/EAC-sphere"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		//Cull Front ZWrite Off ZTest Always // Cull front will flip normals

        Tags { "RenderType"="Opaque" }
		LOD 100

		Cull Front


		//Only 4 lines I added
		Stencil{
			Ref 1
			Comp [_StencilTest]
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
        float4 vertex : POSITION;
        float3 normal : NORMAL;
			};

			struct v2f
			{
        float4 vertex : SV_POSITION;
				float3 coord : TEXCOORD0;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.coord = v.normal;
				return o;
			}
			
			sampler2D _MainTex;

			float4 frag (v2f i) : SV_Target {
				float pi = UNITY_PI;
				float3 xyz = normalize(i.coord);
				float x = xyz.x, y = xyz.y, z = xyz.z;

				float u = 0, v = 0;
				float scale; // sphere coordinates to cube coordinates according to similar-triangle
				if (abs(x) >= abs(y) && abs(x) >= abs(z)) {
					scale = 1.0 / abs(x); // let's assume that radius of sphere is 1, which means u is 6.0 and v is 4.0
					if (x >= 0) { // right
						u = 5.0 - 4.0 * atan(z * scale) / pi;
						v = 3.0 + 4.0 * atan(y * scale) / pi;
					} else { // left
						u = 1.0 + 4.0 * atan(z * scale) / pi;
						v = 3.0 + 4.0 * atan(y * scale) / pi;
					}
				} else if (abs(y) >= abs(x) && abs(y) >= abs(z)) {
					scale = 1.0 / abs(y);
					if (y >= 0) { // top
						u = 5.0 + 4.0 * atan(z * scale) / pi;
						v = 1.0 + 4.0 * atan(x * scale) / pi;
					} else { // down
						u = 1.0 - 4.0 * atan(z * scale) / pi;
						v = 1.0 + 4.0 * atan(x * scale) / pi;
					}
				} else if (abs(z) >= abs(x) && abs(z) >= abs(y)) {
					scale = 1.0 / abs(z);
					if (z >= 0) { // front
						u = 3.0 + 4.0 * atan(x * scale) / pi;
						v = 3.0 + 4.0 * atan(y * scale) / pi;
					} else { // end
						u = 3.0 + 4.0 * atan(y * scale) / pi;
						v = 1.0 + 4.0 * atan(x * scale) / pi;
					}
				}

				return tex2D(_MainTex, float2(u / 6.0, 1.0 - v / 4.0));
			}

			ENDCG
		}
	}
}
