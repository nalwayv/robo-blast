using Godot;
using RoboBlast.scripts.item;
using RoboBlast.scripts.player.components;
using RoboBlast.scripts.player.resourse;

namespace RoboBlast.scripts.player.weapon;


public partial class HitscanWeapon : Node3D, IEquipable, ISwitchable
{
    [ExportGroup("Settings")]
    [Export] private WeaponStrategy _strategy;
    [Export] private float _fireRate = 14f;
    [ExportGroup("Ammo")]
    [Export] private AmmoTypes _ammoType;
    [Export] private AmmoManager _ammoManager;
    [Export] private EnergyManager _energyManager;
    [ExportGroup("Components")]
    [Export] private InputHandler _inputHandler;
    [ExportGroup("Resources")]
    [Export] private CameraBus _cameraBus;
    [Export] private AmmoBus _ammoBus;
    [ExportSubgroup("Camera Shake")]
    [Export] private float _cameraShakeIntensity = 2f;
    
    #region @OnReady
    private Timer _cooldownTimer;
    private RayCast3D _shootRayCast;
    private WeaponDamage _damage;
    private WeaponEffects _effects;
    private WeaponAnimation _animation;
    #endregion
    
    public bool ManualShot { get; set; }
    public int AmmoCount => _ammoManager?.AmmoCount(_ammoType) ?? 0;
    public float EnergyRatio => _energyManager?.EnergyRatio ?? 0;
    public bool IsShooting => _inputHandler.IsShooting;
    public bool CanShoot => _cooldownTimer.IsStopped();
    public EnergyManager EnergyManager => _energyManager;
    public Timer CoolDownTimer => _cooldownTimer;
    public AmmoManager AmmoManager => _ammoManager;
    public AmmoTypes AmmoType => _ammoType;

    
    public override void _Ready()
    {
        _cooldownTimer = GetNode<Timer>("CooldownTimer");
        _shootRayCast = GetNode<RayCast3D>("ShootCast");
        _damage = GetNode<WeaponDamage>("WeaponDamage");
        _effects = GetNode<WeaponEffects>("WeaponEffects");
        _animation = GetNode<WeaponAnimation>("WeaponAnimation");

        _cooldownTimer.WaitTime = 1f / _fireRate;
        
        _inputHandler.FireWeaponPressed += () => ManualShot = true;
        _inputHandler.FireWeaponReleased += () => ManualShot = false;
    }

    public override void _Process(double delta)
    {
        if (_strategy.FireWeapon(this, delta))
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
