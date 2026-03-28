namespace RoboBlast.scripts.player.states;


public partial class GroundedState : BaseState
{
    public override void Enter()
    {
    }
    
    public override void Exit()
    {}

    public override void Process(double delta)
    {
        
        CameraController.RotateCamera(MouseHandler.Motion, delta);
        if (InputHandler.IsAiming)
        {
            CameraController.ZoomIn(delta);
        }
        else
        {
            CameraController.ZoomOut(delta);
        }
        PlayerController.GlobalBasis = CameraController.HorizontalRotation();
    }

    public override void PhysicsProcess(double delta)
    {
        var wishVelocity = PlayerController.ConvertInputDirectionToWorld(InputHandler.Direction);
        var wishDirection = wishVelocity.Normalized();
        var wishSpeed = wishVelocity.Length();
        
        PlayerController.ApplyFriction(delta);
        PlayerController.ApplyAcceleration(wishDirection, wishSpeed, delta);
        PlayerController.StepOver();

        PlayerController.MoveAndSlide();
        
        TransitionToAirborneFromJump();
        TransitionToAirborneFromFall();
            
    }
    
    private void TransitionToAirborneFromJump()
    {
        if (!InputHandler.IsJumping)
        {
            return;
        }
        
        PlayerController.Jump();
        OnTransition(PlayerState.Airborne);
    }

    private void TransitionToAirborneFromFall()
    {
        if (PlayerController.IsOnFloor())
        {
            return;
        }
        
        OnTransition(PlayerState.Airborne);
    }
}
