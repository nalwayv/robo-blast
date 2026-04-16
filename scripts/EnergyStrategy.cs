namespace RoboBlast
{
    public partial class EnergyStrategy : WeaponStrategy
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
                weapon.EnergyManager.StartRechargeTimer();            
        
            weapon.EnergyManager.RechargeEnergy(delta);
            return false;
        }

        public override void SwitchWeapon(HitscanWeapon weapon)
        {
            AmmoBus.EmitEnergySwitched(weapon.EnergyRatio);
        }
    }
}
