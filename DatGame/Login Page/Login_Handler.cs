using Godot;
using System;

namespace DATGame
{
    public partial class Login_Handler : Control
    {
        internal void _Submit_Button_Clicked()
        {
            UserDAO userdao = new UserDAO();

            GD.Print(userdao.FetchUsers());
        }
    }
}
