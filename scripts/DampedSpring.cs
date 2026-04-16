using Godot;

namespace RoboBlast
{
    public class DampedSpring
    {
        private const float Epsilon = 0.00001f;

        private float _pp;
        private float _pv;
        private float _vp;
        private float _vv;
        private double _lastDelta;

        private float _frequency = 20f;
        private float _damping = 0.5f;
        
        public float Frequency
        {
            get => _frequency;
            set
            {
                _frequency = value;
                _lastDelta = -1f;
            }
        }
        public float Damping
        {
            get => _damping;
            set
            {
                _damping = value;
                _lastDelta = -1f;
            }
        }
        public Vector3 Position { get; set; } = Vector3.Zero;
        public Vector3 Velocity { get; set; } = Vector3.Zero;
        public Vector3 Target { get; set; } = Vector3.Zero;

        public void Step(double delta)
        {
            if (!Mathf.IsEqualApprox(delta, _lastDelta))
            {
                UpdateCoefficients(delta);
                _lastDelta = delta;
            }
            
            var relPos = Position - Target;
            var newPos = relPos * _pp + Velocity * _pv;
            var newVel = relPos * _vp + Velocity * _vv;
            
            Position = newPos + Target;
            Velocity = newVel;
        }

        private void UpdateCoefficients(double delta)
        {
            var zeta = Mathf.Max(Damping, 0f);
            var omega = Mathf.Max(Frequency, 0f);

            if (omega < Epsilon)
            {
                _pp = 1f;
                _pv = 0f;
                _vp = 0f;
                _vv = 1f;
                return;
            }

            if (zeta > 1f + Epsilon)
            {
                var za = -omega * zeta;
                var zb = omega * Mathf.Sqrt(zeta * zeta - 1f);
                var z1 = za - zb;
                var z2 = za + zb;
                var e1 = Mathf.Exp(z1 * (float)delta);
                var e2 = Mathf.Exp(z2 * (float)delta);
                var inv2Zb = 1f / (2f * zb);

                _pp = (e1 * z2 - e2 * z1) * inv2Zb;
                _pv = (e2 - e1) * inv2Zb;
                _vp = (e1 - e2) * (z1 * z2 * inv2Zb);
                _vv = (e2 * z2 - e1 * z1) * inv2Zb;
            }
            else if (zeta < 1f - Epsilon)
            {
                var omegaZeta = omega * zeta;
                var alpha = omega * Mathf.Sqrt(1f - zeta * zeta);
                var expTerm = Mathf.Exp(-omegaZeta * (float)delta);
                var cosTerm = Mathf.Cos(alpha * (float)delta);
                var sinTerm = Mathf.Sin(alpha * (float)delta);
                var invAlpha = 1f / alpha;

                _pp = expTerm * (cosTerm + omegaZeta * sinTerm * invAlpha);
                _pv = expTerm * (sinTerm * invAlpha);
                _vp = -expTerm * (sinTerm * alpha + omegaZeta * omegaZeta * sinTerm * invAlpha);
                _vv = expTerm * (cosTerm - omegaZeta * sinTerm * invAlpha);
            }
            else
            {
                var expTerm = Mathf.Exp(-omega * (float)delta);
                _pp = expTerm * (1f + omega * (float)delta);
                _pv = expTerm * (float)delta;
                _vp = expTerm * (-omega * omega * (float)delta);
                _vv = expTerm * (1f - omega * (float)delta);
            }
        }
    }
}