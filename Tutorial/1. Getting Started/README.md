[<- Back to Tutorial info](../README.md)
<h2 align="center">Part 1. Flat color shader</h2>

To start with, here are some stats and versions that will be used in this tutorial

- Unity: 2022.3 
- Template: URP 3D Sample
- Universal RP package: 14.0.11
- Scene: Garden by Unity

URP Samples are very good for building shaders as they already contain a variety of features such as SSAO, light probes, skybox, baked lighting, etc. Don't worry if you don't know what these terms mean, advanced features are not the focus of this chapter, but we might need them in the future. But also Garden scene is just beautiful, what can be better than some secluded pretty place to work? Of cource, if you feel comfortable without some beautiful ambient environment, then feel free to start with a default scene, as you can easily transfer your progress to another scene or project as all created shader assets are scene independent.

So let's hop on the scene and get started!

### Setup

> [!IMPORTANT] 
> **If on URP Sample**, there is one optimization that should be turned off for the beginning. Go to the project settings `Edit -> Project Settings` and select `Quality` tab. In `Rendering -> Rendering Pipeline Assets` you will find a currently used render pipeline asset. Double-click it to see it in inspector. On the very top there is a list of renderers `Rendering -> Renderer List`. Double-click the one that is set to default and make sure `Rendering -> Depth Priming Mode` is set to `Disabled`. This optimization makes Unity skip rendering depending on depth buffer. Since we will not use it for the beginning, our objects will simply not render if this option is on.

Go to `Assets -> Scenes -> Garden -> Garden Scene`

It is recommended to open some useful tools that will help you to debug your shaders:

On your toolbar select `Window -> Analysis -> Frame debugger`. It is a very powerful tool that breaks down the entire rendering sequence and lets you see actual intermediate textures and go through it step-by-step.

## Flat shader
Now let's start with the first step, let's create a plain color shader.

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
We got rid of some extra properties that are not a priority right now and default shader code (written in CG), we don't need it because we will be using HLSL, furthermore CG is slightly outdated, and all unity shader base is also in HLSL. 

This is not out shader yet, but rather a configuration file. Unity uses [ShaderLab](/ShaderLab/README.md) to properly put shaders into the general structure.

Let's go through each line and see what it does:

`Shader "Custom/MyLit"` sets a path for your shader, so that next time you create a material you can find can set material's shader by this path.

[Properties](/ShaderLab/Properties/README.md) define which variables will your shader accept as input. This is the main variables definition point, as properties can be set both through inspector and C# scripts.

[Subshader](/ShaderLab/SubShader/README.md) is a container for all the information about execution of your shader, you can have multiple SubShader blocks in your Shader block, but we will keep only 1.

