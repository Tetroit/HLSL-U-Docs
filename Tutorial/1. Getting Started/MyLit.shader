//Your shader will be accessible by this path in inspector
Shader "Custom/MyLit"
{
    //Define material inputs here
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    //Shader logic here
    SubShader
    {
        Tags {
            "RenderType"="Opaque"

            //Set rendering pipeline
            "RenderPipeline" = "UniversalPipeline"
        }

        LOD 300

        Pass {
            //Name to display in debugger
            Name "ForwardLit"
            //Set light mode to tell that we render the color in this pass
            Tags {
                "LightMode" = "UniversalForward"
            }
            
            //HLSL code here 
            HLSLPROGRAM

            //hook up the shaders
            #pragma vertex vert
            #pragma fragment frag

            //include your hlsl file
            #include "./HLSL/Passes/MyLitForwardPass.hlsl"

            ENDHLSL
        }
    }
}
