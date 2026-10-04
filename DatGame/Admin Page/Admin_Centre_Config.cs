using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Admin_Centre_Config : Control
    {
        private Main _head;
        private VBoxContainer _playerpane;
        private VBoxContainer _accountpane;
        private VBoxContainer _roompane;
        private VBoxContainer _deletepane;
        private Entry_Select_Filler _list;

        private int _view = 0;
        private Array _currentselection = [];

        public int View { get => _view; }
        public Array CurrentSelection { get => _currentselection; set => _currentselection = value; }

        public override void _Ready()
        {
            _head = GetNode<Main>("/root/Main");
            
            _playerpane = GetNode<VBoxContainer>("CanvasLayer/Columns/Column 2/Player Edit");
            _accountpane = GetNode<VBoxContainer>("CanvasLayer/Columns/Column 2/Account Edit");
            _roompane = GetNode<VBoxContainer>("CanvasLayer/Columns/Column 2/Room Edit");
            _deletepane = GetNode<VBoxContainer>("CanvasLayer/Columns/Column 2/Delete Confirm");

            _list = GetNode<Entry_Select_Filler>("CanvasLayer/Columns/Column 3/Scroll Bar/Name List");

            GetNode<Label>("CanvasLayer/Columns/Column 1/lblAccount").Text = _head.Account;
        }

        public void _Delete_Clicked()
        {
            _deletepane.Visible = true;
        }

        public void _Cancel_Clicked()
        {
            _deletepane.Visible = false;
        }

        public void _Confirm_Delete_Clicked()
        {
            switch (_view)
            {
                case 0:
                    UserDAO udao = new UserDAO();

                    udao.DeleteAccount((string)_currentselection[0]);

                    if (_head.Account == (string)_currentselection[0])
                    {
                        _head.SwitchScene("res://Login Page/Login.tscn");
                    }

                    break;

                case 1:
                    PlayerDAO pdao = new PlayerDAO();

                    pdao.DeletePlayer((string)_currentselection[0], (int)_currentselection[1]);

                    break;

                case 2:
                    RoomDAO rdao = new RoomDAO();

                    rdao.KillRoom((int)_currentselection[0]);

                    break;

                default:
                    break;
            }

            _currentselection = [];
            _deletepane.Visible = false;
        }

        public void _Account_View_Clicked()
        {
            _view = 0;

            _playerpane.Visible = false;
            _roompane.Visible = false;
            _deletepane.Visible = false;

            _accountpane.Visible = true;

            _currentselection = [];

            GetNode<Data_Display>("CanvasLayer/Columns/Column 2").Editing = false;

            _list.LoadNames();
        }

        public void _Player_View_Clicked()
        {
            _view = 1;

            _accountpane.Visible = false;
            _roompane.Visible = false;
            _deletepane.Visible = false;

            _playerpane.Visible = true;

            _currentselection = [];

            GetNode<Data_Display>("CanvasLayer/Columns/Column 2").Editing = false;

            _list.LoadNames();
        }

        public void _Room_View_Clicked()
        {
            _view = 2;

            _playerpane.Visible = false;
            _accountpane.Visible = false;
            _deletepane.Visible = false;

            _roompane.Visible = true;

            _currentselection = [];

            GetNode<Data_Display>("CanvasLayer/Columns/Column 2").Editing = false;

            _list.LoadNames();
        }

        public void _Back_Button_Clicked()
        {
            _head.SwitchScene("res://Room Select Page/Room Select.tscn");
        }

    }
}
