namespace RoboBlast
{
    public partial class Airborne : BaseState
    {
        public override void Enter()
        {
            Player.CoyoteTimer.Start();
            InputHandler.JumpPressed += OnJumpPressed;
            InputHandler.AimPressed += OnZoomedIn;
            InputHandler.AimReleased += OnZoomedOut;
        }

        public override void Exit()
        {
            Player.CoyoteTimer.Stop();
            Player.JumpBufferTimer.Stop();
        
            InputHandler.JumpPressed -= OnJumpPressed;
            InputHandler.AimPressed -= OnZoomedIn;
            InputHandler.AimReleased -= OnZoomedOut;
        }
    
        public override void Update(double delta)
        {
            CameraController.RotateCamera(MouseHandler.Motion, delta);
        
            if (Player.IsZoomedIn)
                CameraController.ZoomIn(delta);
            else
                CameraController.ZoomOut(delta);
        
            Player.GlobalBasis = CameraController.HorizontalRotation();
        }

        public override void PhysicsUpdate(double delta)
        {
            var inputDirection = InputHandler.Move;
            var wishDirection = Player.DirectionToWorld(inputDirection);
            var wishSpeed = inputDirection.Length() * Player.MaxSpeed;
        
            Player.ApplyGravity(delta);
            Player.ApplyAcceleration(wishDirection, wishSpeed, delta);
        
            Player.MoveAndSlide();

            if (Player.IsOnFloor() && !Player.JumpBufferTimer.IsStopped())
            {
                Player.Jump();
                Player.JumpBufferTimer.Stop();
            }

            if (Player.IsOnFloor() && Player.JumpBufferTimer.IsStopped())
            {
                EmitTransition((int)PlayerState.Grounded);
            }
        }

        private void OnJumpPressed()
        {
            if (Player.IsOnFloor() || !Player.CoyoteTimer.IsStopped())
            {
                Player.Jump();
                Player.CoyoteTimer.Stop();
            }
            else
                Player.JumpBufferTimer.Start();
        }
    
        private void OnZoomedIn() => Player.IsZoomedIn = true;
    
        private void OnZoomedOut() => Player.IsZoomedIn = false;
    }
}
