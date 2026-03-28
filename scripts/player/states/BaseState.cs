using Godot;
using System;
using RoboBlast.Player.Components;

namespace RoboBlast.Player.States;

public partial class BaseState : State
{
    [ExportGroup("Components")]
    [Export] protected PlayerController PlayerController;
    [Export] protected MouseHandler MouseHandler;
    [Export] protected InputHandler InputHandler;
    [Export] protected CameraController CameraController;
}
