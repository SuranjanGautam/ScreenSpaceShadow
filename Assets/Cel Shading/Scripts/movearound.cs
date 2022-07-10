using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class movearound : MonoBehaviour
{
    Vector3 original_pos;
    // Start is called before the first frame update
    void Start()
    {
        original_pos = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        var t = original_pos;
        t.z += Mathf.Sin(Time.time);
        transform.position = t;
    }
}
