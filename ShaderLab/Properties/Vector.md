[<- Back to Properties](./README.md)

<h2 align = "center">Vector property</h2>

Defines a 4-component vector

> [!NOTE]
> It is not possible to create 2-component or 3-component
> A workaround could be storing the value in floats separately
> Or using a 4-component vector, but only use xy/xyz

### Syntax
```C#
_VarName ("InspectorName", Vector) = (0.0, 0.0, 0.0, 0.0)
//or
_VarName ("InspectorName", Vector) = (0.0, 0.0, 0.0)
```
Basically same as [**Color**](./Color.md), but shows like 4 values in the inspector.
Default value is given as a 3-component (without alpha, alpha defaults to ```1.0```) or with 4-component (with alpha) set of floats between round brackets.

Applicable [attributes](../Attributes/README.md):

- ```[HideInInspector]```