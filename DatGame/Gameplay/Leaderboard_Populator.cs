using Godot;
using Godot.Collections;
using System;

namespace DATGame
{
    public partial class Leaderboard_Populator : VBoxContainer
    {
        Main _head;

        public override void _Ready()
        {
            _head = GetNode<Main>("/root/Main");

            LoadLeaders();
        }

        public void LoadLeaders()
        {
            foreach (Node child in GetChildren())
            {
                child.QueueFree();
            }

            PlayerDAO dao = new PlayerDAO();

            Godot.Collections.Array leaderboard = dao.GetLeaderboard(_head.Room);

            for (int i = 0; i < Math.Min(leaderboard.Count, 5); i++)
            {
                Node leaderboardentry = GD.Load<PackedScene>("res://Gameplay/Leaderboard Entry.tscn").Instantiate();
                Leaderboard_Entry_Conf conf = leaderboardentry as Leaderboard_Entry_Conf;

                Dictionary entryinfo = (Dictionary)leaderboard[i];

                conf.Username = (string)entryinfo["AccountName"];
                conf.Score = (int)entryinfo["HighScore"];
                conf.Rank = i + 1;

                CallDeferred("add_child", leaderboardentry);
            }

            VBoxContainer col3 = GetParent<VBoxContainer>();
            Leaderboard_Entry_Conf selfconf = col3.GetNode<Leaderboard_Entry_Conf>("Rank Panel");

            selfconf.Username = _head.Account;
            selfconf.Score = dao.GetPlayerScore(_head.Account, _head.Room);
        }
    }
}
