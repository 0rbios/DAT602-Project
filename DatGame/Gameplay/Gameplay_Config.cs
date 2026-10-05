using Godot;

namespace DATGame
{
    public partial class Gameplay_Config : Control
    {
        private Main _head;

        public override void _Ready()
        {
            _head = GetNode<Main>("/root/Main");

        }

        public void _Back_Button_Clicked()
        {
            _head.SwitchScene("res://Room Select Page/Room Select.tscn");
        }

    }
}
