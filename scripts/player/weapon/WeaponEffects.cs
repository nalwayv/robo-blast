using Godot;

namespace RoboBlast.scripts.player.weapon;


public partial class WeaponEffects : Node
{
    [Export] private PackedScene _sparksScene;
    [Export] private GpuParticles3D _muzzleParticles;
    
    public void AddHitEffect(Vector3 globalPosition)
    {
        var sparks = _sparksScene.Instantiate<GpuParticles3D>();
        if (sparks != null)
        {
            GetTree().CurrentScene.AddChild(sparks);
            sparks.GlobalPosition = globalPosition;
        }
        _muzzleParticles.Emitting = true;
    }

    public void EmmitMuzzleFlash()
    {
        _muzzleParticles.Restart();
    }
}
