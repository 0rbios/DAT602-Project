using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Room_Getter : VBoxContainer
    {
        // Called when the node enters the scene tree for the first time.
        public override void _Ready()
        {
            RoomDAO dao = new RoomDAO();
            Main head = GetNode<Main>("/root/Main");

            Array rooms = dao.GetRooms();

            foreach (Dictionary room in rooms)
            {
                Node roombox = GD.Load<PackedScene>("res://Room Select Page/Room Entry.tscn").Instantiate();
                Room_Config roomboxconf = roombox as Room_Config;

                roomboxconf.Id = (int)room["RoomID"];
                roomboxconf.Roomname = (string)room["RoomName"];
                roomboxconf.Playercount = (int)room["PlayerCount"];

                AddChild(roombox);
            }
        }
    }
}
