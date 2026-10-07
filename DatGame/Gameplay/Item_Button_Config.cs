using Godot;
using Godot.Collections;
using System.Resources;
using System.Security.Policy;

namespace DATGame
{
    public partial class Item_Button_Config : PanelContainer
    {
        private Dictionary _info;

        public Dictionary Info { set => _info = value; }

        public override void _Ready()
        {
            if (_info == null)
            {
                return;
            }

            string _path = $"res://Gameplay/Game Sprites/{_info["Sprite"]}.png";

            if (ResourceLoader.Exists(_path))
            {
                GetNode<TextureRect>("sprIcon").Texture = GD.Load<Texture2D>(_path);
            }
            else
            {
                GetNode<TextureRect>("sprIcon").Texture = GD.Load<Texture2D>("res://Gameplay/Game Sprites/Missing Texture.png");
            }

        }
    }
}
