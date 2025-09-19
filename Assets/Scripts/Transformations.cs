using UnityEngine;

public class Transformations : MonoBehaviour
{
     CreateGrid createGrid;

        Vector3[] startPos;

        [Header("Movement Controls")]
        public float moveFrequency = 2f;
        public float moveAmplitude = 5f;
        public float moveOffset = 0f;

        Vector3 startScale = Vector3.zero;

        [Header("Scale Controls")]
        public float scaleFrequency = 2f;
        public float scaleAmplitude = 5f;
        public float scaleOffset = 0f;

        [Header("Rotation Controls")]
        public float rotationSpeed = 1f;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        createGrid = GetComponent<CreateGrid>();
        startPos = createGrid.startPos;
        startScale = createGrid.grid[0].localScale;
    }

    // Update is called once per frame
    void Update()
    {
        for (int i = 0, z = 0; z < createGrid.gridResolution; z++){

            for (int y = 0; y < createGrid.gridResolution; y++){

                for (int x = 0; x < createGrid.gridResolution; x++, i++){

                    createGrid.grid[i].localPosition = startPos[i] + Vector3.up * Mathf.Sin(Time.time * moveFrequency + moveOffset) * moveAmplitude;

                    createGrid.grid[i].localScale = startScale *  Mathf.Sin(Time.time * scaleFrequency) * scaleAmplitude + Vector3.one * scaleOffset;

                    createGrid.grid[i].Rotate(Vector3.forward * Time.deltaTime * rotationSpeed);
                }
            }
        }
    }
}
