[<- Back to URP info](../README.md)

***! Work in progress... !** Some info might be missing*
<h2 align="center">Core.hlsl</h2>

### See Unity [source](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl) on Github
## Includes

## Structs

### VertexPositioninputs

Is used to represent position in different coordinate systems.

Syntax:
```C++
struct VertexPositionInputs
{
    float3 positionWS; // World space position
    float3 positionVS; // View space position
    float4 positionCS; // Homogeneous clip space position
    float4 positionNDC;// Homogeneous normalized device coordinates
};
```
### VertexNormalinputs

Is used to represent normal info.

Syntax:
```C=+
struct VertexNormalInputs
{
    real3 tangentWS;
    real3 bitangentWS;
    float3 normalWS;
};
```
## Functions
