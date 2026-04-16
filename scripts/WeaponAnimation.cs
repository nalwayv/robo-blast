using Godot;

namespace RoboBlast
{
    public partial class WeaponAnimation : Node
    {
        private const float Buffer = 0.99f;
        private const float RecoilLengthLimit = 0.2f;
    
        [Export] private Node3D _model;
        [Export] private float _recoilForce = 0.1f;
        [Export] private float _recoilSharpness = 50f;
        [Export] private float _recoilRest = 10f;
    
        private Vector3 _modelOriginalPosition;
        private Vector3 _accumulateRecoil = Vector3.Zero;

        public override void _Ready()
        {
            _modelOriginalPosition = _model.Position;
        }

        public override void _Process(double delta)
        {
            if (_model.Position.Z <= _accumulateRecoil.Z * Buffer)
            {
                _model.Position = _model.Position.Lerp(_accumulateRecoil, _recoilSharpness * (float)delta);
            }
            else
            {
                _model.Position = _model.Position.Lerp(_modelOriginalPosition, _recoilRest * (float)delta);
                _accumulateRecoil = _model.Position;
            }
        }

        public void Recoil()
        {
            _accumulateRecoil += Vector3.Back * _recoilForce;
            _accumulateRecoil = _accumulateRecoil.LimitLength(RecoilLengthLimit);
        }
    }
}
