using Godot;
using System;

namespace RoboBlast.Player.Resourse;

public partial class EnergyWeaponStrategy : Resource, IWeaponStrategy
{
    public void FireWeapon(HitscanWeapon weapon, double delta)
    {
        throw new NotImplementedException();
    }

    public void SwitchWeapon(HitscanWeapon weapon)
    {
        throw new NotImplementedException();
    }
}
