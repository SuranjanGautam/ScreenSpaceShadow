using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class Screen_space_shadows : MonoBehaviour
{
    // Start is called before the first frame update
    Camera cam;
    public Transform light;
    public Material pp;
    public Shader ab;
    Material x;
    Material xp;
    public RenderTexture shadowmap;
    public RenderTexture shadowmap_1;
    public RenderTexture shadowmap_2;


    public Material blur;
    public float max_depth_difference = 0.2f;
    public bool blur_toggle = true;

    void Start()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.Depth;
        
        x = pp;
        xp = new Material(ab);

        x.SetColor("_ShadowColor", RenderSettings.subtractiveShadowColor);
        x.SetFloat("_clipDepth", cam.farClipPlane - cam.nearClipPlane);
        var t = new RenderTextureDescriptor(Screen.width , Screen.height,RenderTextureFormat.Default);
        shadowmap = new RenderTexture(t);
        t = new RenderTextureDescriptor(Screen.width/2, Screen.height/2, RenderTextureFormat.Default);
        shadowmap_1 = new RenderTexture(t);
        t = new RenderTextureDescriptor(Screen.width / 4, Screen.height / 4, RenderTextureFormat.Default);
        shadowmap_2 = new RenderTexture(t);

        shadowmap.filterMode = FilterMode.Trilinear;
    }

    // Update is called once per frame
    void Update()
    {
        var depth = -(cam.worldToCameraMatrix * new Vector4(light.position.x, light.position.y, light.position.z, 1.0f)).z / (cam.farClipPlane -cam.nearClipPlane);

        var lp = cam.WorldToScreenPoint(light.position);
        lp.x /= Screen.width;
        lp.y /= Screen.height;
        lp.z = depth;

        x.SetVector("_LightPos",lp);
        x.SetFloat("_max_depth", max_depth_difference);
        
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //shadowmap
        Graphics.Blit(source, shadowmap, x,0);
        Graphics.Blit(source, shadowmap_1, x, 2);
        Graphics.Blit(source, shadowmap_2, x, 3);

        

        //blured shadowmap
        if (blur_toggle)
        {
            blur.SetFloat("_StandardDeviation", 0.01f);
            blur.SetFloat("_BlurSize", 0.01f);

            var t = new RenderTexture(shadowmap);
            Graphics.Blit(shadowmap, t, blur, 0);
            Graphics.Blit(t, shadowmap, blur, 1);

            RenderTexture.Destroy(t);

            blur.SetFloat("_StandardDeviation", 0.08f);
            blur.SetFloat("_BlurSize", 0.015f);

            var t2 = new RenderTexture(shadowmap_1);
            Graphics.Blit(shadowmap_1, t2, blur, 0);
            Graphics.Blit(t2, shadowmap_1, blur, 1);

            RenderTexture.Destroy(t2);

            blur.SetFloat("_StandardDeviation", 0.1f);
            blur.SetFloat("_BlurSize", 0.03f);


            var t3 = new RenderTexture(shadowmap_2);
            Graphics.Blit(shadowmap_2, t3, blur, 0);
            Graphics.Blit(t3, shadowmap_2, blur, 1);

            RenderTexture.Destroy(t3);
        }


        //combine different samples
        Graphics.Blit(shadowmap_1, shadowmap, xp);
        Graphics.Blit(shadowmap_2, shadowmap, xp);


        //set shadowmap in material
        x.SetTexture("_ShadowMap", shadowmap);
        //draw shadows
        Graphics.Blit(source, destination,x,1);
    }
}
