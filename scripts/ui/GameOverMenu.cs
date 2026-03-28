using Godot;

namespace RoboBlast.scripts.ui;

public partial class GameOverMenu : Control
{
    private Button _restartButton;
    private Button _quitButton;

    public override void _Ready()
    {
        _restartButton = GetNode<Button>("RestartButton");
        _quitButton = GetNode<Button>("QuitButton");

        _restartButton.Pressed += OnRestartButtonOnPressed;


        _quitButton.Pressed += OnQuitButtonOnPressed;
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

    public void GameOver()
    {
        Visible = true;
        GetTree().Paused = true;
        Input.MouseMode = Input.MouseModeEnum.Visible;
    }
}
