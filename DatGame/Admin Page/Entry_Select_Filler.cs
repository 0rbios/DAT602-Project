using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Entry_Select_Filler : VBoxContainer
    {
        public override void _Ready()
        {
            LoadNames();
        }

        public void LoadNames()
        {
            Admin_Centre_Config conf = GetNode<Admin_Centre_Config>("/root/Main/Admin Centre");

            foreach (Node child in GetChildren())
            {
                child.QueueFree();
            }

            switch (conf.View)
            {
                case 0:
                    UserDAO udao = new UserDAO();

                    Array accountlist = udao.GetAccounts();

                    foreach (Dictionary account in accountlist)
                    {
                        Button accountbutton = new Button
                        {
                            Text = (string)account["AccountName"]
                        };

                        CallDeferred("add_child", accountbutton);
                    }

                    break;

                case 1:
                    PlayerDAO pdao = new PlayerDAO();

                    Array playerlist = pdao.GetPlayers();

                    foreach (Dictionary player in playerlist)
                    {
                        Button playerbutton = new Button
                        {
                            Text = $"{(string)player["AccountName"]} ({(string)player["RoomName"]})"
                        };

                        CallDeferred("add_child", playerbutton);
                    }

                    break;

                case 2:
                    RoomDAO rdao = new RoomDAO();

                    Array roomlist = rdao.GetRooms();

                    foreach (Dictionary room in roomlist)
                    {
                        Button roombutton = new Button
                        {
                            Text = (string)room["RoomName"]
                        };

                        CallDeferred("add_child", roombutton);
                    }

                    break;

                default:
                    GD.Print("Invalid view value");
                    break;
            }

        }

    }

}