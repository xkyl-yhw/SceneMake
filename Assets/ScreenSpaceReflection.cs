using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class ScreenSpaceReflection : MonoBehaviour
{
    public Material mat;
    public Shader backfaceShader;
    private Camera backfaceCanera;
    private RenderTexture backfaceText;

    private void Start()
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
        backfaceCanera = null;
    }

    private RenderTexture GetBackfaceTexture()
    {
        if (backfaceText == null)
        {
            backfaceText = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.RFloat);
            backfaceText.filterMode = FilterMode.Point;
        }
        return backfaceText;
    }

    private void RenderBackface()
    {
        if(backfaceCanera == null)
        {
            var t = new GameObject();
            var mainCamera = Camera.main;
            t.transform.SetParent(mainCamera.transform);
            t.hideFlags = HideFlags.HideAndDontSave;
            backfaceCanera = t.AddComponent<Camera>();
            backfaceCanera.CopyFrom(mainCamera);
            backfaceCanera.enabled = false;
            backfaceCanera.clearFlags = CameraClearFlags.SolidColor;
            backfaceCanera.backgroundColor = Color.white;
            backfaceCanera.renderingPath = RenderingPath.Forward;
            backfaceCanera.SetReplacementShader(backfaceShader, "RenderType");
            backfaceCanera.targetTexture = GetBackfaceTexture();
        }
        backfaceCanera.Render();
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        RenderBackface();
        mat.SetTexture("_BackfaceTex", GetBackfaceTexture());
        mat.SetMatrix("_WorldToView", GetComponent<Camera>().worldToCameraMatrix);
        Graphics.Blit(source, destination, mat, 0);
    }
}
