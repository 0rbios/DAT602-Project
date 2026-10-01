using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Login_Handler : Control
    {
        private UserDAO dao = new UserDAO();

        VBoxContainer logincontrols;
        VBoxContainer lock_msg;
        Label attempt_text;

        private string _attemptedaccount = "";

        public override void _Ready()
        {
            base._Ready();

            Main main = GetNode<Main>("/root/Main");

            Control head = GetNode<Control>("CanvasLayer/Container");

            logincontrols = head.GetNode<VBoxContainer>("Login Controls");

            lock_msg = head.GetNode<VBoxContainer>("Lockout Message");
            attempt_text = logincontrols.GetNode<Label>("lblAttempts");
        }

        public override void _Process(double delta)
        {
            base._Process(delta);

            Dictionary attempteduserdetails = dao.GetAccount(_attemptedaccount);

            if (attempteduserdetails.Keys.Count == 1)
            {
                return;
            }

            if ((bool)attempteduserdetails["Locked"] == true){
                lock_msg.Visible = true;
                logincontrols.Visible = false;
            }

            attempt_text.Text = $"Attempt {(int)attempteduserdetails["LoginAttempts"]}/5";
        }

        internal void _Submit_Button_Clicked()
        {
            Main main = GetNode<Main>("/root/Main");

            Control head = GetNode<Control>("CanvasLayer/Container");

            VBoxContainer accountpopup = head.GetNode<VBoxContainer>("New Account Controls");

            string uname = logincontrols.GetNode<LineEdit>("txtboxUsername").Text;
            string pword = logincontrols.GetNode<LineEdit>("txtboxPassword").Text;

            Label warninglabel = logincontrols.GetNode<Label>("lblWarning");
            Label message = accountpopup.GetNode<Label>("lblMessage");

            _attemptedaccount = uname;

            string login_result = dao.Login(uname, pword);
            switch (login_result)
            {
                case "Login success":
                    main.Account = uname;
                    main.SwitchScene("res://Room Select Page/Room Select.tscn");
                    break;

                case "Login failed":
                    warninglabel.Text = "Incorrect username or password";
                    warninglabel.Visible = true;
                    break;

                case "Account not found":
                    message.Text = $"Username '{uname}' does not exist.\nCreate new account?";
                    logincontrols.Visible = false;
                    accountpopup.Visible = true;
                    break;

                default:
                    warninglabel.Text = $"Something went wrong: {login_result}";
                    warninglabel.Visible = true;
                    break;
            }
        }

        internal void _Create_Confirm_Clicked()
        {
            Main main = GetNode<Main>("/root/Main");

            Control head = GetNode<Control>("CanvasLayer/Container");

            VBoxContainer logincontrols = head.GetNode<VBoxContainer>("Login Controls");
            VBoxContainer accountpopup = head.GetNode<VBoxContainer>("New Account Controls");

            string uname = logincontrols.GetNode<LineEdit>("txtboxUsername").Text;
            string pword = logincontrols.GetNode<LineEdit>("txtboxPassword").Text;

            Label warninglabel = logincontrols.GetNode<Label>("lblWarning");

            string creation_result = dao.CreateAccount(uname, pword);
            switch (creation_result)
            {
                case "Account created successfully":
                    main.Account = uname;
                    main.SwitchScene("res://Room Select Page/Room Select.tscn");
                    break;

                case "Account name already exists":
                    warninglabel.Text = $"Account couldn't be created\nUser '{uname}' already exists";

                    logincontrols.Visible = true;
                    accountpopup.Visible = false;

                    warninglabel.Visible = true;
                    break;

                default:
                    warninglabel.Text = $"Something went wrong: {creation_result}";

                    logincontrols.Visible = true;
                    accountpopup.Visible = false;

                    warninglabel.Visible = true;
                    break;
            }
        }
        
        internal void _Cancel_Creation()
        {
            Main main = GetNode<Main>("/root/Main");

            Control head = GetNode<Control>("CanvasLayer/Container");

            VBoxContainer logincontrols = head.GetNode<VBoxContainer>("Login Controls");
            VBoxContainer accountpopup = head.GetNode<VBoxContainer>("New Account Controls");

            logincontrols.Visible = true;
            accountpopup.Visible = false;

            logincontrols.GetNode<LineEdit>("txtboxUsername").Text = "";
            logincontrols.GetNode<LineEdit>("txtboxPassword").Text = "";

            logincontrols.GetNode<Label>("lblWarning").Visible = false;
        }
    }
}
