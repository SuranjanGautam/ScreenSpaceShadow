// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'unity_World2Shadow' with 'unity_WorldToShadow'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Lit/Cel-Shader"
{
    Properties
    {
		_Color("Color",Color)=(1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
		_Cels ("Gradient", 2D) = "white" {}
		_thres("threshold",Range(0,1))=0.5
		_shadowthres("shadow threshold",Range(0,1))=0.3
		_max("max",Range(0.5,1))=1
		_min("min",Range(0,0.5))=0
		[MaterialToggle] _gradtoggle("use gradient texture", Float) = 0.1
		[MaterialToggle] _toggle("cel shading", Float) = 0.9
		[MaterialToggle] _toggleshadow("cel shadow", Float) = 0.9
    }
    SubShader
    {
        Tags {"LightMode"="ForwardBase"}
		Lighting On

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			 
            
			
			#include "UnityLightingCommon.cginc"
            #include "UnityCG.cginc"
			

			#pragma multi_compile_fwdbase 
			#include "AutoLight.cginc"
	

            struct v2f
            { 
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				fixed4 amb :COLOR;
				float3 wpos : TEXCOORD2;
				SHADOW_COORDS(1)
            };

            sampler2D _MainTex;
			sampler2D _Cels; 
            float4 _MainTex_ST;
			half _thres;
			half _max;
			half _gradtoggle;
			half _toggle;
			half _min;
			fixed _toggleshadow;
			half _shadowthres;
			fixed4 _Color;
			

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.wpos = mul(unity_ObjectToWorld,v.vertex);

				half3 worldNormal = UnityObjectToWorldNormal(v.normal);

				o.normal = normalize( worldNormal);
				
				o.amb = fixed4(0,0,0,1);
				o.amb.rgb += ShadeSH9(half4(v.normal,1));
				
				TRANSFER_SHADOW(o)

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
				float cel;
				float atten;
				
				 
				
				fixed shadow= SHADOW_ATTENUATION(i);
				if(_toggleshadow==1){
				shadow = shadow > _shadowthres?_max:_min;
				}
				

				cel = saturate(dot(i.normal,_WorldSpaceLightPos0.xyz));

				
				cel = saturate(dot(i.normal,_WorldSpaceLightPos0.xyz));
				atten=1;
				
				//if(true){
				//float3 fag= i.wpos - float3(unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x);
				//atten = 1/length(fag);
				//fag = normalize(fag);
				//if(atten>0.1){
				//cel = saturate(dot(i.normal,-fag));
				//}
				//}



				if(_toggle==0){}
				else{
				if(_gradtoggle==0){
				cel = cel>_thres?1:0;
					}
				else{
				cel = cel >= _thres? (cel - _thres)/(1 - _thres):0;
				cel = 0.5 + (cel * 0.5);
				cel = tex2D(_Cels, float2(cel,0.5));
					}
				}
				cel = clamp(cel,_min,_max);
				fixed4 coll = cel * _LightColor0 * atten * shadow ;
				coll += i.amb;
				col *= coll;

                return col;
            }
			
            ENDCG
        }
		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

    }
    
}
