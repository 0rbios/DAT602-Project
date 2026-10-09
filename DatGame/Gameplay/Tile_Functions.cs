using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Tile_Functions : TextureButton
    {
        private Main _head;

        private Dictionary _info;

        private MapDAO _dao = new MapDAO();

        public override void _Ready()
        {
            _head = GetNode<Main>("/root/Main");

            if ((TileTypes.Type)(int)_info["type"] == TileTypes.Type.OOBE)
            {
                return;
            }
        }

        public void UpdateTile(Dictionary info)
        {
            _info = info;

            switch ((TileTypes.Type)(int)_info["type"])
            {
                case TileTypes.Type.Normal:
                    TextureNormal = GD.Load<Texture2D>("res://Gameplay/Game Sprites/Tile Normal.png");
                    break;

                case TileTypes.Type.Unavailable:
                    TextureNormal = GD.Load<Texture2D>("res://Gameplay/Game Sprites/Tile Unavailable.png");
                    break;

                case TileTypes.Type.Highlighted:   
                    TextureNormal = GD.Load<Texture2D>("res://Gameplay/Game Sprites/Tile Highlighted.png");
                    break;

                case TileTypes.Type.Combat:
                    TextureNormal = GD.Load<Texture2D>("res://Gameplay/Game Sprites/Tile Combat.png");
                    break;

                default:
                    TextureNormal = GD.Load<Texture2D>("res://Gameplay/Game Sprites/Missing Texture.png");
                    break;
            }

            if ((TileTypes.Type)(int)_info["type"] != TileTypes.Type.OOBE)
            {
                TextureRect playeroverlay = GetNode<TextureRect>("sprPlayerOverlay");

                // Places a player icon on top of the tile if one exists
                if (ResourceLoader.Exists($"res://Gameplay/Game Sprites/{(string)_info["Sprite"]}.png"))
                {
                    playeroverlay.Texture = GD.Load<Texture2D>($"res://Gameplay/Game Sprites/{(string)_info["Sprite"]}.png");

                    playeroverlay.Size = new Vector2((int)(CustomMinimumSize.X * 0.8), (int)(CustomMinimumSize.Y * 0.8));

                    int offset = (int)(CustomMinimumSize.X - playeroverlay.Size.X) / 2;
                    playeroverlay.Position = new Vector2(offset, offset);
                }
                else if ((string)_info["Sprite"] == "")
                {
                    playeroverlay.Texture = null;
                }
                else
                {
                    playeroverlay.Texture = GD.Load<Texture2D>($"res://Gameplay/Game Sprites/Missing Texture.png");
                }
            }
        }

        public void _TileClicked()
        {
            if ((TileTypes.Type)(int)_info["type"] != TileTypes.Type.OOBE)
            {
                if (_head.Combatant is not null)
                {
                    _dao.Disengage(_head.Account, _head.Room);
                    _head.Combatant = null;
                }
                else if ((string)_info["PlayerID"] != "")
                {
                    _dao.Engage(_head.Account, _head.Room, (int)_info["PlayerID"]);
                    _head.Combatant = (int)_info["PlayerID"];
                }

                if (_head.Canmove == true)
                {
                    _dao.MovePlayer(_head.Account, _head.Room, (int)_info["XPos"], (int)_info["YPos"], (int)_info["moveradius"], (bool)_info["diagonal"]);
                    _head.Canmove = false;
                }
            }
        }

    }
}
