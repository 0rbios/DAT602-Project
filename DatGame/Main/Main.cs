using Godot;

public partial class Main : Node
{
	private string _account;
	private int _roomID;
	private string _roomName;

	private bool _canmove = true;

	private int ? _swapitemid1 = null;
	private int ? _swapitemid2 = null;
	private bool _itemselected = false;
	
	private int? _combatant = null;

	public string Account { get => _account; set => _account = value; }
    public int Room { get => _roomID; set => _roomID = value; }
    public string RoomName { get => _roomName; set => _roomName = value; }
    public bool Canmove { get => _canmove; set => _canmove = value; }
	public int? Swapitemid2 { get => _swapitemid2; set => _swapitemid2 = value; }
    public int? Swapitemid1 { get => _swapitemid1; set => _swapitemid1 = value; }
    public bool Itemselected { get => _itemselected; set => _itemselected = value; }
    public int? Combatant { get => _combatant; set => _combatant = value; }

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
