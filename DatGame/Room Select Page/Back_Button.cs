using Godot;

namespace DATGame
{
    public partial class Back_Button : Button
    {
        public void _Back_Button_Clicked()
        {
            Main main = GetNode<Main>("/root/Main");

            main.Account = null;
            main.SwitchScene("res://Login Page/Login.tscn");
        }
    }
}
