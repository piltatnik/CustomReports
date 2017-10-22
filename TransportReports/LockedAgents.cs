using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Xml.Linq;
using Oracle.DataAccess.Client;

namespace TransportReports
{
    

    public partial class LockedAgents : Form
    {
        private readonly OracleConnection _connection;

        public LockedAgents(OracleConnection connection)
        {
            InitializeComponent();
            _connection = connection;
        }

        private void LoadLockedAgents ()
        {
            dgvLockedAgents.DataSource = DatabaseUtils.FillDataView(_connection, Constants.ConstGetLockedAgentsList);
        }

        private void SetLockedState()
        {
            XElement root = new XElement("agents");
            foreach (DataGridViewRow row in dgvLockedAgents.Rows)
            {
                root.Add(new XElement("agent", 
                    new XElement("id", Routines.GetString(row.Cells["colId"].Value)),
                    new XElement("state", Routines.GetString(row.Cells["colIsLocked"].Value))
                    ));
            }
            DialogResult = 
            DatabaseUtils.CallProcedure(_connection, "pkg$trep_reports.setagentlockedstate",
                new OracleParameter[]
                {
                    new OracleParameter()
                    {
                        ParameterName = "pAgentsStateList",
                        OracleDbType = OracleDbType.Clob,
                        Value = new XDocument(root).ToString(SaveOptions.DisableFormatting)
                    }
                }) ? DialogResult.OK : DialogResult.Cancel;
        }

        private void LockedAgents_Load(object sender, EventArgs e)
        {
            LoadLockedAgents();
        }

        private void btnOk_Click(object sender, EventArgs e)
        {
            SetLockedState();
        }

        private void dgvLockedAgents_CellBeginEdit(object sender, DataGridViewCellCancelEventArgs e)
        {
            btnOk.Enabled = true;
        }
    }
}
