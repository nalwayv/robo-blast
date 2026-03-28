using Godot;
using RoboBlast.scripts.player.components;

namespace RoboBlast.scripts.player.weapon;


public partial class WeaponManager : Node
{
    [Export] private InputHandler _inputHandler;

    private int _currentEquipped;

    public override void _Ready()
    {
        foreach (var child in GetChildren())
        {
            if (child is IEquipable equipable)
            {
                equipable.Unequip();
            }
        }

        _inputHandler.EquipWeapon += OnInputHandlerOnEquipWeapon;
        _inputHandler.EquipNextWeapon += OnInputHandlerOnEquipNextWeapon;
        _inputHandler.EquipPreviousWeapon += OnInputHandlerOnEquipPreviousWeapon;
    }

    private void OnInputHandlerOnEquipPreviousWeapon()
    {
        OnInputHandlerOnEquipWeapon(Mathf.Wrap(_currentEquipped - 1, 0, GetChildren().Count));
        
    }

    private void OnInputHandlerOnEquipNextWeapon()
    {
        OnInputHandlerOnEquipWeapon(Mathf.Wrap(_currentEquipped + 1, 0, GetChildren().Count));
    }

    private void OnInputHandlerOnEquipWeapon(int idx)
    {
        if (!ValidateEquip(idx)) return;

        var current = GetChild(idx);
        if (current is IEquipable currentEquipable)
        {
            currentEquipable.Unequip();
        }

        _currentEquipped = idx;

        var next = GetChild(_currentEquipped);
        if (next is IEquipable nextEquipable)
        {
            nextEquipable.Equip();
        }

        if (next is ISwitchable switchable)
        {
            switchable.Switched();
        }
    }

    private bool ValidateEquip(int idx)
    {
        return idx >= 0 && idx < GetChildren().Count;
    }
}
