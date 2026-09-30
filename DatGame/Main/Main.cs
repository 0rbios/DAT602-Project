using Godot;

public partial class Main : Node
{
	private string _account;
    public string Account { get => _account; set => _account = value; }

    public override void _Ready()
	{
		SwitchScene("res://Login Page/Login.tscn");
    }

	public void SwitchScene(string scenepath)
	{
		foreach (Node child in GetChildren()){
			child.QueueFree();
		}

		try
        {
            Node switchscene = GD.Load<PackedScene>(scenepath).Instantiate();
            AddChild(switchscene);
        }
		catch
		{
			GD.Print("Scene Switch Failed");
		}
    }
}
