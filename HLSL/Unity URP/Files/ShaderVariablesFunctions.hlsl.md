[<- Back to URP info](../README.md)

***! Work in progress... !** Some info might be missing*
<h2 align="center">ShaderVariablesFunctions.hlsl</h2>

### See Unity [source](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl) on Github

## Defines

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
- [AlphaDiscard](#alphadiscard)
- [OutputAlpha](#OutputAlpha)
- [AlphaModulate](#AlphaModulate)
- [AlphaPremultiply](#alphapremultiply)
- [NormalizeNormalPerVertex](#NormalizeNormalPerVertex)
- [NormalizeNormalPerPixel](#NormalizeNormalPerPixel)
- [ComputeFogFactorZ0ToFar](#ComputeFogFactorZ0ToFar)
- [ComputeFogFactor](#ComputeFogFactor)
- [ComputeFogIntensity](#ComputeFogIntensity)
- [InitializeInputDataFog](#InitializeInputDataFog)
- [MixFogColor](#MixFogColor)
- [MixFog](#mixfog)
- [LinearDepthToEyeDepth](#LinearDepthToEyeDepth)
- [TransformScreenUV](#TransformScreenUV)
- [TransformNormalizedScreenUV](#TransformNormalizedScreenUV)
- [GetNormalizedScreenSpaceUV](#GetNormalizedScreenSpaceUV)
- [Select4](#Select4)
- [GetMeshRenderingLayer](#GetMeshRenderingLayer)
- [EncodeMeshRenderingLayer](#EncodeMeshRenderingLayer)
- [GetCurrentExposureMultiplier](#GetCurrentExposureMultiplier)


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

---
### AlphaDiscard

Terminates the current invocation if the input alpha value is below the specified cutoff value and returns an updated alpha value otherwise. You should call this method to properly clip pixels.

> [!IMPORTANT]
> `_ALPHATEST_ON` must be defined.

Arguments:
- **real** alpha - input alpha value
- **real** cutoff - pixels with alpha below this value will be clipped
- **real** offset - is just added to cutoff, kinda stupid

Returns:
- **real** - a modified alpha value if alphaMask is available 

```cpp
// Terminates the current invocation if the input alpha value is below the specified cutoff value and returns an updated alpha value otherwise.
// When provided, the offset value is added to the cutoff value during the comparison logic.
// The return value from this function should be exported as the final alpha value in fragment shaders so it can be combined with the MSAA coverage mask.
//
// When _ALPHATEST_ON is defined:     The returned value follows the behavior noted in the AlphaClip function
// When _ALPHATEST_ON is not defined: The returned value is equal to the original alpha input parameter
//
// NOTE: When _ALPHATEST_ON is not defined, this function is effectively a no-op.
real AlphaDiscard(real alpha, real cutoff, real offset = real(0.0))
{
#if defined(_ALPHATEST_ON)
    if (IsAlphaDiscardEnabled())
        alpha = AlphaClip(alpha, cutoff + offset);
#endif

    return alpha;
}
```

---
### OutputAlpha

Returns alpha of the current surface, works with all types of surfaces. Basically returns input value if the surface is transparent.

Arguments:
- **half** alpha - input alpha value
- **bool** isTransparent - if the surface transparent

Returns:
- **real** - 1 if surface is opaque, alpha otherwise

```cpp
half OutputAlpha(half alpha, bool isTransparent)
{
    if (isTransparent)
    {
        return alpha;
    }
    else
    {
#if defined(_ALPHATEST_ON)
        // Opaque materials should always export an alpha value of 1.0 unless alpha-to-coverage is available
        return IsAlphaToMaskAvailable() ? alpha : 1.0;
#else
        return 1.0;
#endif
    }
}
```

---
### AlphaModulate
Fake alpha for multiply blend by lerping albedo towards 1 (white) using alpha.

Arguments:
- **half3** albedo - input color value
- **half** alpha - input alpha value

Returns:
- **half3** - interpolated value between albedo and white depending on alpha

```cpp
half3 AlphaModulate(half3 albedo, half alpha)
{
    // Fake alpha for multiply blend by lerping albedo towards 1 (white) using alpha.
    // Manual adjustment for "lighter" multiply effect (similar to "premultiplied alpha")
    // would be painting whiter pixels in the texture.
    // This emulates that procedure in shader, so it should be applied to the base/source color.
#if defined(_ALPHAMODULATE_ON)
    return lerp(half3(1.0, 1.0, 1.0), albedo, alpha);
#else
    return albedo;
#endif
}
```

---
### AlphaPremultiply
Is used for premultiply alpha blending. Multiplies albedo by alpha if `_ALPHAPREMULTIPLY_ON` is defined

Arguments:
- **half3** albedo - input color value
- **half** alpha - input alpha value

Returns:
- **half3** - multiplied albedo value

```cpp
half3 AlphaPremultiply(half3 albedo, half alpha)
{
    // Multiply alpha into albedo only for Preserve Specular material diffuse part.
    // Preserve Specular material (glass like) has different alpha for diffuse and specular lighting.
    // Logically this is "variable" Alpha blending.
    // (HW blend mode is premultiply, but with alpha multiply in shader.)
#if defined(_ALPHAPREMULTIPLY_ON)
    return albedo * alpha;
#endif
    return albedo;
}
```

---
### NormalizeNormalPerVertex

Normalizes vertex normal (for vertex shader)

Arguments:
- **half3**/**float3** normalWS - normal in world space

Returns:
- **half3**/**float3** - normalized normal in world space


```cpp
// Normalization used to depend on SHADER_QUALITY
// Currently we always normalize to avoid lighting issues
// and platform inconsistencies.
half3 NormalizeNormalPerVertex(half3 normalWS)
{
    return normalize(normalWS);
}

float3 NormalizeNormalPerVertex(float3 normalWS)
{
    return normalize(normalWS);
}
```

---
### NormalizeNormalPerPixel

Normalizes fragment normal (for fragment shader)

Arguments:
- **half3**/**float3** normalWS - normal in world space

Returns:
- **half3**/**float3** - normalized normal in world space

```cpp
half3 NormalizeNormalPerPixel(half3 normalWS)
{
// With XYZ normal map encoding we sporadically sample normals with near-zero-length causing Inf/NaN
#if defined(UNITY_NO_DXT5nm) && defined(_NORMALMAP)
    return SafeNormalize(normalWS);
#else
    return normalize(normalWS);
#endif
}

float3 NormalizeNormalPerPixel(float3 normalWS)
{
#if defined(UNITY_NO_DXT5nm) && defined(_NORMALMAP)
    return SafeNormalize(normalWS);
#else
    return normalize(normalWS);
#endif
}
```

---
### ComputeFogFactorZ0ToFar

Computes fog from camera. `FOG_LINEAR_KEYWORD_DECLARED` should be defined

Arguments:
- **float** z - z position in camera space.

Returns:
- **real** - fog factor (how much a pixel should be interpolated to fog color).


```cpp
real ComputeFogFactorZ0ToFar(float z)
{
    #if defined(FOG_LINEAR_KEYWORD_DECLARED)
    if (FOG_LINEAR)
    {
        // factor = (end-z)/(end-start) = z * (-1/(end-start)) + (end/(end-start))
        float fogFactor = saturate(z * unity_FogParams.z + unity_FogParams.w);
        return real(fogFactor);
    }
    else if (FOG_EXP || FOG_EXP2)
    {
        // factor = exp(-(density*z)^2)
        // -density * z computed at vertex
        return real(unity_FogParams.x * z);
    }
    else
    {
        // This process is necessary to avoid errors in iOS graphics tests
        // when using the dynamic branching of fog keywords.
        return real(0.0);
    }
    #else // #if defined(FOG_LINEAR_KEYWORD_DECLARED)
    return real(0.0);
    #endif // #if defined(FOG_LINEAR_KEYWORD_DECLARED)
}
```

---
### ComputeFogFactor

Computes fog from clip space. `FOG_LINEAR_KEYWORD_DECLARED` should be defined

Arguments:
- **float** zPositionCS - z position in clip space [-1, 1] in world space

Returns:
- **real** - fog factor 

```cpp
real ComputeFogFactor(float zPositionCS)
{
    float clipZ_0Far = UNITY_Z_0_FAR_FROM_CLIPSPACE(zPositionCS);
    return ComputeFogFactorZ0ToFar(clipZ_0Far);
}
```

---
### ComputeFogIntensity

Computes fog intensity from factor. `FOG_LINEAR_KEYWORD_DECLARED` should be defined

Arguments:
- **half**/**float** fogFactor - z position in clip space [-1, 1] in world space

Returns:
- **half**/**float** - fog intensity (how much a pixel should be interpolated to fog color).

```cpp
half ComputeFogIntensity(half fogFactor)
{
    half fogIntensity = half(0.0);
    #if defined(FOG_LINEAR_KEYWORD_DECLARED)
    if (FOG_EXP)
    {
        // factor = exp(-density*z)
        // fogFactor = density*z compute at vertex
        fogIntensity = saturate(exp2(-fogFactor));
    }
    else if (FOG_EXP2)
    {
        // factor = exp(-(density*z)^2)
        // fogFactor = density*z compute at vertex
        fogIntensity = saturate(exp2(-fogFactor * fogFactor));
    }
    else if (FOG_LINEAR)
    {
        fogIntensity = fogFactor;
    }
    #endif // #if defined(FOG_LINEAR_KEYWORD_DECLARED
    return fogIntensity;
}
```
```cpp
float ComputeFogIntensity(float fogFactor)
{
    float fogIntensity = 0.0;
    #if defined(FOG_LINEAR_KEYWORD_DECLARED)
        if (FOG_EXP)
        {
            // factor = exp(-density*z)
            // fogFactor = density*z compute at vertex
            fogIntensity = saturate(exp2(-fogFactor));
        }
        else if (FOG_EXP2)
        {
            // factor = exp(-(density*z)^2)
            // fogFactor = density*z compute at vertex
            fogIntensity = saturate(exp2(-fogFactor * fogFactor));
        }
        else if (FOG_LINEAR)
        {
            fogIntensity = fogFactor;
        }
    #endif // #if defined(FOG_LINEAR_KEYWORD_DECLARED)
    return fogIntensity;
}
```



---
### InitializeInputDataFog

Computes fog factor from position in world space. `FOG_LINEAR_KEYWORD_DECLARED` should be defined. `vertFogFactor` is kinda useless because Unity forces fragment stage fog

Arguments:
- **float4** positionWS - pixel position in world space.
- **real** vertFogFactor - factor from vertex shader, if fog is done in vertex sahder.   

Returns:
- **real** - fog intensity (how much a pixel should be interpolated to fog color).

```cpp

// Force enable fog fragment shader evaluation
#define _FOG_FRAGMENT 1
real InitializeInputDataFog(float4 positionWS, real vertFogFactor)
{
    real fogFactor = 0.0;
#if defined(_FOG_FRAGMENT)
    #if defined(FOG_LINEAR_KEYWORD_DECLARED)
    if (FOG_LINEAR || FOG_EXP || FOG_EXP2)
    {
        // Compiler eliminates unused math --> matrix.column_z * vec
        float viewZ = -(mul(UNITY_MATRIX_V, positionWS).z);
        // View Z is 0 at camera pos, remap 0 to near plane.
        float nearToFarZ = max(viewZ - _ProjectionParams.y, 0);
        fogFactor = ComputeFogFactorZ0ToFar(nearToFarZ);
    }
    #endif // #if defined(FOG_LINEAR_KEYWORD_DECLARED)
#else // #if defined(_FOG_FRAGMENT)
    fogFactor = vertFogFactor;
#endif // #if defined(_FOG_FRAGMENT)
    return fogFactor;
}
```

---
### MixFogColor

Interpolates pixel color between actual color and fog depending on factor. (Calculates intensity first) `FOG_LINEAR_KEYWORD_DECLARED` should be defined.

Arguments:
- **half3**/**float3** fragColor - pixel position in world space.
- **half3**/**float3** fogColor - fog color
- **half**/**float**  vertFogFactor - factor from vertex shader, if fog is done in vertex sahder.   

Returns:
- **half3**/**float3** - mixed color.

```cpp
half3 MixFogColor(half3 fragColor, half3 fogColor, half fogFactor)
{
    #if defined(FOG_LINEAR_KEYWORD_DECLARED)
        if (FOG_LINEAR || FOG_EXP || FOG_EXP2)
        {
            half fogIntensity = ComputeFogIntensity(fogFactor);
            // Workaround for UUM-61728: using a manual lerp to avoid rendering artifacts on some GPUs when Vulkan is used
            fragColor = fragColor * fogIntensity + fogColor * (half(1.0) - fogIntensity);    
        }
    #endif // #if defined(FOG_LINEAR_KEYWORD_DECLARED)
    return fragColor;
}

float3 MixFogColor(float3 fragColor, float3 fogColor, float fogFactor)
{
    #if defined(FOG_LINEAR_KEYWORD_DECLARED)
        if (FOG_LINEAR || FOG_EXP || FOG_EXP2)
        {
            if (IsFogEnabled())
            {
                float fogIntensity = ComputeFogIntensity(fogFactor);
                fragColor = lerp(fogColor, fragColor, fogIntensity);
            }
        }
    #endif // #if defined(FOG_LINEAR_KEYWORD_DECLARED)
    return fragColor;
} 
```


---
### MixFog

Same as [MixFogColor](#mixfogcolor).
Interpolates pixel color between actual color and fog depending on factor. (Calculates intensity first) `FOG_LINEAR_KEYWORD_DECLARED` should be defined. Gets global fog color.

Arguments:
- **half3**/**float3** fragColor - pixel position in world space.
- **half**/**float**  vertFogFactor - factor from vertex shader, if fog is done in vertex sahder.   

Returns:
- **half3**/**float3** - mixed color.


```cpp
half3 MixFog(half3 fragColor, half fogFactor)
{
    return MixFogColor(fragColor, half3(unity_FogColor.rgb), fogFactor);
}

float3 MixFog(float3 fragColor, float fogFactor)
{
    return MixFogColor(fragColor, unity_FogColor.rgb, fogFactor);
}
```
---
### LinearDepthToEyeDepth
Transforms depth from linear normalized space [0, 1] to camera space [nearZ, farZ]. Interpolation is linear.

Arguments:
- **half**/**float**  rawDepth - clip space depth

Returns:
- **half**/**float** - camera space depth

```cpp
// Linear depth buffer value between [0, 1] or [1, 0] to eye depth value between [near, far]
half LinearDepthToEyeDepth(half rawDepth)
{
    #if UNITY_REVERSED_Z
        return half(_ProjectionParams.z - (_ProjectionParams.z - _ProjectionParams.y) * rawDepth);
    #else
        return half(_ProjectionParams.y + (_ProjectionParams.z - _ProjectionParams.y) * rawDepth);
    #endif
}

float LinearDepthToEyeDepth(float rawDepth)
{
    #if UNITY_REVERSED_Z
        return _ProjectionParams.z - (_ProjectionParams.z - _ProjectionParams.y) * rawDepth;
    #else
        return _ProjectionParams.y + (_ProjectionParams.z - _ProjectionParams.y) * rawDepth;
    #endif
}

```
---
### TransformScreenUV

Since different plaforms define UVs in different coordinates, Unity accommodates by implementing y-axis flip when needed.

Arguments:
- **float2** uv - initial UVs
- **float** screenHeight - screen Y size

Returns:
- **float2** uv - changed UVs

```cpp
void TransformScreenUV(inout float2 uv, float screenHeight)
{
    #if UNITY_UV_STARTS_AT_TOP
    uv.y = screenHeight - (uv.y * _ScaleBiasRt.x + _ScaleBiasRt.y * screenHeight);
    #endif
}

void TransformScreenUV(inout float2 uv)
{
    #if UNITY_UV_STARTS_AT_TOP
    TransformScreenUV(uv, GetScaledScreenParams().y);
    #endif
}
```
---
### TransformNormalizedScreenUV

Same as [TransformScreenUV](#TransformScreenUV) but sets height to 1.

Arguments:
- **float2** uv - initial UVs

Returns:
- **float2** uv - changed UVs

```cpp
void TransformNormalizedScreenUV(inout float2 uv)
{
    #if UNITY_UV_STARTS_AT_TOP
    TransformScreenUV(uv, 1.0);
    #endif
}
```
---
### GetNormalizedScreenSpaceUV

Same as [TransformScreenUV](#TransformScreenUV) but sets height to 1.

Arguments:
- **float2**/**float4** positionCS - initial UVs

Returns:
- **float2** uv - changed UVs

```cpp
float2 GetNormalizedScreenSpaceUV(float2 positionCS)
{
    float2 normalizedScreenSpaceUV = positionCS.xy * rcp(GetScaledScreenParams().xy);
    TransformNormalizedScreenUV(normalizedScreenSpaceUV);
    return normalizedScreenSpaceUV;
}

float2 GetNormalizedScreenSpaceUV(float4 positionCS)
{
    return GetNormalizedScreenSpaceUV(positionCS.xy);
}
```
---
### Select4

Selects i-th element from a 4-component array 

Arguments:
- **uint4** v - uint vector

Returns:
- **float2** uv - changed UVs

```cpp
// Select uint4 component by index.
// Helper to improve codegen for 2d indexing (data[x][y])
// Replace:
// data[i / 4][i % 4];
// with:
// select4(data[i / 4], i % 4);
uint Select4(uint4 v, uint i)
{
    // x = 0 = 00
    // y = 1 = 01
    // z = 2 = 10
    // w = 3 = 11
    uint mask0 = uint(int(i << 31) >> 31);
    uint mask1 = uint(int(i << 30) >> 31);
    return
        (((v.w & mask0) | (v.z & ~mask0)) & mask1) |
        (((v.y & mask0) | (v.x & ~mask0)) & ~mask1);
}
```
---
I don't know what this is but trust me you will not need it
```cpp
#if SHADER_TARGET < 45
uint URP_FirstBitLow(uint m)
{
    // http://graphics.stanford.edu/~seander/bithacks.html#ZerosOnRightFloatCast
    return (asuint((float)(m & asuint(-asint(m)))) >> 23) - 0x7F;
}
#define FIRST_BIT_LOW URP_FirstBitLow
#else
#define FIRST_BIT_LOW firstbitlow
#endif
```
---
### GetMeshRenderingLayer

Returns:
- **uint** - Current rendering layer id.

```cpp

uint GetMeshRenderingLayer()
{
    return asuint(unity_RenderingLayer.x);
}
```
---
### EncodeMeshRenderingLayer

Same as [GetMeshRenderingLayer](#GetMeshRenderingLayer)

Returns:
- **uint** - Current rendering layer id.

```cpp
uint EncodeMeshRenderingLayer()
{
    // Force any bits above max to be skipped
    return GetMeshRenderingLayer() & _RenderingLayerMaxInt;
}
```
### GetCurrentExposureMultiplier

No implementation...

```cpp
// TODO: implement
float GetCurrentExposureMultiplier()
{
    return 1;
}
```