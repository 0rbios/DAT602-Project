using Godot;

namespace DATGame
{
    public partial class Message_Controls : HBoxContainer
    {
        private Main _head;

        public override void _Ready()
        {
            _head = GetNode<Main>("/root/Main");
        }

        public void _Send_Message_Clicked()
        {
            string message = GetNode<LineEdit>("txtMessage").Text;

            ChatDAO dao = new ChatDAO();

            dao.SendMessage(message, _head.Account, _head.Room);

            GetNode<LineEdit>("txtMessage").Text = "";
        }

    }
}