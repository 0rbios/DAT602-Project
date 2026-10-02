using Godot;

namespace DATGame
{
    public partial class Room_Config : Panel
    {
        private int _id;
        private string _roomname;
        private int _playercount;

        public int Id { get => _id; set => _id = value; }
        public string Roomname { get => _roomname; set => _roomname = value; }
        public int Playercount { get => _playercount; set => _playercount = value; }

        public override void _Ready()
        {
            GetNode<Label>("Container/lblName").Text = _roomname;
            GetNode<Label>("Container/lblPlayers").Text = $"{_playercount} Players";
        }

        public void _Join_Button_Clicked()
        {
            Main head = GetNode<Main>("/root/Main");

            head.Room = _id;
            head.RoomName = _roomname;

            head.SwitchScene("res://Class Select Page/Class Select.tscn");
        }

    }
}
