using UnityEngine;
using System.Collections;
 
public class outline : MonoBehaviour
{
    Camera AttachedCamera;
    public Shader DrawSimple;
    Camera TempCam;
    public Material Post_Mat;
    public bool toggle = false;
    

    void Start()
    {
        AttachedCamera = GetComponent<Camera>();
        TempCam = new GameObject().AddComponent<Camera>();
        TempCam.enabled = false;
    }
    
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (toggle)
        {
            blurgussian(source, destination);
        }
        else blurnormal(source,destination);
    }

    void blurnormal(RenderTexture source, RenderTexture destination) {
        TempCam.CopyFrom(AttachedCamera);
        TempCam.clearFlags = CameraClearFlags.Color;
        TempCam.backgroundColor = Color.black;


        TempCam.cullingMask = 1 << LayerMask.NameToLayer("Outline");


        RenderTextureFormat rtFormat = RenderTextureFormat.ARGBHalf;
        if (!SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.ARGBHalf))
            rtFormat = RenderTextureFormat.ARGB32;


        //RenderTexture TempRT = new RenderTexture(source.width, source.height, 0, rtFormat);
        RenderTexture TempRT = new RenderTexture(source.width/2, source.height/2, 0, rtFormat);

        TempRT.filterMode = FilterMode.Trilinear;
        TempRT.Create();

        //set the camera's target texture when rendering
        TempCam.targetTexture = TempRT;

        TempCam.RenderWithShader(DrawSimple, "");

        //RenderTexture horizontalBlur = new RenderTexture(source.width, source.height, 0, rtFormat);
        //horizontalBlur.Create();

        //Post_Mat.SetVector("_BlurDirection", new Vector2(1, 0));
        //Graphics.Blit(TempRT, horizontalBlur, Post_Mat, 1);

        RenderTexture verticalBlur = new RenderTexture(source.width, source.height, 0, rtFormat);
        
        verticalBlur.filterMode = FilterMode.Trilinear;
        
        verticalBlur.Create();
        //Post_Mat.SetVector("_BlurDirection", new Vector2(0, 1));
        //Graphics.Blit(TempRT, verticalBlur, Post_Mat, 1);

        RenderTexture horizontalBlur = new RenderTexture(source.width/4 , source.height /4, 0, rtFormat);
        
        horizontalBlur.filterMode = FilterMode.Trilinear;
        horizontalBlur.Create();

        Graphics.Blit(TempRT, horizontalBlur, Post_Mat, 3);
        

        Graphics.Blit(horizontalBlur, verticalBlur, Post_Mat, 2);

        Graphics.Blit(source, destination);

        Graphics.Blit(verticalBlur, null, Post_Mat, 3);
        //Graphics.Blit(verticalBlur, destination);

        TempRT.Release();
        horizontalBlur.Release();
        verticalBlur.Release();
    }

    void blurgussian(RenderTexture source, RenderTexture destination)
    {
        TempCam.CopyFrom(AttachedCamera);
        TempCam.clearFlags = CameraClearFlags.Color;
        TempCam.backgroundColor = Color.black;


        TempCam.cullingMask = 1 << LayerMask.NameToLayer("Outline");


        RenderTextureFormat rtFormat = RenderTextureFormat.ARGBHalf;
        if (!SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.ARGBHalf))
            rtFormat = RenderTextureFormat.ARGB32;


        
        RenderTexture TempRT = new RenderTexture(source.width/2, source.height/2, 0, rtFormat);
        TempRT.Create();

        //set the camera's target texture when rendering
        TempCam.targetTexture = TempRT;

        TempCam.RenderWithShader(DrawSimple, "");

        RenderTexture horizontalBlur = new RenderTexture(source.width/2, source.height/2, 0, rtFormat);
        horizontalBlur.Create();

        Post_Mat.SetVector("_BlurDirection", new Vector2(1, 0));
        Graphics.Blit(TempRT, horizontalBlur, Post_Mat, 1);

        RenderTexture verticalBlur = new RenderTexture(source.width/2, source.height/2, 0, rtFormat);
        verticalBlur.Create();

        Post_Mat.SetVector("_BlurDirection", new Vector2(0, 1));
        Graphics.Blit(TempRT, verticalBlur, Post_Mat, 1);

        TempRT.Release();
        TempRT = new RenderTexture(source.width , source.height , 0, rtFormat);
        TempRT.Create();
        RenderTexture TempRT2 = new RenderTexture(source.width, source.height, 0, rtFormat);
        TempRT2.Create();

        Graphics.Blit(horizontalBlur, verticalBlur, Post_Mat, 3);

        

        Graphics.Blit(verticalBlur, horizontalBlur, Post_Mat, 2);

        Graphics.Blit(source, destination);

        Graphics.Blit(horizontalBlur, null, Post_Mat, 3);


        TempRT.Release();
        horizontalBlur.Release();
        verticalBlur.Release();
    }

}
