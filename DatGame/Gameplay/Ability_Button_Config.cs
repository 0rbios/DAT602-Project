using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Ability_Button_Config : TextureButton
    {
        private Dictionary _info;

        public void UpdateContents(Dictionary info)
        {
            _info = info;

            if (_info == null)
            {
                return;
            }

            string _path = $"res://Gameplay/Game Sprites/{_info["Sprite"]}.png";

            if (ResourceLoader.Exists(_path))
            {
                TextureNormal = GD.Load<Texture2D>(_path);
            }
            else
            {
                TextureNormal = GD.Load<Texture2D>("res://Gameplay/Game Sprites/Missing Texture.png");
            }
        }

    }
}
