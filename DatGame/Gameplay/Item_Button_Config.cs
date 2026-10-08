using Godot;
using Godot.Collections;
using System.IO;

namespace DATGame
{
    public partial class Item_Button_Config : PanelContainer
    {
        private Main _head;

        private Dictionary _info;

        public override void _Ready()
        {
            _head = GetNode<Main>("/root/Main");
        }

        public void UpdateContents(Dictionary info)
        {
            _info = info;

            if (_info is not null)
            {
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
            else
            {
                GetNode<TextureRect>("sprIcon").Texture = null;
            }
        }

        public void _ItemButtonClicked()
        {
            GD.Print("Clicked");

            if (_head.Itemselected == false)
            {
                if (_info is not null)
                {
                    _head.Swapitemid1 = (int)_info["AbilityID"];
                    _head.Itemselected = true;
                }
            }
            else
            {
                if (_info is not null)
                {
                    _head.Swapitemid2 = (int)_info["AbilityID"];
                }

                PlayerDAO dao = new PlayerDAO();
                dao.SwapItems(_head.Account, _head.Room, _head.Swapitemid1, _head.Swapitemid2);

                _head.Swapitemid1 = null;
                _head.Swapitemid2 = null;
                _head.Itemselected = false;
            }
        }

    }
}
