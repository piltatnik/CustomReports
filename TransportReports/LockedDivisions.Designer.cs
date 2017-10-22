namespace TransportReports
{
    partial class LockedDivisions
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
            this.pnlButtons = new System.Windows.Forms.Panel();
            this.btnCancel = new System.Windows.Forms.Button();
            this.btnOk = new System.Windows.Forms.Button();
            this.dgvLockedDivisions = new System.Windows.Forms.DataGridView();
            this.colId = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.colName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.colIsLocked = new System.Windows.Forms.DataGridViewCheckBoxColumn();
            this.pnlButtons.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvLockedDivisions)).BeginInit();
            this.SuspendLayout();
            // 
            // pnlButtons
            // 
            this.pnlButtons.Controls.Add(this.btnCancel);
            this.pnlButtons.Controls.Add(this.btnOk);
            this.pnlButtons.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlButtons.Location = new System.Drawing.Point(0, 463);
            this.pnlButtons.Name = "pnlButtons";
            this.pnlButtons.Size = new System.Drawing.Size(999, 35);
            this.pnlButtons.TabIndex = 0;
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.Location = new System.Drawing.Point(912, 6);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(75, 23);
            this.btnCancel.TabIndex = 1;
            this.btnCancel.Text = "Отмена";
            this.btnCancel.UseVisualStyleBackColor = true;
            // 
            // btnOk
            // 
            this.btnOk.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOk.Enabled = false;
            this.btnOk.Location = new System.Drawing.Point(831, 6);
            this.btnOk.Name = "btnOk";
            this.btnOk.Size = new System.Drawing.Size(75, 23);
            this.btnOk.TabIndex = 0;
            this.btnOk.Text = "ОК";
            this.btnOk.UseVisualStyleBackColor = true;
            this.btnOk.Click += new System.EventHandler(this.btnOk_Click);
            // 
            // dgvLockedDivisions
            // 
            this.dgvLockedDivisions.AllowUserToAddRows = false;
            this.dgvLockedDivisions.AllowUserToDeleteRows = false;
            this.dgvLockedDivisions.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvLockedDivisions.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.colId,
            this.colName,
            this.colIsLocked});
            this.dgvLockedDivisions.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvLockedDivisions.Location = new System.Drawing.Point(0, 0);
            this.dgvLockedDivisions.Name = "dgvLockedDivisions";
            this.dgvLockedDivisions.RowHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
            this.dgvLockedDivisions.RowHeadersVisible = false;
            this.dgvLockedDivisions.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvLockedDivisions.Size = new System.Drawing.Size(999, 463);
            this.dgvLockedDivisions.TabIndex = 1;
            this.dgvLockedDivisions.CellBeginEdit += new System.Windows.Forms.DataGridViewCellCancelEventHandler(this.dgvLockedDivisions_CellBeginEdit);
            // 
            // colId
            // 
            this.colId.DataPropertyName = "id";
            this.colId.HeaderText = "Идентификатор подразделения";
            this.colId.Name = "colId";
            this.colId.ReadOnly = true;
            this.colId.Width = 170;
            // 
            // colName
            // 
            this.colName.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.colName.DataPropertyName = "name";
            this.colName.HeaderText = "Наименование подразделения";
            this.colName.Name = "colName";
            this.colName.ReadOnly = true;
            // 
            // colIsLocked
            // 
            this.colIsLocked.DataPropertyName = "is_locked";
            this.colIsLocked.FalseValue = "N";
            this.colIsLocked.HeaderText = "Заблокирован";
            this.colIsLocked.Name = "colIsLocked";
            this.colIsLocked.TrueValue = "Y";
            // 
            // LockedDivisions
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(999, 498);
            this.Controls.Add(this.dgvLockedDivisions);
            this.Controls.Add(this.pnlButtons);
            this.Name = "LockedDivisions";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Список заблокированных подразделений";
            this.Load += new System.EventHandler(this.LockedDivisions_Load);
            this.pnlButtons.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvLockedDivisions)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel pnlButtons;
        private System.Windows.Forms.DataGridView dgvLockedDivisions;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnOk;
        private System.Windows.Forms.DataGridViewTextBoxColumn colId;
        private System.Windows.Forms.DataGridViewTextBoxColumn colName;
        private System.Windows.Forms.DataGridViewCheckBoxColumn colIsLocked;
    }
}