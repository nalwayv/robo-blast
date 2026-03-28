using Godot;
using System;


namespace RoboBlast.Components;

public partial class Health : Node
{
    public event Action<int> HealthChanged;
    public event Action Damaged;
    public event Action Dead;
        
    [Export] private int _maxHealthPoints = 100;
        
    private int _healthPointsPoints;
    private bool _dead;

    public float HealthPercentage => (float)_healthPointsPoints / _maxHealthPoints;
    public bool IsDead => _dead;
    public int HealthPoints
    {
        get => _healthPointsPoints;
        set
        {
            var clampedValue = Mathf.Clamp(value, 0, _maxHealthPoints);
                
            if (clampedValue < _healthPointsPoints)
            {
                Damaged?.Invoke();
            }
                
            _healthPointsPoints = clampedValue;
                
            if (!_dead)
            {
                HealthChanged?.Invoke(_healthPointsPoints);
            }

            if (_healthPointsPoints <= 0)
            {
                _dead = true;
                Dead?.Invoke();
            }
        }
    }

    public override void _Ready()
    {
        _healthPointsPoints = _maxHealthPoints;
    }
}