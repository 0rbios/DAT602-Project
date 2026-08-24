namespace DATGame
{
    partial class Admin
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
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
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            btnBack = new Button();
            btnPlayers = new Button();
            btnRooms = new Button();
            btnCloseRoom = new Button();
            dataRooms = new DataGridView();
            lblAccountName = new Label();
            txtRoomInfo = new TextBox();
            ((System.ComponentModel.ISupportInitialize)dataRooms).BeginInit();
            SuspendLayout();
            // 
            // btnBack
            // 
            btnBack.Location = new Point(12, 12);
            btnBack.Name = "btnBack";
            btnBack.Size = new Size(124, 38);
            btnBack.TabIndex = 0;
            btnBack.Text = "Back to Menu";
            btnBack.UseVisualStyleBackColor = true;
            btnBack.Click += BackClicked;
            // 
            // btnPlayers
            // 
            btnPlayers.Location = new Point(586, 390);
            btnPlayers.Name = "btnPlayers";
            btnPlayers.Size = new Size(97, 29);
            btnPlayers.TabIndex = 1;
            btnPlayers.Text = "Players";
            btnPlayers.UseVisualStyleBackColor = true;
            // 
            // btnRooms
            // 
            btnRooms.Location = new Point(691, 390);
            btnRooms.Name = "btnRooms";
            btnRooms.Size = new Size(97, 29);
            btnRooms.TabIndex = 2;
            btnRooms.Text = "Rooms";
            btnRooms.UseVisualStyleBackColor = true;
            // 
            // btnCloseRoom
            // 
            btnCloseRoom.Location = new Point(466, 184);
            btnCloseRoom.Name = "btnCloseRoom";
            btnCloseRoom.Size = new Size(114, 29);
            btnCloseRoom.TabIndex = 3;
            btnCloseRoom.Text = "Close Room";
            btnCloseRoom.UseVisualStyleBackColor = true;
            // 
            // dataRooms
            // 
            dataRooms.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dataRooms.Location = new Point(586, 12);
            dataRooms.Name = "dataRooms";
            dataRooms.RowHeadersWidth = 51;
            dataRooms.Size = new Size(202, 374);
            dataRooms.TabIndex = 4;
            // 
            // lblAccountName
            // 
            lblAccountName.AutoSize = true;
            lblAccountName.ForeColor = SystemColors.ControlDarkDark;
            lblAccountName.Location = new Point(12, 421);
            lblAccountName.Name = "lblAccountName";
            lblAccountName.Size = new Size(222, 20);
            lblAccountName.TabIndex = 5;
            lblAccountName.Text = "[Account Name] (Administrator)";
            // 
            // txtRoomInfo
            // 
            txtRoomInfo.Location = new Point(142, 12);
            txtRoomInfo.Multiline = true;
            txtRoomInfo.Name = "txtRoomInfo";
            txtRoomInfo.ReadOnly = true;
            txtRoomInfo.Size = new Size(438, 166);
            txtRoomInfo.TabIndex = 6;
            txtRoomInfo.TextAlign = HorizontalAlignment.Center;
            // 
            // Admin
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(800, 450);
            Controls.Add(txtRoomInfo);
            Controls.Add(lblAccountName);
            Controls.Add(dataRooms);
            Controls.Add(btnCloseRoom);
            Controls.Add(btnRooms);
            Controls.Add(btnPlayers);
            Controls.Add(btnBack);
            Name = "Admin";
            Text = "Admin";
            ((System.ComponentModel.ISupportInitialize)dataRooms).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Button btnBack;
        private Button btnPlayers;
        private Button btnRooms;
        private Button btnCloseRoom;
        private DataGridView dataRooms;
        private Label lblAccountName;
        private TextBox txtRoomInfo;
    }
}