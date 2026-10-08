using Godot;

public partial class Main : Node
{
	private string _account;
	private int _roomID;
	private string _roomName;

	private bool _canmove = true;

	public string Account { get => _account; set => _account = value; }
    public int Room { get => _roomID; set => _roomID = value; }
    public string RoomName { get => _roomName; set => _roomName = value; }
    public bool Canmove { get => _canmove; set => _canmove = value; }

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
