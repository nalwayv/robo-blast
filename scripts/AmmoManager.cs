using Godot;
using Godot.Collections;
namespace RoboBlast
{
    public partial class AmmoManager : Node
    {
        [ExportGroup("Settings")] 
        [Export] private Dictionary<AmmoType, int> _ammoStock = new();
    
        [ExportGroup("Resource")]
        [Export] private AmmoBus _ammoBus;
    
        public override void _Ready()
        {
            // make sure the ammo stock is always positive
            foreach (var (ammo, count) in _ammoStock)
            {
                _ammoStock[ammo] = Mathf.Abs(count);
            }
        }
    
        public void AddAmmo(AmmoType ammo, int count)
        {
            _ammoStock[ammo] += count;
            _ammoBus.EmitAmmoUpdated(ammo, _ammoStock[ammo]);
        }

        public void UseAmmo(AmmoType ammo, int count)
        {
            _ammoStock[ammo] = Mathf.Max(0, _ammoStock[ammo] - count);
            _ammoBus.EmitAmmoUpdated(ammo, _ammoStock[ammo]);
        }

        public int AmmoCount(AmmoType ammo)
        {
            if (_ammoStock.ContainsKey(ammo))
            {
                return _ammoStock[ammo];
            }

            return 0;
        }
    }
}
