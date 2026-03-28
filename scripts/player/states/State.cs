using Godot;
using System;

namespace RoboBlast.scripts.player.states;


public partial class State : Node
{
    [Export] private PlayerState _playerState;

    public event Action<PlayerState> Transition;

    public PlayerState PlayerState => _playerState;
    
    public void OnTransition(PlayerState playerState)
    {
        Transition?.Invoke(playerState);
    }
    
    public virtual void Enter(){}
    public virtual void Exit(){}
    public virtual void Process(double delta){}
    public virtual void PhysicsProcess(double delta){}
}
