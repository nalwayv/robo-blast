using Godot;
using Godot.Collections;
using RoboBlast.Components;
using RoboBlast.Player.Resourse;

namespace RoboBlast.Player;

public partial class PlayerController : CharacterBody3D
{
    private const float HistoricalVelocityTimerInterval = 0.1f;
    private const int MaxVelocityHistory = 10;
    private const float MaxEdgeFriction = 2f;
    private const float MaxStepHeight = 0.25f;
    private const float MaxStepDistance = 0.25f;
        
    [ExportGroup("Movement")]
    [ExportSubgroup("Ground")]
    [Export] private float _maxSpeed = 7f;
    [Export] private float _stopSpeed = 3f;
    [Export] private float _acceleration = 10f;
    [Export] private float _friction = 6f;
    [ExportSubgroup("Air")]
    [Export] private float _airAcceleration = 1.5f;
    [Export] private float _airCapped = 0.9f;
    [Export] private float _maxJumpHeight = 1f;
    [Export] private float _timeToPeak = 0.45f;
    [Export] private float _timeToDecent = 0.35f;
    [ExportGroup("Timers")]
    [Export] private float _coyoteTime = 0.15f;
    [Export] private float _jumpBufferTime = 0.15f;
    [ExportGroup("Resources")]
    [Export] private CameraBus _cameraBus;
    [ExportSubgroup("Camera Shake")]
    [Export] private float _cameraShakeIntensity = 0.7f;
    [ExportGroup("Misc")]
    [Export] private Node3D _model;
    [Export] private float _modelRotationSpeed = 50f;
        
        
    private float _jumpVelocity;
    private float _jumpGravity;
    private float _fallGravity;

    private Array<Vector3> _historicalVelocities;

    public Timer CoyoteTimer => _coyoteTimer;
    public Timer JumpBufferTimer => _jumpBufferTimer;
    
