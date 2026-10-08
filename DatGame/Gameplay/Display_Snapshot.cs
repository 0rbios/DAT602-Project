using Godot;
using Godot.Collections;
using System;

namespace DATGame
{
	public partial class Display_Snapshot : VBoxContainer
	{
		private Main _head;

		public override void _Ready()
		{
			_head = GetNode<Main>("/root/Main");

			Regenerate_Display(2, 1, false);
		}

		public void _MovementRecharged()
		{
			_head.Canmove = true;
		}

		public void Regenerate_Display(int viewradius, int moveradius, bool movediagonal)
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
            Godot.Collections.Array tiles = dao.GetMapSnapshot(_head.Account, _head.Room, viewradius);

            // Get the smallest x and y values
            int miny = 0;
            int minx = 0;

            // Create a linear counter for non-player tile names
            int npi = 0;

            // Get all returned tile positions as Vector2's for easier reading
            Dictionary posvals = new Dictionary();
            foreach (Dictionary tile in tiles)
            {
                string playername;

                if ((string)tile["AccountName"] != "")
                {
                    playername = $"{tile["AccountName"]}";
                }
                else
                {
                    playername = $"{npi}";
                    npi++;
                }

                posvals[$"{playername}"] = (new Vector2((int)tile["XPos"], (int)tile["YPos"]));

                if (miny > (int)tile["YPos"]) { miny = (int)tile["YPos"]; }
                if (minx > (int)tile["XPos"]) { minx = (int)tile["XPos"]; }
            }

            // Create each map row and generate all tiles across
            for (int y = miny; y < viewwidth; y++)
            {

                // Create a new row on the map
                HBoxContainer maprow = new HBoxContainer { Alignment = AlignmentMode.Center };
                maprow.AddThemeConstantOverride("separation", 0);
                CallDeferred("add_child", maprow);

                // Iterate over each x position on the row
                for (int x = minx; x < viewwidth; x++)
                {
                    // Create a new tile button
                    TextureButton tilebutton = (TextureButton)GD.Load<PackedScene>("res://Gameplay/Tile Button.tscn").Instantiate();
                    tilebutton.CustomMinimumSize = new Vector2((450 / viewwidth), (450 / viewwidth));
                    tilebutton.CustomMaximumSize = tilebutton.CustomMinimumSize;

                    // Set the tiles default configuration
                    Tile_Functions conf = (Tile_Functions)tilebutton;
                    Dictionary tileinfo = new Dictionary();
                    tileinfo["type"] = (int)TileTypes.Type.OOBE;

                    // If the tile's position actually exists
                    if (posvals.Values.Contains(new Vector2(x, y)))
                    {

                        // Get the detailed information for the current tile
                        tileinfo = (Dictionary)tiles[((Godot.Collections.Array)posvals.Values).IndexOf(new Vector2(x, y))];
                        tileinfo["moveradius"] = moveradius;
                        tileinfo["diagonal"] = movediagonal;

                        // Get the distance between the player and the current tile
                        int xdiff = Math.Abs((int)tileinfo["XPos"] - (int)((Vector2)posvals[_head.Account])[0]);
                        int ydiff = Math.Abs((int)tileinfo["YPos"] - (int)((Vector2)posvals[_head.Account])[1]);

                        // Set the tile sprite according to it's situation

                            // If the tile is occupied by a player
                        if ((string)tileinfo["AccountName"] != "") { tileinfo["type"] = (int)TileTypes.Type.Unavailable; }

                            // If the tile is within the player's movement range (A.K.A can be moved to)
                        else if (xdiff <= moveradius && ydiff <= moveradius)
                        {
                            // Only highlight diagonally available tiles if diagonal movement is enabled
                            if ((xdiff != ydiff) || (xdiff == ydiff && movediagonal == true))
                            {
                                tileinfo["type"] = (int)TileTypes.Type.Highlighted;
                            }
                            else
                            {
                                tileinfo["type"] = (int)TileTypes.Type.Normal;
                            }
                        }

                            //If the tile is just a regular tile
                        else
                        {
                            tileinfo["type"] = (int)TileTypes.Type.Normal;
                        }
                    }

                    conf.UpdateTile(tileinfo);
                    maprow.AddChild(tilebutton);
                }
            }
        }

