using Godot;

namespace RoboBlast.Item;

public partial class AmmoItem : Item
{
    [ExportGroup("Ammo Settings")]
    [Export] private AmmoTypes _ammoType = AmmoTypes.Default;
    [Export] private int _ammoCount = 1;
    
    public override void Collected(Node3D body)
    {
        // TODO: Add ammo manager
        var ammoManager = body.GetNodeOrNull<AmmoManager>("AmmoManager");
        if (ammoManager != null)
        {
            ammoManager.AddAmmo(_ammoType, _ammoCount);
        }
    }
}
