Shader "Custom/GroundShader" {
	Properties {
		[Toggle(WET)] _WetInvert("Wet?", Float) = 0
		[Toggle(DRY)] _DryInvert("Dry?", Float) = 0
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump"{}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Saturation("Saturation", Range(0,0.2)) = 0.1
		_Lightness("Lightness", Range(0.1,1)) = 1

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0
		#pragma multi_compile _ WET
		#pragma multi_compile _ DRY

		sampler2D _MainTex;
		sampler2D _BumpMap;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		half _Saturation;
		half _Lightness;

		half3 RGBtoHSL(fixed3 color){
			half red = color.r;
			half green = color.g;
			half blue = color.b;
			half hue;
			half saturation;
			half lightness;
			half maxChannel = max(max(red, green),blue);
			half minChannel = min(min(red,green), blue);
			
			/// hue
			if(maxChannel==minChannel) hue = 0;
			else if(minChannel == blue) hue = 60 * (green-red)/(maxChannel-minChannel) + 60;
			else if(minChannel == red) hue = 60 * (blue-green)/(maxChannel-minChannel) + 180;
			else if(minChannel == green) hue = 60 * (red-blue)/(maxChannel-minChannel) + 300;
			hue /= 360;
			
			/// saturation
			saturation = (maxChannel - minChannel)/ (1-abs(maxChannel+minChannel-1));

			/// lightness
			lightness = (maxChannel+minChannel)/2;
			
			return half3(hue,saturation, lightness);
		}

		half3 HSLtoRGB(fixed3 color){
			half hue = color.r * 360;
			half saturation = color.g;
			half lightness = color.b;
			half3 rgbColor;
			half maxChannel = lightness + (saturation*(1-abs(2*lightness-1)))/2;
			half minChannel = lightness - (saturation*(1-abs(2*lightness-1)))/2;
			if(hue<60){
				rgbColor.r = maxChannel;
				rgbColor.g = minChannel + (maxChannel - minChannel) * hue / 60;
				rgbColor.b =  minChannel;
			}else if(hue < 120){
				rgbColor.r = minChannel + (maxChannel - minChannel) * (120-hue) /60;
				rgbColor.g = maxChannel;
				rgbColor.b = minChannel;
			}else if(hue < 180){
				rgbColor.r = minChannel;
				rgbColor.g = maxChannel;
				rgbColor.b = minChannel + (maxChannel - minChannel) * (hue-120)/60;
			}else if(hue < 240){
				rgbColor.r = minChannel;
				rgbColor.g = minChannel + (maxChannel-minChannel)*(240-hue)/60;
				rgbColor.b = maxChannel;
			}else if(hue < 300){
				rgbColor.r = minChannel + (maxChannel-minChannel)*(hue-240)/60;
				rgbColor.g = minChannel;
				rgbColor.b = maxChannel;
			}else{
				rgbColor.r = maxChannel;
				rgbColor.g = minChannel;
				rgbColor.b = minChannel + (maxChannel-minChannel)*(360-hue)/60;
			}
			return rgbColor;
		}

		half3 Wetter(half3 color){
			half3 hslColor = RGBtoHSL(color);
			hslColor.g += _Saturation;
			hslColor.b = hslColor.b*hslColor.b*_Lightness;
			half3 wetColor = HSLtoRGB(hslColor);
			return wetColor;
		}

		half3 Dryer(half3 color){
			half3 hslColor = RGBtoHSL(color);
			hslColor.g -= _Saturation;
			hslColor.b = sqrt(hslColor.b)*_Lightness;
			half3 dryColor = HSLtoRGB(hslColor);
			return dryColor;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			half3 color = c.rgb;
			#ifdef WET
				color = Wetter(color);
			#endif

			#ifdef DRY
				color = Dryer(color);
			#endif

			o.Albedo = color;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
			o.Normal = tex2D(_BumpMap, IN.uv_MainTex).rgb;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
