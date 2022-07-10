Shader "Lit/Cel-Shader-surface"
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
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Ramp addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
		sampler2D _Cels; 
		half _thres;
		half _max;
		half _gradtoggle;
		half _toggle;
		half _min;
		fixed4 _Color;
		fixed _toggleshadow;
		half _shadowthres;

        struct Input
        {
            float2 uv_MainTex;
        };

		half4 LightingRamp (SurfaceOutput s, half3 lightDir, half atten) {
		half cel=dot (s.Normal, lightDir);
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
			half4 c;

			if(_toggleshadow==1){
				atten = atten > _shadowthres?_max:_min;
				}

			c.rgb = s.Albedo * _LightColor0.rgb * cel * atten;
			c.a = s.Alpha;
			return c;
		}
        

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb * _Color;
            // Metallic and smoothness come from slider variables
            
            
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
