using Godot;
using System;

namespace DATGame
{
    public partial class Login_Handler : Control
    {
        private UserDAO dao = new UserDAO();

        internal void _Submit_Button_Clicked()
        {
            string uname = GetNode<LineEdit>("CanvasLayer/Container/txtboxUsername").Text;
            string pword = GetNode<LineEdit>("CanvasLayer/Container/txtboxPassword").Text;

            GD.Print(dao.Login(uname, pword));
        }
    }
}
