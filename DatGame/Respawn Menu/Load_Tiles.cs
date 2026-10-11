using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Load_Tiles : VBoxContainer
    {
        Main _head;
        MapDAO _dao = new MapDAO();

        public override void _Ready()
        {
            _head = GetNode<Main>("/root/Main");
            _UpdateTileList();
        }

        public void _UpdateTileList()
        {
            Array tiles = _dao.GetAvailableTiles(_head.Room);
            Array tilebuttons = (Array)GetChildren();

            for (int rm = tilebuttons.Count; rm > tiles.Count; rm--)
            {
                ((Node)tilebuttons[rm]).QueueFree();
            }

            for (int cr = tilebuttons.Count; cr < tiles.Count; cr++)
            {
                Button tilebutton = (Button)GD.Load<PackedScene>("res://Respawn Menu/Tile Button.tscn").Instantiate();
                CallDeferred("add_child", tilebutton);
            }

            for (int slot = 0; slot < tilebuttons.Count; slot++)
            {
                Tile_Button_Config conf = (Tile_Button_Config)tilebuttons[slot];
                conf.UpdateContents((Dictionary)tiles[slot]);
            }
        }

    }
}
