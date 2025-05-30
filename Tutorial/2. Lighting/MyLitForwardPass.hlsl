//Include guard
#ifndef MY_LITFORWARDPASS_INCLUDED
#define MY_LIT_FORWARD_PASS_INCLUDED

//Include Lighting.hlsl form the URP package
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

//Get the color property from ShaderLab
float4 _Color;

//Vertex shader input
struct Vertex
{
	//Position in object space as position input
	float3 positionOS : POSITION;
};

//Vertex shader output and fragment shader input
struct Interpolators
{
	//Position in clip space as position output
	float4 positionCS : SV_POSITION;
};

//Vertex shader
Interpolators vert(Vertex vertInput)
{
	//Create struct
	Interpolators result = (Interpolators)0;
	//Get transformed positions
	VertexPositionInputs positionInputs = GetVertexPositionInputs(vertInput.positionOS);
	//Set clip space position to the struct
	result.positionCS = positionInputs.positionCS;

    return result;
}

//Fragment shader as color output
float4 frag(Interpolators fragInput) : SV_Target
{
	//Simply set the color
	return _Color;
}

#endif