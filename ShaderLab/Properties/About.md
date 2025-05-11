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

| Type | Syntax |
| --- | --- |
| [**Integer**](./Integer.md) | ```_VarName ("InspectorName", Integer) = 0``` |
| [**Float**](./Float.md) | ```_VarName ("InspectorName", Float) = 0.0``` |
| [**Range**](./Range.md) | ```_VarName ("InspectorName", Range(min, max)) = 0.0``` |
| [**Vector**](./Vector.md) | ```_VarName ("InspectorName", Vector) = (0.0, 0.0, 0.0, 1.0)``` |
| [**Color**](./Color.md) | ```_VarName ("InspectorName", Color) = (0.0, 0.0, 0.0, 1.0)``` |
| [**2D**](./Texture2D.md) |```_VarName ("InspectorName", 2D) = ""{}``` |
| [**3D**](./Texture3D.md) | ```_VarName ("InspectorName", 3D) = ""{}``` |
| [**2DArray**](./Texture2DArray.md) |```_VarName ("InspectorName", 2DArray) = ""{}``` |
| [**Cube**](./Cubemap.md) |```_VarName ("InspectorName", Cube) = ""{}``` |
| [**CubemapArray**](./CubemapArray.md) | ```_VarName ("InspectorName", CubeArray) = ""{}``` |