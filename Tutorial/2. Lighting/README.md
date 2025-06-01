[<- Back to Tutorial info](../README.md)

<nav style="display: flex; flex-wrap: wrap; justify-content: space-around; font-size: 20px;">
<a href = "../1.%20Getting%20Started/README.md">1. Getting started</a>
<p href = "../2.%20Lighting/README.md" style = "text-decoration: underline">2. Lighting</p>
</nav>

<h2 align="center">Part 2. Flat color shader</h2>

This is a continuation of the [previous chapter](../1.%20Getting%20Started/README.md), where we've created a flat color shader, so if you did not look through it, I would highly recommend to do so, since in this chapter we will continue with the resulting code.

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

However, if we look at our material it is just black, thats because inputData needs to contain a couple more parameters in order for the PBR function to work:

- normalWS
- positionWS (not mandatory)
- positionCS (not mandatory)
- viewDirectionWS (not mandatory)

To get normal data we need to first get it from geometry, so we need to modify the structure:

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
	
	inputData.normalWS = fragInput.normalWS;
	inputData.positionWS = fragInput.positionWS;
	inputData.positionCS = fragInput.positionCS;
	inputData.viewDirectionWS = float3 GetWorldSpaceNormalizeViewDir(fragInput.positionWS);
	
	//Surface structure
	SurfaceData surfaceData = (SurfaceData)0;
	surfaceData.albedo = _Color.rgb;
	surfaceData.alpha = _Color.a;
	//Simply set the color
	return UniversalFragmentBlinnPhong(inputData, surfaceData);
}
```
*MyLitForwardPass.hlsl*

Basically, we did all the same steps as previously with position: Get normal in `Vertex` struct, get world space normal through vertex shader and pass to fragment shader through `Interpolators`. There are a couple things worth noticing though:

- in `Vertex` normal vector is marked with `NORMAL` semantic tag.
- since normals are needed in world space we cannot assign any specific semantic tag to it, the way to pass it is to attach a `TEXCOORD(n)` tag to it, number doesn't really matter as long as you don't use it more than once.
- the same trick was performed to get `positionWS` to fragment shader as well.
- in vertex shader, there is a similar function to position that allows to transform normal from object to world space [GetVertexNormalInputs](/HLSL/Unity%20URP/Files/ShaderVariablesFunctions.hlsl.md#GetVertexNormalInputs). It returns a [VertexNormalInputs](/HLSL/Unity%20URP/Files/Core.hlsl.md#VertexNormalInputs).
- current view direction can be obtained with [GetWorldSpaceNormalizeViewDir](/HLSL/Unity%20URP/Files/ShaderVariablesFunctions.hlsl.md#GetWorldSpaceNormalizeViewDir).


On the scene it will still remain black, that is because all lights in our scene are **baked**, so in order to see changes we need to rebake the entire scene, which is not what we will do, instead, we will just add another directional light and will make it **realtime**.

> [!TIP]
> You can think of baked lighing as a frozen pizza: we do all hard work prior and freeze it, so then when needed we can quickly get a good quality result. Light is baked into so called **lighmaps**, then on runtime they are applied as textures. One limitation is that it only works with **static** lights and objects.

## Extras

### Code

Here is full resulting code from this chapter:
- [Shader file](./MyLit.shader)
- [Forward Pass file](./MyLitForwardPass.hlsl)

### Practice
If you are not sure if you understood everything or just want to go deeper in the subjects discussed in this chapter, you may try these little practical tasks:
