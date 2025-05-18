To start with, here are some stats and versions that will be used in this tutorial

- Unity: 2022.3 
- Template: URP 3D Sample
- Universal RP package: 14.0.11
- Scene: Garden by Unity

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
We got rid of some extra properties that are not a priority right now and default shader code (written in CG), we don't need it because we will be using HLSL, as CG is slightly outdated, and all unity shader base is also in HLSL.

This is not out shader yet, but rather a configuration file. Unity uses [ShaderLab](/ShaderLab/README.md) to properly put shaders into the general structure.

Let's go through each line and see what it does:

`Shader "Custom/MyLit"` sets a path for your shader, so that next time you create a material you can find can set material's shader by this path.

[Properties](/ShaderLab/Properties/README.md) define which variables will your shader accept as input. This is the main variables definition point, as properties can be set both through inspector and C# scripts.

[Subshader](/ShaderLab/SubShader/README.md) is a container for all the information about execution of your shader, you can have multiple SubShader blocks in your Shader block, but we will keep only 1.

[Tags](/ShaderLab/SubShader/README.md/#tags-for-subshader) define a general behaviour of the shader, for example, tag `"RenderType"="Opaque"` tells the compiler that this block will render opaque geometry, we can set it to `"Transparent"` if we would make a transparent shader, so Unity puts its execution in the transparent queue.

LOD allows to change level of detail of your shader, if, for example, you have 2 subshaders with LOD 300 (more details) and LOD 200 (less details) unity will automatically decide which subshader to use depending on LOD of the object in question.

The one thing we are missing is [Pass](/ShaderLab/Pass/README.md) block, which corresponds to rendering directly. Create a new Pass:

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
        Pass {
            Name "Forward Pass"
            Tags {"LightMode" = "UniversalForward"}
            HLSLPROGRAM
            ENDHLSL
        }
    }
}
```

Here, between HLSLPROGRAM and ENDHLSL we will write our HLSL code, as compiler now treats everything between those 2 statements as HLSL

Name is just a name for your pass, we will see it a bit later.

Pass also defines its own [Tags](/ShaderLab/Pass/README.md/#tags-for-pass). Bear in mind, those are different from [SubShader Tags](/ShaderLab/SubShader/README.md/#tags-for-subshader). Here we set light mode to `"UniversalForward"` to tell Unity that in this part we will render color output for geometry.

This is it for config, so we can finally step into HLSL. Since HLSL supports [#include directive](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-appendix-pre-include) we can easily include any hlsl file in our ShaderLab file. So, for better structure, we will separate HLSL file from SHaderLab file. in `Shaders` folder create a new `HLSL` folder and then inside the latter one `Passes` folder. Why it is better to have 2 folders will be explained later. Now, unfortunately Unity doesn't allow to create new .hlsl files, so from here we will need to do it manually. You may try 2 ways:

1. Right-cLick inside your folder in Unity and select `Show in explorer`, there create a new `.txt` file and rename it into `MyLitForwardPass.hlsl`
2. Through Visual Studio, right-click your folder `Add -> New Item... -> Text File`. Rename it into `MyLitForwardPass.hlsl`

Now we can include this file into the ShaderLab file, don't forget to use relative path:

```C++
...
HLSLPROGRAM

#include "../HLSL/Passes/MyLitForwardPass.hlsl"

ENDHLSL
...
```

Similarly to C++ we need to define an include guard in HLSL file, and just like in C++ we can do

```C++
#ifdef MY_LITFORWARDPASS_INCLUDED
#define MY_LIT_FORWARD_PASS_INCLUDED

#endif
```

You can name it however you want but make sure you follow your conventions, however, it is recommended to use Unity's naming convention, which is exactly what was done.

From here we will define 2 functions, which will be vertex stage and fragment stage. If you are unfamiliar with shader structure, please check this article on [Learn OpenGL](https://learnopengl.com/Getting-started/Hello-Triangle) ![shader structure image](https://learnopengl.com/img/getting-started/pipeline.png)

What we need to do is
1. Gather data from properties
2. Pass through vertex shader to get Interpolators
3. Pass Interpolators through fragment shader to get a color

![](/src/images/HLSL%20Shader%20Structure.png)
