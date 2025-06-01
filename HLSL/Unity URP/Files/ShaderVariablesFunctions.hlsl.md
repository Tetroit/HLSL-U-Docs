[<- Back to URP info](../README.md)

***! Work in progress... !** Some info might be missing*
<h2 align="center">ShaderVariablesFunctions.hlsl</h2>

### See Unity [source](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl) on Github

## Includes

## Structs

## Constants and variables
 - `const kSurfaceTypeOpaque = 0.0;`
 - `const kSurfaceTypeTransparent = 1.0;`
## Functions

- [GetVertexPositionInputs](#getvertexpositioninputs)
- [GetVertexNormalsInputs](#getvertexnormalinputs)
- [GetScaledScreenParams](#getscaledscreenparams)
- [IsPerspectiveProjection](#isperspectiveprojection)
- [GetCameraPositionWS](#getcamerapositionws)
- [GetCurrentViewPosition](#getcurrentviewposition)
- [GetViewForwardDir](#getviewforwarddir)
- [GetWorldSpaceViewDir](#getworldspaceviewdir)
- [GetObjectSpaceNormalizeViewDir](#getobjectspacenormalizeviewdir)
- [GetWorldSpaceNormalizeViewDir](#getworldspacenormalizeviewdir)
- [GetLeftHandedViewSpaceMatrices](#getlefthandedviewspacematrices)
- [IsSurfaceTypeOpaque](#issurfacetypeopaque)
- [IsSurfaceTypeTransparent](#issurfacetypetransparent)
- [IsAlphaToMaskAvailable](#isalphatomaskavailable)
- [SharpenAlphaStrict](#sharpenalphastrict)
- [AlphaClip](#alphaclip)

### GetVertexPositionInputs
Performs Transforms to world, view and clip space from the gived coordinate in Object space.

Arguments:
- **float3** positionOS - position in object space.

Returns:
- [**VertexPositionInputs**](./Core.hlsl.md#vertexpositioninputs) - A collection of positions in differenet coordinate spaces.

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
---
### GetVertexNormalInputs

Arguments:
- **float3** normalOS - normal in object space.
- **float4** tangentOS - tangent vector in object space.

Returns:
- [**VertexNormalInputs**](./Core.hlsl.md#vertexnormalinputs) - A collection of normals in differenet coordinate spaces.

```cpp
VertexNormalInputs GetVertexNormalInputs(float3 normalOS)
{
    VertexNormalInputs tbn;
    tbn.tangentWS = real3(1.0, 0.0, 0.0);
    tbn.bitangentWS = real3(0.0, 1.0, 0.0);
    tbn.normalWS = TransformObjectToWorldNormal(normalOS);
    return tbn;
}
```
```cpp
VertexNormalInputs GetVertexNormalInputs(float3 normalOS, float4 tangentOS)
{
    VertexNormalInputs tbn;

    // mikkts space compliant. only normalize when extracting normal at frag.
    real sign = real(tangentOS.w) * GetOddNegativeScale();
    tbn.normalWS = TransformObjectToWorldNormal(normalOS);
    tbn.tangentWS = real3(TransformObjectToWorldDir(tangentOS.xyz));
    tbn.bitangentWS = real3(cross(tbn.normalWS, float3(tbn.tangentWS))) * sign;
    return tbn;
}
```
---

### GetScaledScreenParams

Returns:
- **float4** - scaled screen parameters.


```cpp
float4 GetScaledScreenParams()
{
    return _ScaledScreenParams;
}
```
---
### IsPerspectiveProjection

Returns:
- **bool** - if the current view performs a perspective projection.


```cpp
// Returns 'true' if the current view performs a perspective projection.
bool IsPerspectiveProjection()
{
    return (unity_OrthoParams.w == 0);
}
```
---

### GetCameraPositionWS

Returns:
- **float3** - current camera position (in world space).

```cpp
float3 GetCameraPositionWS()
{
    // Currently we do not support Camera Relative Rendering so
    // we simply return the _WorldSpaceCameraPos until then
    return _WorldSpaceCameraPos;

    // We will replace the code above with this one once
    // we start supporting Camera Relative Rendering
    //#if (SHADEROPTIONS_CAMERA_RELATIVE_RENDERING != 0)
    //    return float3(0, 0, 0);
    //#else
    //    return _WorldSpaceCameraPos;
    //#endif
}
```
---
### GetCurrentViewPosition

Returns:
- **float3** - current camera position (in world space).

```cpp
// Could be e.g. the position of a primary camera or a shadow-casting light.
float3 GetCurrentViewPosition()
{
    // Currently we do not support Camera Relative Rendering so
    // we simply return the _WorldSpaceCameraPos until then
    return GetCameraPositionWS();

    // We will replace the code above with this one once
    // we start supporting Camera Relative Rendering
    //#if defined(SHADERPASS) && (SHADERPASS != SHADERPASS_SHADOWS)
    //    return GetCameraPositionWS();
    //#else
    //    // This is a generic solution.
    //    // However, for the primary camera, using '_WorldSpaceCameraPos' is better for cache locality,
    //    // and in case we enable camera-relative rendering, we can statically set the position is 0.
    //    return UNITY_MATRIX_I_V._14_24_34;
    //#endif
}
```
---

### GetViewForwardDir

Gets current camera's forward direction (in world space).

Returns:
- **float3** a ray from the current camera to the position (in world space).

```cpp
// Returns the forward (central) direction of the current view in the world space.
float3 GetViewForwardDir()
{
    float4x4 viewMat = GetWorldToViewMatrix();
    return -viewMat[2].xyz;
}
```
---
### GetWorldSpaceViewDir

Gets camera ray to the current position in world space.

Arguments:
- **float3** positionWS - position in world space.

Returns:
- **float3** a ray from the current camera to the position (in world space).


```cpp
// Computes the world space view direction (pointing towards the viewer).
float3 GetWorldSpaceViewDir(float3 positionWS)
{
    if (IsPerspectiveProjection())
    {
        // Perspective
        return GetCurrentViewPosition() - positionWS;
    }
    else
    {
        // Orthographic
        return -GetViewForwardDir();
    }
}
```

---
### GetObjectSpaceNormalizeViewDir

Gets normalized camera ray to the current position in object space.

Arguments:
- **float3** positionOS - position in object space.

Returns:
- **half3** a ray from the current camera to the position (in object space).

```cpp
half3 GetObjectSpaceNormalizeViewDir(float3 positionOS)
{
    if (IsPerspectiveProjection())
    {
        // Perspective
        float3 V = TransformWorldToObject(GetCurrentViewPosition()) - positionOS;
        return half3(normalize(V));
    }
    else
    {
        // Orthographic
        return half3(TransformWorldToObjectNormal(-GetViewForwardDir()));
    }
}
```
---
### GetWorldSpaceNormalizeViewDir

Gets normalized camera ray to the current position in world space.

Arguments:
- **float3** positionOS - position in world space.

Returns:
- **half3** a ray from the current camera to the position (in world space).

```cpp
half3 GetWorldSpaceNormalizeViewDir(float3 positionWS)
{
    if (IsPerspectiveProjection())
    {
        // Perspective
        float3 V = GetCurrentViewPosition() - positionWS;
        return half3(normalize(V));
    }
    else
    {
        // Orthographic
        return half3(-GetViewForwardDir());
    }
}
```

---

### GetLeftHandedViewSpaceMatrices

Flips z coordinate for current view and projection matrixes 

Returns:
- **float4x4** viewMatrix - same as view matrix with flipped Z axis.
- **float4x4** projMatrix - same as view matrix with but with flipped Z axis.

```cpp
// UNITY_MATRIX_V defines a right-handed view space with the Z axis pointing towards the viewer.
// This function reverses the direction of the Z axis (so that it points forward),
// making the view space coordinate system left-handed.
void GetLeftHandedViewSpaceMatrices(out float4x4 viewMatrix, out float4x4 projMatrix)
{
    viewMatrix = UNITY_MATRIX_V;
    viewMatrix._31_32_33_34 = -viewMatrix._31_32_33_34;

    projMatrix = UNITY_MATRIX_P;
    projMatrix._13_23_33_43 = -projMatrix._13_23_33_43;
}
```

---
### IsSurfaceTypeOpaque

Compares surface type with [constant opaque type value](#constants-and-variables) (0.0)

Arguments:
- **half** surfaceType - surface type in question.

Returns:
- **bool** - if surfaceType is opaque.

```cpp
// Returns true if the input value represents an opaque surface
bool IsSurfaceTypeOpaque(half surfaceType)
{
    return (surfaceType == kSurfaceTypeOpaque);
}
```

---

### IsSurfaceTypeTransparent

Compares surface type with [constant transparent type value](#constants-and-variables) (0.0)

Arguments:
- **half** surfaceType - surface type in question.

Returns:
- **bool** - if surfaceType is transparent.

```cpp
// Returns true if the input value represents a transparent surface
bool IsSurfaceTypeTransparent(half surfaceType)
{
    return (surfaceType == kSurfaceTypeTransparent);
}
```
---

### IsAlphaToMaskAvailable

> [!IMPORTANT]
> `_ALPHATEST_ON` must be defined.

Returns:
- **bool** - if alpha mask functionality is available.  
```cpp
// Returns true if AlphaToMask functionality is currently available
// NOTE: This does NOT guarantee that AlphaToMask is enabled for the current draw. It only indicates that AlphaToMask functionality COULD be enabled for it.
//       In cases where AlphaToMask COULD be enabled, we export a specialized alpha value from the shader.
//       When AlphaToMask is enabled:     The specialized alpha value is combined with the sample mask
//       When AlphaToMask is not enabled: The specialized alpha value is either written into the framebuffer or dropped entirely depending on the color write mask

bool IsAlphaToMaskAvailable()
{
    return (_AlphaToMaskAvailable != 0.0);
}
```
---
### SharpenAlphaStrict

Implements [Alpha to coverage](https://bgolus.medium.com/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f) technique
> [!IMPORTANT]
> `_ALPHATEST_ON` must be defined.


Arguments:
- **half** alpha - input alpha value
- **half** cutoff - pixels with alpha below this value will be clipped

Returns:
- **half** coverage alpha

```cpp
// Returns a sharpened alpha value for use with alpha to coverage
// This function behaves correctly in cases where alpha and cutoff are constant values (degenerate usage of alpha clipping)
half SharpenAlphaStrict(half alpha, half alphaClipTreshold)
{
    half dAlpha = fwidth(alpha);
    return saturate(((alpha - alphaClipTreshold - (0.5 * dAlpha)) / max(dAlpha, 0.0001)) + 1.0);
}
```

---

### AlphaClip

Clips pixels based on alpha and cutoff

> [!IMPORTANT]
> `_ALPHATEST_ON` must be defined.

Arguments:
- **half** alpha - input alpha value
- **half** cutoff - pixels with alpha below this value will be clipped

Returns:
- **half** - a modified alpha value if alphaMask is available 

```cpp
// When AlphaToMask is available:     Returns a modified alpha value that should be exported from the shader so it can be combined with the sample mask
// When AlphaToMask is not available: Terminates the current invocation if the alpha value is below the cutoff and returns the input alpha value otherwise
half AlphaClip(half alpha, half cutoff)
{
    bool a2c = IsAlphaToMaskAvailable();

    // We explicitly detect cases where the alpha cutoff threshold is zero or below.
    // When this case occurs, we need to modify the alpha to coverage logic to avoid visual artifacts.
    bool zeroCutoff = (cutoff <= 0.0);

    // If the user has specified zero as the cutoff threshold, the expectation is that the shader will function as if alpha-clipping was disabled.
    // Ideally, the user should just turn off the alpha-clipping feature in this case, but in order to make this case work as expected, we force alpha
    // to 1.0 here to ensure that alpha-to-coverage never throws away samples when its active. (This would cause opaque objects to appear transparent)
    half alphaToCoverageAlpha = zeroCutoff ? 1.0 : SharpenAlphaStrict(alpha, cutoff);

    // When the alpha to coverage alpha is used for clipping, we subtract a small value from it to ensure that pixels with zero alpha exit early
    // rather than running the entire shader and then multiplying the sample coverage mask by zero which outputs nothing.
    half clipVal = (a2c && !zeroCutoff) ? (alphaToCoverageAlpha - 0.0001) : (alpha - cutoff);

    // When alpha-to-coverage is available:     Use the specialized value which will be exported from the shader and combined with the MSAA coverage mask.
    // When alpha-to-coverage is not available: Use the "clipped" value. A clipped value will always result in thread termination via the clip() logic below.
    half outputAlpha = a2c ? alphaToCoverageAlpha : alpha;

    clip(clipVal);

    return outputAlpha;
}
```