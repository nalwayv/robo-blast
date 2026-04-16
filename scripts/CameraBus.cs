using Godot;

namespace RoboBlast
{
    public partial class CameraBus : Resource
    {
        [Signal] public delegate void CameraShakeEventHandler(float intensity);

        public void EmitCameraShake(float intensity)
        {
            EmitSignal(SignalName.CameraShake, intensity);
        }
    }
}
