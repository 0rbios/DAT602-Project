using Godot;
using ZstdSharp.Unsafe;

namespace DATGame {
    public partial class Glitch_Item_Movement : Timer
    {
        Main _head;

        PlayerDAO _pdao = new PlayerDAO();
        MapDAO _mdao = new MapDAO();

        public override void _Ready()
        {
            base._Ready();

            _head = GetNode<Main>("/root/Main");
        }

        public void _GlitchItemTimeout()
        {
            if (_pdao.GetPrimaryPlayer(_head.Room) == _head.Account)
            {
                _mdao.Glitch(_head.Room);
            }
        }

    }
}
