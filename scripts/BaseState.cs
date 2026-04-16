using Godot;

namespace RoboBlast
{
    public partial class BaseState : State
    {
        [ExportGroup("Components")]
        [Export] protected PlayerController Player;
        [Export] protected MouseHandler MouseHandler;
        [Export] protected InputHandler InputHandler;
        [Export] protected CameraController CameraController;
    }
}
