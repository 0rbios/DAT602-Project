namespace DATGame
{
    public partial class LoginForm : Form
    {
        public LoginForm()
        {
            InitializeComponent();
        }

        private void SubmitClicked(object sender, EventArgs e)
        {
            //UserDAO userDAO = new UserDAO();
            //userDAO.FetchUsers();

            this.Visible = false;

            Gameplay gameplay = new Gameplay();
            gameplay.ShowDialog();

            this.Visible = true;

        }

        private void AdminCenterClicked(object sender, EventArgs e)
        {
            this.Visible = false;

            Admin admin = new Admin();
            admin.ShowDialog();

            this.Visible = true;
        }
    }
}
