using Godot;

 namespace RoboBlast.Player;
 
public partial class CameraController : Node3D
{
    private const float MaxXRotation = 70f;
    private const float MinXRotation = -89f;
    
    [ExportGroup("Cameras")]
    [Export] private Camera3D _mainCamera;
    [Export] private Camera3D _secondCamera;
    [ExportGroup("Camera Smoothing")]
    [Export] private float _smoothWeight = 20f;
    [ExportGroup("Mouse Sensitivity")]
    [Export] private float _inchesPer360 = 12f;
    [Export] private float _dpi = 800f;
    [Export] private float _mouseSensitivity = 1f;
    [ExportGroup("Field Of View")]
    [Export] private float _fovPercentage = 0.7f;
    [Export] private float _zoomInWeight = 20f;
    [Export] private float _zoomOutWeight = 30f;
    
    private float _mainCameraDefaultFov;
    private float _secondCameraDefaultFov;

    private Vector2 _targetRotation;
    private Vector2 _currentRotation;
    private float _radiansPerDegree;
    private float _minXRotation;
    private float _maxXRotation;

    public override void _Ready()
    {
        _mainCameraDefaultFov = _mainCamera.Fov;
        _secondCameraDefaultFov = _secondCamera.Fov;
        _radiansPerDegree = Mathf.Tau / (_inchesPer360 * _dpi * _mouseSensitivity);
        
        _minXRotation = Mathf.DegToRad( MinXRotation);
        _maxXRotation = Mathf.DegToRad(MaxXRotation);
    }

    public void ZoomIn(double delta)
    {
        _mainCamera.Fov = Mathf.Lerp(
            _mainCamera.Fov, 
            _mainCameraDefaultFov * _fovPercentage, 
            _zoomInWeight * (float)delta);
        
        _secondCamera.Fov = Mathf.Lerp(
            _secondCamera.Fov,
            _secondCameraDefaultFov * _fovPercentage,
            _zoomInWeight * (float)delta);
    }

    public void ZoomOut(double delta)
    {
        _mainCamera.Fov = Mathf.Lerp(
            _mainCamera.Fov, 
            _mainCameraDefaultFov, 
            _zoomOutWeight * (float)delta);
        
        _secondCamera.Fov = Mathf.Lerp(
            _secondCamera.Fov,
            _secondCameraDefaultFov,
            _zoomOutWeight * (float)delta);
    }

    public void RotateCamera(Vector2 motion, double delta)
    {
        _targetRotation += new Vector2(motion.Y, motion.X) * _radiansPerDegree;
        _targetRotation = _targetRotation with { X = Mathf.Clamp(_targetRotation.X, _minXRotation, _maxXRotation) };
        
        var weight = 1f - Mathf.Exp(-_smoothWeight * (float)delta);
        _currentRotation = _currentRotation.Lerp(_targetRotation, weight);
        
        var rotation = new Vector3(_currentRotation.X,0f, 0f);
        Basis = Basis.FromEuler(rotation);
    }
    
    public Basis HorizontalRotation()
    {
        return Basis.FromEuler(new Vector3(0f, _currentRotation.Y, 0f));
    }
}
