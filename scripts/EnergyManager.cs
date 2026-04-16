using Godot;

namespace RoboBlast
{
    public partial class EnergyManager : Node
    {
        [ExportGroup("Settings")]
        [Export] private float _maxEnergy = 10f;
        [Export] private float _energyRegenRate = 1f;
        [Export] private float _energyDrainRate = 20f;
        [Export] private float _rechargeDelay = 0.5f;
    
        [ExportGroup("Resources")]
        [Export] private AmmoBus _ammoBus;
    
        private bool _canRecharge;
        private float _currentEnergy;
        public float EnergyRatio
        {
            get
            {
                var denom = _maxEnergy <= 0 ? 1 : _maxEnergy;
                return _currentEnergy / denom;
            }
        }
    
        private Timer _rechargeTimer;

        public override void _Ready()
        {
            _rechargeTimer = GetNode<Timer>("RechargeTimer");
            _rechargeTimer.OneShot = true;
            _rechargeTimer.WaitTime = _rechargeDelay;
            _rechargeTimer.Timeout += () => _canRecharge = true;
        
            _currentEnergy = _maxEnergy;
        }
    
        public bool ConsumeEnergy(double delta)
        {
            if (_currentEnergy <= 0)
            {
                _rechargeTimer.Stop();
                _canRecharge = false;
                return false;
            }

            _canRecharge = false;
            _rechargeTimer.Stop();
        
            _currentEnergy = Mathf.Max(0f, _currentEnergy - _energyDrainRate * (float)delta);
            _ammoBus.EmitEnergyUpdated(EnergyRatio);
        
            return true;
        }

        public void RechargeEnergy(double delta)
        {
            if (_canRecharge && _currentEnergy < _maxEnergy)
            {
                _currentEnergy = Mathf.Min(_maxEnergy, _currentEnergy + _energyRegenRate * (float)delta);
                _ammoBus.EmitEnergyUpdated(EnergyRatio);
            }
        }
    
        public void StartRechargeTimer()
        {
            if (_rechargeTimer.IsStopped() && !_canRecharge)
            {
                _rechargeTimer.Start();
            }
        }
    }
}
