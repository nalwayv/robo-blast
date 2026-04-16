using Godot;

namespace RoboBlast
{
    public partial class CameraController : Node3D
    {
        private const float MinXRotation = -89f;
        private const float MaxXRotation = 70f;
    
        [ExportGroup("Cameras")]
        [Export] private Camera3D _mainCamera;
        [Export] private Camera3D _secondCamera;
    
        [ExportGroup("Camera Smoothing")]
        [Export] private float _smoothWeight = 20f;
        [Export] private float _baseSensitivity = 0.001f;
    
        [ExportGroup("Sensitivity")]
        [Export] private float _inchesPer360 = 12f;
        [Export] private float _dpi = 800f;
        [Export] private float _mouseSensitivity = 1f;
    
        [ExportGroup("Field Of View")]
        [Export] private float _zoomInRatio = 0.7f;
        [Export] private float _zoomInSpeed = 20f;
        [Export] private float _zoomOutSpeed = 30f;
    
        private float _mainCameraFov;
        private float _secondCameraFov;
        private Vector2 _targetRotation;
        private Vector2 _currentRotation;
        private float _radiansPerDegree;

        public override void _Ready()
        {
            _mainCameraFov = _mainCamera.Fov;
            _secondCameraFov = _secondCamera.Fov;
            _radiansPerDegree = Mathf.Tau / (_inchesPer360 * _dpi * _mouseSensitivity);
        }

        /// <summary>
        /// Alter the cameras FOV to zoom in.
        /// </summary>
        public void ZoomIn(double delta)
        {
            _mainCamera.Fov = Mathf.Lerp(
                _mainCamera.Fov, 
                _mainCameraFov * _zoomInRatio, 
                _zoomInSpeed * (float)delta);
        
            _secondCamera.Fov = Mathf.Lerp(
                _secondCamera.Fov,
                _secondCameraFov * _zoomInRatio,
                _zoomInSpeed * (float)delta);
        }
    
        /// <summary>
        /// Reset the camera's FOV to its default value.
        /// </summary>
        public void ZoomOut(double delta)
        {
            _mainCamera.Fov = Mathf.Lerp(
                _mainCamera.Fov, 
                _mainCameraFov, 
                _zoomOutSpeed * (float)delta);
        
            _secondCamera.Fov = Mathf.Lerp(
                _secondCamera.Fov,
                _secondCameraFov,
                _zoomOutSpeed * (float)delta);
        }

        /// <summary>
        /// Rotate the camera based on the mouse motion.
        /// </summary>
        /// <param name="motion">mouse input motion</param>
        /// <param name="delta">time</param>
        public void RotateCamera(Vector2 motion, double delta)
        {
            _targetRotation += new Vector2(motion.Y, motion.X) * _radiansPerDegree;
            _targetRotation.X = Mathf.Clamp(
                _targetRotation.X, 
                Mathf.DegToRad(MinXRotation), 
                Mathf.DegToRad(MaxXRotation));
        
            var weight = 1f - Mathf.Exp(-_smoothWeight * (float)delta);
            _currentRotation = _currentRotation.Lerp(_targetRotation, weight);
            Basis = Basis.FromEuler(Vector3.Right * _currentRotation.X);
        }
    
        /// <summary>
        /// Returns the horizontal rotation of the camera.
        /// </summary>
        public Basis HorizontalRotation()
        {
            return Basis.FromEuler(Vector3.Up * _currentRotation.Y);
        }
    }
}
