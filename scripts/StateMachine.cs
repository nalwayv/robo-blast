using Godot;

namespace RoboBlast
{
    public partial class StateMachine : Node
    {
        private State _currentState;
        private Godot.Collections.Dictionary<int, State> _states = new();

        public override void _Ready()
        {
            foreach (var state in GetChildren())
            {
                if (state is State stateNode)
                {
                    stateNode.Transition += OnTransition;
                    _states.Add((int)stateNode.PlayerState, stateNode);
                }
            }

            _states[(int)PlayerState.Grounded].Enter();
            _currentState = _states[(int)PlayerState.Grounded];
        }

        public override void _Process(double delta)
        {
            if(_currentState == null)
                return;
        
            _currentState.Update(delta);
        }

        public override void _PhysicsProcess(double delta)
        {
            if(_currentState == null)
                return;
        
            _currentState.PhysicsUpdate(delta);
        }

        private void OnTransition(int playerState)
        {
            if (_states.TryGetValue(playerState, out var nextState))
            {
                if (nextState == _currentState)
                    return;
            
                _currentState.Exit();
                nextState.Enter();
                _currentState = nextState;
            }
        }
    }
}
