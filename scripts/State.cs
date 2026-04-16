using Godot;

namespace RoboBlast
{
    public partial class State : Node
    {
        [Signal] public delegate void TransitionEventHandler(int state);
    
        [Export] private PlayerState _playerState;

        public PlayerState PlayerState => _playerState;
    
        public virtual void Enter(){}
        public virtual void Exit(){}
        public virtual void Update(double delta){}
        public virtual void PhysicsUpdate(double delta){}


        public void EmitTransition(int state)
        {
            EmitSignal(SignalName.Transition, state);
        }
    }
}