    #region @OnReady
    private Timer _coyoteTimer;
    private Timer _jumpBufferTimer;
    private Timer _historicalVelocityTimer;
    private RayCast3D _edgeRayCast;
    private AnimationPlayer _animation;
    private Health _health;
    #endregion
    /// <summary>
    /// Average velocity over time.
    /// </summary>
    public Vector3 AverageVelocity
    {
        get
        {
            if (_historicalVelocities == null || _historicalVelocities.Count == 0)
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
            
        _coyoteTimer = GetNode<Timer>("CoyoteTimer");
        _jumpBufferTimer = GetNode<Timer>("JumpBufferTimer");
        _historicalVelocityTimer = GetNode<Timer>("HistoricalVelocityTimer");
        _edgeRayCast = GetNode<RayCast3D>("EdgeRayCast");
        _animation = GetNode<AnimationPlayer>("AnimationPlayer");
        _health = GetNode<Health>("Health");
            
        _jumpVelocity = 2f * _maxJumpHeight / _timeToPeak;
        _jumpGravity = -2f * _maxJumpHeight / Mathf.Pow(_timeToPeak, 2f);
        _fallGravity = -2f * _maxJumpHeight / Mathf.Pow(_timeToDecent, 2f);
            
        _historicalVelocities = [];
        _historicalVelocities.Resize(MaxVelocityHistory);
            
        // Timers
        _coyoteTimer.OneShot = true;
        _coyoteTimer.WaitTime = _coyoteTime;
            
        _jumpBufferTimer.OneShot = true;
        _jumpBufferTimer.WaitTime = _jumpBufferTime;
            
        _historicalVelocityTimer.OneShot = false;
        _historicalVelocityTimer.WaitTime = HistoricalVelocityTimerInterval;
        _historicalVelocityTimer.Timeout += OnHistoricalVelocityTimerOnTimeout;

        _health.Dead += Died;
        _health.Damaged += DamageTaken;
    }
        

    public override void _Process(double delta)
    {
        if (_model != null)
        {
            // Interpolate model rotation with character rotation
            var weight = Mathf.Clamp(_modelRotationSpeed * (float)delta, 0f, 1f);
            _model.GlobalTransform = _model.GlobalTransform.InterpolateWith(GlobalTransform, weight);
        }
    }

    /// <summary>
    /// Apply gravity to the character.
    /// </summary>
    /// <param name="delta"></param>
    public void ApplyGravity(double delta)
    {
        if (IsOnFloor())
        {
            return;
        }
            
        var currentGravity = Velocity.Y < 0f ? _fallGravity : _jumpGravity;
        Velocity += Vector3.Up * currentGravity * (float)delta;
    }

    public void Jump()
    {
        Velocity = Velocity with { Y = _jumpVelocity };
    }

    public void ApplyFriction(double delta)
    {
        var speed = Velocity.Length();
        if (Mathf.IsZeroApprox(speed))
        {
            Velocity = Vector3.Zero;
            return;
        }

        var frictionValue = _friction;
        if (IsNearEdge())
        {
            frictionValue *= MaxEdgeFriction;
        }

        var control = Mathf.Max(speed, _stopSpeed);
        var newSpeed = Mathf.Max(0f, speed - control * frictionValue * (float)delta);
            
        if (speed > 0f)
        {
            newSpeed /= speed;
        }
            
        Velocity *= newSpeed;
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

    public Vector3 ConvertInputDirectionToWorld(Vector2 inputDir)
    {
        return GlobalBasis * new Vector3(inputDir.X, 0f, inputDir.Y);
    }

    private bool TestBodyMotion(Transform3D from, Vector3 motion, PhysicsTestMotionResult3D result)
    {
        result ??= new PhysicsTestMotionResult3D();
        var motionParams = new PhysicsTestMotionParameters3D
        {
            From = from,
            Motion = motion,
            MaxCollisions = 1
        };
        return PhysicsServer3D.BodyTestMotion(GetRid(), motionParams, result);
    }

    public void StepOver()
    {
        var horizontalVelocity = Velocity with { Y = 0f };
        if (Mathf.IsZeroApprox(horizontalVelocity.Length()))
        {
            return;
        }
            
        var direction = horizontalVelocity.Normalized();
        var stepDistance = direction * MaxStepDistance;
        var elevationChange = MaxStepHeight;

        // check if we can step forward
        var testForward = new PhysicsTestMotionResult3D();
        if (!TestBodyMotion(GlobalTransform, stepDistance, testForward))
        {
            return;
        }
            
        // ground normal is sloped, so we can't step up'
        if (testForward.GetCollisionNormal().Y > 0.7f)
        {
            return;
        }
            
        // check if we can step up
        var testUpwards = new PhysicsTestMotionResult3D();
        if (TestBodyMotion(GlobalTransform, Vector3.Up * MaxStepHeight, testUpwards))
        {
            elevationChange = testUpwards.GetTravel().Y;
            if (Mathf.IsZeroApprox(elevationChange))
            {
                return;
            }
        }
            
        // check forward from the raised position
        var raised = GlobalTransform.Translated(Vector3.Up * elevationChange);
        var testForwardRaised = new PhysicsTestMotionResult3D();
        if (TestBodyMotion(raised, stepDistance, testForwardRaised))
        {
            return;
        }

        // check down from the raised position
        var raisedForward = raised.Translated(stepDistance);
        var testDownFromRaisedForward = new PhysicsTestMotionResult3D();
        if (!TestBodyMotion(raisedForward, Vector3.Down * elevationChange, testDownFromRaisedForward))
        {
            return;
        }
            
        // check elevation is within bounds
        var decelerationAmount = testDownFromRaisedForward.GetTravel().Y;
        var totalElevation = elevationChange + decelerationAmount;
        if (totalElevation <= 0f || totalElevation > MaxStepDistance)
        {
            return;
        }
            
        // we can step up
        GlobalPosition = GlobalPosition with { Y = totalElevation };
        Velocity = Velocity with { Y = 0f };
    }
        
        
    private bool IsNearEdge()
    {
        if (!IsOnFloor())
        {
            return false;
        }
            
        var horizontalVelocity = Velocity with { Y = 0f };
        if (Mathf.IsZeroApprox(horizontalVelocity.Length()))
        {
            return false;
        }
            
        _edgeRayCast.ForceRaycastUpdate();
        return _edgeRayCast.IsColliding();
    }


    private void OnHistoricalVelocityTimerOnTimeout()
    {
        if (_historicalVelocities.Count > MaxVelocityHistory)
        {
            _historicalVelocities.RemoveAt(0);
        }

        _historicalVelocities.Add(Velocity);
    }
        
    private void DamageTaken()
    {
        _animation.Stop();
        if (_animation.HasAnimation("takeDamage"))
        {
            _animation.Play("takeDamage");
            _cameraBus.InvokeCameraShake(_cameraShakeIntensity);
        }
    }

    private void Died()
    {
        //TODO: add game over scene
        GD.Print("Game Over");
    }
}