using Godot;

namespace RoboBlast.Player.Resourse;

public partial class WeaponStrategy : Resource
{
    public virtual bool FireWeapon(HitscanWeapon weapon, double delta)
    {}
    
    public virtual void SwitchWeapon(HitscanWeapon weapon)
    {}
}