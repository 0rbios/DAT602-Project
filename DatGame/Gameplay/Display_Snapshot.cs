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

				maprow.AddThemeConstantOverride("separation", 0);

				CallDeferred("add_child", maprow);

				for (int x = minx; x < viewwidth; x++)
				{
					if (posvals.Values.Contains(new Vector2(x, y)))
					{
						// Rip out the vector position of the tiles and find the matching detailed info
						Godot.Collections.Array posvalspositions = (Godot.Collections.Array)posvals.Values;
						Dictionary tileinfo = (Dictionary)tiles[posvalspositions.IndexOf(new Vector2(x, y))];

						// Create a new tile button
						TextureButton tilebutton = (TextureButton)GD.Load<PackedScene>("res://Gameplay/Tile Button.tscn").Instantiate();
						tilebutton.CustomMinimumSize = new Vector2((450 / viewwidth), (450 / viewwidth));
						tilebutton.CustomMaximumSize = tilebutton.CustomMinimumSize;

						// Set the tile sprite according to it's situation
						// If the tile is occupied by a player
						if ((string)tileinfo["AccountName"] != "")
						{
							tilebutton.TextureNormal = GD.Load<Texture2D>("res://Gameplay/Game Sprites/Tile Unavailable.png");
						}

						// If the tile is within the player's movement range (A.K.A can be moved to)
						else if (
							(int)tileinfo["XPos"] - (int)((Vector2)posvals[_head.Account])[0] <= moveradius &&
							(int)tileinfo["YPos"] - (int)((Vector2)posvals[_head.Account])[1] <= moveradius
							)
						{
							// Only show diagonally available tiles if diagonal movement is enabled
							if ((int)tileinfo["XPos"] != (int)tileinfo["YPos"])
                            {
                                tilebutton.TextureNormal = GD.Load<Texture2D>("res://Gameplay/Game Sprites/Tile Highlighted.png");
                            }

							else if (
								((int)tileinfo["XPos"] == (int)tileinfo["YPos"]) &&
                                movediagonal == true
								)
                            {
                                tilebutton.TextureNormal = GD.Load<Texture2D>("res://Gameplay/Game Sprites/Tile Highlighted.png");
                            }

							else
                            {
                                tilebutton.TextureNormal = GD.Load<Texture2D>("res://Gameplay/Game Sprites/Tile Normal.png");
                            }

                        }

						//If the tile is just a regular tile
						else
						{
							tilebutton.TextureNormal = GD.Load<Texture2D>("res://Gameplay/Game Sprites/Tile Normal.png");
						}

						// Places a player icon on top of the tile if one exists
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
					// Create an unavailable tile if the position is searched but doesn't exist
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
