using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Tile_Button_Config : Button
    {
        private Dictionary _info;
        private Main _head;

        public override void _Ready()
        {
            base._Ready();

            _head = GetNode<Main>("/root/Main");
        }

        public void UpdateContents(Dictionary Info)
        {
            _info = Info;

            if (_info is null)
            {
                return;
            }

            Text = $"({_info["XPos"]}, {_info["YPos"]})";
        }

        public void _TileSelected()
        {
            PlayerDAO dao = new PlayerDAO();

            dao.Rejoin(_head.Account, _head.Room, (int)_info["TileID"]);

            _head.SwitchScene("res://Gameplay/Gameplay.tscn");
        }

    }
}
