using Godot;

namespace DATGame
{
    public partial class Class_Config : Panel
    {
        private string _sprite;
        private string _classname;
        private string _ability;

        public string Sprite { get => _sprite; set => _sprite = value; }
        public string Classname { get => _classname; set => _classname = value; }
        public string Ability { get => _ability; set => _ability = value; }

        public override void _Ready()
        {
            string spritepath = $"res://Gameplay/Game Sprites/{_sprite}.png";

            GetNode<TextureRect>("Stack/sprIcon").Texture = (Texture2D)GD.Load(spritepath);
            GetNode<Label>("Stack/lblClassName").Text = _classname;
            GetNode<Label>("Stack/lblStartingAbility").Text = _ability;
        }

        public void _Class_Clicked()
        {
            Main head = GetNode<Main>("/root/Main");
            PlayerDAO dao = new PlayerDAO();

            dao.JoinGame(head.Account, head.Room, _classname);

            head.SwitchScene("res://Gameplay/Gameplay.tscn");
        }

    }
}
