using Godot;
using RoboBlast.scripts.components;
using RoboBlast.scripts.player;

namespace RoboBlast.scripts.enemy;

public partial class Enemy : CharacterBody3D
{
    private const float MaxTurnAngle = 60f;
    
    [ExportGroup("Movement")]
    [Export] private float _maxSpeed = 2.5f;
    [Export] private float _stopSpeed = 2f;
    [Export] private float _acceleration = 10f;
    [Export] private float _friction = 6f;
    [Export] private float _maxTurnSpeed = 15f;
    [Export] private float _minTurnSpeed = 5f;
    [ExportGroup("Detection")]
    [Export] private float _detectionRadius = 5f;
    [Export] private float _detectionAngle = 90f;
    [ExportGroup("Attack")]
    [Export] private float _attackRange = 2f;
    [Export] private int _attackDamage = 20;

    private float _directionWight = 10f;
    private bool _provoked;
    private float _movementPredictionThreshold = 0.33f;
    private float _movementPredictionTime = 1f;
    private Vector3 _currentDirection = Vector3.Forward;
    
    private Health _health;
    private NavigationAgent3D _navigationAgent;
    private AnimationPlayer _animationPlayer;
    private PlayerController _playerController;

    public override void _Ready()
    {
        AddToGroup("enemy");
        
        _health = GetNode<Health>("Health");
        _playerController = GetTree().GetFirstNodeInGroup("player") as PlayerController;
        _navigationAgent = GetNode<NavigationAgent3D>("NavigationAgent");
        _animationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");

        _health.Dead += QueueFree;
    }

    public override void _Process(double delta)
    {
        UpdatePredictionTarget();
    }

    public override void _PhysicsProcess(double delta)
    {
        ApplyGravity(delta);

        if (_provoked)
        {
            var nextPathPosition = _navigationAgent.GetNextPathPosition();
            var directionToNextPathPosition = GlobalPosition.DirectionTo(nextPathPosition);
            
            _currentDirection = _currentDirection.Lerp(
                directionToNextPathPosition, 
                _directionWight * (float)delta);
            var wishDir = (_currentDirection with { Y = 0 }).Normalized();
            
            ApplyFriction(delta);
            ApplyAcceleration(wishDir, _maxSpeed, delta);
            ApplyRotation(directionToNextPathPosition, delta);
        }
        else
        {
            ApplyFriction(delta);
        }

        MoveAndSlide();
        
        CheckPlayerProximity();
        PerformAttack();
    }

    private void ApplyRotation(Vector3 direction, double delta)
    {
        var yaw = Mathf.Atan2(-direction.X, -direction.Z);
        var diff = Mathf.AngleDifference(Rotation.Y, yaw);
        var turnSpeed = Mathf.Abs(diff) > Mathf.DegToRad(MaxTurnAngle) ? _maxTurnSpeed : _minTurnSpeed;
        Rotation = Rotation with
        {
            Y = Mathf.LerpAngle(Rotation.Y, yaw, turnSpeed * (float)delta)
        };
    }

    private void ApplyGravity(double delta)
    {
        if (IsOnFloor())
        {
            return;
        }
        Velocity += GetGravity() * (float)delta;
    }

    private void CheckPlayerProximity()
    {
        if (GlobalPosition.DistanceTo(_playerController.GlobalPosition) <= _detectionRadius)
        {
            if (IsPlayerWithinFov())
            {
                _provoked = true;
            }
        }
    }

    private bool IsPlayerWithinFov()
    {
        var forward = -GlobalBasis.Z;
        var halfFov = Mathf.DegToRad(_detectionAngle * 0.5f);
        var directionToPlayer = GlobalPosition.DirectionTo(_playerController.GlobalPosition);
        return forward.Dot(directionToPlayer) > Mathf.Cos(halfFov);
    }

    private void PerformAttack()
    {
        if (_provoked && GlobalPosition.DistanceTo(_playerController.GlobalPosition) <= _attackRange)
        {
            _animationPlayer.Play("attack");
        }
    }
    
    private void UpdatePredictionTarget()
    {
        if (!_provoked)
        {
            return;
        }

        var timeToPlayer = Mathf.Min(GlobalPosition.DistanceTo(_playerController.GlobalPosition) / Mathf.Max(1f, _maxSpeed), 1f);
        var targetPrediction = _playerController.GlobalPosition + _playerController.AverageVelocity * timeToPlayer;
        var directionToTarget = GlobalPosition.DirectionTo(targetPrediction);
        var directionToPlayer = GlobalPosition.DirectionTo(_playerController.GlobalPosition);

        if (directionToPlayer.Dot(directionToTarget) < _movementPredictionThreshold)
        {
            targetPrediction = _playerController.GlobalPosition;
        }
        
        _navigationAgent.TargetPosition = targetPrediction;
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
        {
            newSpeed /= speed;
        }
        Velocity *= newSpeed;
    }


    private void ApplyAcceleration(Vector3 wishDir, float wishSpeed, double delta)
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

    // called by the animation player
    private void Attack()
    {
        var health = _playerController.GetNodeOrNull<Health>("Health");
        if (health != null)
        {
            health.HealthPoints -= _attackDamage;
        }
    }
}
