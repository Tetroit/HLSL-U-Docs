[<- Back to URP info](../README.md)

***! Work in progress... !** Some info might be missing*
<h2 align="center">SurfaceData.hlsl</h2>

### See Unity [source](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl) on Github

Contains a surface template structure used for PBR and Blinn-Phong lighting, exists since 2021.
## Structs

### SurfaceData

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