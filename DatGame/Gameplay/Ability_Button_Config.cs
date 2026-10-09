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

            string tooltip = $"{_info["AbilityName"]}\n";

            if ((bool)_info["Combat"] == true)
            {
                tooltip += $"{_info["Damage"]} DMG | ";
            }

            if ((int)_info["Cost"] > 0)
            {
                tooltip += $"{_info["Cost"]} | ";
            }

            tooltip += $"{_info["Value"]} Points\n{_info["Description"]}";

            TooltipText = tooltip;

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

        public void _Ability_Clicked()
        {
            if ((bool)_info["Combat"] == true)
            {
                PlayerDAO dao = new PlayerDAO();

                dao.Attack((int)_info["AbilityID"]);
            }
        }

    }
}
