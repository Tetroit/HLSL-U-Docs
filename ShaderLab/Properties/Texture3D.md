[<- Back to Properties](./About.md)

<h2 align = "center">Texture3D property</h2>

Defines a 3D texture
### Syntax
```C#
_VarName ("InspectorName", 3D) = "default_texture_keyword" {}
```
Unity uses special keywords for default solid-colored textures:
- "gray" (0.5, 0.5, 0.5, 1)
- "white" (1, 1, 1, 1)
- "black" (0, 0, 0, 0)
- "red" (1, 0, 0, 1)
- “bump” (0.5, 0.5, 1, 1)
- anything else defaults to "gray"

Make sure you added the empty curly brackets after the keyword! 