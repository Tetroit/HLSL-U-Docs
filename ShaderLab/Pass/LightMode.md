[<- Back to Pass block info](./README.md)
<h2 align="center">LightMode tag</h2>

**LightMode** tag is a Pass tag, which allows you to tell compiler where in the rendering order your Pass is. it uses default rendering pipeline structure as reference, so values of this tag are also defined by your rendering pipeline.

### Values in URP

| Value | Description | URP Version |
| --- | --- | --- |
| UniversalForward | Main color pass in URP, used with Forward Rendering only | 7.0+ |
| Universal2D | Used in 2D renderer | 7.0+ |
| ShadowCaster | Renders shadows for geometry to shadowmaps | 7.0+ |
| DepthOnly | Renders depth of the geometry from the camera perspective | 7.0+ |
| Meta | Used when baking lights, no idea what it does exactly | 7.0+ | 
| SRPDefaultUnlit | This value is set by **default** if the pass has no LightMode tag | 7.0+
| UniversalForwardOnly | Similar to UniversalForward, but also works with Deferred Rendering | 10.0+
| UniversalGBuffer | Similar to UniversalForward, but is used for Deferred rendering only, meaning it calculates surface color but without light contribution | 10.0+
| DepthNormalsOnly | AKA DepthNormals, renders depth and normals from camera perspective | 10.0+ |
| Motion Vectors | Renders motion vectors, more info [here](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@16.0/manual/features/motion-vectors.html#motion-vectors-in-shaderlab) | 16.0+ |

This tag is very similar to [Queue SubShader tag](../SubShader/README.md/#tags-for-subshader), which defines which geometry is rendered first. You may think of it as a different low level superqueue. The main difference is that Queue only sorts geometry independantly from passes, while Passes define in which order and how geometry is rendered overall, same geometry can be rendered multiple times as well. It is more clear in an example:

Consider 3 shaders with the following structure:
```C#
...
SubShader{
    Tags { "Queue" = "Geometry" }
    Pass {
        Tags {"LightMode" = "ShadowCaster"} //Tells Unity that this pass calculates shadows for geometry
        ...
    }
    Pass {
        Tags {"LightMode" = "UniversalForward" } //Tells Unity that this pass renders color to display on screen (forward rendering)
        ...
    }
}
```
the other 2 shaders though have Queue set to "Geometry - 1" and "Geometry + 1"

Then in Frame debugger you will see that  

in **MainLightShadow** Pass Unity renders geometry (ShadowCaster pass) in order:

1. Geometry - 1
2. Geometry
3. Geometry + 1

in **RenderOpaque** Pass Unity renders geometry (UniversalForward pass) in order:

1. Geometry - 1
2. Geometry
3. Geometry + 1

Furthermore, in URP there is an opportunity to add your own render pass using [Scriptable Render Pass](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@14.0/manual/renderer-features/scriptable-render-passes.html). You can define your own LightMode value via C# by calling
```C#
new ShaderTagId("<name of your pass>");
 ```