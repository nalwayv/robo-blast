using Godot;

namespace RoboBlast
{
    /// <summary>
    /// Component that handles player input using the InputMap and signals.
    /// </summary>
    public partial class InputHandler : Node
    {
        [Signal] public delegate void ShootPressedEventHandler();
        [Signal] public delegate void ShootReleasedEventHandler();
        [Signal] public delegate void EquipPressedEventHandler(int index);
        [Signal] public delegate void EquipNextPressedEventHandler();
        [Signal] public delegate void EquipPreviousPressedEventHandler();
        [Signal] public delegate void JumpPressedEventHandler();
        [Signal] public delegate void AimPressedEventHandler();
        [Signal] public delegate void AimReleasedEventHandler();

        public Vector2 Move { get; private set; } = Vector2.Zero;

        public override void _UnhandledInput(InputEvent @event)
        {
            if (@event.IsActionPressed("fireWeapon"))
                EmitSignal(SignalName.ShootPressed);

            if (@event.IsActionReleased("fireWeapon"))
                EmitSignal(SignalName.ShootReleased);

            if (@event.IsActionPressed("equipFirstWeapon"))
                EmitSignal(SignalName.EquipPressed, 0);

            if (@event.IsActionPressed("equipSecondWeapon"))
                EmitSignal(SignalName.EquipPressed, 1);

            if (@event.IsActionPressed("equipNextWeapon"))
                EmitSignal(SignalName.EquipNextPressed);

            if (@event.IsActionPressed("equipPreviousWeapon"))
                EmitSignal(SignalName.EquipPreviousPressed);
            
            if (@event.IsActionPressed("jump"))
                EmitSignal(SignalName.JumpPressed);

            if (@event.IsActionPressed("aim"))
                EmitSignal(SignalName.AimPressed);

            if (@event.IsActionReleased("aim"))
                EmitSignal(SignalName.AimReleased);
        }

        public override void _Process(double delta)
        {
            Move = Input.GetVector(
                "moveLeft",
                "moveRight",
                "moveForward",
                "moveBackward");
        }
    }
}