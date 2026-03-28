using Godot;
using System;

namespace RoboBlast.Player.Components;

public partial class InputHandler : Node
{
    public event Action FireWeaponPressed;
    public event Action FireWeaponReleased;
    public event Action<int> EquipWeapon;
    public event Action EquipNextWeapon;
    public event Action EquipPreviousWeapon;
        
    private Vector2 _direction = Vector2.Zero;
    private bool _isAiming;
    private bool _isShooting;

    public bool IsAiming => _isAiming;
    public bool IsShooting => _isShooting;
    public Vector2 Direction => _direction;
    public bool  IsJumping { get; set; }

    public override void _UnhandledInput(InputEvent @event)
    {
        if (@event.IsActionPressed("fireWeapon"))
        {
            _isShooting = true;
            FireWeaponPressed?.Invoke();
        }

        if (@event.IsActionReleased("fireWeapon"))
        {
            _isShooting = false;
            FireWeaponReleased?.Invoke();
        }

        if (@event.IsActionPressed("equipFirstWeapon"))
        {
            EquipWeapon?.Invoke(0);
        }

        if (@event.IsActionPressed("equipSecondWeapon"))
        {
            EquipWeapon?.Invoke(1);
        }

        if (@event.IsActionPressed("equipNextWeapon"))
        {
            EquipNextWeapon?.Invoke();
        }

        if (@event.IsActionPressed("equipPreviousWeapon"))
        {
            EquipPreviousWeapon?.Invoke();
        }
            
        if (@event.IsActionPressed("jump"))
        {
            IsJumping = true;
        }
    }

    public override void _Process(double delta)
    {
        _direction = Input.GetVector(
            "moveLeft",
            "moveRight",
            "moveForward",
            "moveBackward");
        _isAiming = Input.IsActionPressed("aim");
    }
}