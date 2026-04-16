using Godot;
using Godot.Collections;

namespace RoboBlast
{
    public partial class PlayerController : CharacterBody3D
    {
        private const float HistoricalTimerInterval = 0.1f;
        private const int MaxVelocityHistory = 10;
        private const float MaxEdgeFriction = 2f;
        private const float StepDistanceBuffer = 0.05f;
        
        [Export] public int Foo { get;set; }
        [Export] private float _maxSpeed = 7f;
        [Export] private float _stopSpeed = 3f;
        [Export] private float _acceleration = 10f;
        [Export] private float _friction = 6f;
        [Export] private float _airCapped = 0.9f;
    
        [Export] private float _maxJumpHeight = 1f;
        [Export] private float _timeToPeak = 0.45f;
        [Export] private float _timeToDecent = 0.35f;
        [Export] private float _airAcceleration = 1.5f;
    
        [Export] private float _coyoteTime = 0.15f;
        [Export] private float _jumpBufferTime = 0.15f;
    
        [Export] private CameraBus _cameraBus;
        [Export] private float _cameraShakeIntensity = 0.7f;

        [Export] private Node3D _model;
        [Export] private float _modelRotationSpeed = 50f;

        private float _stepHeight = 0.3f;
        private float _stepDistance = 0.2f;
    
        private float _jumpVelocity;
        private float _jumpGravity;
        private float _fallGravity;
        public bool IsZoomedIn  { get; set; }

        private Array<Vector3> _historicalVelocities;
    
        public float MaxSpeed => _maxSpeed;
        public Timer CoyoteTimer { get; private set; }
        public Timer JumpBufferTimer { get; private set; }
        private Timer _historicalVelocityTimer;
        private AnimationPlayer _animation;
        private GameOverMenu _gameOverMenu;
    
        private RayCast3D _edgeRayCast;
        private Health _health;
        public Vector3 AverageVelocity
        {
            get
            {
                if (_historicalVelocities.Count == 0)
                {
                    return Vector3.Zero;
                }

                var average = Vector3.Zero;
                foreach (var v in _historicalVelocities)
                {
                    average += v;
                }
                average.Y = 0f;
                
                return average / _historicalVelocities.Count;
            }
        }
        
        public override void _Ready()
        {
            AddToGroup("player");
            
            CoyoteTimer = GetNode<Timer>("CoyoteTimer");
            JumpBufferTimer = GetNode<Timer>("JumpBufferTimer");
            _historicalVelocityTimer = GetNode<Timer>("HistoricalVelocityTimer");
            _animation = GetNode<AnimationPlayer>("AnimationPlayer");
            _edgeRayCast = GetNode<RayCast3D>("NearEdgeRayCast");
            _health = GetNode<Health>("%Health");
            _gameOverMenu = GetNode<GameOverMenu>("GameOverMenu");
            
            _jumpVelocity = 2f * _maxJumpHeight / _timeToPeak;
            _jumpGravity = -2f * _maxJumpHeight / Mathf.Pow(_timeToPeak, 2f);
            _fallGravity = -2f * _maxJumpHeight / Mathf.Pow(_timeToDecent, 2f);
            
            _historicalVelocities = new Array<Vector3>();
            _historicalVelocities.Resize(MaxVelocityHistory);
            
            // Timers
            CoyoteTimer.OneShot = true;
            CoyoteTimer.WaitTime = _coyoteTime;
            
            JumpBufferTimer.OneShot = true;
            JumpBufferTimer.WaitTime = _jumpBufferTime;
            
            _historicalVelocityTimer.OneShot = false;
            _historicalVelocityTimer.WaitTime = HistoricalTimerInterval;
            _historicalVelocityTimer.Timeout += OnHistoricalVelocityTimerOnTimeout;

            _health.Damaged += OnDamageTaken;
            _health.Dead += _gameOverMenu.GameOver;
        }

        public override void _Process(double delta)
        {
            var weight = Mathf.Clamp(_modelRotationSpeed * (float)delta, 0f, 1f);
            _model.GlobalTransform = _model.GlobalTransform.InterpolateWith(GlobalTransform, weight);
        }

        /// <summary>
        /// Apply gravity to the character.
        /// </summary>
        /// <param name="delta"></param>
        public void ApplyGravity(double delta)
        {
            if (IsOnFloor())
            {
                if (Velocity.Y < 0f)
                {
                    var velocity = new Vector3(Velocity.X, 0f, Velocity.Z);
                    Velocity = velocity;
                }
                return;
            }
            
            var gravity = Velocity.Y < 0f ? _fallGravity : _jumpGravity;
            Velocity += Vector3.Up * gravity * (float)delta;
        }

