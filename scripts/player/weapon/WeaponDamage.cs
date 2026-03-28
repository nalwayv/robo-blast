using Godot;
using RoboBlast.Components;

namespace RoboBlast.Player.Weapon;

public partial class WeaponDamage : Node
{
    [Export] private int _damageAmount = 1;

    public void ApplyDamageToTarget(Node target)
    {
        var health = target.GetNodeOrNull<Health>("Health");
        if (health != null)
        {
            health.HealthPoints -= _damageAmount;
        }
    }
}
