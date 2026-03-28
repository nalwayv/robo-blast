using Godot;
using RoboBlast.scripts.player.resourse;

namespace RoboBlast.scripts.player.weapon;


public partial class AmmoPresenter : Node
{
    [Export] private Label _ammoLabel;
    [ExportGroup("Resource")]
    [Export] private AmmoBus _ammoBus;

    public override void _Ready()
    {
        _ammoBus.AmmoChanged += OnAmmoBusOnAmmoChanged;
        _ammoBus.EnergyChanged += OnAmmoBusOnEnergyChanged;
        _ammoBus.WeaponSwitched += OnAmmoBusOnWeaponSwitched;
        _ammoBus.EnergySwitched += OnAmmoBusOnEnergySwitched;
    }

    private void OnAmmoBusOnEnergySwitched(float ratio)
    {
        var percent = ratio * 100f;
        _ammoLabel.Text = $"{percent:.0f}";
    }

    private void OnAmmoBusOnWeaponSwitched(int ammoCount)
    {
        _ammoLabel.Text = ammoCount.ToString();
    }

    private void OnAmmoBusOnEnergyChanged(float ratio)
    {
        var percent = ratio * 100f;
        _ammoLabel.Text = $"{percent:.0f}";
    }

    private void OnAmmoBusOnAmmoChanged(int ammoCount, bool isActive)
    {
        if (!isActive)
        {
            return;
        }
        _ammoLabel.Text = ammoCount.ToString();
    }
}
