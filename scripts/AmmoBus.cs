using Godot;

namespace RoboBlast
{
    public partial class AmmoBus : Resource
    {
        [Signal] public delegate void AmmoUpdatedEventHandler(int ammoCount, bool isCurrentAmmo);
        [Signal] public delegate void EnergyUpdatedEventHandler(float ratio);
        [Signal] public delegate void WeaponSwitchedEventHandler(int ammoCount);
        [Signal] public delegate void EnergySwitchedEventHandler(float ratio);
    
        private AmmoType _currentAmmoType;
    
        public void EmitAmmoUpdated(AmmoType ammo, int ammoCount)
        {
            var isCurrentAmmo = _currentAmmoType == ammo;
            EmitSignal(SignalName.AmmoUpdated, ammoCount, isCurrentAmmo);
        }
    
        public void EmitEnergyUpdated(float energyRatio)
        {
            EmitSignal(SignalName.EnergyUpdated, energyRatio);
        }
    
        public void EmitWeaponSwitched(AmmoType ammo, int ammoCount)
        {
            _currentAmmoType = ammo;
            EmitSignal(SignalName.WeaponSwitched);
        }
    
        public void EmitEnergySwitched(float energyRatio)
        {
            EmitSignal(SignalName.EnergySwitched, energyRatio);   
        }
    }
}