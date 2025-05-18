[<- Back to Properties](./README.md)

<h2 align = "center">Range property</h2>

Defines a float between 2 given min and max parameters
### Syntax
```C#
_VarName ("InspectorName", Range(min, max)) = 0.0
```
Defalt value can be any number (```0.0``` in this example)  
Will be displayed as a slider in the inspector, internally it is the same as [float](./Float.md).

Applicable [attributes](../Attributes/README.md):

- ```[HideInInspector]```