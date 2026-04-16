using Godot;

namespace RoboBlast
{
    public partial class Health : Node
    {
        [Signal] public delegate void DeadEventHandler();
        [Signal] public delegate void DamagedEventHandler();
        [Signal] public delegate void HealthChangedEventHandler(int healthPoints);
        
        [Export] private int _maxHitPoints = 100;
        private int _hitPoints;
    
        public bool IsDead { get; private set; }
        public float HealthRatio => (float)_hitPoints / _maxHitPoints;
        public int HitPoints
        {
            get => _hitPoints;
            set
            {
                value = Mathf.Clamp(value, 0, _maxHitPoints);
                
                if (value < _hitPoints)
                {
                    EmitSignal(SignalName.Damaged);
                }
            
                _hitPoints = value;
                
                if (!IsDead)
                {
                    EmitSignal(SignalName.HealthChanged, _hitPoints);
                }

                if (_hitPoints <= 0)
                {
                    IsDead = true;
                    EmitSignal(SignalName.Dead);
                }
            }
        }

        public override void _Ready()
        {
            _hitPoints = _maxHitPoints;
        }
    }
}