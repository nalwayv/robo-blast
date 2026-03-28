using Godot;
using Godot.Collections;

namespace RoboBlast.Player.Tools;

[Tool]
public partial class Crosshair : Control
{
    private readonly float _start = 16f;
    private readonly float _end = 24f;
    private readonly float _backgroundRadius = 4f;
    private readonly float _foregroundRadius = 3f;
    private readonly float _foregroundWidth = 5f;
    private readonly float _backgroundWidth = 4f;

    private readonly Array<Vector2> _directions =
    [
        Vector2.Up,
        Vector2.Down,
        Vector2.Left,
        Vector2.Right
    ];

    private readonly Color _backgroundColor = Colors.DimGray;
    private readonly Color _foregroundColor = Colors.White;

    public override void _Draw()
    {
        DrawCenter();
        DrawCrosshair();
    }

    private void DrawCenter()
    {
        DrawCircle(Vector2.Zero, _backgroundRadius, _backgroundColor);
        DrawCircle(Vector2.Zero, _foregroundRadius, _foregroundColor);
    }
    
    private void DrawCrosshair()
    {
        foreach (var direction in _directions)
        {
            DrawLine(
                direction * (_start - 1f),
                direction * (_end + 1f),
                _backgroundColor,
                _backgroundWidth);
            DrawLine(
                direction * _start,
                direction * _end,
                _foregroundColor,
                _foregroundWidth);
        }
    }
}
