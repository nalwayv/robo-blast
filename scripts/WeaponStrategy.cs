using Godot;

namespace RoboBlast;

public partial class WeaponStrategy : Resource
{
    [Export] protected AmmoBus AmmoBus;
    
    public virtual bool FireWeapon(HitscanWeapon weapon, double delta)
    {
        return false;
    }

    public virtual void SwitchWeapon(HitscanWeapon weapon)
    {
    }
}