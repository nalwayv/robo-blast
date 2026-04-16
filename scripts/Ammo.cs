using Godot;

namespace RoboBlast
{
    public partial class Ammo : Item
    {
        [Export] private AmmoType _ammoType;
        [Export] private int _ammoCount;

        private protected override void Collected(Node3D body)
        {
            var ammoManager = body.GetNodeOrNull<AmmoManager>("AmmoManager");
            if (ammoManager != null)
                ammoManager.AddAmmo(_ammoType, _ammoCount);
        }
    }
}
