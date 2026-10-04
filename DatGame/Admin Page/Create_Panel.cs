using Godot;

namespace DATGame
{
    public partial class Create_Panel : Panel
    {
        public void _Open_Create_Clicked()
        {
            Visible = true;
        }

        public void _Cancel_Create_Clicked()
        {
            Visible = false;
        }

        public void _Confirm_Create_Clicked()
        {
            UserDAO dao = new UserDAO();

            string username = GetNode<LineEdit>("Account Creator/Line 1/txtUsername").Text;
            string password = GetNode<LineEdit>("Account Creator/Line 2/txtPassword").Text;

            string response = dao.CreateAccount(username, password);

            GetNode<Label>("Account Creator/lblWarning").Text = response;
        }

    }
}