        public void Jump()
        {
            Velocity = new Vector3(Velocity.X, _jumpVelocity, Velocity.Z);
        }

        public void ApplyFriction(double delta)
        {
            var speed = Velocity.Length();
            if (speed < 0.1f)
            {
                Velocity = Vector3.Zero;
                return;
            }

            var frictionAmount = _friction;
            if (IsNearEdge())
            {
                frictionAmount *= MaxEdgeFriction;
            }

            var control = Mathf.Max(speed, _stopSpeed);
            var newSpeed = Mathf.Max(0f, speed - control * frictionAmount * (float)delta);
            
            if (speed > 0f)
            {
                newSpeed /= speed;
            }
            
            Velocity *= newSpeed;
        }
    
        private bool IsNearEdge()
        {
            if (!IsOnFloor())
            {
                return false;
            }

            var horizontalVelocity = new Vector3(Velocity.X, 0f, Velocity.Z);
            if(horizontalVelocity.IsZeroApprox())
            {
                return false;
            }
            
            _edgeRayCast.ForceRaycastUpdate();
            return _edgeRayCast.IsColliding();
        }

        public void ApplyAcceleration(Vector3 wishDir, float wishSpeed, double delta)
        {
            var currentSpeed = Velocity.Dot(wishDir);
            var addSpeed = wishSpeed - currentSpeed;
            if (addSpeed <= 0f)
            {
                return;
            }
            var accelerationSpeed = Mathf.Min(addSpeed, _acceleration * wishSpeed * (float)delta);
            Velocity += wishDir * accelerationSpeed;
        }

        public void ApplyAirAcceleration(Vector3 wishDir, float wishSpeed, double delta)
        {
            var speedCap = Mathf.Min(wishSpeed, _airCapped);
            
            var currentSpeed = Velocity.Dot(wishDir);
            var addSpeed = speedCap - currentSpeed;
            if (addSpeed <= 0f)
            {
                return;
            }
            
            var accelerationSpeed = Mathf.Min(addSpeed, _airAcceleration * wishSpeed * (float)delta);
            Velocity += wishDir * accelerationSpeed;
        }

        public Vector3 DirectionToWorld(Vector2 inputDir)
        {
            return GlobalBasis * new Vector3(inputDir.X, 0f, inputDir.Y);
        }


        public void StepOver()
        {
            var horizontalVelocity = new Vector3(Velocity.X, 0f, Velocity.Z);
            if (horizontalVelocity.IsZeroApprox())
            {
                return;
            }
        
            var direction = horizontalVelocity.Normalized();
            var physicsParams = new PhysicsTestMotionParameters3D();
            var physicsResult = new PhysicsTestMotionResult3D();
        
            // check forward collision
            // if nothing is hit, we can step forward
            physicsParams.From = GlobalTransform;
            physicsParams.Motion = direction * _stepDistance;
            if (!PhysicsServer3D.BodyTestMotion(GetRid(), physicsParams, physicsResult))
            {
                return;
            }
        
            // check height collision
            // if ceiling is hit we can't step
            var raised = GlobalTransform.Translated(Vector3.Up * _stepHeight);
            physicsParams.From = raised;
            physicsParams.Motion = direction * _stepDistance;
            if (PhysicsServer3D.BodyTestMotion(GetRid(), physicsParams, physicsResult))
            {
                return;
            }
        
            // check floor collision
            // if floor is not hit we can step down
            physicsParams.From = raised.Translated(direction * _stepDistance);
            physicsParams.Motion = Vector3.Down * _stepHeight;
            if (!PhysicsServer3D.BodyTestMotion(GetRid(), physicsParams, physicsResult))
            {
                return;
            }
        
            // we can step up to the height of the step
            var stepAmount = _stepHeight - physicsResult.GetTravel().Length();
            if (stepAmount > 0.1f)
            {
                GlobalPosition += Vector3.Up * stepAmount;
                GlobalPosition += direction * StepDistanceBuffer;
            }
        }
    
        private void OnDamageTaken()
        {
            _animation.Stop();
            if (_animation.HasAnimation("takeDamage"))
            {
                _animation.Play("takeDamage");
                _cameraBus.EmitCameraShake(_cameraShakeIntensity);
            }
        }

        private void OnHistoricalVelocityTimerOnTimeout()
        {
            if (_historicalVelocities.Count > MaxVelocityHistory)
            {
                _historicalVelocities.RemoveAt(0);
            }

            _historicalVelocities.Add(Velocity);
        }
    }
}