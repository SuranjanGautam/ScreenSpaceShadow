Shader "Custom/ScreenSpaceShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightPos("Light Pos ",Vector) = (0,0,0)
        _ShadowMap("shadowmap",2D) = "white"{}
        _ShadowColor("shadow color",Color) = (1,1,1)
        _clipDepth("far_clip",Float) = 0
        _max_depth("Max depth difference",Float) = 0.3

        _high("close distance",Float) = 0.1
        _medium("medium distance", Float) = 0.5
        _cut_off("cutoff",Float)=1
        
    }
        SubShader
        {
            // No culling or depth
            Cull Off
            ZWrite Off
            ZTest Always

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

            v2f vert (appdata v)
            {
                v2f o;                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

           
            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _LightPos;
            half _clipDepth;
            half _max_depth;
            half _high;
          
            

            fixed4 frag(v2f i) : SV_Target
            {
                half max_limit = _max_depth / _clipDepth;
                float depth = Linear01Depth(tex2D(_CameraDepthTexture, i.uv).r);
                float3 screenPos = float3(i.uv, depth);
                float3 ray = (_LightPos - screenPos)/100;
                half4 return_col = 0;
                half dist = distance(_LightPos.xy, i.uv);
                if (depth < 1 && dist <= _high)
                {
                    for (int i = 0;i < 100 ;i++)
                    {                    
                            float3 newPos = screenPos + (ray * i);
                            float depthh = Linear01Depth(tex2D(_CameraDepthTexture, newPos.xy).r);
                            float diff = newPos.z - depthh;
                            if ( diff< max_limit && diff > 0)
                            {
                                return 1;
                            }
                    }
                }
                return 0;
            }
            ENDCG
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }


            sampler2D _MainTex;
            sampler2D _ShadowMap;
            half _ShadowColor;
           

            fixed4 frag(v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float sad = tex2D(_ShadowMap, i.uv).r;
                col.xyz *= sad == 0 ? 1 : (1 - sad*0.5);
                return col;
            }
            ENDCG
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }


            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _LightPos;
            half _clipDepth;
            half _max_depth;

            half _high;
            half _medium;



            fixed4 frag(v2f i) : SV_Target
            {
                half max_limit = _max_depth / _clipDepth;
                float depth = Linear01Depth(tex2D(_CameraDepthTexture, i.uv).r);
                float3 screenPos = float3(i.uv, depth);
                float3 ray = (_LightPos - screenPos) / 100;
                
                half dist = distance(_LightPos, screenPos);
                if (depth < 1 && dist >= _high * 0.8 && dist <=_medium)
                {
                    for (int i = 0;i < 100;i++)
                    {
                            float3 newPos = screenPos + (ray * i);
                            float depthh = Linear01Depth(tex2D(_CameraDepthTexture, newPos.xy).r);
                            float diff = newPos.z - depthh;
                            if (diff < max_limit && diff > 0)
                            {
                                return 1;
                            }
                    }
                }
                return 0;
            }
            ENDCG
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }


            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _LightPos;
            half _clipDepth;
            half _max_depth;
            half _high;
            half _medium;
            half _cut_off;


            fixed4 frag(v2f i) : SV_Target
            {
                half max_limit = _max_depth / _clipDepth;
                float depth = Linear01Depth(tex2D(_CameraDepthTexture, i.uv).r);
                float3 screenPos = float3(i.uv, depth);
                float3 ray = (_LightPos - screenPos) / 100;
                half4 return_col = 0;
                half dist = distance(_LightPos.xy, i.uv);
                if (depth < 1 && dist >= _medium*0.95 && dist <= _cut_off)
                {
                    for (int i = 0;i < 100;i++)
                    {
                            float3 newPos = screenPos + (ray * i);
                            float depthh = Linear01Depth(tex2D(_CameraDepthTexture, newPos.xy).r);
                            float diff = newPos.z - depthh;
                            if (diff < max_limit && diff > 0)
                            {
                                return 1;
                            }
                    }
                }
                return 0;
            }
            ENDCG
            }
    }
}
