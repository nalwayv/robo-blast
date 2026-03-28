using Godot;

namespace RoboBlast.Player.States;

public partial class StateMachine : Node
{
    private State _currentState;
    private Godot.Collections.Dictionary<PlayerState, State> _stateDictionary = [];

    public override void _Ready()
    {
        foreach (var state in GetChildren())
        {
            if (state is State stateNode)
            {
                stateNode.Transition += OnTransition;
                _stateDictionary.Add(stateNode.PlayerState, stateNode);
            }
        }

        if (_stateDictionary.TryGetValue(PlayerState.Grounded, out var playerState))
        {
            playerState.Enter();
            _currentState = playerState;
        }
    }

    public override void _Process(double delta)
    {
        _currentState.Process(delta);
    }

    public override void _PhysicsProcess(double delta)
    {
        _currentState.PhysicsProcess(delta);
    }
    
    public void OnTransition(PlayerState playerState)
    {
        if (_stateDictionary.TryGetValue(playerState, out var nextState))
        {
            if (nextState == _currentState)
            { 
                return;
            }
            
            _currentState.Exit();
            nextState.Enter();
            _currentState = nextState;
        }
    }
}
