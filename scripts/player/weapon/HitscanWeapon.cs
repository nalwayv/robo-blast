using Godot;
using System;
using RoboBlast.Item;
using RoboBlast.Player.Components;
using RoboBlast.Player.Resourse;

namespace RoboBlast.Player.Weapon;

public partial class HitscanWeapon : Node3D, IEquipable, ISwitchable
{
    [ExportGroup("Settings")]
    [Export] private WeaponStrategy _strategy;
    [Export] private float _fireRate = 14f;
    [ExportGroup("Ammo")]
    [Export] private AmmoTypes _ammoType;
    [Export] private AmmoManager _ammoManager;
    [ExportGroup("Components")]
    [Export] private InputHandler _inputHandler;
    [ExportGroup("Resources")]
    [Export] private CameraBus _cameraBus;
    [Export] private AmmoBus _ammoBus;
    [ExportSubgroup("Camera Shake")]
    [Export] private float _cameraShakeIntensity = 2f;

    // private Vector3 _modelOrigin;
    private bool _isShooting;
    
    private Timer _cooldownTimer;
    private Node3D _model;
    private GpuParticles3D _muzzleFlash;
    private RayCast3D _shootRayCast;
    private WeaponDamage _damage;
    private WeaponEffects _effects;
    private WeaponAnimation _animation;

    public int AmmoCount => _ammoManager?.AmmoCount(_ammoType) ?? 0;

    public override void _Ready()
    {
        _cooldownTimer = GetNode<Timer>("CooldownTimer");
        _model = GetNode<Node3D>("Model");
        _muzzleFlash = GetNode<GpuParticles3D>("MuzzleFlash");
        _shootRayCast = GetNode<RayCast3D>("ShootCast");
        _damage = GetNode<WeaponDamage>("WeaponDamage");
        _effects = GetNode<WeaponEffects>("WeaponEffects");
        _animation = GetNode<WeaponAnimation>("WeaponAnimation");

        _cooldownTimer.WaitTime = 1f / _fireRate;
        // _modelOrigin = _model.Position;
        
        _inputHandler.FireWeaponPressed += () => _isShooting = true;
        _inputHandler.FireWeaponReleased += () => _isShooting = false;
    }

    public override void _Process(double delta)
    {
        var shotFired = _strategy.FireWeapon(this, delta);
        if (shotFired)
        {
            _shootRayCast.ForceRaycastUpdate();
            _cooldownTimer.Start();
            _cameraBus.InvokeCameraShake(_cameraShakeIntensity);
            
            _effects.EmmitMuzzleFlash();
            _animation.Recoil();
            
            if (_shootRayCast.IsColliding())
            {
                _damage.ApplyDamageToTarget((Node)_shootRayCast.GetCollider());
                _effects.AddHitEffect(_shootRayCast.GetCollisionPoint());
            }
        }
    }

    public void Equip()
    {
        Visible = false;
        SetProcess(false);
    }

    public void Unequip()
    {
        Visible = true;
        SetProcess(true);
    }

    public void Switched()
    {
        _strategy.SwitchWeapon(this);
    }
}
