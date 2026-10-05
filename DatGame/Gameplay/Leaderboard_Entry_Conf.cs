using Godot;

namespace DATGame
{
    public partial class Leaderboard_Entry_Conf : Panel
    {
        private string _username;
        private int _score;
        private int _rank;

        public string Username { set => _username = value; }
        public int Score { set => _score = value; }
        public int Rank { set => _rank = value; }

        public override void _Ready()
        {
            GetNode<Label>("Columns/Info/lblUsername").Text = _username;
            GetNode<Label>("Columns/Info/lblScore").Text = $"{_score} Points";

            TextureRect _sprite = GetNode<TextureRect>("Columns/sprIcon");

            switch (_rank)
            {
                case 1:
                    _sprite.Texture = (Texture2D)GD.Load("res://Gameplay/Game Sprites/Crown.png");
                    break;

                case 2:
                    _sprite.Texture = (Texture2D)GD.Load("res://Gameplay/Game Sprites/Second Place Icon.png");
                    break;

                case 3:
                    _sprite.Texture = (Texture2D)GD.Load("res://Gameplay/Game Sprites/Third Place Icon.png");
                    break;

                default:
                    _sprite.Visible = false;
                    break;
            }
        }
    }
}