        public void Update_Display(int viewradius, int moveradius, bool movediagonal)
        {
            // Get the data from the database for the tiles around the player
            MapDAO dao = new MapDAO();
            Godot.Collections.Array tiles = dao.GetMapSnapshot(_head.Account, _head.Room, viewradius);

            // Get the smallest x and y values
            int ? miny = null;
            int ? minx = null;

            // Create a linear counter for non-player tile names
            int npi = 0;

            // Get all returned tile positions as Vector2's for easier reading
            Dictionary posvals = new Dictionary();
            foreach (Dictionary tile in tiles)
            {
                string playername;

                if ((string)tile["AccountName"] != "")
                {
                    playername = $"{tile["AccountName"]}";
                }
                else
                {
                    playername = $"{npi}";
                    npi++;
                }

                posvals[$"{playername}"] = (new Vector2((int)tile["XPos"], (int)tile["YPos"]));

                if (miny > (int)tile["YPos"] || miny is null) { miny = (int)tile["YPos"]; }
                if (minx > (int)tile["XPos"] || minx is null) { minx = (int)tile["XPos"]; }
            }

            for (int row = 0; row < GetChildCount(); row++)
            {
                HBoxContainer currentrow = GetChild<HBoxContainer>(row);

                // Iterate over each x position on the row
                for (int tile = 0; tile < currentrow.GetChildCount(); tile++)
                {
                    int tilexpos = (int)minx + tile;
                    int tileypos = (int)miny + row;

                    TextureButton currenttile = currentrow.GetChild<TextureButton>(tile);

                    // Set the tiles default configuration
                    Tile_Functions conf = (Tile_Functions)currenttile;
                    Dictionary tileinfo = new Dictionary();
                    tileinfo["type"] = (int)TileTypes.Type.OOBE;

                    // If the tile's position actually exists
                    if (posvals.Values.Contains(new Vector2(tilexpos, tileypos)))
                    {

                        // Get the detailed information for the current tile
                        tileinfo = (Dictionary)tiles[((Godot.Collections.Array)posvals.Values).IndexOf(new Vector2(tilexpos, tileypos))];
                        tileinfo["moveradius"] = moveradius;
                        tileinfo["diagonal"] = movediagonal;

                        // Get the distance between the player and the current tile
                        int xdiff = Math.Abs((int)tileinfo["XPos"] - (int)((Vector2)posvals[_head.Account])[0]);
                        int ydiff = Math.Abs((int)tileinfo["YPos"] - (int)((Vector2)posvals[_head.Account])[1]);

                        // Set the tile sprite according to it's situation

                        // If the tile is occupied by a player
                        if ((string)tileinfo["AccountName"] != "") { tileinfo["type"] = (int)TileTypes.Type.Unavailable; }

                        // If the tile is within the player's movement range (A.K.A can be moved to)
                        else if (xdiff <= moveradius && ydiff <= moveradius)
                        {
                            // Only highlight diagonally available tiles if diagonal movement is enabled
                            if ((xdiff != ydiff) || (xdiff == ydiff && movediagonal == true))
                            {
                                tileinfo["type"] = (int)TileTypes.Type.Highlighted;
                            }
                            else
                            {
                                tileinfo["type"] = (int)TileTypes.Type.Normal;
                            }
                        }

                        //If the tile is just a regular tile
                        else
                        {
                            tileinfo["type"] = (int)TileTypes.Type.Normal;
                        }
                    }

                    conf.UpdateTile(tileinfo);
                }
            }
        }

    }
}
