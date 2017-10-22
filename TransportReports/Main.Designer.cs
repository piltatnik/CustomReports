namespace TransportReports
{
    partial class Main
    {
                /// <summary>
        /// Обязательная переменная конструктора.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Освободить все используемые ресурсы.
        /// </summary>
        /// <param name="disposing">истинно, если управляемый ресурс должен быть удален; иначе ложно.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Код, автоматически созданный конструктором форм Windows

        /// <summary>
        /// Требуемый метод для поддержки конструктора — не изменяйте 
        /// содержимое этого метода с помощью редактора кода.
        /// </summary>
        private void InitializeComponent()
        {
            this.btnRun = new System.Windows.Forms.Button();
            this.scReportListReportParam = new System.Windows.Forms.SplitContainer();
            this.scReportListRunParam = new System.Windows.Forms.SplitContainer();
            this.tvReports = new System.Windows.Forms.TreeView();
            this.chbOpenExcelReport = new System.Windows.Forms.CheckBox();
            this.chbColorizeExcelReport = new System.Windows.Forms.CheckBox();
            this.pnlButtons = new System.Windows.Forms.Panel();
            this.btnSetAgents = new System.Windows.Forms.Button();
            this.tcReportParams = new System.Windows.Forms.TabControl();
            this.tpActivePass = new System.Windows.Forms.TabPage();
            this.gbActivePassActivation = new System.Windows.Forms.GroupBox();
            this.lbActivePassActivationBeginDate = new System.Windows.Forms.Label();
            this.dtActivePassActivationBeginDate = new System.Windows.Forms.DateTimePicker();
            this.lbActivePassActivationEndDate = new System.Windows.Forms.Label();
            this.dtActivePassActivationEndDate = new System.Windows.Forms.DateTimePicker();
            this.gbActivePassPass = new System.Windows.Forms.GroupBox();
            this.lbActivePassPassBeginDate = new System.Windows.Forms.Label();
            this.dtActivePassPassEndDate = new System.Windows.Forms.DateTimePicker();
            this.lbActivePassPassEndDate = new System.Windows.Forms.Label();
            this.dtActivePassPassBeginDate = new System.Windows.Forms.DateTimePicker();
            this.tpActive = new System.Windows.Forms.TabPage();
            this.gbActiveActivation = new System.Windows.Forms.GroupBox();
            this.lbActiveActivationBeginDate = new System.Windows.Forms.Label();
            this.dtActiveActivationBeginDate = new System.Windows.Forms.DateTimePicker();
            this.lbActiveActvationEndDate = new System.Windows.Forms.Label();
            this.dtActiveActivationEndDate = new System.Windows.Forms.DateTimePicker();
            this.tpPass = new System.Windows.Forms.TabPage();
            this.gbPass = new System.Windows.Forms.GroupBox();
            this.lbPassPassBeginDate = new System.Windows.Forms.Label();
            this.dtPassPassBeginDate = new System.Windows.Forms.DateTimePicker();
            this.lbPassPassEndDate = new System.Windows.Forms.Label();
            this.dtPassPassEndDate = new System.Windows.Forms.DateTimePicker();
            this.tpTransportVehicle = new System.Windows.Forms.TabPage();
            this.tpTransportCard = new System.Windows.Forms.TabPage();
            this.tpOrganisation = new System.Windows.Forms.TabPage();
            this.tpRoute = new System.Windows.Forms.TabPage();
            this.tpTerminal = new System.Windows.Forms.TabPage();
            this.tpEmpty = new System.Windows.Forms.TabPage();
            this.ssUserInfo = new System.Windows.Forms.StatusStrip();
            this.tsslUserInfoText = new System.Windows.Forms.ToolStripStatusLabel();
            this.btnSetDivisions = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.scReportListReportParam)).BeginInit();
            this.scReportListReportParam.Panel1.SuspendLayout();
            this.scReportListReportParam.Panel2.SuspendLayout();
            this.scReportListReportParam.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.scReportListRunParam)).BeginInit();
            this.scReportListRunParam.Panel1.SuspendLayout();
            this.scReportListRunParam.Panel2.SuspendLayout();
            this.scReportListRunParam.SuspendLayout();
            this.pnlButtons.SuspendLayout();
            this.tcReportParams.SuspendLayout();
            this.tpActivePass.SuspendLayout();
            this.gbActivePassActivation.SuspendLayout();
            this.gbActivePassPass.SuspendLayout();
            this.tpActive.SuspendLayout();
            this.gbActiveActivation.SuspendLayout();
            this.tpPass.SuspendLayout();
            this.gbPass.SuspendLayout();
            this.ssUserInfo.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnRun
            // 
            this.btnRun.Dock = System.Windows.Forms.DockStyle.Fill;
            this.btnRun.Location = new System.Drawing.Point(318, 0);
            this.btnRun.Name = "btnRun";
            this.btnRun.Size = new System.Drawing.Size(179, 26);
            this.btnRun.TabIndex = 0;
            this.btnRun.Text = "Сформировать";
            this.btnRun.UseVisualStyleBackColor = true;
            this.btnRun.Click += new System.EventHandler(this.btnRun_Click);
            // 
            // scReportListReportParam
            // 
            this.scReportListReportParam.Dock = System.Windows.Forms.DockStyle.Fill;
            this.scReportListReportParam.Location = new System.Drawing.Point(0, 0);
            this.scReportListReportParam.Name = "scReportListReportParam";
            // 
            // scReportListReportParam.Panel1
            // 
            this.scReportListReportParam.Panel1.Controls.Add(this.scReportListRunParam);
            // 
            // scReportListReportParam.Panel2
            // 
            this.scReportListReportParam.Panel2.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.scReportListReportParam.Panel2.Controls.Add(this.tcReportParams);
            this.scReportListReportParam.Size = new System.Drawing.Size(873, 382);
            this.scReportListReportParam.SplitterDistance = 497;
            this.scReportListReportParam.TabIndex = 3;
            this.scReportListReportParam.TabStop = false;
            // 
            // scReportListRunParam
            // 
            this.scReportListRunParam.Dock = System.Windows.Forms.DockStyle.Fill;
            this.scReportListRunParam.Location = new System.Drawing.Point(0, 0);
            this.scReportListRunParam.Name = "scReportListRunParam";
            this.scReportListRunParam.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // scReportListRunParam.Panel1
            // 
            this.scReportListRunParam.Panel1.Controls.Add(this.tvReports);
            // 
            // scReportListRunParam.Panel2
            // 
            this.scReportListRunParam.Panel2.Controls.Add(this.chbOpenExcelReport);
            this.scReportListRunParam.Panel2.Controls.Add(this.chbColorizeExcelReport);
            this.scReportListRunParam.Panel2.Controls.Add(this.pnlButtons);
            this.scReportListRunParam.Size = new System.Drawing.Size(497, 382);
            this.scReportListRunParam.SplitterDistance = 270;
            this.scReportListRunParam.TabIndex = 4;
            // 
            // tvReports
            // 
            this.tvReports.BackColor = System.Drawing.SystemColors.Control;
            this.tvReports.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.tvReports.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tvReports.DrawMode = System.Windows.Forms.TreeViewDrawMode.OwnerDrawText;
            this.tvReports.Location = new System.Drawing.Point(0, 0);
            this.tvReports.Name = "tvReports";
            this.tvReports.Size = new System.Drawing.Size(497, 270);
            this.tvReports.TabIndex = 3;
            this.tvReports.DrawNode += new System.Windows.Forms.DrawTreeNodeEventHandler(this.tvReports_DrawNode);
            this.tvReports.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.tvReports_AfterSelect);
            // 
            // chbOpenExcelReport
            // 
            this.chbOpenExcelReport.AutoSize = true;
            this.chbOpenExcelReport.Location = new System.Drawing.Point(12, 34);
            this.chbOpenExcelReport.Name = "chbOpenExcelReport";
            this.chbOpenExcelReport.Size = new System.Drawing.Size(224, 17);
            this.chbOpenExcelReport.TabIndex = 2;
            this.chbOpenExcelReport.Text = "Открывать отчет после формирования";
            this.chbOpenExcelReport.UseVisualStyleBackColor = true;
            // 
            // chbColorizeExcelReport
            // 
            this.chbColorizeExcelReport.AutoSize = true;
            this.chbColorizeExcelReport.Checked = true;
            this.chbColorizeExcelReport.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chbColorizeExcelReport.Location = new System.Drawing.Point(12, 13);
            this.chbColorizeExcelReport.Name = "chbColorizeExcelReport";
            this.chbColorizeExcelReport.Size = new System.Drawing.Size(253, 17);
            this.chbColorizeExcelReport.TabIndex = 1;
            this.chbColorizeExcelReport.Text = "Раскрашивать выгружаемые отчеты цветом";
            this.chbColorizeExcelReport.UseVisualStyleBackColor = true;
            // 
            // pnlButtons
            // 
            this.pnlButtons.Controls.Add(this.btnRun);
            this.pnlButtons.Controls.Add(this.btnSetDivisions);
            this.pnlButtons.Controls.Add(this.btnSetAgents);
            this.pnlButtons.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlButtons.Location = new System.Drawing.Point(0, 82);
            this.pnlButtons.Name = "pnlButtons";
            this.pnlButtons.Size = new System.Drawing.Size(497, 26);
            this.pnlButtons.TabIndex = 3;
            // 
            // btnSetAgents
            // 
            this.btnSetAgents.Dock = System.Windows.Forms.DockStyle.Left;
            this.btnSetAgents.Location = new System.Drawing.Point(0, 0);
            this.btnSetAgents.Name = "btnSetAgents";
            this.btnSetAgents.Size = new System.Drawing.Size(137, 26);
            this.btnSetAgents.TabIndex = 1;
            this.btnSetAgents.Text = "Заблокировать агентов";
            this.btnSetAgents.UseVisualStyleBackColor = true;
            this.btnSetAgents.Click += new System.EventHandler(this.btnSetAgents_Click);
            // 
            // tcReportParams
            // 
            this.tcReportParams.Appearance = System.Windows.Forms.TabAppearance.FlatButtons;
            this.tcReportParams.Controls.Add(this.tpActivePass);
            this.tcReportParams.Controls.Add(this.tpActive);
            this.tcReportParams.Controls.Add(this.tpPass);
            this.tcReportParams.Controls.Add(this.tpTransportVehicle);
            this.tcReportParams.Controls.Add(this.tpTransportCard);
            this.tcReportParams.Controls.Add(this.tpOrganisation);
            this.tcReportParams.Controls.Add(this.tpRoute);
            this.tcReportParams.Controls.Add(this.tpTerminal);
            this.tcReportParams.Controls.Add(this.tpEmpty);
            this.tcReportParams.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tcReportParams.ItemSize = new System.Drawing.Size(0, 1);
            this.tcReportParams.Location = new System.Drawing.Point(0, 0);
            this.tcReportParams.Multiline = true;
            this.tcReportParams.Name = "tcReportParams";
            this.tcReportParams.Padding = new System.Drawing.Point(1, 1);
            this.tcReportParams.SelectedIndex = 0;
            this.tcReportParams.Size = new System.Drawing.Size(372, 382);
            this.tcReportParams.SizeMode = System.Windows.Forms.TabSizeMode.Fixed;
            this.tcReportParams.TabIndex = 3;
            this.tcReportParams.TabStop = false;
            // 
            // tpActivePass
            // 
            this.tpActivePass.BackColor = System.Drawing.SystemColors.Control;
            this.tpActivePass.Controls.Add(this.gbActivePassActivation);
            this.tpActivePass.Controls.Add(this.gbActivePassPass);
            this.tpActivePass.Location = new System.Drawing.Point(4, 5);
            this.tpActivePass.Name = "tpActivePass";
            this.tpActivePass.Padding = new System.Windows.Forms.Padding(3);
            this.tpActivePass.Size = new System.Drawing.Size(364, 373);
            this.tpActivePass.TabIndex = 0;
            // 
            // gbActivePassActivation
            // 
            this.gbActivePassActivation.Controls.Add(this.lbActivePassActivationBeginDate);
            this.gbActivePassActivation.Controls.Add(this.dtActivePassActivationBeginDate);
            this.gbActivePassActivation.Controls.Add(this.lbActivePassActivationEndDate);
            this.gbActivePassActivation.Controls.Add(this.dtActivePassActivationEndDate);
            this.gbActivePassActivation.Location = new System.Drawing.Point(12, 18);
            this.gbActivePassActivation.Margin = new System.Windows.Forms.Padding(9, 15, 3, 3);
            this.gbActivePassActivation.Name = "gbActivePassActivation";
            this.gbActivePassActivation.Size = new System.Drawing.Size(284, 132);
            this.gbActivePassActivation.TabIndex = 1;
            this.gbActivePassActivation.TabStop = false;
            this.gbActivePassActivation.Text = "Активация карты (включительно)";
            // 
            // lbActivePassActivationBeginDate
            // 
            this.lbActivePassActivationBeginDate.AutoSize = true;
            this.lbActivePassActivationBeginDate.Location = new System.Drawing.Point(6, 26);
            this.lbActivePassActivationBeginDate.Name = "lbActivePassActivationBeginDate";
            this.lbActivePassActivationBeginDate.Size = new System.Drawing.Size(130, 13);
            this.lbActivePassActivationBeginDate.TabIndex = 6;
            this.lbActivePassActivationBeginDate.Text = "Дата начала активации:";
            // 
            // dtActivePassActivationBeginDate
            // 
            this.dtActivePassActivationBeginDate.CustomFormat = "dd.MM.yyyy HH:mm:ss";
            this.dtActivePassActivationBeginDate.Format = System.Windows.Forms.DateTimePickerFormat.Short;
            this.dtActivePassActivationBeginDate.Location = new System.Drawing.Point(9, 46);
            this.dtActivePassActivationBeginDate.Name = "dtActivePassActivationBeginDate";
            this.dtActivePassActivationBeginDate.Size = new System.Drawing.Size(200, 20);
            this.dtActivePassActivationBeginDate.TabIndex = 3;
            // 
            // lbActivePassActivationEndDate
            // 
            this.lbActivePassActivationEndDate.AutoSize = true;
            this.lbActivePassActivationEndDate.Location = new System.Drawing.Point(6, 76);
            this.lbActivePassActivationEndDate.Name = "lbActivePassActivationEndDate";
            this.lbActivePassActivationEndDate.Size = new System.Drawing.Size(148, 13);
            this.lbActivePassActivationEndDate.TabIndex = 7;
            this.lbActivePassActivationEndDate.Text = "Дата окончания активации:";
            // 
            // dtActivePassActivationEndDate
            // 
            this.dtActivePassActivationEndDate.CustomFormat = "dd.MM.yyyy HH:mm:ss";
            this.dtActivePassActivationEndDate.Format = System.Windows.Forms.DateTimePickerFormat.Short;
            this.dtActivePassActivationEndDate.Location = new System.Drawing.Point(9, 96);
            this.dtActivePassActivationEndDate.Name = "dtActivePassActivationEndDate";
            this.dtActivePassActivationEndDate.Size = new System.Drawing.Size(200, 20);
            this.dtActivePassActivationEndDate.TabIndex = 4;
            // 
            // gbActivePassPass
            // 
            this.gbActivePassPass.Controls.Add(this.lbActivePassPassBeginDate);
            this.gbActivePassPass.Controls.Add(this.dtActivePassPassEndDate);
            this.gbActivePassPass.Controls.Add(this.lbActivePassPassEndDate);
            this.gbActivePassPass.Controls.Add(this.dtActivePassPassBeginDate);
            this.gbActivePassPass.Location = new System.Drawing.Point(12, 168);
            this.gbActivePassPass.Margin = new System.Windows.Forms.Padding(9, 15, 3, 3);
            this.gbActivePassPass.Name = "gbActivePassPass";
            this.gbActivePassPass.Size = new System.Drawing.Size(284, 132);
            this.gbActivePassPass.TabIndex = 2;
            this.gbActivePassPass.TabStop = false;
            this.gbActivePassPass.Text = "Проезд по картам (начальная дата включительно)";
            // 
            // lbActivePassPassBeginDate
            // 
            this.lbActivePassPassBeginDate.AutoSize = true;
            this.lbActivePassPassBeginDate.Location = new System.Drawing.Point(6, 26);
            this.lbActivePassPassBeginDate.Name = "lbActivePassPassBeginDate";
            this.lbActivePassPassBeginDate.Size = new System.Drawing.Size(172, 13);
            this.lbActivePassPassBeginDate.TabIndex = 8;
            this.lbActivePassPassBeginDate.Text = "Дата начала отчетного периода:";
            // 
            // dtActivePassPassEndDate
            // 
            this.dtActivePassPassEndDate.CustomFormat = "dd.MM.yyyy HH:mm:ss";
            this.dtActivePassPassEndDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtActivePassPassEndDate.Location = new System.Drawing.Point(9, 96);
            this.dtActivePassPassEndDate.Name = "dtActivePassPassEndDate";
            this.dtActivePassPassEndDate.Size = new System.Drawing.Size(200, 20);
            this.dtActivePassPassEndDate.TabIndex = 6;
            // 
            // lbActivePassPassEndDate
            // 
            this.lbActivePassPassEndDate.AutoSize = true;
            this.lbActivePassPassEndDate.Location = new System.Drawing.Point(6, 76);
            this.lbActivePassPassEndDate.Name = "lbActivePassPassEndDate";
            this.lbActivePassPassEndDate.Size = new System.Drawing.Size(190, 13);
            this.lbActivePassPassEndDate.TabIndex = 9;
            this.lbActivePassPassEndDate.Text = "Дата окончания отчетного периода:";
            // 
            // dtActivePassPassBeginDate
            // 
            this.dtActivePassPassBeginDate.CustomFormat = "dd.MM.yyyy HH:mm:ss";
            this.dtActivePassPassBeginDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtActivePassPassBeginDate.Location = new System.Drawing.Point(9, 46);
            this.dtActivePassPassBeginDate.Name = "dtActivePassPassBeginDate";
            this.dtActivePassPassBeginDate.Size = new System.Drawing.Size(200, 20);
            this.dtActivePassPassBeginDate.TabIndex = 5;
            // 
            // tpActive
            // 
            this.tpActive.Controls.Add(this.gbActiveActivation);
            this.tpActive.Location = new System.Drawing.Point(4, 5);
            this.tpActive.Name = "tpActive";
            this.tpActive.Padding = new System.Windows.Forms.Padding(3);
            this.tpActive.Size = new System.Drawing.Size(364, 373);
            this.tpActive.TabIndex = 1;
            this.tpActive.UseVisualStyleBackColor = true;
            // 
            // gbActiveActivation
            // 
            this.gbActiveActivation.Controls.Add(this.lbActiveActivationBeginDate);
            this.gbActiveActivation.Controls.Add(this.dtActiveActivationBeginDate);
            this.gbActiveActivation.Controls.Add(this.lbActiveActvationEndDate);
            this.gbActiveActivation.Controls.Add(this.dtActiveActivationEndDate);
            this.gbActiveActivation.Location = new System.Drawing.Point(12, 15);
            this.gbActiveActivation.Margin = new System.Windows.Forms.Padding(9, 15, 3, 3);
            this.gbActiveActivation.Name = "gbActiveActivation";
            this.gbActiveActivation.Size = new System.Drawing.Size(284, 132);
            this.gbActiveActivation.TabIndex = 2;
            this.gbActiveActivation.TabStop = false;
            this.gbActiveActivation.Text = "Активация карты (включительно)";
            // 
            // lbActiveActivationBeginDate
            // 
            this.lbActiveActivationBeginDate.AutoSize = true;
            this.lbActiveActivationBeginDate.Location = new System.Drawing.Point(6, 26);
            this.lbActiveActivationBeginDate.Name = "lbActiveActivationBeginDate";
            this.lbActiveActivationBeginDate.Size = new System.Drawing.Size(130, 13);
            this.lbActiveActivationBeginDate.TabIndex = 6;
            this.lbActiveActivationBeginDate.Text = "Дата начала активации:";
            // 
            // dtActiveActivationBeginDate
            // 
            this.dtActiveActivationBeginDate.CustomFormat = "dd.MM.yyyy HH:mm:ss";
            this.dtActiveActivationBeginDate.Format = System.Windows.Forms.DateTimePickerFormat.Short;
            this.dtActiveActivationBeginDate.Location = new System.Drawing.Point(9, 46);
            this.dtActiveActivationBeginDate.Name = "dtActiveActivationBeginDate";
            this.dtActiveActivationBeginDate.Size = new System.Drawing.Size(200, 20);
            this.dtActiveActivationBeginDate.TabIndex = 3;
            // 
            // lbActiveActvationEndDate
            // 
            this.lbActiveActvationEndDate.AutoSize = true;
            this.lbActiveActvationEndDate.Location = new System.Drawing.Point(6, 76);
            this.lbActiveActvationEndDate.Name = "lbActiveActvationEndDate";
            this.lbActiveActvationEndDate.Size = new System.Drawing.Size(148, 13);
            this.lbActiveActvationEndDate.TabIndex = 7;
            this.lbActiveActvationEndDate.Text = "Дата окончания активации:";
            // 
            // dtActiveActivationEndDate
            // 
            this.dtActiveActivationEndDate.CustomFormat = "dd.MM.yyyy HH:mm:ss";
            this.dtActiveActivationEndDate.Format = System.Windows.Forms.DateTimePickerFormat.Short;
            this.dtActiveActivationEndDate.Location = new System.Drawing.Point(9, 96);
            this.dtActiveActivationEndDate.Name = "dtActiveActivationEndDate";
            this.dtActiveActivationEndDate.Size = new System.Drawing.Size(200, 20);
            this.dtActiveActivationEndDate.TabIndex = 4;
            // 
            // tpPass
            // 
            this.tpPass.Controls.Add(this.gbPass);
            this.tpPass.Location = new System.Drawing.Point(4, 5);
            this.tpPass.Name = "tpPass";
            this.tpPass.Padding = new System.Windows.Forms.Padding(3);
            this.tpPass.Size = new System.Drawing.Size(364, 373);
            this.tpPass.TabIndex = 4;
            this.tpPass.UseVisualStyleBackColor = true;
            // 
            // gbPass
            // 
            this.gbPass.Controls.Add(this.lbPassPassBeginDate);
            this.gbPass.Controls.Add(this.dtPassPassBeginDate);
            this.gbPass.Controls.Add(this.lbPassPassEndDate);
            this.gbPass.Controls.Add(this.dtPassPassEndDate);
            this.gbPass.Location = new System.Drawing.Point(12, 19);
            this.gbPass.Margin = new System.Windows.Forms.Padding(9, 15, 3, 3);
            this.gbPass.Name = "gbPass";
            this.gbPass.Size = new System.Drawing.Size(284, 132);
            this.gbPass.TabIndex = 3;
            this.gbPass.TabStop = false;
            this.gbPass.Text = "Проезд по картам (начальная дата включительно)";
            // 
            // lbPassPassBeginDate
            // 
            this.lbPassPassBeginDate.AutoSize = true;
            this.lbPassPassBeginDate.Location = new System.Drawing.Point(6, 26);
            this.lbPassPassBeginDate.Name = "lbPassPassBeginDate";
            this.lbPassPassBeginDate.Size = new System.Drawing.Size(172, 13);
            this.lbPassPassBeginDate.TabIndex = 8;
            this.lbPassPassBeginDate.Text = "Дата начала отчетного периода:";
            // 
            // dtPassPassBeginDate
            // 
            this.dtPassPassBeginDate.CustomFormat = "dd.MM.yyyy HH:mm:ss";
            this.dtPassPassBeginDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtPassPassBeginDate.Location = new System.Drawing.Point(9, 46);
            this.dtPassPassBeginDate.Name = "dtPassPassBeginDate";
            this.dtPassPassBeginDate.Size = new System.Drawing.Size(200, 20);
            this.dtPassPassBeginDate.TabIndex = 5;
            // 
            // lbPassPassEndDate
            // 
            this.lbPassPassEndDate.AutoSize = true;
            this.lbPassPassEndDate.Location = new System.Drawing.Point(6, 76);
            this.lbPassPassEndDate.Name = "lbPassPassEndDate";
            this.lbPassPassEndDate.Size = new System.Drawing.Size(190, 13);
            this.lbPassPassEndDate.TabIndex = 9;
            this.lbPassPassEndDate.Text = "Дата окончания отчетного периода:";
            // 
            // dtPassPassEndDate
            // 
            this.dtPassPassEndDate.CustomFormat = "dd.MM.yyyy HH:mm:ss";
            this.dtPassPassEndDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtPassPassEndDate.Location = new System.Drawing.Point(9, 96);
            this.dtPassPassEndDate.Name = "dtPassPassEndDate";
            this.dtPassPassEndDate.Size = new System.Drawing.Size(200, 20);
            this.dtPassPassEndDate.TabIndex = 6;
            // 
            // tpTransportVehicle
            // 
            this.tpTransportVehicle.Location = new System.Drawing.Point(4, 5);
            this.tpTransportVehicle.Name = "tpTransportVehicle";
            this.tpTransportVehicle.Padding = new System.Windows.Forms.Padding(3);
            this.tpTransportVehicle.Size = new System.Drawing.Size(364, 373);
            this.tpTransportVehicle.TabIndex = 2;
            this.tpTransportVehicle.UseVisualStyleBackColor = true;
            // 
            // tpTransportCard
            // 
            this.tpTransportCard.Location = new System.Drawing.Point(4, 5);
            this.tpTransportCard.Name = "tpTransportCard";
            this.tpTransportCard.Padding = new System.Windows.Forms.Padding(3);
            this.tpTransportCard.Size = new System.Drawing.Size(364, 373);
            this.tpTransportCard.TabIndex = 3;
            this.tpTransportCard.UseVisualStyleBackColor = true;
            // 
            // tpOrganisation
            // 
            this.tpOrganisation.Location = new System.Drawing.Point(4, 5);
            this.tpOrganisation.Name = "tpOrganisation";
            this.tpOrganisation.Padding = new System.Windows.Forms.Padding(3);
            this.tpOrganisation.Size = new System.Drawing.Size(364, 373);
            this.tpOrganisation.TabIndex = 5;
            this.tpOrganisation.UseVisualStyleBackColor = true;
            // 
            // tpRoute
            // 
            this.tpRoute.Location = new System.Drawing.Point(4, 5);
            this.tpRoute.Name = "tpRoute";
            this.tpRoute.Padding = new System.Windows.Forms.Padding(3);
            this.tpRoute.Size = new System.Drawing.Size(364, 373);
            this.tpRoute.TabIndex = 6;
            this.tpRoute.UseVisualStyleBackColor = true;
            // 
            // tpTerminal
            // 
            this.tpTerminal.Location = new System.Drawing.Point(4, 5);
            this.tpTerminal.Name = "tpTerminal";
            this.tpTerminal.Padding = new System.Windows.Forms.Padding(3);
            this.tpTerminal.Size = new System.Drawing.Size(364, 373);
            this.tpTerminal.TabIndex = 7;
            this.tpTerminal.UseVisualStyleBackColor = true;
            // 
            // tpEmpty
            // 
            this.tpEmpty.Location = new System.Drawing.Point(4, 5);
            this.tpEmpty.Name = "tpEmpty";
            this.tpEmpty.Padding = new System.Windows.Forms.Padding(3);
            this.tpEmpty.Size = new System.Drawing.Size(364, 373);
            this.tpEmpty.TabIndex = 8;
            this.tpEmpty.UseVisualStyleBackColor = true;
            // 
            // ssUserInfo
            // 
            this.ssUserInfo.BackColor = System.Drawing.SystemColors.Control;
            this.ssUserInfo.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.ssUserInfo.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.tsslUserInfoText});
            this.ssUserInfo.Location = new System.Drawing.Point(0, 382);
            this.ssUserInfo.Name = "ssUserInfo";
            this.ssUserInfo.RenderMode = System.Windows.Forms.ToolStripRenderMode.ManagerRenderMode;
            this.ssUserInfo.Size = new System.Drawing.Size(873, 22);
            this.ssUserInfo.SizingGrip = false;
            this.ssUserInfo.Stretch = false;
            this.ssUserInfo.TabIndex = 3;
            // 
            // tsslUserInfoText
            // 
            this.tsslUserInfoText.Name = "tsslUserInfoText";
            this.tsslUserInfoText.Size = new System.Drawing.Size(0, 17);
            // 
            // btnSetDivisions
            // 
            this.btnSetDivisions.Dock = System.Windows.Forms.DockStyle.Left;
            this.btnSetDivisions.Location = new System.Drawing.Point(137, 0);
            this.btnSetDivisions.Name = "btnSetDivisions";
            this.btnSetDivisions.Size = new System.Drawing.Size(181, 26);
            this.btnSetDivisions.TabIndex = 2;
            this.btnSetDivisions.Text = "Заблокировать подразделения";
            this.btnSetDivisions.UseVisualStyleBackColor = true;
            this.btnSetDivisions.Click += new System.EventHandler(this.btnSetDivisions_Click);
            // 
            // Main
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(873, 404);
            this.Controls.Add(this.scReportListReportParam);
            this.Controls.Add(this.ssUserInfo);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "Main";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Формирование отчетов";
            this.Load += new System.EventHandler(this.Main_Load);
            this.scReportListReportParam.Panel1.ResumeLayout(false);
            this.scReportListReportParam.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.scReportListReportParam)).EndInit();
            this.scReportListReportParam.ResumeLayout(false);
            this.scReportListRunParam.Panel1.ResumeLayout(false);
            this.scReportListRunParam.Panel2.ResumeLayout(false);
            this.scReportListRunParam.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.scReportListRunParam)).EndInit();
            this.scReportListRunParam.ResumeLayout(false);
            this.pnlButtons.ResumeLayout(false);
            this.tcReportParams.ResumeLayout(false);
            this.tpActivePass.ResumeLayout(false);
            this.gbActivePassActivation.ResumeLayout(false);
            this.gbActivePassActivation.PerformLayout();
            this.gbActivePassPass.ResumeLayout(false);
            this.gbActivePassPass.PerformLayout();
            this.tpActive.ResumeLayout(false);
            this.gbActiveActivation.ResumeLayout(false);
            this.gbActiveActivation.PerformLayout();
            this.tpPass.ResumeLayout(false);
            this.gbPass.ResumeLayout(false);
            this.gbPass.PerformLayout();
            this.ssUserInfo.ResumeLayout(false);
            this.ssUserInfo.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnRun;
        private System.Windows.Forms.SplitContainer scReportListReportParam;
        private System.Windows.Forms.TreeView tvReports;
        private System.Windows.Forms.TabControl tcReportParams;
        private System.Windows.Forms.TabPage tpActivePass;
        private System.Windows.Forms.GroupBox gbActivePassActivation;
        private System.Windows.Forms.Label lbActivePassActivationBeginDate;
        private System.Windows.Forms.DateTimePicker dtActivePassActivationEndDate;
        private System.Windows.Forms.Label lbActivePassActivationEndDate;
        private System.Windows.Forms.DateTimePicker dtActivePassActivationBeginDate;
        private System.Windows.Forms.GroupBox gbActivePassPass;
        private System.Windows.Forms.Label lbActivePassPassBeginDate;
        private System.Windows.Forms.DateTimePicker dtActivePassPassEndDate;
        private System.Windows.Forms.Label lbActivePassPassEndDate;
        private System.Windows.Forms.DateTimePicker dtActivePassPassBeginDate;
        private System.Windows.Forms.TabPage tpActive;
        private System.Windows.Forms.TabPage tpRoute;
        private System.Windows.Forms.TabPage tpOrganisation;
        private System.Windows.Forms.TabPage tpTerminal;
        private System.Windows.Forms.TabPage tpPass;
        private System.Windows.Forms.TabPage tpTransportCard;
        private System.Windows.Forms.TabPage tpTransportVehicle;
        private System.Windows.Forms.TabPage tpEmpty;
        private System.Windows.Forms.GroupBox gbPass;
        private System.Windows.Forms.Label lbPassPassBeginDate;
        private System.Windows.Forms.DateTimePicker dtPassPassBeginDate;
        private System.Windows.Forms.Label lbPassPassEndDate;
        private System.Windows.Forms.DateTimePicker dtPassPassEndDate;
        private System.Windows.Forms.SplitContainer scReportListRunParam;
        private System.Windows.Forms.CheckBox chbOpenExcelReport;
        private System.Windows.Forms.CheckBox chbColorizeExcelReport;
        private System.Windows.Forms.StatusStrip ssUserInfo;
        private System.Windows.Forms.ToolStripStatusLabel tsslUserInfoText;
        private System.Windows.Forms.Panel pnlButtons;
        private System.Windows.Forms.Button btnSetAgents;
        private System.Windows.Forms.GroupBox gbActiveActivation;
        private System.Windows.Forms.Label lbActiveActivationBeginDate;
        private System.Windows.Forms.DateTimePicker dtActiveActivationBeginDate;
        private System.Windows.Forms.Label lbActiveActvationEndDate;
        private System.Windows.Forms.DateTimePicker dtActiveActivationEndDate;
        private System.Windows.Forms.Button btnSetDivisions;
    }
}