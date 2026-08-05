namespace DATGame
{
    partial class LoginForm
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            btnSubmit = new Button();
            txtboxUsername = new TextBox();
            txtboxPassword = new TextBox();
            txtTitle = new Label();
            SuspendLayout();
            // 
            // btnSubmit
            // 
            btnSubmit.Location = new Point(171, 183);
            btnSubmit.Name = "btnSubmit";
            btnSubmit.Size = new Size(94, 29);
            btnSubmit.TabIndex = 0;
            btnSubmit.Text = "Submit";
            btnSubmit.UseVisualStyleBackColor = true;
            btnSubmit.Click += btnSubmitClicked;
            // 
            // txtboxUsername
            // 
            txtboxUsername.Location = new Point(157, 117);
            txtboxUsername.Name = "txtboxUsername";
            txtboxUsername.PlaceholderText = "Username";
            txtboxUsername.Size = new Size(125, 27);
            txtboxUsername.TabIndex = 3;
            // 
            // txtboxPassword
            // 
            txtboxPassword.Location = new Point(157, 150);
            txtboxPassword.Name = "txtboxPassword";
            txtboxPassword.PlaceholderText = "Password";
            txtboxPassword.Size = new Size(125, 27);
            txtboxPassword.TabIndex = 4;
            txtboxPassword.UseSystemPasswordChar = true;
            // 
            // txtTitle
            // 
            txtTitle.AutoSize = true;
            txtTitle.Font = new Font("Segoe UI", 18F, FontStyle.Regular, GraphicsUnit.Point, 0);
            txtTitle.Location = new Point(142, 47);
            txtTitle.Name = "txtTitle";
            txtTitle.Size = new Size(157, 41);
            txtTitle.TabIndex = 5;
            txtTitle.Text = "DAT Game";
            txtTitle.TextAlign = ContentAlignment.TopCenter;
            // 
            // LoginForm
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(450, 269);
            Controls.Add(txtTitle);
            Controls.Add(txtboxPassword);
            Controls.Add(txtboxUsername);
            Controls.Add(btnSubmit);
            MaximizeBox = false;
            Name = "LoginForm";
            StartPosition = FormStartPosition.CenterScreen;
            Text = "Game";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Button btnSubmit;
        private TextBox txtboxUsername;
        private TextBox txtboxPassword;
        private Label txtTitle;
    }
}
