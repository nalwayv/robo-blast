using Godot;

namespace RoboBlast
{
    public partial class HitscanWeapon : Node3D, IEquipable
    {
        [ExportGroup("Settings")]
        [Export] private WeaponStrategy _strategy;
        [Export] private float _fireRate = 14f;
    
        [ExportGroup("Ammo")]
        [Export] private AmmoType _ammoType;
        [Export] private AmmoManager _ammoManager;
        [Export] private EnergyManager _energyManager;
    
        [ExportGroup("Component")]
        [Export] private InputHandler _inputHandler;
    
        [ExportGroup("Resource")]
        [Export] private CameraBus _cameraBus;
        [Export] private AmmoBus _ammoBus;
    
        [ExportSubgroup("Camera Shake")]
        [Export] private float _cameraShakeIntensity = 2f;
    
        public bool OneShot { get; set; }
        public bool IsShooting { get; private set; }
        public int AmmoCount => _ammoManager?.AmmoCount(_ammoType) ?? 0;
        public float EnergyRatio => _energyManager?.EnergyRatio ?? 0;
        public bool CanShoot => _cooldownTimer.IsStopped();
    
        public Timer CoolDownTimer => _cooldownTimer;
        public EnergyManager EnergyManager => _energyManager;
        public AmmoManager AmmoManager => _ammoManager;
        public AmmoType AmmoType => _ammoType;
    
        private Timer _cooldownTimer;
        private RayCast3D _shootRayCast;
        private WeaponDamage _damage;
        private WeaponAnimation _animation;
        private WeaponEffects _effects;
        // private Node3D _model;
    
        public override void _Ready()
        {
            _cooldownTimer = GetNode<Timer>("CooldownTimer");
            _shootRayCast = GetNode<RayCast3D>("ShootCast");
            _damage = GetNode<WeaponDamage>("WeaponDamage");
            _effects = GetNode<WeaponEffects>("WeaponEffects");
            _animation = GetNode<WeaponAnimation>("WeaponAnimation");

            _cooldownTimer.WaitTime = 1f / _fireRate;
            _inputHandler.ShootPressed += () => {
                IsShooting = true;
                OneShot = true;
            };
            _inputHandler.ShootReleased += () => {
                IsShooting = false;
                OneShot = false;
            };
        }

        public override void _Process(double delta)
        {
            if (_strategy.FireWeapon(this, delta))
            {
                _shootRayCast.ForceRaycastUpdate();
                _cooldownTimer.Start();
                _cameraBus.EmitCameraShake(_cameraShakeIntensity);
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

        public void Switch()
        {
            _strategy.SwitchWeapon(this);
        }
    }
}
