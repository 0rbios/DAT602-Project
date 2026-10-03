using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Room_Box_Controls : Panel
    {
        private Main _head;
        private VBoxContainer _infopanel;
        private VBoxContainer _creationpanel;
        private VBoxContainer _killpanel;
        private VBoxContainer _replacepanel;

        public override void _Ready()
        {
            base._Ready();

            _head = GetNode<Main>("/root/Main");

            _infopanel = GetNode<VBoxContainer>("RoomInfo");
            _creationpanel = GetNode<VBoxContainer>("RoomCreation");
            _killpanel = GetNode<VBoxContainer>("RoomKill");
            _replacepanel = GetNode<VBoxContainer>("RoomReplace");
        }

        public void _Join_Room_Clicked()
        {
            _head.SwitchScene("res://Class Select Page/Class Select.tscn");
        }

        public void _Kill_Room_Clicked()
        {
            _infopanel.Visible = false;
            _killpanel.Visible = true;
        }

        public void _Confirm_Creation_Clicked()
        {
            RoomDAO dao = new RoomDAO();

            string roomname = _creationpanel.GetNode<LineEdit>("txtNameInput").Text;

            dao.CreateRoom(roomname, _head.Account);

            Dictionary room_details = dao.GetRoom(_head.Account);

            _head.Room = (int)room_details["RoomID"];
            _head.RoomName = (string)room_details["RoomName"];

            _infopanel.Visible = true;
            _creationpanel.Visible = false;

            _infopanel.GetNode<Label>("lblName").Text = (string)room_details["RoomName"];
            _infopanel.GetNode<Label>("lblPlayers").Text = $"{(string)room_details["PlayerCount"]} Players";
        }

        public void _Cancel_Creation_Clicked()
        {
            _creationpanel.Visible = false;
        }

        public void _Confirm_Replace_Clicked()
        {
            RoomDAO dao = new RoomDAO();

            dao.KillRoom(_head.Room);

            _replacepanel.Visible = false;
            _creationpanel.Visible = true;
        }

        public void _Confirm_Kill_Clicked()
        {
            RoomDAO dao = new RoomDAO();

            dao.KillRoom(_head.Room);

            _killpanel.Visible = false;
        }

        public void _Cancel_Kill_Clicked()
        {
            _killpanel.Visible = false;
            _replacepanel.Visible = false;

            RoomDAO dao = new RoomDAO();

            if (dao.HasRooms(_head.Account))
            {
                _infopanel.Visible = true;
                _creationpanel.Visible = false;
            }
            else
            {
                _infopanel.Visible = false;
                _creationpanel.Visible = true;
            }
        }

    }
}
