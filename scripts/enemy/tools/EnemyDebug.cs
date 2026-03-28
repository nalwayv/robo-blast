using Godot;

namespace RoboBlast.scripts.enemy.tools;

[Tool]
public partial class EnemyDebug : Node3D
{
    private const int Segments = 16;
    
    [Export] private float _fovAngle = 90f;
    [Export] private float _detectionRadius = 10f;
    [Export] private bool _drawDebug;
    
    public override void _Process(double delta)
    {
        if (_drawDebug)
        {
            DrawDebug();
        }
    }

    public void DrawDebug()
    {
        var origin = GlobalPosition;
        var forward = -GlobalBasis.Z;
        var halfFov = Mathf.DegToRad(_fovAngle * 0.5f);
        var left = forward.Rotated(Vector3.Up, halfFov);
        var right = forward.Rotated(Vector3.Up, -halfFov);
        
        DebugDraw3D.DrawLine(origin, origin + forward * _detectionRadius, Colors.Green);
        DebugDraw3D.DrawLine(origin, origin + left * _detectionRadius, Colors.Red);
        DebugDraw3D.DrawLine(origin, origin + right * _detectionRadius, Colors.Red);
        
        var previous = Vector3.Zero;
        for (int i = 0; i < Segments + 1; i++)
        {
            var weight = (float)i / Segments;
            var angle = Mathf.Lerp(-halfFov, halfFov, weight);
            var dir = forward.Rotated(Vector3.Up, angle).Normalized();
            var pos = origin + dir * _detectionRadius;
            if (previous != Vector3.Zero)
            {
                DebugDraw3D.DrawLine(previous, pos, Colors.Blue);
            }
            previous = pos;
        }
    }
}
