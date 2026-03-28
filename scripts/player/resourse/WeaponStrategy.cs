using Godot;
using RoboBlast.scripts.player.weapon;

namespace RoboBlast.scripts.player.resourse;

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