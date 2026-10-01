using Godot;

namespace DATGame
{
    public partial class Admin_Button : Button
    {
        public void _Admin_Button_Clicked()
        {
            Main head = GetNode<Main>("/root/Main");

            head.SwitchScene("res://Admin Page/Admin Centre.tscn");
        }

    }
}
