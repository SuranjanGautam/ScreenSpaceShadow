Shader "Hidden/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Outlinesize("Outlinesize",Range(0,1))=0.5
    }
    SubShader
    {
       
	   // 0: color every outline objects red in a pass
        Pass
        {
			Blend One Zero
            ZTest LEqual
            Cull Off
            ZWrite Off

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(1,1,1,1);
                return col;
            }
            ENDCG
        }
		//  1: Blur the pass
		Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off
           
            CGPROGRAM
            
			#pragma vertex vert
            #pragma fragment fragment
            
            #include "UnityCG.cginc"
 
            float2 _BlurDirection;
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
 
            // 9-tap Gaussian kernel, that blurs green & blue channels,
            // keeps red & alpha intact.
            static const half4 kCurveWeights[9] = {
                half4(0,0.0204001988,0,0),
                half4(0,0.0577929595,0,0),
                half4(0,0.1215916882,0,0),
                half4(0,0.1899858519,0,0),
                half4(1,0.2204586031,0,1),
                half4(0,0.1899858519,0.0,0),
                half4(0,0.1215916882,0,0),
                half4(0,0.0577929595,0,0),
                half4(0,0.0204001988,0.0,0)
            };

           

            half4 fragment(v2f i): SV_Target
            {
                float2 step = _MainTex_TexelSize.xy * _BlurDirection;
                float2 uv = i.uv - step * 4;
                half4 col = 0;
                for (int tap = 0; tap < 9; ++tap)
                {
                    col += tex2D(_MainTex, uv) * kCurveWeights[tap];
                    uv += step;
                }
				col.a=0.5;
                return col;
            }
            ENDCG
        }

		//  2: substract the original and threshold the blurred ones
		Pass
        {
			ZTest Always
            Cull Off
            ZWrite Off

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
			half _Outlinesize;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                if(col.g >=0.9){
					col.rgb=0;
					col.a=0;
				}
				else{
					if(col.g > _Outlinesize){ 
					col.a=1;
					col.rgb=0;
					}
					else{
					col.a=0;
					}
				}
				return col;
            }
            ENDCG
        }
		// 3: blending
		Pass
        {
			ZTest Always
            Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }

    }
}
