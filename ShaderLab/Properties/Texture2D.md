[<- Back to Properties](./README.md)

<h2 align = "center">Texture2D property</h2>

Defines a 2D texture
### Syntax
```C#
_VarName ("InspectorName", 2D) = "default_texture_keyword" {}
```

If you name this texture as ```_MainTex``` it will automatically be marked as mainTexture and will haev the same effect as adding [MainTexture attribute](../Attributes/README.md)
Unity uses special keywords for default solid-colored textures:
- "gray" (0.5, 0.5, 0.5, 1)
- "white" (1, 1, 1, 1)
- "black" (0, 0, 0, 0)
- "red" (1, 0, 0, 1)
- “bump” (0.5, 0.5, 1, 1)
- anything else defaults to "gray"

Make sure you added the empty curly brackets after the keyword!

Applicable [attributes](../Attributes/README.md):

- ```[HideInInspector]```
- ```[MainTexture]```
- ```[NoScaleOffset]```
- ```[Normal]```
- ```[PerRendererData]```