//Include guard
#ifndef MY_LITFORWARDPASS_INCLUDED
#define MY_LIT_FORWARD_PASS_INCLUDED

//Include Lighting.hlsl form the URP package
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

//Get properties from ShaderLab
float4 _Color;
float _Smoothness;
float _Metallic;
float _Occlusion;

//Main texture
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
float4 _MainTex_ST;

//Vertex shader input
struct Vertex
{
	//Position in object space as position input
	float3 positionOS : POSITION;
	//Normal in object space as normal input
	float3 normalOS : NORMAL;
	//UVs as texture coordinates #0 input
	float2 UV : TEXCOORD0;
};

//Vertex shader output and fragment shader input
struct Interpolators
{
	//Positions
	float4 positionCS : SV_POSITION;
	float3 positionWS : TEXCOORD0;
	//Normals
	float3 normalWS : TEXCOORD1;
	//UVs
	float2 UV : TEXCOORD2;
	//GI data
    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 3);
};

//Vertex shader
Interpolators vert(Vertex vertInput)
{
	//Create struct
	Interpolators result = (Interpolators)0;

	//Get transformed positions and normals
	VertexPositionInputs positionInputs = GetVertexPositionInputs(vertInput.positionOS);
	VertexNormalInputs normalInputs = GetVertexNormalInputs(vertInput.normalOS);

	//Get clip space position from positionInputs
	result.positionCS = positionInputs.positionCS;
	//Get world space position from positionInputs
	result.positionWS = positionInputs.positionWS;
	//Get world space normal from normalInputs
	result.normalWS = normalInputs.normalWS;
	result.UV = vertInput.UV;

    return result;
}

//Fragment shader as color output
float4 frag(Interpolators fragInput) : SV_Target0
{
	//Input structure
	InputData inputData = (InputData)0;
	
	inputData.normalWS = normalize(fragInput.normalWS);
	inputData.positionWS = fragInput.positionWS;
	inputData.positionCS = fragInput.positionCS;
	inputData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(fragInput.positionWS);
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(fragInput.positionCS);
    inputData.bakedGI = SAMPLE_GI(fragInput.staticLightmapUV, fragInput.vertexSH, fragInput.normalWS);

	//Surface structure
	SurfaceData surfaceData = (SurfaceData)0;

	float2 uv = TRANSFORM_TEX(fragInput.UV, _MainTex);
	float4 textureColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
	
	surfaceData.albedo = _Color.rgb;
	surfaceData.albedo = _Color.rgb * textureColor;
	surfaceData.alpha = _Color.a;
	surfaceData.smoothness = _Smoothness;
	surfaceData.metallic = _Metallic;
	surfaceData.occlusion = 1.0;

	//Simply set the color
	return UniversalFragmentPBR(inputData, surfaceData);
}

#endif