[<- Back to ShaderLab info](../About.md)
<h2 align="center">Properties in ShaderLab</h2>

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
> - Hidden variables should begin with two underscores ```__``` and start with lowercase  

You can find more info about each element in this folder, or by references below

Types:
- [**Integer**](./Integer.md)
- [**Float**](./Float.md)
- [**Range**](./Range.md)
- [**Vector**](./Vector.md)
- [**Color**](./Color.md)
- [**2D**](./Texture2D.md)
- [**3D**](./Texture3D.md)
- [**2DArray**](./Texture2DArray.md)
- [**Cube**](./Cubemap.md)
- [**CubemapArray**](./CubemapArray.md)