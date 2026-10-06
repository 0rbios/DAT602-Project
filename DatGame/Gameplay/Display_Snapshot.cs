using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Display_Snapshot : VBoxContainer
    {
        private Main _head;

        public override void _Ready()
        {
            _head = GetNode<Main>("/root/Main");

            Update_Display(2, 1, false);
        }

        public void Update_Display(int viewradius, int moveradius, bool movediagonal)
        {
            // Get the number of tiles across the view window
            int viewwidth = (viewradius * 2) + 1;

            // Remove any previous display
            foreach (Node child in GetChildren())
            {
                child.QueueFree();
            }

            // Get the data from the database for the tiles around the player
            MapDAO dao = new MapDAO();
            Array tiles = dao.GetMapSnapshot(_head.Account, _head.Room, viewradius);

            // Get the smallest x and y values
            int miny = 0;
            int minx = 0;

            // Get all returned tile positions as Vector2's for easier reading
            Array posvals = new Array();
            foreach (Dictionary tile in tiles)
            {
                posvals.Add(new Vector2((int)tile["XPos"], (int)tile["YPos"]));
            
                if (miny > (int)tile["YPos"])
                {
                    miny = (int)tile["YPos"];
                }

                if (minx > (int)tile["XPos"])
                {
                    minx = (int)tile["XPos"];
                }
            }

            // Create each map row and generate all tiles across
            for (int y = miny; y < viewwidth; y++)
            {
                HBoxContainer maprow = new HBoxContainer
                {
                    Alignment = AlignmentMode.Center
                };

                CallDeferred("add_child", maprow);

                for (int x = minx; x < viewwidth; x++)
                {
                    if (posvals.Contains(new Vector2(x, y)))
                    {
                        Dictionary tileinfo = (Dictionary)tiles[posvals.IndexOf(new Vector2(x, y))];

                        TextureButton tilebutton = (TextureButton)GD.Load<PackedScene>("res://Gameplay/Tile Button.tscn").Instantiate();

                        tilebutton.TextureNormal = GD.Load<Texture2D>("res://Gameplay/Game Sprites/Tile Normal.png");

                        tilebutton.CustomMinimumSize = new Vector2((450 / viewwidth), (450 / viewwidth));
                        tilebutton.CustomMaximumSize = tilebutton.CustomMinimumSize;

                        if (ResourceLoader.Exists($"res://Gameplay/Game Sprites/{(string)tileinfo["Sprite"]}.png"))
                        {
                            TextureRect playeroverlay = tilebutton.GetNode<TextureRect>("sprPlayerOverlay");
                            
                            playeroverlay.Texture = GD.Load<Texture2D>($"res://Gameplay/Game Sprites/{(string)tileinfo["Sprite"]}.png");

                            playeroverlay.Size = new Vector2((int)(tilebutton.CustomMinimumSize.X * 0.8), (int)(tilebutton.CustomMinimumSize.Y * 0.8));

                            int offset = (int)(tilebutton.CustomMinimumSize.X - playeroverlay.Size.X) / 2;
                            playeroverlay.Position = new Vector2(offset, offset);
                        }

                        maprow.CallDeferred("add_child", tilebutton);
                    }
                    else
                    {
                        TextureButton tileblank = (TextureButton)GD.Load<PackedScene>("res://Gameplay/Tile Button.tscn").Instantiate();
                        tileblank.TextureNormal = GD.Load<Texture2D>("res://Gameplay/Game Sprites/Tile Unavailable.png");
                        tileblank.CustomMinimumSize = new Vector2((450 / viewwidth), (450 / viewwidth));
                        tileblank.CustomMaximumSize = tileblank.CustomMinimumSize;

                        maprow.CallDeferred("add_child", tileblank);
                    }
                }
            }

        }

    }
}
