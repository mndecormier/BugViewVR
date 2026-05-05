using UnityEngine;

namespace FlyVision
{
    /// Head-locks a quad in front of the HMD so a fullscreen overlay material
    /// covers the camera FOV. Attach to an empty GameObject; assign Head (the
    /// CenterEyeAnchor / Main Camera transform) and OverlayMaterial.
    [ExecuteAlways]
    public class FlyVisionOverlay : MonoBehaviour
    {
        [Tooltip("Camera / CenterEyeAnchor the overlay should follow.")]
        public Transform head;

        [Tooltip("Material using the FlyVision/Overlay shader.")]
        public Material overlayMaterial;

        [Tooltip("Distance in meters from the eye to the overlay quad.")]
        [Min(0.05f)] public float distance = 0.3f;

        [Tooltip("Extra padding so the quad always overshoots the FOV.")]
        [Min(1f)] public float fovPadding = 1.4f;

        [Tooltip("Vertical FOV in degrees used to size the quad. Quest ~ 96-106.")]
        [Range(60f, 130f)] public float assumedVerticalFovDeg = 110f;

        [Tooltip("Aspect (width/height) of the overlay. >1 widens it.")]
        [Min(0.1f)] public float aspect = 1.6f;

        MeshFilter _mf;
        MeshRenderer _mr;

        void OnEnable()
        {
            EnsureQuad();
            ApplyMaterial();
        }

        void LateUpdate()
        {
            if (head == null || _mr == null) return;

            transform.position = head.position + head.forward * distance;
            transform.rotation = head.rotation;

            float h = 2f * distance * Mathf.Tan(0.5f * assumedVerticalFovDeg * Mathf.Deg2Rad) * fovPadding;
            float w = h * aspect;
            transform.localScale = new Vector3(w, h, 1f);
        }

        void EnsureQuad()
        {
            _mf = GetComponent<MeshFilter>();
            if (_mf == null) _mf = gameObject.AddComponent<MeshFilter>();
            if (_mf.sharedMesh == null) _mf.sharedMesh = BuildQuad();

            _mr = GetComponent<MeshRenderer>();
            if (_mr == null) _mr = gameObject.AddComponent<MeshRenderer>();
            _mr.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
            _mr.receiveShadows = false;
            _mr.lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;
            _mr.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off;
            _mr.allowOcclusionWhenDynamic = false;
        }

        void ApplyMaterial()
        {
            if (_mr != null && overlayMaterial != null)
                _mr.sharedMaterial = overlayMaterial;
        }

        static Mesh BuildQuad()
        {
            var m = new Mesh { name = "FlyVisionQuad" };
            m.vertices = new[]
            {
                new Vector3(-0.5f, -0.5f, 0f),
                new Vector3( 0.5f, -0.5f, 0f),
                new Vector3( 0.5f,  0.5f, 0f),
                new Vector3(-0.5f,  0.5f, 0f),
            };
            m.uv = new[]
            {
                new Vector2(0,0), new Vector2(1,0), new Vector2(1,1), new Vector2(0,1)
            };
            m.triangles = new[] { 0, 2, 1, 0, 3, 2 };
            m.RecalculateNormals();
            m.RecalculateBounds();
            return m;
        }
    }
}
