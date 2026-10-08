using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Statistic_Readout : RichTextLabel
    {
        Main _head;
        PlayerDAO _dao = new PlayerDAO();

        public override void _Ready()
        {
            _head = GetNode<Main>("/root/Main");
        }

        public override void _Process(double delta)
        {
            Dictionary playerinfo = _dao.GetPlayer(_head.Account, _head.Room);

            Text = $"Position: ({playerinfo["XPos"]}, {playerinfo["YPos"]})\nStatistics:\n\tStength: {playerinfo["Strength"]}\n\tSpeed: {playerinfo["Speed"]}\n\tEnergy: {playerinfo["Energy"]}\n\tHealth: {playerinfo["Health"]}\n\nCurrent Score: {playerinfo["CurrentScore"]}\n\nHP: {playerinfo["CurrentHealth"]}";
        }

    }
}

