using Godot;

namespace RoboBlast
{
    public partial class GameOverMenu : Control
    {
        private Button _restartButton;
        private Button _quitButton;

        public override void _Ready()
        {
            _restartButton = GetNode<Button>("RestartButton");
            _restartButton.Pressed += OnRestartButtonOnPressed;
        
            _quitButton = GetNode<Button>("QuitButton");
            _quitButton.Pressed += OnQuitButtonOnPressed;
        }
    
        public void GameOver()
        {
            Visible = true;
            GetTree().Paused = true;
            Input.MouseMode = Input.MouseModeEnum.Visible;
        }

        private void OnRestartButtonOnPressed()
        {
            GetTree().Paused = false;
            GetTree().ReloadCurrentScene();
        }
    
        private void OnQuitButtonOnPressed()
        {
            GetTree().Quit();
        }
    }
}
