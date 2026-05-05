using UnityEngine;

public class WebcamToShader : MonoBehaviour
{
    WebCamTexture webcamTexture;
    public Material mosquitoMaterial;

    void Start()
    {
        webcamTexture = new WebCamTexture();
        // Use the texture as the main map for the material
        // " _MainTex" is the default name, but check your Shader Graph property name!
        mosquitoMaterial.SetTexture("_MainTex", webcamTexture);
        webcamTexture.Play();
    }
}