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
    

    public partial class LockedDivisions : Form
    {
        private readonly OracleConnection _connection;

        public LockedDivisions(OracleConnection connection)
        {
            InitializeComponent();
            _connection = connection;
        }

        private void LoadLockedDivisions ()
        {
            dgvLockedDivisions.DataSource = DatabaseUtils.FillDataView(_connection, Constants.ConstGetLockedDivisionsList);
        }

        private void SetLockedState()
        {
            XElement root = new XElement("divisions");
            foreach (DataGridViewRow row in dgvLockedDivisions.Rows)
            {
                root.Add(new XElement("division", 
                    new XElement("id", Routines.GetString(row.Cells["colId"].Value)),
                    new XElement("state", Routines.GetString(row.Cells["colIsLocked"].Value))
                    ));
            }
            DialogResult = 
            DatabaseUtils.CallProcedure(_connection, "pkg$trep_reports.setdivisionlockedstate",
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

        private void LockedDivisions_Load(object sender, EventArgs e)
        {
            LoadLockedDivisions();
        }

        private void btnOk_Click(object sender, EventArgs e)
        {
            SetLockedState();
        }

        private void dgvLockedDivisions_CellBeginEdit(object sender, DataGridViewCellCancelEventArgs e)
        {
            btnOk.Enabled = true;
        }
    }
}
