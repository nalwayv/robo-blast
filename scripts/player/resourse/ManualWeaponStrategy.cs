using RoboBlast.Player.Weapon;

namespace RoboBlast.Player.Resourse;

public partial class ManualWeaponStrategy : WeaponStrategy
{
    public override bool FireWeapon(HitscanWeapon weapon, double delta)
    {
        if (weapon.CanShoot && weapon.IsShooting && weapon.AmmoCount > 0 && weapon.ManualShot)
        {
            weapon.ManualShot = false;
            weapon.AmmoManager.UseAmmo(weapon.AmmoType, 1);
            return true;
        }
        
        return false;
    }

    public override void SwitchWeapon(HitscanWeapon weapon)
    {
        AmmoBus.InvokeWeaponSwitched(weapon.AmmoType, weapon.AmmoCount);
    }
}
