using Godot;


namespace RoboBlast
{
    /// <summary>
    /// A Helper node that handles the players camera movement and shake effects.<br/>
    /// A Camera bus is used to receive shake requests from the player controller and 
    /// apply them to the camera using a damped spring for smooth movement.
    /// </summary>
    public partial class PlayerCamera : Camera3D
    {
        [ExportGroup("Camera Smoothing")] 
        [Export] private float _rotationSpeed = 50f;
    
        [ExportGroup("Camera Shake")] 
        [Export] private float _frequency = 22f;
        [Export] private float _damping = 0.5f;
    
        [ExportGroup("Resources")]
        [Export] private CameraBus _cameraBus;

        private DampedSpring _shakeSpring;

        public override void _Ready()
        {
            TopLevel = true;
            _shakeSpring = new DampedSpring
            {
                Frequency = _frequency,
                Damping = _damping,
            };

            _cameraBus.CameraShake += OnCameraShake;
        }

        public override void _Process(double delta)
        {
            var targetTransform = new Transform3D();
            
            _shakeSpring.Step(delta);
            
            targetTransform *= GetSmoothMoveTransform(delta);
            targetTransform *= GetShakeOffset();
            
            GlobalTransform = targetTransform;
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
    
        private Transform3D GetShakeOffset()
        {
            return new Transform3D(Basis.Identity, _shakeSpring.Position);
        }
    
        private void OnCameraShake(float intensity)
        {
            var x = (float)GD.RandRange(-intensity, intensity);
            var y = (float)GD.RandRange(-intensity, intensity);
            _shakeSpring.Velocity += new Vector3(x, y, 0f);
        }
    }
}