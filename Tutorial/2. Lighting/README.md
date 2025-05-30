[<- Back to Tutorial info](../README.md)

<nav style="display: flex; flex-wrap: wrap; justify-content: space-around; font-size: 20px;">
<a href = "../1.%20Getting%20Started/README.md">1. Getting started</a>
<p href = "../2.%20Lighting/README.md" style = "text-decoration: underline">2. Lighting</p>
</nav>

<h2 align="center">Part 2. Flat color shader</h2>

This is a continuation of the [previous chapter](../1.%20Getting%20Started/README.md), where we've created a flat color shader, so if you did not look through it, I would highly recommend to do so, since in this chapter we will continue with the resulting code.

### Surface parameters

I believe it is not a secret that lighting is a fairly complex topic and has a lot of aspects, so we will not go deep into details, but we will explore what each parameter does. First of all, there are 2 types of paramerers: **surface** and **input**
- Surface parameters is what defines the material: position, roughness, metallicness, etc
- Input parameters are external factors that affect color in a certain way, mainly light, shadows and GI.

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


## Extras

### Code

Here is full resulting code from this chapter:
- [Shader file](./MyLit.shader)
- [Forward Pass file](./MyLitForwardPass.hlsl)

### Practice
If you are not sure if you understood everything or just want to go deeper in the subjects discussed in this chapter, you may try these little practical tasks:
