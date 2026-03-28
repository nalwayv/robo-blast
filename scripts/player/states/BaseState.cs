using Godot;
using RoboBlast.scripts.player.components;

namespace RoboBlast.scripts.player.states;


public partial class BaseState : State
{
    [ExportGroup("Components")]
    [Export] protected PlayerController PlayerController;
    [Export] protected MouseHandler MouseHandler;
    [Export] protected InputHandler InputHandler;
    [Export] protected CameraController CameraController;
}
