//Your shader will be accessible by this path in inspector
Shader "Custom/MyLit"
{
    //Define material inputs here
    Properties
    {
        _MainTex ("Base Map", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.5
    }
    //Shader logic here
    SubShader
    {
        Tags {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
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

            //pipeline
            #pragma multi_compile _ _FORWARD_PLUS

            //hook up the shaders
            #pragma vertex vert
            #pragma fragment frag

            //include your hlsl file

            #include "./HLSL/Passes/MyLitForwardPass.hlsl"

            ENDHLSL
        }
    }
}
