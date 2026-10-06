using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Message_Display : RichTextLabel
    {
        Main _head;

        public override void _Ready()
        {
            base._Ready();

            _head = GetNode<Main>("/root/Main");

            RefreshChat();
        }

        public void RefreshChat()
        {
            ChatDAO dao = new ChatDAO();

            Array rawchat = dao.GetMessages(_head.Room);

            string formattedchat = "";

            foreach (Dictionary message in rawchat)
            {
                formattedchat += $"{message["AccountName"]}: {message["Text"]}";

                // Add a newline for each line that isn't at the end of the log
                if (rawchat.IndexOf(message) != rawchat.Count) {
                    formattedchat += $"\n";
                }
            }

            Text = formattedchat;
        }

    }
}
