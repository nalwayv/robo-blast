using Godot;

namespace RoboBlast
{
    public partial class MouseHandler : Node
    {
        private Vector2 _motion;

        public Vector2 Motion
        {
            get
            {
                var result = _motion;
                _motion = Vector2.Zero;
                return result;
            }
        }

        public override void _Ready()
        {
            Input.MouseMode = Input.MouseModeEnum.Captured;
        }

        public override void _UnhandledInput(InputEvent @event)
        {
            if (@event is InputEventMouseMotion mouseMotion)
            {
                if (Input.MouseMode == Input.MouseModeEnum.Captured)
                {
                    _motion += -mouseMotion.Relative;
                }
            }

            if (@event.IsActionPressed("escape"))
            {
                Input.MouseMode = Input.MouseModeEnum.Visible;
            }
        }
    }
}