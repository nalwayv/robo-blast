
namespace RoboBlast
{
    public partial class AutomaticStrategy : WeaponStrategy
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
            AmmoBus.EmitWeaponSwitched(weapon.AmmoType, weapon.AmmoCount);
        }
    }
}
