
using RoboBlast.scripts.player.weapon;

namespace RoboBlast.scripts.player.resourse;


public partial class AutomaticWeaponStrategy : WeaponStrategy
{
    public override bool FireWeapon(HitscanWeapon weapon, double delta)
    {
        if (weapon.IsShooting && weapon.CanShoot && weapon.AmmoCount > 0)
        {
            weapon.AmmoManager.UseAmmo(weapon.AmmoType,1);
            return true;
        }
        return false;
    }

    public override void SwitchWeapon(HitscanWeapon weapon)
    {
        AmmoBus.InvokeWeaponSwitched(weapon.AmmoType, weapon.AmmoCount);
    }
}
