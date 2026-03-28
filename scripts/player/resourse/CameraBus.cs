using Godot;
using System;

namespace RoboBlast.scripts.player.resourse;


public partial class CameraBus : Resource
{
    public event Action<float> OnCameraShake;

    public void InvokeCameraShake(float intensity)
    {
        OnCameraShake?.Invoke(intensity);
    }
}
