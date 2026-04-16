using Godot;

namespace RoboBlast
{
    [Tool]
    public partial class EnemyDebug : Node3D
    {
        private const int Segments = 16;
    
        [Export] private bool _drawDebug = false;
        [Export] private float _fovAngle = 90f;
        [Export] private float _detectionRadius = 10f;
    
        public override void _Process(double delta)
        {
            if (_drawDebug)
            {
                DrawDebug();
            }
        }

        private void DrawDebug()
        {
            var origin = GlobalPosition;
            var forward = -GlobalBasis.Z;
            var halfFov = Mathf.DegToRad(_fovAngle * 0.5f);
            var left = forward.Rotated(Vector3.Up, halfFov);
            var right = forward.Rotated(Vector3.Up, -halfFov);
        
            DebugDraw3D.DrawLine(origin, origin + forward * _detectionRadius, Colors.Green);
            DebugDraw3D.DrawLine(origin, origin + left * _detectionRadius, Colors.Red);
            DebugDraw3D.DrawLine(origin, origin + right * _detectionRadius, Colors.Red);
        
            var previousPosition = Vector3.Zero;
            for (int i = 0; i < Segments + 1; i++)
            {
                var weight = (float)i / Segments;
                var angle = Mathf.Lerp(-halfFov, halfFov, weight);
                var direction = forward.Rotated(Vector3.Up, angle).Normalized();
                var position = origin + direction * _detectionRadius;
            
                if (previousPosition != Vector3.Zero)
                    DebugDraw3D.DrawLine(previousPosition, position, Colors.Blue);
            
                previousPosition = position;
            }
        }
    }
}
