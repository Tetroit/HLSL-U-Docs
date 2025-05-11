## Properties in ShaderLab

### Also see [Unity documentation](https://docs.unity3d.com/Manual/SL-Properties.html) on this topic
ShaderLab allows a lot of customization for properties from your materials.
```C#
[MainTexture] _BaseMap("Albedo", 2D) = "white" {}
//     |        \        |       \        |
// Attributes   |        \      Type      \
//       Name in shader  |          Default value
//                  Name in inspector
```
> [!TIP]
> Some tips to begin with!  
>
> - For better clarity "Name in shader" field should begin with an underscore ```_``` as it indicates a global variable  
> - Booleans are normally passed as floats (yeah it is disgusting I know)  
> - Hidden variables should begin with two underscores ```__```  

You can find more info about each element in this folder, or by references below

Types:
- **Integer**
- **Float**
- **Range**
- **Vector**
- **Color**
- **2D**
- **3D**
- **2DArray**
- **Cube**
- **CubemapArray**