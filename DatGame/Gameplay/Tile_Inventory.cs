using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Tile_Inventory : VBoxContainer
    {
        private Main _head;

        public override void _Ready()
        {
            base._Ready();

            _head = GetNode<Main>("/root/Main");

            LoadTileInventory();
        }

        public void LoadTileInventory()
        {
            MapDAO dao = new MapDAO();

            Array tileabilities = dao.GetTileInventory(_head.Account, _head.Room, 0, 0);

            HBoxContainer toprow = GetNode<HBoxContainer>("Top Row");
            HBoxContainer bottomrow = GetNode<HBoxContainer>("Bottom Row");

            Array<Node> toprowchildren = toprow.GetChildren();
            Array<Node> bottomrowchildren = bottomrow.GetChildren();

            Array<Node> allchildren = toprowchildren + bottomrowchildren;

            foreach (Node child in allchildren)
            {
                child.QueueFree();
            }

            bool ontoprow = true;

            foreach (Dictionary ability in tileabilities)
            {
                Node itembutton = GD.Load<PackedScene>("res://Gameplay/Item Button.tscn").Instantiate();

                if (ontoprow == true)
                {
                    toprow.CallDeferred("add_child", itembutton);
                }
                else
                {
                    bottomrow.CallDeferred("add_child", itembutton);
                }

                ontoprow = !ontoprow;
            }
        }
    }

}
