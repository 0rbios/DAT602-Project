using Godot;
using Godot.Collections;

namespace DATGame
{
	public partial class Room_Select_Config : Control
	{
		public override void _Ready()
		{
			Main main = GetNode<Main>("/root/Main");

			Control head = GetNode<Control>("CanvasLayer/Columns");

			UserDAO dao = new UserDAO();

			Dictionary account_details = dao.GetAccount(main.Account);

			head.GetNode<Button>("Column 1/Options Column/btnAdmin").Visible = (bool)account_details["Admin"];
			head.GetNode<Label>("Column 2/lblPlayerName").Text = (string)account_details["Name"];
		}
	}
}
