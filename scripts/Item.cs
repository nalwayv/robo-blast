using Godot;

namespace RoboBlast
{
    public partial class Item : Area3D
    {
        [ExportGroup("Spring Animation")]
        [Export] private float _frequency = 4f;
        [Export] private float _nudge = 0.8f;
    
        [ExportGroup("Model Rotation")]
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
        
            _dampedSpring.Velocity += Vector3.Up * _nudge;

            BodyEntered += OnBodyEntered;
        }

        public override void _Process(double delta)
        {
            _dampedSpring.Step(delta);
            Position = _dampedSpring.Position;
            _model.RotateY(_rotationSpeed * (float)delta);
        }
    
        private void OnBodyEntered(Node3D body)
        {
            if (!body.IsInGroup("player"))
                return;
        
            Collected(body);
            QueueFree();
        }

        private protected virtual void Collected(Node3D body)
        {
        }
    }
}
