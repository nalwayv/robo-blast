using Godot;

namespace RoboBlast
{
    public partial class AmmoPresenter : Node
    {
        [Export] private Label _ammoLabel;
        [Export] private AmmoBus _ammoBus;

        public override void _Ready()
        {
            _ammoBus.AmmoUpdated += OnAmmoUpdated;
            _ammoBus.EnergyUpdated += OnEnergyUpdated;
            _ammoBus.WeaponSwitched += OnWeaponSwitched;
            _ammoBus.EnergySwitched += OnEnergySwitched;
        }

        private void OnAmmoUpdated(int ammoCount, bool isActive)
        {
            if (!isActive)
                return;
        
            _ammoLabel.Text = ammoCount.ToString();
        }
    
        private void OnEnergyUpdated(float ratio)
        {
            _ammoLabel.Text = $"{(ratio * 100f):.0f}";
        }

        private void OnWeaponSwitched(int ammoCount)
        {
            _ammoLabel.Text = ammoCount.ToString();
        }

        private void OnEnergySwitched(float ratio)
        {
            _ammoLabel.Text = $"{(ratio * 100f):.0f}";
        }
    }
}
