[<- Back to URP info](../README.md)

***! Work in progress... !** Some info might be missing*
<h2 align="center">ShaderVariablesFunctions.hlsl</h2>

### See Unity [source](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl) on Github

## Includes

## Structs

## Functions

### GetVertexPositionInputs
Performs Transforms to world, view and clip space from the gived coordinate in Object space

Arguments:
- float3 positionOS - position in object space

Returns:
- [VertexPositionInputs](./Core.hlsl.md#vertexpositioninputs)
```C++
VertexPositionInputs GetVertexPositionInputs(float3 positionOS)
{
    VertexPositionInputs input;
    input.positionWS = TransformObjectToWorld(positionOS);
    input.positionVS = TransformWorldToView(input.positionWS);
    input.positionCS = TransformWorldToHClip(input.positionWS);

    float4 ndc = input.positionCS * 0.5f;
    input.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
    input.positionNDC.zw = input.positionCS.zw;

    return input;
}
```