using Godot;
using RoboBlast.Utils;

namespace RoboBlast.Item;

public partial class Item : Area3D
{
    [ExportGroup("Animation")]
    [ExportSubgroup("Spring")]
    [Export] private float _frequency = 4f;
    [Export] private float _nudge = 0.8f;
    [ExportSubgroup("Model Rotation")]
    [Export] private float _rotationSpeed = 1.5f;
    [Export] private Node3D _model;

    private DampedSpring _dampedSpring;

    public override void _Ready()
    {
        _dampedSpring = new DampedSpring
        {
            Target = Position,
            Position = Position,
            Frequency = _frequency,
            Damping = 0f
        };
        
        // initiate the spring to start animating
        _dampedSpring.Velocity += Vector3.Up * _nudge;

        BodyEntered += OnBodyEntered;
    }

    private void OnBodyEntered(Node3D body)
    {
        if (!body.IsInGroup("player"))
        {
            return;
        }
        
        Collected(body);
        QueueFree();
    }

    public virtual void Collected(Node3D body)
    {
    }
}
