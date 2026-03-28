using Godot;
using RoboBlast.scripts.player.resourse;
using RoboBlast.scripts.utils;


namespace RoboBlast.scripts.player;


public partial class PlayerCamera : Camera3D
{
    [ExportGroup("Camera Smoothing")] 
    [Export] private float _rotationSpeed = 50f;
    [ExportGroup("Camera Shake")] 
    [Export] private float _cameraShakeFrequency = 22f;
    [Export] private float _cameraShakeDamping = 0.5f;
    [ExportGroup("Resources")]
    [Export] private CameraBus _cameraBus;

    private DampedSpring _shakeSpring;

    public override void _Ready()
    {
        TopLevel = true;
        _shakeSpring = new DampedSpring
        {
            Frequency = _cameraShakeFrequency,
            Damping = _cameraShakeDamping,
        };

        _cameraBus.OnCameraShake += OnCameraShake;
    }

    public override void _Process(double delta)
    {
        var targetTransform = new Transform3D();
            
        _shakeSpring.Step(delta);
            
        targetTransform *= GetSmoothMoveTransform(delta);
        targetTransform *= GetShakeTransform();
            
        GlobalTransform = targetTransform;
    }

    private void OnCameraShake(float intensity)
    {
        var x = (float)GD.RandRange(-intensity, intensity);
        var y = (float)GD.RandRange(-intensity, intensity);

        var shakeOffset = new Vector3(x, y, 0f);

        _shakeSpring.Velocity += shakeOffset;
    }

    private Transform3D GetShakeTransform()
    {
        return new Transform3D(Basis.Identity, _shakeSpring.Position);
    }

    private Transform3D GetSmoothMoveTransform(double delta)
    {
        if (GetParent() is Node3D parent)
        {
            var weight = Mathf.Clamp(_rotationSpeed * (float)delta, 0f, 1f);
            return parent.GlobalTransform.InterpolateWith(parent.GlobalTransform, weight);
        }
        return Transform3D.Identity;
    }
}