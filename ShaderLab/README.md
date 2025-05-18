<h2 align="center">Unity ShaderLab</h2>

### Also see [Unity documentation](https://docs.unity3d.com/Manual/SL-Reference.html) on this topic  
**ShaderLab** is a marking language used by unity shaders. Its structure goes as follows:
```C#
Shader "Your shader/Shader category"
{
    Properties {...}

    SubShader {
        Tags {...}
        LOD N //N is any positive integer, normally 100, 200 or 300
        Pass {
            Name "PassName"
            Tags  {...}
            HLSLPROGRAM/CGPROGRAM
            "Your HSLS or CG code"
            ENDHLSL/ENDCG
        }
        Pass {...}
        ...
    }
    SubShader {...}
    ... // more subshaders
    FallBack "Fallback"
    CustomEditor "CustomEditor"
}
```
Here is a brief breakdown:
- **Shader** is the general keyword indicating the beginning of the shader, followed by your shader name.  
- [**Properties**](./Properties/README.md) define which global variables will be used for the shader.
- [**SubShader**](./SubShader/README.md) defines main structure of the shader code itself, you can have multiple SubShaders to accommodate for different hardware.
    - [**Tags**](./SubShader/README.md/#tags-for-subshader) allows to define the behaviour of the shader
    - **LOD (Level Of Detail)** indicates whether this SubShader should be used according to the level of detail of the object, you can create multiple same-purpose SubShaders but for different levels of details.  
    Is set to 300 by default.
    - [**Pass**](./Pass/README.md) wraps all info README a specific rendering place at which your shader code will be called. 1 pass per draw call to put it simpler. For example, you will have one pass for forward rendering another for rendering shadow maps.
        - **Name** represents how your pass will be called, usefull for frame debugging.
        - [**Tags**](./Pass/README.md/#tags-for-pass) help Unity identify what kind of operation you are doing, so it can adjust internal logic for it
        - Also worth mentioning that your HLSL code should be in a separate file just to keep it cleaner, Unity does that as well
- **Fallback** tells which error handling tool to use
- **CustomEditor** allows to assign a material editor script to customize your shader in the inspector
