using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace DATGame
{
    public partial class Admin : Form
    {
        public Admin()
        {
            InitializeComponent();
        }

        private void BackClicked(object sender, EventArgs e)
        {
            UserDAO userdao = new UserDAO();
            userdao.FetchRooms();

            this.Close();
        }
    }
}
