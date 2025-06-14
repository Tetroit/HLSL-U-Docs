[<- Back to ShaderLab info](../README.md)
<h2 align="center">Unity ShaderLab</h2>

### Also see [Unity documentation](https://docs.unity3d.com/Manual/SL-Properties.html) on this topic  
### Also see [Properties](../Properties/README.md)

ShaderLab Attributes work pretty much exactly as in C#. To use them, just prepend your property with the syntax. Here is a list of attributes:

| Attribute | Description |
| --- | --- |
| [Gamma] | Applicable to [colors](../Properties/Color.md). Indicates that a float or vector property uses sRGB values, which means that it must be converted along with other sRGB values if the color space in your project requires this. |
| [HDR] | Applicable to [colors](../Properties/Color.md). Will be displayed in editor as an HDR color. |
| [HideInInspector] | Hides the property from the inspector. Useful for user restricted variables or while working with custom editors |
| [MainTexture] | Applicable to [2D textures](../Properties/Texture2D.md). Unity will set this texture as default map, which can be accessed from C# as ```Material.mainTexture```. If the variable name is ```_MainTex```, is applied automatically |
| [MainColor] | Applicable to [colors](../Properties/Color.md). Unity will set this color as default, which can be accessed from C# as ```Material.color```. If the variable name is ```_Color```, is applied automatically|
| [NoScaleOffset] | Applicable to [2D Textures](../Properties/Texture2D.md). Will hide "Tiling" and "Offset" from the inspector |
| [Normal] | Should be applied to [2D textures](../Properties/Texture2D.md), but also applicable to [3D textures](../Properties/Texture3D.md) and [cubemaps](../Properties/Cubemap.md). Indicates that a texture property expects a normal map. |
| [PerRendererData] | Usually applied to [2D textures](../Properties/Texture2D.md), but can also be applied to [3D textures](../Properties/Texture3D.md) and [cubemaps](../Properties/Cubemap.md). Indicates that a texture property will be coming from per-renderer data in the form of a MaterialPropertyBlock. The Material inspector shows these properties as read-only. |
| [Toggle] | Is used to define shader keywords and booleans, can be [integer](../Properties/Integer.md) or [float](../Properties/Float.md). Is displayed as a boolean in inspector. However, in shader it will be perceived as a numeric type with a value of 0 or 1. In shader can be used with `#pragma shader_feature` directive but with _ON suffix. For example in properties: `[Toggle] _RED ("Make red", Integer) = 0`, in HLSL: `#pragma shader_feature _RED_ON` |
| [KeywordEnum(VALUE_1, VALUE_2, ...)] | Defines a list of values as an enum. Works with [integers](../Properties/Integer.md) and floats. Is displayed as an enum in the inspector with VALUE_1, VALUE_2, ... items. Allows to define keywords as _KEYWORD_VALUE_1, _KEYWORD_VALUE_2 etc. Compatible with `#pragma shader_feature` directive. For example in properties: `[KeywordEnum(RED, GREEN, BLUE)] _PICK_RGB ("Pick RGB", Integer) = 0`, in HLSL: `#pragma shader_feature _PICK_RGB_RED _PICK_RGB_GREEN _PICK_RGB_BLUE`|