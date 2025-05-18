[<- Back to ShaderLab info](../README.md)
<h2 align="center">SubShader</h2>

### Also see [Unity documentation](https://docs.unity3d.com/Manual/SL-SubShader.html) on this topic

SubShader is usually associated with the geometry in the scene and how the renderer operates with this geometry. Different subshaders inside the shader relate to different types of geometry which depends on the pipeline, queue and other variables such as LOD.

### Syntax:
```C#
SubShader
{
    Tags {...}
    LOD N //N is any positive integer, normally 100, 200 or 300
    Pass {...}
    //more than 1 Pass block can be here
}
```

### Tags for SubShader:

Applicable Tags:
| Tag | Description | Values |
| --- | --- | --- |
| RenderPipeline | Tells Unity whether the subshader is compatible with URP or HDRP. | ```"UniversalPipeline"```, ```"HDRenderPipeline"``` |
| Queue | Tells unity at which point in the rendering queue to render the geometry will be executed.  | ```"Background"```, ```"Geometry"```, ```"AlphaTest"```, ```"Transparent"```, ```"Overlay"```, ```<any integer>```.  Values can also add integers for different results, for example: ```"Geometry" + 1```|
| ForceNoShadowCasting | Disables all shadows cast by this subshader | ```"True"```, ```"False"``` |
| DisableBatching | Disables GPU instancing (batching) for all geometry with this subshader | ```"True"```, ```"False"```, ```"LODFading"``` |
| IgnoreProjector | Geometry will be ignored by Projector component | ```"True"```, ```False``` |
| PreviewType | Changes the material preview | ```"Sphere"```, ```"Plane"```, ```"Skybox"``` |


Usage example:  
```
Tags{
    "RenderPipeline" = "UniversalPipeline"
    "Queue" = 3000
}
```

> [!NOTE]
> tags are NOT separated with comma
>
