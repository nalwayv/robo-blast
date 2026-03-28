namespace RoboBlast.scripts.player.states;

public partial class AirborneState : BaseState
{
    public override void Enter()
    {
        PlayerController.CoyoteTimer.Start();
    }

    public override void Exit()
    {
        PlayerController.CoyoteTimer.Stop();
        PlayerController.JumpBufferTimer.Stop();
    }
    
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
        PlayerController.ApplyGravity(delta);
        
        var wishVelocity = PlayerController.ConvertInputDirectionToWorld(InputHandler.Direction);
        var wishDirection = wishVelocity.Normalized();
        var wishSpeed = wishVelocity.Length();
        
        PlayerController.ApplyAcceleration(wishDirection, wishSpeed, delta);

        ProcessJump();
        
        PlayerController.MoveAndSlide();

        HandleJumpBuffer();
        TransitionToGrounded();
    }

    private void TransitionToGrounded()
    {
        if (PlayerController.IsOnFloor() && PlayerController.JumpBufferTimer.IsStopped())
        {
            OnTransition(PlayerState.Grounded);
        }
    }

    private void HandleJumpBuffer()
    {
        if (PlayerController.IsOnFloor() && !PlayerController.JumpBufferTimer.IsStopped())
        {
            PlayerController.Jump();
            PlayerController.JumpBufferTimer.Stop();
        }
    }

    private void ProcessJump()
    {
        if(!InputHandler.IsJumping)
        {
            return;
        }

        if (PlayerController.IsOnFloor() || !PlayerController.CoyoteTimer.IsStopped())
        {
            PlayerController.Jump();
            PlayerController.CoyoteTimer.Stop();
            InputHandler.IsJumping = false;
        }
        else
        {
            PlayerController.JumpBufferTimer.Start();
            InputHandler.IsJumping = false;
        }
    }
}
