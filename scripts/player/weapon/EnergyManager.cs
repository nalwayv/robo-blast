using Godot;
using RoboBlast.scripts.player.resourse;

namespace RoboBlast.scripts.player.weapon;


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
    
    #region @OnReady
    private Timer _rechargeTimer;
    #endregion
    
    public float EnergyRatio
    {
        get
        {
            var denom = _maxEnergy > 0 ? _maxEnergy : 1;
            return _currentEnergy / denom;
        }
    }

    public override void _Ready()
    {
        _rechargeTimer = GetNode<Timer>("RechargeTimer");
        _rechargeTimer.WaitTime = _rechargeDelay;
        _rechargeTimer.OneShot = true;
        _rechargeTimer.Timeout += () => _canRecharge = true;
    }
    
    public bool ConsumeEnergy(double delta)
    {
        if (_currentEnergy <= 0)
        {
            _rechargeTimer.Stop();
            _canRecharge = false;
            return false;
        }

        _canRecharge = true;
        _rechargeTimer.Start();
        
        _currentEnergy = Mathf.Max(0f, _currentEnergy - _energyDrainRate * (float)delta);
        _ammoBus.InvokeEnergyChanged(EnergyRatio);
        
        return true;
    }

    public void RechargeEnergy(double delta)
    {
        if (!_canRecharge || !(_currentEnergy < _maxEnergy))
        {
            return;
        }
        
        _currentEnergy = Mathf.Min(_maxEnergy, _currentEnergy + _energyRegenRate * (float)delta);
        _ammoBus.InvokeEnergyChanged(EnergyRatio);
    }
    
    
    public void StartRechargeTimer()
    {
        if (!_rechargeTimer.IsStopped() || _canRecharge)
        {
            return;
        }
        
        _rechargeTimer.Start();
    }
}
