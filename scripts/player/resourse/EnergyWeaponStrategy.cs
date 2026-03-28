using RoboBlast.scripts.player.weapon;

namespace RoboBlast.scripts.player.resourse;


public partial class EnergyWeaponStrategy : WeaponStrategy
{
    public override bool FireWeapon(HitscanWeapon weapon, double delta)
    {
        if (weapon.IsShooting && weapon.CanShoot)
        {
            if (weapon.EnergyManager.ConsumeEnergy(delta))
            {
                weapon.CoolDownTimer.Start();
                return true;
            }
        }
        else
        {
            weapon.EnergyManager.StartRechargeTimer();            
        }
        
        weapon.EnergyManager.RechargeEnergy(delta);
        return false;
    }

    public override void SwitchWeapon(HitscanWeapon weapon)
    {
        AmmoBus.InvokeEnergySwitched(weapon.EnergyRatio);
    }
}
