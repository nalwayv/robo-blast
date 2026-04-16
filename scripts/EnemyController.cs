using Godot;

namespace RoboBlast
{
    public partial class EnemyController : CharacterBody3D
    {
        private const float MaxTurnAngle = 60f;
        private const float PredictionThreshold = 0.33f;
        private const float NavigationInterval = 0.1f;
    
        [ExportGroup("Movement")]
        [Export] private float _maxSpeed = 2.5f;
        [Export] private float _stopSpeed = 2f;
        [Export] private float _acceleration = 10f;
        [Export] private float _friction = 6f;
        [Export] private float _maxTurnSpeed = 15f;
        [Export] private float _minTurnSpeed = 5f;
        [Export] private float _directionWight = 10f;
    
        [ExportGroup("Detection")]
        [Export] private float _detectionRadius = 5f;
        [Export] private float _detectionAngle = 90f;
    
        [ExportGroup("Attack")]
        [Export] private float _attackRange = 2f;
        [Export] private int _attackDamage = 20;
    
        private bool _provoked;
        private PlayerController _playerController;
        private Vector3 _currentDirection = Vector3.Forward;
        private float _navigationDelay;
    
    
        private Health _health;
        private NavigationAgent3D _navigationAgent;
        private AnimationPlayer _animationPlayer;

        public override void _Ready()
        {
            AddToGroup("enemy");
        
            _health = GetNode<Health>("Health");
            _playerController = GetTree().GetFirstNodeInGroup("player") as PlayerController;
            _navigationAgent = GetNode<NavigationAgent3D>("NavigationAgent");
            _animationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");

            _health.Dead += QueueFree;
            _health.Damaged += () => _provoked = true;
        }

        public override void _Process(double delta)
        {
            _navigationDelay -= (float)delta;
            if (_navigationDelay <= 0f)
            {
                _navigationAgent.TargetPosition = UpdatePredictionTarget();
                _navigationDelay = NavigationInterval;
            }
        }

        public override void _PhysicsProcess(double delta)
        {
            ApplyGravity(delta);

            if (_provoked)
            {
                if (!_navigationAgent.IsNavigationFinished())
                {
                    var nextPosition = _navigationAgent.GetNextPathPosition();
                    var direction = GlobalPosition.DirectionTo(nextPosition);
                    _currentDirection = _currentDirection.Lerp(direction, _directionWight * (float)delta);
                
                    var wishDirection = new Vector3(_currentDirection.X, 0f, _currentDirection.Z).Normalized();
                    var wishSpeed = _maxSpeed;
                
                    ApplyFriction(delta);
                    ApplyAcceleration(wishDirection, wishSpeed, delta);
                    ApplyRotation(wishDirection, delta);
                
                }
                else
                {
                    var directionToPlayer = GlobalPosition.DirectionTo(_playerController.GlobalPosition);
                    _currentDirection = _currentDirection.Lerp(directionToPlayer, _directionWight * (float)delta);
                    var wishDirection = new Vector3(_currentDirection.X, 0f, _currentDirection.Z).Normalized();

                    ApplyFriction(delta);
                    ApplyRotation(wishDirection, delta);
                }
            }
            else
            {
                ApplyFriction(delta);
            }

            MoveAndSlide();
        
            PlayerWithinRange();
            PerformAttack();
        }

        private void ApplyGravity(double delta)
        {
            if (IsOnFloor())
                return;
        
            Velocity += GetGravity() * (float)delta;
        }
    
        private void ApplyRotation(Vector3 direction, double delta)
        {
            var yaw = Mathf.Atan2(-direction.X, -direction.Z);
            var diff = Mathf.AngleDifference(Rotation.Y, yaw);
            var turnSpeed = Mathf.Abs(diff) > Mathf.DegToRad(MaxTurnAngle) ? _maxTurnSpeed : _minTurnSpeed;

            var lerpAngle = Mathf.LerpAngle(Rotation.Y, yaw, turnSpeed * (float)delta);

            var rotation = Rotation;
            rotation.Y = lerpAngle;
            Rotation = rotation;
        }

        private void PlayerWithinRange()
        {
            if (GlobalPosition.DistanceTo(_playerController.GlobalPosition) > _detectionRadius)
                return;
        
            if (!PlayerWithinFovAngle())
                return;
        
            _provoked = true;
        }

        private bool PlayerWithinFovAngle()
        {
            var forward = -GlobalBasis.Z;
            var halfFov = Mathf.DegToRad(_detectionAngle * 0.5f);
            var directionToPlayer = GlobalPosition.DirectionTo(_playerController.GlobalPosition);
            return forward.Dot(directionToPlayer) > Mathf.Cos(halfFov);
        }

        private void PerformAttack()
        {
            if(!_provoked)
                return;
        
            if (GlobalPosition.DistanceTo(_playerController.GlobalPosition) > _attackRange)
                return;
        
            _animationPlayer.Play("attack");
        }
    
        private Vector3 UpdatePredictionTarget()
        {
            if (!_provoked)
                return Vector3.Zero;
        
            var distanceToPlayer = GlobalPosition.DistanceTo(_playerController.GlobalPosition);
            var timeToPlayer = Mathf.Min(distanceToPlayer / Mathf.Max(1f, _maxSpeed), 1f);
        
            var targetPrediction = _playerController.GlobalPosition + _playerController.AverageVelocity * timeToPlayer;
            var directionToTarget = GlobalPosition.DirectionTo(targetPrediction);
            var directionToPlayer = GlobalPosition.DirectionTo(_playerController.GlobalPosition);
        
            if(directionToPlayer.Dot(directionToTarget) < PredictionThreshold)
                targetPrediction = _playerController.GlobalPosition;

            return targetPrediction;
        }
    
        private void ApplyFriction(double delta)
        {
            var speed = Velocity.Length();
            if (Mathf.IsZeroApprox(speed))
            {
                Velocity = Vector3.Zero;
                return;
            }
            var control = Mathf.Max(speed, _stopSpeed);
            var drop = control * _friction * (float)delta;
            var newSpeed = Mathf.Max(0f, speed - drop);
            if (speed > 0f)
                newSpeed /= speed;

            Velocity *= newSpeed;
        }

        private void ApplyAcceleration(Vector3 wishDir, float wishSpeed, double delta)
        {
            var currentSpeed = Velocity.Dot(wishDir);
            var addSpeed = wishSpeed - currentSpeed;
            if (addSpeed <= 0f)
                return;
            
            var accelerationSpeed = Mathf.Min(addSpeed, _acceleration * wishSpeed * (float)delta);
            Velocity += wishDir * accelerationSpeed;
        }

        public void Attack()
        {
            // NOTE: this method is called by the animation player
            var health = _playerController.GetNodeOrNull<Health>("Health");
            if (health != null)
                health.HitPoints -= _attackDamage;
        }
    }
}
