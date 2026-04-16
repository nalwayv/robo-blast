namespace RoboBlast
{
    public partial class Grounded : BaseState
    {
        public override void Enter()
        {
            InputHandler.JumpPressed += OnJumpPressed;
            InputHandler.AimPressed += OnZoomedIn;
            InputHandler.AimReleased += OnZoomedOut;
        }

        public override void Exit()
        {
            InputHandler.JumpPressed += OnJumpPressed;
            InputHandler.AimPressed += OnZoomedIn;
            InputHandler.AimReleased += OnZoomedOut;
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
            Player.ApplyFriction(delta);
            Player.ApplyAcceleration(wishDirection, wishSpeed, delta);
        
            Player.StepOver();
        
            Player.MoveAndSlide();
        
            if(!Player.IsOnFloor())
                EmitTransition((int)PlayerState.Airborne);
        }
    
        private void OnJumpPressed()
        {
            Player.Jump();
            EmitTransition((int)PlayerState.Airborne);
        }

        private void OnZoomedIn() => Player.IsZoomedIn = true;
    
        private void OnZoomedOut() => Player.IsZoomedIn = false;
    }
}
