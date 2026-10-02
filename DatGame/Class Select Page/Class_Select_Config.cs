using Godot;

namespace DATGame
{
    public partial class Class_Select_Config : Control
    {
        public override void _Ready()
        {
            Main head = GetNode<Main>("/root/Main");

            GetNode<Label>("CanvasLayer/Rows/lblRoomName").Text = head.RoomName;
        }

        public void _Back_Button_Clicked()
        {
            Main head = GetNode<Main>("/root/Main");

            head.Room = -1;
            head.RoomName = "";
            head.SwitchScene("res://Room Select Page/Room Select.tscn");
        }
    }
}
