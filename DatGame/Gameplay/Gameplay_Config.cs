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
            PlayerDAO dao = new PlayerDAO();
            _head.Combatant = null;
            _head.Itemselected = false;
            dao.ExitRoom(_head.Account, _head.Room);
            _head.SwitchScene("res://Room Select Page/Room Select.tscn");
        }

    }
}
