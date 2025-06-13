[<- Back to Tutorial info](../README.md)

1. [Getting started](../1.%20Getting%20Started/README.md)
2. Lighting

<h2 align="center">Part 2. Lighting</h2>

This is a continuation of the [previous chapter](../1.%20Getting%20Started/README.md), where we've created a flat color shader, so if you did not look through it, I would highly recommend to do so, since in this chapter we will continue with the resulting code.

Here we are going to go through:

1. Recieving light\
![](/src/images/Tutorial2%20Lights.png)
2. Surface parameters\
![](/src/images/Tutorial2%20Smoothness.png)
3. Baked GI\
![](/src/images/Tutorial2%20BakedGI.png)
4. Texture\
![](/src/images/Tutorial2%20Texture.png)
### Surface parameters

I believe it is not a secret that lighting is a fairly complex topic and has a lot of aspects, so we will not go deep into details, but we will explore what each parameter does. First of all, there are 2 types of paramerers: **surface** and **input**
- Surface parameters is what defines the material: color, roughness, metallicness, etc
- Input parameters are external and geometric factors that affect color in a certain way, mainly positions, directions, lights, shadows and GI.

Unity already has premade storages for those parameters and is actively using them in the pipeline!


From [SurfaceData.hlsl](/HLSL/Unity%20URP/Files/SurfaceData.hlsl.md):

