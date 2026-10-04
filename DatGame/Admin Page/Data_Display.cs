using DATGame;
using Godot;
using Godot.Collections;

public partial class Data_Display : VBoxContainer
{
	private Admin_Centre_Config _conf;

	private Array _currentdata;

	private Label _accountname;
    private Label _accountlocked;
    private CheckButton _lockedtoggle;
    private Label _accountadmin;
    private CheckButton _admintoggle;
    private HBoxContainer _accountbuttons;

	private Label _playername;
	private Label _playerroom;
	private Label _playerhigh;
    private SpinBox _highselect;
	private Label _playerscore;
    private SpinBox _currentselect;
    private HBoxContainer _playerbuttons;

	private Label _roomname;
	private Label _roomtop;
	private Button _roombuttons;

    private bool _editing = false;
    public bool Editing { set => _editing = value; }

    private UserDAO _udao = new UserDAO();
    private PlayerDAO _pdao = new PlayerDAO();

    public override void _Ready()
	{
        base._Ready();

		_conf = GetNode<Admin_Centre_Config>("/root/Main/Admin Centre");
		
		_accountname = GetNode<Label>("Account Edit/Account Panel/Account Info/lblName");
        
        _accountlocked = GetNode<Label>("Account Edit/Account Panel/Account Info/Locked/lblLocked");
        _lockedtoggle = GetNode<CheckButton>("Account Edit/Account Panel/Account Info/Locked/tglLocked");

        _accountadmin = GetNode<Label>("Account Edit/Account Panel/Account Info/Admin/lblAdmin");
        _admintoggle = GetNode<CheckButton>("Account Edit/Account Panel/Account Info/Admin/tglAdmin");

        _accountbuttons = GetNode<HBoxContainer>("Account Edit/Buttons");

        _playername = GetNode<Label>("Player Edit/Player Panel/Player Info/lblName");
        _playerroom = GetNode<Label>("Player Edit/Player Panel/Player Info/lblRoom");
     
        _playerhigh = GetNode<Label>("Player Edit/Player Panel/Player Info/HighScore/lblHigh");
        _highselect = GetNode<SpinBox>("Player Edit/Player Panel/Player Info/HighScore/numHigh");

        _playerscore = GetNode<Label>("Player Edit/Player Panel/Player Info/CurrentScore/lblCurrent");
        _currentselect = GetNode<SpinBox>("Player Edit/Player Panel/Player Info/CurrentScore/numCurrent");

        _playerbuttons = GetNode<HBoxContainer>("Player Edit/Buttons");

        _roomname = GetNode<Label>("Room Edit/Room Panel/Room Info/lblName");
        _roomtop = GetNode<Label>("Room Edit/Room Panel/Room Info/lblTop");
        _roombuttons = GetNode<Button>("Room Edit/btnKill");

		UpdateDisplay();
	}

    public override void _Process(double delta)
    {
        base._Process(delta);
        UpdateDisplay();

        _lockedtoggle.Visible = _editing;
        _admintoggle.Visible = _editing;
        _highselect.Visible = _editing;
        _currentselect.Visible = _editing;

        if (_editing == true)
        {
            switch (_conf.View)
            {
                case 0:
                    _udao.UpdateAccount((string)_currentdata[0], _admintoggle.ButtonPressed, _lockedtoggle.ButtonPressed);
                    break;

                case 1:
                    _pdao.UpdatePlayer((string)_currentdata[0], (int)_currentdata[1], (int)_highselect.Value, (int)_currentselect.Value);
                    break;

                default:
                    break;
            }
        }
    }

    public void _Update_Clicked()
    {
        _editing = !_editing;
    }

	public void UpdateDisplay()
	{
		if (_conf.CurrentSelection.Count < 1)
		{
            _accountname.Visible = false;
            _accountlocked.Visible = false;
            _accountadmin.Visible = false;
            _accountbuttons.Visible = false;
            _playername.Visible = false;
            _playerroom.Visible = false;
            _playerhigh.Visible = false;
            _playerscore.Visible = false;
            _playerbuttons.Visible = false;
            _roomname.Visible = false;
            _roomtop.Visible = false;
            _roombuttons.Visible = false;

            return;
        }
		else
        {
            _accountname.Visible = true;
            _accountlocked.Visible = true;
            _accountadmin.Visible = true;
            _accountbuttons.Visible = true;
            _playername.Visible = true;
            _playerroom.Visible = true;
            _playerhigh.Visible = true;
            _playerscore.Visible = true;
            _playerbuttons.Visible = true;
            _roomname.Visible = true;
            _roomtop.Visible = true;
            _roombuttons.Visible = true;
        }

        // Only update if the selection has changed
        if (_currentdata != _conf.CurrentSelection)
        {
            _currentdata = _conf.CurrentSelection;
            _editing = false;

            switch (_conf.View)
            {
                case 0:
                    UserDAO udao = new UserDAO();

                    Dictionary accountdata = udao.GetAccount((string)_currentdata[0]);

                    _lockedtoggle.ButtonPressed = (bool)accountdata["Locked"];
                    _admintoggle.ButtonPressed = (bool)accountdata["Admin"];

                    break;

                case 1:
                    PlayerDAO pdao = new PlayerDAO();

                    Dictionary playerdata = pdao.GetPlayer((string)_currentdata[0], (int)_currentdata[1]);

                    _highselect.Value = (int)playerdata["HighScore"];
                    _currentselect.Value = (int)playerdata["CurrentScore"];

                    break;

                default:
                    break;
            }
        }

        switch (_conf.View)
        {
            case 0:
                UserDAO udao = new UserDAO();

                Dictionary accountdata = udao.GetAccount((string)_currentdata[0]);

                _accountname.Text = $"Selected Account | {(string)accountdata["Name"]}";
                _accountlocked.Text = $"Account Locked | {(string)accountdata["Locked"]}";
                _accountadmin.Text = $"Administrator | {(string)accountdata["Admin"]}";

                break;

            case 1:
                PlayerDAO pdao = new PlayerDAO();

                Dictionary playerdata = pdao.GetPlayer((string)_currentdata[0], (int)_currentdata[1]);

                _playername.Text = $"Selected Player | {(string)playerdata["AccountName"]}";
                _playerroom.Text = $"Room | {(string)playerdata["RoomName"]}";
                _playerhigh.Text = $"High Score | {(string)playerdata["HighScore"]}";
                _playerscore.Text = $"Current Score | {(string)playerdata["CurrentScore"]}";

                break;

            case 2:
                RoomDAO rdao = new RoomDAO();

                Dictionary roomdata = rdao.GetRoomInfo((int)_currentdata[0]);

                _roomname.Text = $"Selected Room | {(string)roomdata["RoomName"]}";
                _roomtop.Text = $"Top Player | {(string)roomdata["AccountName"]}";

                break;

            default:
                break;
        }
    }

}
