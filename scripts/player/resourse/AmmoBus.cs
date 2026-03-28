using Godot;
using System;
using RoboBlast.Item;

namespace RoboBlast.Player.Resourse;

public partial class AmmoBus : Resource
{
    public event Action<int, bool> AmmoChanged;
    public event Action<float> EnergyChanged;
    public event Action<int> AmmoTypeSwitched;
    public event Action<float> EnergySwitched;
    
    private AmmoTypes _currentAmmoType = AmmoTypes.Default;
    
    public void InvokeAmmoChanged(AmmoTypes ammo, int ammoCount)
    {
        var isCurrentAmmo = _currentAmmoType == ammo;
        AmmoChanged?.Invoke(ammoCount, isCurrentAmmo);
    }
    
    public void InvokeEnergyChanged(float energyPercent)
    {
        EnergyChanged?.Invoke(energyPercent);
    }
    
    public void InvokeAmmoSwitched(AmmoTypes ammo, int ammoCount)
    {
        _currentAmmoType = ammo;
        AmmoTypeSwitched?.Invoke(ammoCount);
    }
    
    public void InvokeEnergySwitched(float energyPercent)
    {
        EnergySwitched?.Invoke(energyPercent);
    }
}
