namespace DATGame
{
    public partial class LoginForm : Form
    {
        public LoginForm()
        {
            InitializeComponent();
        }

        private void btnSubmitClicked(object sender, EventArgs e)
        {
            UserDAO userDAO = new UserDAO();
            userDAO.FetchUsers();
        }
    }
}