[Tags](/ShaderLab/SubShader/README.md/#tags-for-subshader) define a general behaviour of the shader, for example, tag `"RenderType"="Opaque"` really does nothing, but identifies the SubShader. Is not really needed now, so you can remove it if you want.

LOD allows to change level of detail of your shader, if, for example, you have 2 subshaders with LOD 300 (more details) and LOD 200 (less details) unity will automatically decide which subshader to use depending on LOD of the object in question.

Moving on, add a new tag `"RenderPipeline" = "UniversalPipeline"` to tell the compiler that this SubShader is compatible with URP and create a new [Pass](/ShaderLab/Pass/README.md) block, which corresponds to rendering directly.

```C++
Shader "Custom/MyLit"
{
    //Define material inputs here
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    //Shader logic here
    SubShader
    {
        Tags {
            "RenderType"="Opaque"

            //Set rendering pipeline
            "RenderPipeline" = "UniversalPipeline"
        }

        LOD 300

        Pass {
            //Name to display in debugger
            Name "ForwardLit"
            //Set light mode to tell that we render the color in this pass
            Tags {
                "LightMode" = "UniversalForward"
            }
            //HLSL code here
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
//HLSL code here
HLSLPROGRAM

//include your hlsl file
#include "./HLSL/Passes/MyLitForwardPass.hlsl"

ENDHLSL
```

Returning to HLSL file. Similarly to C++ we need to define an include guard, and it is done exactly as in C++:

```C++
//Include guard
#ifndef MY_LITFORWARDPASS_INCLUDED
#define MY_LIT_FORWARD_PASS_INCLUDED

#endif
```

You can name it however you want but make sure you follow your conventions, however, it is recommended to use Unity's naming convention, which is exactly what was done above.

We can reference Unity HLSL files as well! You actually see them in assets if you go to `Packages -> UniversalRP -> ShaderLibrary`. We will need one single file `Lighting.hlsl`. Include it as follows:
```C++
//Include guard
#ifndef MY_LITFORWARDPASS_INCLUDED
#define MY_LIT_FORWARD_PASS_INCLUDED

//Include Lighting.hlsl form the URP package
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#endif
```

Watch out for the spelling, since Unity has its own naming conventions for packages!  
This file includes other necessary files from the ShaderLibrary, so we do not need to include them.

From here we will define 2 functions, which will be vertex stage and fragment stage. If you are unfamiliar with shader structure, please check this article on [Learn OpenGL](https://learnopengl.com/Getting-started/Hello-Triangle).

![shader structure image](https://learnopengl.com/img/getting-started/pipeline.png)

What we need to do is
1. Gather data from properties
2. Pass through vertex shader to get Interpolators
3. Pass Interpolators through fragment shader to get a color

In order to transfer data we need to define 2 structs and 2 functions:
![](/src/images/HLSL%20Shader%20Structure.png)



```C++
//include guard
#ifndef MY_LITFORWARDPASS_INCLUDED
#define MY_LIT_FORWARD_PASS_INCLUDED

//Include Lighting.hlsl form the URP package
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

//Vertex shader input
struct Vertex
{
	//Position in object space as position input
	float3 positionOS : POSITION;
};

//Vertex shader output and fragment shader input
struct Interpolators
{
	//Position in clip space as position output
	float4 positionCS : SV_POSITION;
};

//Vertex shader
Interpolators vert(Vertex vertInput)
{
	//Create struct
	Interpolators result = (Interpolators)0;
	//Get transformed positions
	VertexPositionInputs positionInputs = GetVertexPositionInputs(vertInput.positionOS);
	//Set clip space position to the struct
	result.positionCS = positionInputs.positionCS;

    return result;
}

//Fragment shader
float4 frag(Interpolators fragInput)
{
}

#endif
```

> [!TIP]
> `Interpolators result = (Interpolators)0;` is a way to create a structure with zeroed fields.

### Conventions

Unity identifies coordinate spaces by suffixes:

| Suffix | Meaning |
| --- | --- |
| -OS | Object Space |
| -WS | World Space |
| -VS | View Space |
| -CS | Clip Space |

I already put some beginning code, so let's have a look at it:
1. Vertex: Here we receive vertex positions from Unity as `float3`, given in **object space**, it is marked with Unity
2. Interpolators: Here we store resulting position in **clip space**, please notice that it is stored as `float4`

> [!NOTE]
> As you notice, here we use a [semantic tag](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-semantics) after the function syntax. "SV_" prefix stands for [System-Value](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-semantics#system-value-semantics), these semantic tags are built in and tell the internal pipeline what data we are providing to it. To put it simple, think of it as an "output field" tag. Position is also a tag but it [vertex shader only](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-semantics#vertex-shader-semantics). You can also define your own semantic tags!  
So in Vertex we marked the input field as `POSITION` and in Interpolators we marked it as `SV_POSITION` position output.

3. vert: Unity already provides us with the necessary tools, so we don't need to worry about math hassle behind object to clip space transformation. [`GetVertexPositionInputs`]() is defined in [ShaderVariablesFunctions.hlsl](). It takes a point in **object space** and returns a [`VertexPositionInputs`]() struct. The struct has the following fields:

*Taken from URP [Core.hlsl]()*
```C++
struct VertexPositionInputs
{
    float3 positionWS; // World space position
    float3 positionVS; // View space position
    float4 positionCS; // Homogeneous clip space position
    float4 positionNDC;// Homogeneous normalized device coordinates
};
```

Right now we will only link the color from the `_Color` field in ShaderLab file.

> [!IMPORTANT]
> To get a property from ShaderLab, we need to declare it in HLSL with the exact same name.

At this stage, we don't use any vertex shader code, so we only need to set fragment output to _Color:
```C++
//Include Lighting.hlsl form the URP package
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

//Get the color property from ShaderLab
float4 _Color

...

//Fragment shader as color output
float4 frag(Interpolators fragInput) : SV_Target
{
	//Simply set the color
	return _Color;
}
```
Here we also attach a semantic tag, which is the same as saying that we output a color with it.

We are almost done here, the last piece we are missing is that hlsl doesn't know which kernel is vertex and which one is fragment. Even though it is HLSL part, we will refereence them in **ShaderLab** file:

```C++
//HLSL code here
HLSLPROGRAM

//hook up the shaders
#pragma vertex vert
#pragma fragment frag

//include your hlsl file
#include "./HLSL/Passes/MyLitForwardPass.hlsl"

ENDHLSL
```

Now we can finally behold the result in Unity! Right-click your shader in Unity `Create -> Material`. This will create a material and automatically assign your shader to it. You should be able to see a white circle in preview and a color property in the Inspector, which you can tweak and see your object changing color.
![](/src/images/Shader%20Result%20Tutorial1.png)

If something goes wrong you can analyse what is missing in the **frame debugger**! At this point you should be able to see your objects being rendered in `DrawOpaqueObjects -> RenderLoop.Draw`. You can see all the details about it, such as:
- Which shader is used.
- The name of your pass (as we set earlier).
- Under `Vectors` you will also see a `_Color` entry.

And a lot more...

![](/src/images/Frame%20Debugger%20Tutorial1.png)

Congratulations, you now have created a very basic color shader, which you can further extend unlimitedly (the only limit is imagination, and well... a max of 8 color outputs, but no worries, this will be far in the future!). 

This concludes the first part, the next topic covers why and how to actually utilize Lighting.hlsl as we will complete our lit shader.

## Extras

### Code

Here is full resulting code from this chapter:
- [Shader file](./MyLit.shader)
- [Forward Pass file](./MyLitForwardPass.hlsl)

### Practice
If you are not sure if you understood everything or just want to go deeper in the subjects discussed in this chapter, you may try these practice tasks:

1. What do you think will happen if in fragment shader you return `fragInput.positionCS`? Try it out yourself. Why does it happen to look so bright?
2. Make a new `_Offset` property as Vector and try to translate your object by this vector using vertex shader. (You will need vertex shader for this)
3. What would happen if in fragment shader you return positionOS? Why can't you do it straight away?  
*Hint: Use COLOR0 tag to pass it (you will see in the next chapter)*