```Cpp
struct SurfaceData
{
    half3 albedo;
    half3 specular;
    half  metallic;
    half  smoothness;
    half3 normalTS;
    half3 emission;
    half  occlusion;
    half  alpha;
    half  clearCoatMask;
    half  clearCoatSmoothness;
};
```
From [Input.hlsl](/HLSL/Unity%20URP/Files/Input.hlsl.md#InputData):
```Cpp
struct InputData
{
    float3  positionWS;
    float4  positionCS;
    float3  normalWS;
    half3   viewDirectionWS;
    float4  shadowCoord;
    half    fogCoord;
    half3   vertexLighting;
    half3   bakedGI;
    float2  normalizedScreenSpaceUV;
    half4   shadowMask;
    half3x3 tangentToWorld;

    #if defined(DEBUG_DISPLAY)
    half2   dynamicLightmapUV;
    half2   staticLightmapUV;
    float3  vertexSH;

    half3 brdfDiffuse;
    half3 brdfSpecular;
    float2 uv;
    uint mipCount;

    // texelSize :
    // x = 1 / width
    // y = 1 / height
    // z = width
    // w = height
    float4 texelSize;

    // mipInfo :
    // x = quality settings minStreamingMipLevel
    // y = original mip count for texture
    // z = desired on screen mip level
    // w = loaded mip level
    float4 mipInfo;
    #endif
};
```

No need to worry, we will not fill everything, only the necessary parts. Then we just call a magic function that does all the hard job for us.
```cpp
half4 UniversalFragmentPBR(InputData inputData, SurfaceData surfaceData)
```  
(from [Lighting.hlsl](/HLSL/Unity%20URP/Files/Lighting.hlsl.md#UniversalFragmentPBR))

This is actually the way shader graph works as well, everything from the graph goes into some of the structures' values and then the pipeline does its job.

Let's start with with adding an albedo color, we will simply reuse the `_Color` property. In the fragment shader initialize the 2 structures and add the PBR function:

```cpp
//Fragment shader as color output
float4 frag(Interpolators fragInput) : SV_Target
{
	//Input structure
	InputData inputData = (InputData)0;

    //Surface structure
	SurfaceData surfaceData = (SurfaceData)0;

    //Set the color
    surfaceData.albedo = _Color.rgb;
	surfaceData.alpha = _Color.a;

	//Simply set the color
	return UniversalFragmentPBR(inputData, surfaceData);
}
```

*MyLitForwardPass.hlsl*

However, if we look at our material it is just black, thats because inputData needs to contain a some more parameters in order for the PBR function to work properly:

- normalWS
- normalizedScreenSpaceUV
- positionWS
- viewDirectionWS
- positionCS (recommended, but not mandatory)

See below for implementation and explanation.

To get normal data we need to first get it from geometry, so we need to modify the structure like this:

```cpp
//Vertex shader input
struct Vertex
{
	//Position in object space as position input
	float3 positionOS : POSITION;
	//Normal in object space as normal input
	float3 normalOS : NORMAL;
};

//Vertex shader output and fragment shader input
struct Interpolators
{
	//Position in clip space as position output
	float4 positionCS : SV_POSITION;
	//Record position in world space
	float3 positionWS : TEXCOORD0;
	//Record normal in world space
	float3 normalWS : TEXCOORD1;
};

//Vertex shader
Interpolators vert(Vertex vertInput)
{
	//Create struct
	Interpolators result = (Interpolators)0;

	//Get transformed positions and normals
	VertexPositionInputs positionInputs = GetVertexPositionInputs(vertInput.positionOS);
	VertexNormalInputs normalInputs = GetVertexNormalInputs(vertInput.normalOS);

	//Get clip space position from positionInputs
	result.positionCS = positionInputs.positionCS;
	//Get world space position from positionInputs
	result.positionWS = positionInputs.positionWS;
	//Get world space normal from normalInputs
	result.normalWS = normalInputs.normalWS;

    return result;
}

//Fragment shader as color output
float4 frag(Interpolators fragInput) : SV_Target
{
	//Input structure
	InputData inputData = (InputData)0;
	
	inputData.normalWS = normalize(fragInput.normalWS);
	inputData.positionWS = fragInput.positionWS;
	inputData.positionCS = fragInput.positionCS;
	inputData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(fragInput.positionWS);
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(fragInput.positionCS);
	
	//Surface structure
	SurfaceData surfaceData = (SurfaceData)0;
	surfaceData.albedo = _Color.rgb;
	surfaceData.alpha = _Color.a;
	//Simply set the color
	return UniversalFragmentBlinnPhong(inputData, surfaceData);
}
```
*MyLitForwardPass.hlsl*

> [!NOTE]
> We additionally normalize the normal vector to avoid feeding the engine with incorrect data, as the fragment value is **linearly interpolated**, not **spherically**.

Explanation:

- in `Vertex` normal vector is marked with `NORMAL` semantic tag.
- since normals are needed in world space we cannot assign any specific semantic tag to it, the way to pass it is to attach a `TEXCOORD(n)` tag to it, number doesn't really matter as long as you don't use it more than once.
- the same trick was performed to get `positionWS` to fragment shader as well.
- in vertex shader, there is a similar function to the position one that allows to transform normal from object to world space [GetVertexNormalInputs](/HLSL/Unity%20URP/Files/ShaderVariablesFunctions.hlsl.md#GetVertexNormalInputs). It returns a [VertexNormalInputs](/HLSL/Unity%20URP/Files/Core.hlsl.md#VertexNormalInputs).
- current view direction can be obtained with [GetWorldSpaceNormalizeViewDir](/HLSL/Unity%20URP/Files/ShaderVariablesFunctions.hlsl.md#GetWorldSpaceNormalizeViewDir).


On the scene it will still remain black, that is because all lights in our scene are **baked**, so in order to see changes we need to rebake the entire scene or just add another directional light and make it **realtime**.

> [!TIP]
> You can think of baked lighing as a frozen pizza: we do all hard work prior and freeze it, so then when needed we can quickly and efficiently get a good quality result. Light is baked into so called **lighmaps**, then on runtime they are applied as textures. One limitation is that it only works with **static** lights and objects.

Moreover, the shader file needs a defined _FORWARD_PLUS **keyword** to operate properly, thats because Unity has 2 forward renderers.

>[!NOTE]
>Forward rendering mode is very basic, it supports up to 4 point lights per object
>Forward+ rendering mode supports hundreds of lights (and this is the reason we must provide clip space position to )

For this, we use [`#pragma multi_compile`](https://docs.unity3d.com/2022.3/Documentation/Manual/SL-MultipleProgramVariants-declare.html). The difference between `#define` and `#pragma multi_compile` is that compiler can create multiple variants of the same shader with different keywords when required. In our case, insert `#pragma multi_compile _ _FORWARD_PLUS` before including the hlsl file. What it will do is compile 2 variants (when required): with `_FORWARD_PLUS` defined and without (indicated with single underscore).

```cpp
Pass {
    //Name to display in debugger
    Name "ForwardLit"
    //Set light mode to tell that we render the color in this pass
    Tags {
        "LightMode" = "UniversalForward"
    }
    
    //HLSL code here 
    HLSLPROGRAM

    //hook up the shaders
    #pragma vertex vert
    #pragma fragment frag
    
    #pragma multi_compile _ _FORWARD_PLUS

    //include your hlsl file

    #include "./HLSL/Passes/MyLitForwardPass.hlsl"

    ENDHLSL
}
```
*MyLit.shader*

After that is done, material in your scene should appear as something like this

![PBR material image](/src/images/Tutorial2%20Lights.png)

It should be lit from directional and nearby point lights.

If something is wrong it might be due to:
- You did not assign all necessary parameters.
- Some keywords might be missing.
- Your current renderer is set to Forward or Deferred.
- You are missing tags in SubShader or Pass tags or they contain typos.

> [!TIP]
> For debug:
> - Again... Use frame debugger! Carefully look through the pass variables and defines for anything weird.
> - Change the scene or move your camera to check if the behaviour is as expected.

### More parameters

Now we got to the fun part, let's decorate the shader with extra values that we can tweak.

Let's start with smoothness:

In MyLit.shader add a [range property](/ShaderLab/Properties/Float.md):

```cpp
_Color ("Color", Color) = (1,1,1,1)
_Smoothness ("Smoothness", Range(0,1)) = 0.5
```

Supply the HLSL side with these values:

```cpp
//Get properties from ShaderLab
float4 _Color;
float _Smoothness;
float _Metallic;

...

//Surface structure
SurfaceData surfaceData = (SurfaceData)0;
surfaceData.albedo = _Color.rgb;
surfaceData.alpha = _Color.a;
surfaceData.smoothness = _Smoothness;
surfaceData.metallic = _Metallic;
```

> [!TIP]
> Unlike [float property](/ShaderLab/Properties/Float.md), range property allows to restrict users from entering invalid values, for example, smoothness is intended to be within [0,1] range (although it may be interesting to see what happens if you go beyond)

You should get a pleasant reflection of the surrounding lights. 

![](/src/images/Tutorial2%20Smoothness.png)

Let's add environment reflection as well!

> [!NOTE]
> In practice in order for this to work you need to have your object to be in a **reflection probe** area. For simplicity you can add 1 reflection probe, place it nearby and make it realtime. But the Garden scene already has baked reflection probes, so it makes things simpler.

Now things will get a bit tricky.

Inside the **vertex** struct type out this:
```cpp
DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 2);
```

\- "But wait, aren't functions in structs forbiddden in HLSL?"\
\- "This is *not* a function..."

This is a **macro**, but with arguments, c++ learners might be familiar with it, if so, then here it is not different!

---
### Macros
Let's make a bit of clarification here:

Shader **keywords** (don't confuse with programming language keywords) are also a kind of macro, but they have no value, so they only serve as compiler key to switch on or off certain parts of code via `#ifdef`/`#ifndef` directives, hence the name. `_FORWARD_PLUS` is an example.

Normally, macro is a constant expression, you can define your own macro by using `#define` directive:
```cpp
#define PI 3.141593
``` 
or
```cpp
#define DIAGONAL_DIR normalize(float3(1,1,1))
``` 
It basically just replaces the defined word with whatever goes after. So there is no type or syntax check.

You can make it **multi-line** as well:

```cpp
#define DEFINE_CONSTS\
float PI = 3.141593;\
float EXP = 2.71828;
``` 

Sometimes, you need to adjust your macro with some parameters, and yes, HLSL allows that:
```cpp
#define ADD(a,b) a + b
```
You will use it as
```cpp
float3 arg1 = float3(0,0,1);
float3 arg2 = float3(0,1,0);
float3 res = ADD(vec1, vec2);
```

> [!NOTE]
> One little detail, you will often see `##` in macros, which simply means **concatenation**. And you can use it both in macro and in the regular code. To put it simple:
> Inside regular code:
> ```cpp
> #define ID 1
> TEXCOORD ID;
> //is the same as 
> TEXCOORD 1;
> ```
> ```cpp
> #define ID 1
> TEXCOORD##ID;
> //is the same as
> TEXCOORD1;
> ```
> 
> Inside macro:
> ```cpp
> #define TEXCOORD(id) TEXCOORD id
> TEXCOORD(1);
> //is the same as 
> TEXCOORD 1;
> ```
> ```cpp
> #define TEXCOORD(id) TEXCOORD##id
> TEXCOORD(1);
> //is the same as 
> TEXCOORD1;
> ```
---

### Baked GI
(or Baked Global Illumination)

Back to the topic, the macro we need is defined in [Lighting.hlsl](/HLSL/Unity%20URP/Files/Lighting.hlsl.md#DECLARE_LIGHTMAP_OR_SH):

```cpp
#if defined(LIGHTMAP_ON)
    #define DECLARE_LIGHTMAP_OR_SH(lmName, shName, index) float2 lmName : TEXCOORD##index
#else
    #define DECLARE_LIGHTMAP_OR_SH(lmName, shName, index) half3 shName : TEXCOORD##index
#endif
```

This is a good example of the branching that is going inside URP, so basically, by typing `DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 2);` in our shader, a proper value is being declared: either `float2 staticLightmapUV` or `half3 vertexSH` and assigned with `TEXCOORD2` semantic tag.

To use the baked lighting we need to simply sample it and there is a very similar macro in built-in Lighting.hlsl (this file is different from what we included in hlsl file at start, but URP Lighting.hlsl refers to built-in Lighting.hlsl, so there is no need to include it in addition).

```cpp
#if defined(LIGHTMAP_ON)
    #define SAMPLE_GI(lmName, shName, normalWSName) SampleLightmap(lmName, normalWSName)
#else
    #define SAMPLE_GI(lmName, shName, normalWSName) SampleSHPixel(shName, normalWSName)
#endif
```

Put the sampled GI into `inputData.bakedGI`. And, most importantly, **set `surfaceData.occlusion` to 1**. By default it is set to 0, which means all the ambient light, including reflections, is occluded (reduced to 0). Inside fragment shader now you will have:
```cpp
	//Input structure
	InputData inputData = (InputData)0;
	
	inputData.normalWS = normalize(fragInput.normalWS);
	inputData.positionWS = fragInput.positionWS;
	inputData.positionCS = fragInput.positionCS;
	inputData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(fragInput.positionWS);
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(fragInput.positionCS);
    inputData.bakedGI = SAMPLE_GI(fragInput.staticLightmapUV, fragInput.vertexSH, fragInput.normalWS);

	//Surface structure
	SurfaceData surfaceData = (SurfaceData)0;

	surfaceData.albedo = _Color.rgb;
	surfaceData.alpha = _Color.a;
	surfaceData.smoothness = _Smoothness;
	surfaceData.metallic = _Metallic;
	surfaceData.occlusion = 1.0;
```
![BakedGI](/src/images/Tutorial2%20BakedGI.png)

Looks much more coherent!

For clearer view, set smoothness and metallic to 1 and you will see the surrounding like through a mirror!

---

### Textures

The last piece of the puzzle is textures and maps, they are quite simple to set up, but there are a couple of nuances.

Here is an [official page](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@14.0/manual/writing-shaders-urp-unlit-texture.html?q=TEXTURE2D) about how to include textures in your shader. For newer versions (Unity 6000+) you can refer to [here](https://docs.unity3d.com/Manual/SL-SamplerStates.html).

To get texture from the inspector define a [texture property](/ShaderLab/Properties/Texture2D.md):

```cpp
_MainTex ("Base Map", 2D) = "white" {}
```

It defaults to a white texture, but Unity provides multiple ones, such as "gray" or "black".

> [!TIP]
> Texture field already includes tiling and offset by default. If you want to get rid of it, use [NoScaleOffset attribute](/ShaderLab/Attributes/README.md)
>
> Add [MainTexture attribute](/ShaderLab/Attributes/README.md) if you want this texture to be accessible with `material.texture` (A texture with `_MainTex` name is automatically considered main);

On HLSL side, a texture and a sampler is needed to be declared.\
If you are unfamiliar with textures, briefly, texture is just pixels and sampler defines the rules about how to read data from these pixels (filtering, uv clamping, etc)  

`Texture2D _MainTex` and `SamplerState sampler_MainTex` are valid initialization types for texture, but it is not recommended to use.\
Use `TEXTURE2D(_MainTex)` and `SAMPLER(sample_MainTex)` instead. It is not a type, it is a macro. The reason is the former is only supported by DirectX, and the latter is cross platform, meaning these macros are defined for each platform individually. For DirectX it expands to [`Texture2D _MainTex`](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.core/ShaderLibrary/API/D3D11.hlsl#L49) and [`SamplerState sampler_MainTex`](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.core/ShaderLibrary/API/D3D11.hlsl#L79) correspondingly.

For the tiling and offset float4 _MainText_ST is needed as well (xy - scale, zw - translate, so "ST" stands for Scale and Translate). It will be automatically hooked by Unity, so no need to worry about it.

To apply the texture we need another piece of vertex data - UV. It is imported to Vertex struct with TEXCOORD0 tag. Since ytexture type is platform-dependant, sampling will also involve macros, for that we need:

[`TRANSFORM_TEX(uv, name)`](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.core/ShaderLibrary/Macros.hlsl#L180) - simply applies tiling and offset, platform independent:
```cpp
#define TRANSFORM_TEX(tex, name) ((tex.xy) * name##_ST.xy + name##_ST.zw)
```
(*even though the comment says it is from legacy version, it is still majorly used by Unity, how thoughful*)

[`SAMPLE_TEXTURE2D(textureName, samplerName, coord2)`](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.core/ShaderLibrary/API/D3D11.hlsl#L122) - platform specific texture sampling:
```cpp
#define PLATFORM_SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               PLATFORM_SAMPLE_TEXTURE2D(textureName, samplerName, coord2)
```
This immplementation is **DirectX specific**

\
\
Now to implementation:

Adjust structs to support UVs
```cpp
//Vertex shader input
struct Vertex
{
	//Position in object space as position input
	float3 positionOS : POSITION;
	//Normal in object space as normal input
	float3 normalOS : NORMAL;
	//UVs as texture coordinates #0 input
	float2 UV : TEXCOORD0;
};

//Vertex shader output and fragment shader input
struct Interpolators
{
	//Positions
	float4 positionCS : SV_POSITION;
	float3 positionWS : TEXCOORD0;
	//Normals
	float3 normalWS : TEXCOORD1;
	//UVs
	float2 UV : TEXCOORD2;
	//GI data
    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 3);
};
```
Set UVs in vertex shader:
```cpp
result.UV = vertInput.UV;
```

In fragment shader apply tiling and offset and sample the texture:
```cpp
float2 uv = TRANSFORM_TEX(fragInput.UV, _MainTex);
float4 textureColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

surfaceData.albedo = _Color.rgb * textureColor;
```
For simplicity we will not apply complex blending, just use multiplication.

In the end the texture should be applied properly with working tiling and offset:

![](/src/images/Tutorial2%20Texture.png)

We will dive deeper into different types of textures in the subsequent chapters. But for now this is the end! Next step will be implementing shadows, transparency and more about shader variants.

## Extras

### Code

Here is full resulting code from this chapter:

|---- [MyLit.shader](./MyLit.shader)  
|---- HLSL  
&emsp;&emsp;|---- Passes  
&emsp;&emsp;&emsp;&emsp;|---- [MyLitForwardPass.hlsl](./MyLitForwardPass.hlsl)

### Practice
If you are not sure if you understood everything or just want to go deeper in the subjects discussed in this chapter, you may try these little practical tasks:

1. Change the HLSL code so that _MainTex is used as smoothness, was the result what you expected?
2. Try setting up other surface sliders and play with them, what will happen if you go beyond [0,1] range?
3. Right now you define texture with 3 parameters: texture, sampler and tiling/offset. Create a macro that cteates all 3 parameters with 1 line (refer to [macros](#macros) section if needed).