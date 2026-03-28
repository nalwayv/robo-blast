using Godot;
using Godot.Collections;
using RoboBlast.scripts.item;
using RoboBlast.scripts.player.resourse;

namespace RoboBlast.scripts.player.weapon;

public partial class AmmoManager : Node
{
    [ExportGroup("Settings")] 
    [Export] private Dictionary<AmmoTypes, int> _ammoStorage = [];
    [ExportGroup("Resource")]
    [Export] private AmmoBus _ammoBus;
    
    public override void _Ready()
    {
        // make sure the ammo stock is always positive
        foreach (var (ammo, count) in _ammoStorage)
        {
            _ammoStorage[ammo] = Mathf.Abs(count);
        }
    }
    
    public void AddAmmo(AmmoTypes ammo, int count)
    {
        _ammoStorage[ammo] += count;
        _ammoBus.InvokeAmmoChanged(ammo, _ammoStorage[ammo]);
    }

    public void UseAmmo(AmmoTypes ammo, int count)
    {
        // prevent negative ammo stock
        _ammoStorage[ammo] = Mathf.Max(0, _ammoStorage[ammo] - count);
        _ammoBus.InvokeAmmoChanged(ammo, _ammoStorage[ammo]);
    }

    public int AmmoCount(AmmoTypes ammo)
    {
        if (_ammoStorage.ContainsKey(ammo))
        {
            return _ammoStorage[ammo];
        }
        return 0;
    }
}
