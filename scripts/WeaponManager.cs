using Godot;

namespace RoboBlast
{
    public partial class WeaponManager : Node
    {
        [Export] private InputHandler _inputHandler;

        private int _current;

        public override void _Ready()
        {
            foreach (var child in GetChildren())
            {
                if (child is IEquipable equipable)
                {
                    equipable.Unequip();
                }
            }

            OnEquipWeapon(_current);

            _inputHandler.EquipPressed += OnEquipWeapon;
            _inputHandler.EquipNextPressed += OnEquipNext;
            _inputHandler.EquipPreviousPressed += OnEquipPrevious;
        }
    
        private bool ValidateIndex(int idx)
        {
            return idx >= 0 && idx < GetChildCount();
        }

        private void OnEquipWeapon(int idx)
        {
            if (!ValidateIndex(idx)) 
                return;
        
            var oldWeapon = GetChild(_current);
            if (oldWeapon is IEquipable oldEquipable)
            {
                oldEquipable.Unequip();
            }
        
            _current = idx;
        
            var newWeapon = GetChild(_current);
            if (newWeapon is IEquipable newEquipable)
            {
                newEquipable.Equip();
                newEquipable.Switch();
            }
        }

        private void OnEquipPrevious()
        {
            OnEquipWeapon(Mathf.Wrap(_current - 1, 0, GetChildCount()));
        }
    
        private void OnEquipNext()
        {
            OnEquipWeapon(Mathf.Wrap(_current + 1, 0, GetChildCount()));
        }
    }
}
