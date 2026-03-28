using Godot;
using RoboBlast.Player.Weapon;

namespace RoboBlast.Player.Resourse;

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