[<- Back to Properties](./About.md)

<h2 align = "center">Color property</h2>

Defines a color
### Syntax
```C#
_VarName ("InspectorName", Color) = (0.0, 0.0, 0.0, 0.0)
//or
_VarName ("InspectorName", Color) = (0.0, 0.0, 0.0)
```
If named ```_Color```, Unity automatically sets the color as default and can be accessed by ```Material.color```, has the same effect as [MainColor attribute](../Attributes/About.md).
Same as [**Vector**](./Vector.md), but is displayed as color picker in the editor.  
Default value is given as a 3-component (without alpha, alpha defaults to ```1.0```) or with 4-component (with alpha) set of floats between round brackets.

Applicable [attributes](../Attributes/About.md):
- ```[Gamma]```
- ```[HDR]```
- ```[HideInInspector]```
- ```[MainColor]```