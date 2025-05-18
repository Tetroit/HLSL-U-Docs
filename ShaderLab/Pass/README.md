[<- Back to ShaderLab info](../README.md)
<h2 align="center">Pass</h2>

### Also see [Unity documentation](https://docs.unity3d.com/Manual/SL-Pass.html) on this topic

Pass defines which data and how will be passedd to the rendering backend. You can see each pass individually in Frame debugger window in Unity. Inside the Pass block you define
- Name
- Pass Tags
- Commands
- Shader code  

### Tags for Pass:

Applicable Tags:
| Tag | Description | Values |
| --- | --- | --- |
| LightMode | Tells Unity how to interpret this pass and what will be the output. Keep in mind, different pipelines support different values | Refer to the [LightMode](./LightMode.md) page for more info |
| UniversalMaterialType | Used with Deferred Rendering, Unity marks pixels with the given material type in stencil |  ```"Lit"``` (PBR lighting), ```"SimpleLit"``` (Blinn-Phong lighting) |


Usage example:  
```
Tags{
    "LightMode" = "ShaderCaster"
}
```

> [!NOTE]
> tags are NOT separated with comma
>