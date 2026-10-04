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

            _list = GetNode<Entry_Select_Filler>("CanvasLayer/Columns/Column 3/Scroll Bar/Name List");

            GetNode<Label>("CanvasLayer/Columns/Column 1/lblAccount").Text = _head.Account;
        }

        public void _Account_View_Clicked()
        {
            _view = 0;

            _playerpane.Visible = false;
            _roompane.Visible = false;

            _accountpane.Visible = true;

            _currentselection = [];

            _list.LoadNames();
        }

        public void _Player_View_Clicked()
        {
            _view = 1;

            _accountpane.Visible = false;
            _roompane.Visible = false;

            _playerpane.Visible = true;

            _currentselection = [];

            _list.LoadNames();
        }

        public void _Room_View_Clicked()
        {
            _view = 2;

            _playerpane.Visible = false;
            _accountpane.Visible = false;

            _roompane.Visible = true;

            _currentselection = [];

            _list.LoadNames();
        }

        public void _Back_Button_Clicked()
        {
            _head.SwitchScene("res://Room Select Page/Room Select.tscn");
        }

    }
}
