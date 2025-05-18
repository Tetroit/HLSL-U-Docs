To start with, here are some stats and versions that will be used in this tutorial

- Unity: 2022.3 
- Template: URP 3D Sample
- Universal RP package: 14.0.11
- Scene: Garden

URP Samples are very good for building shaders as they already contain a variety of features such as SSAO, light probes, skybox, baked lighting, etc. Don't worry if you don't know what these terms mean, advanced features are not the focus of this chapter, but we might need them in the future. But also Garden scene is just beautiful, what can be better than some secluded pretty place to work? Of cource, if you feel comfortable without some beautiful amvient environment, then feel free to start with a default scene, as you can easily transfer your progress to another scene or project as all created shader assets are scene independant.

So let's hop on the scene and get started!

### Setup
Go to `Assets -> Scenes -> Garden -> Garden Scene`

It is recommended to open some useful tools that will help you to debug your shaders:

On your toolbar select `Window -> Analysis -> Frame debugger`. It is a very powerful tool that breaks down the entire rendering sequence and lets you see actual intermediate textures and go through it step-by-step.

### Flat shader
Now lets start with the first step, let's create a plain color shader
In `Assets` folder create a new `Shaders` folder to keep things clean, then `Right click -> Create -> Standard Surface Shader` and name it however you like. I will name it "MyLit" for this tutorial

Unity will auto generate a shader file for you, however we will get rid of most of its contents

```C++
Shader "Custom/MyLit"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> DELETE FROM HERE
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> TO HERE
    }
    SubShader
    {
        
        Tags { "RenderType"="Opaque" }
        LOD 200

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> DELETE FROM HERE
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
        
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> TO HERE
    }
    
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> DELETE FROM HERE
    FallBack "Diffuse"
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> TO HERE
}
```

So we end up with
```C++
Shader "Custom/MyLit"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
    }
}
```

This is not out shader yet, but rather a configuration file. Unity uses [ShaderLab](/ShaderLab/README.md)