using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UpdataPros : MonoBehaviour
{
    private static int nHash;
    private static int pHash;

    public GameObject obj;
    public GameObject plane;

    private Material objMat;

    private void Start()
    {
        objMat = obj.GetComponent<MeshRenderer>().sharedMaterial;
        nHash = Shader.PropertyToID("n");
        pHash = Shader.PropertyToID("p");
    }

    private void Update()
    {
        var n = plane.transform.up;
        var p = plane.transform.position;

        objMat.SetVector(nHash, n);
        objMat.SetVector(pHash, p);
    }
}
