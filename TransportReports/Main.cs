using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Threading;
using System.Windows.Forms;
using OfficeOpenXml.FormulaParsing.Excel.Functions.DateTime;
using Oracle.DataAccess.Client;
using TransportReports;

namespace TransportReports
{
    public partial class Main : Form
    {
        private readonly string _database;
        private readonly string _login;
        private readonly string _password;
        private int _threadActiveCount;
        private int _threadFullCount;
        private int _threadFinishedCount;
        private int _threadWaitingCount;
        private DateTime _timeCalcBegin;
        private DateTime _timeOutputBegin;
        private bool _isEditorMode;
        private readonly OracleConnection _connection;
        private bool Lock {
            set
            {
                //btnRun.Enabled = value;
                Invoke((MethodInvoker) delegate { scReportListReportParam.Enabled = !value; });
            }
        }

        public Main(string database, string login, string password)
        {
            InitializeComponent();

            _database = database;
            _login = login;
            _password = password;
            _connection = DatabaseUtils.CreateConnection(database, login, password);
        }

        public Main(string database, string login, string password, string isEditorMode)
            : this(database, login, password)
        {
            _isEditorMode = "0".Equals(isEditorMode);
        }

        private void SetStatusText(string text)
        {
            if (InvokeRequired)
                Invoke((MethodInvoker)delegate { tsslUserInfoText.Text = text; });
            else
            {
                tsslUserInfoText.Text = text;
            }
        }

        private void UpdateStatusProgressText()
        {
            SetStatusText($"Выгружено {_threadFinishedCount}/{_threadFullCount}. " +
                          $"Прошло {(DateTime.Now - _timeOutputBegin).ToString(@"dd\.hh\:mm\:ss")}. " +
                          $"Выгрузка еще не завершена.");
        }

        private void ClearThreadVars()
        {
            _threadActiveCount = 0;
            _threadFullCount = 0;
            _threadFinishedCount = 0;
            _threadWaitingCount = 0;
        }

        private void btnRun_Click(object sender, EventArgs e)
        {
            Calc(((ReportTreeNode)tvReports.SelectedNode).Type);
        }

        private void Main_Load(object sender, EventArgs e)
        {
            Text += $" ({Application.ProductVersion})";
            SetDefaultValues();
            ReportUtils.LoadReportList(tvReports);
        }

        private void Calc(ReportType type)
        {
            var tCalc = new Thread(() =>
            {
                Lock = true;
                lock (this)
                {
                    _timeCalcBegin = DateTime.Now;
                }
                if (!CalcData(type)) return;
                SetStatusText("Идет подготовка к выгрузке файлов.");
                
                if (new [] { ReportType.Route, ReportType.Terminal, ReportType.TransportVehicle, ReportType.TransportCard, ReportType.Organisation }.Contains(type))
                {
                    var query = ReportUtils.GetReaderQuery(type);
                    var reader = (type == ReportType.TransportCard)
                        ? DatabaseUtils.GetReader(_connection, query, new[]
                        {
                            new OracleParameter
                            {
                                ParameterName = "pActivationBeginDate",
                                OracleDbType = OracleDbType.Date,
                                Value = dtActivePassActivationBeginDate.Value
                            },
                            new OracleParameter
                            {
                                ParameterName = "pActivationEndDate",
                                OracleDbType = OracleDbType.Date,
                                Value = dtActivePassActivationEndDate.Value
                            }
                        })
                        : DatabaseUtils.GetReader(_connection, query);
                    if ((reader == null) || (!reader.HasRows)) return;
                    _timeOutputBegin = DateTime.Now;
                    ClearThreadVars();

                    while (reader.Read())
                    {
                        var id = Routines.GetLong(reader["id_element"]);
                        var name = Routines.GetString(reader["name_element"]);
                        var t = new Thread(() =>
                        {
                            lock (this)
                            {
                                _threadWaitingCount++;
                                _threadFullCount++;
                            }
                            while (true)
                            {
                                lock (this)
                                {
                                    if (_threadActiveCount < ((new List<ReportType> { ReportType.TransportVehicle}.Contains(type)) ? 4 : 16))
                                    {
                                        _threadActiveCount++;
                                        _threadWaitingCount--;
                                        UpdateStatusProgressText();
                                        break;
                                    }
                                }
                                Thread.Sleep(50);
                            }
                            CalcOutput(type, id, name);
                            lock (this)
                            {
                                _threadActiveCount--;
                                _threadFinishedCount++;
                                UpdateStatusProgressText();
                            }
                            if ((_threadActiveCount != 0)||(_threadWaitingCount != 0)) return;
                            //Если это последний поток
                            Lock = false;
                            MessageBox.Show(
                                $"Выгрузилось {_threadFullCount} отчетов за {(DateTime.Now - _timeCalcBegin).ToString(@"dd\.hh\:mm\:ss")}!");
                            SetStatusText("");
                        }) {IsBackground = true};
                        if (_threadWaitingCount < 500)
                            t.Start();
                        else
                        {
                            while (true)
                            {
                                if (_threadWaitingCount < 50)
                                {
                                    t.Start();
                                    break;
                                }
                                Thread.Sleep(50);
                            }
                        }
                    }
                }
                else
                {
                    CalcOutput(type);
                    Lock = false;
                    MessageBox.Show(
                        $"Выгрузился за {(DateTime.Now - _timeCalcBegin).ToString(@"dd\.hh\:mm\:ss")}!");
                    SetStatusText("");
                }
            });
            tCalc.Start();
        }

        private bool CalcData(ReportType type)
        {
            SetStatusText("Идет расчет предварительных данных");
            switch (type)
            {
                case ReportType.Route:
                    return DatabaseUtils.CallProcedure(_connection, "cptt.pkg$trep_reports.fillpassroutetermday", GetOracleParameters(type));
                case ReportType.Terminal:
                case ReportType.TransportVehicle:
                case ReportType.TransportCard:
                    return DatabaseUtils.CallProcedure(_connection, "cptt.pkg$trep_reports.filldata",
                        GetOracleParameters(type).Where(p => ((p.ParameterName == "pPassBeginDate")||(p.ParameterName == "pPassEndDate"))).ToArray());
                case ReportType.ActiveAgents:
                    return DatabaseUtils.CallProcedure(_connection, "cptt.pkg$trep_reports.fillactivationseries",
                        new[]
                        {
                            new OracleParameter
                            {
                                ParameterName = "pActivationBeginDate",
                                OracleDbType = OracleDbType.Date,
                                Value = dtActivePassActivationBeginDate.Value
                            },
                            new OracleParameter
                            {
                                ParameterName = "pActivationEndDate",
                                OracleDbType = OracleDbType.Date,
                                Value = dtActivePassActivationEndDate.Value
                            }
                        });

                case ReportType.Organisation:
                    return DatabaseUtils.CallProcedure(_connection,
                        "cptt.pkg$trep_reports.fillActivationSeriesPrivilege",
                        GetOracleParameters(type)
                            .Where(
                                p =>
                                    ((p.ParameterName == "pActivationBeginDate") ||
                                     (p.ParameterName == "pActivationEndDate")))
                            .Concat(new[]
                            {
                                new OracleParameter()
                                {
                                    ParameterName = "pAllPrivilege",
                                    OracleDbType = OracleDbType.Varchar2,
                                    Value = "Y"
                                }
                            })
                            .ToArray())
                           &&
                           DatabaseUtils.CallProcedure(_connection,
                               "cptt.pkg$trep_reports.fillPassSeriesPrivilegeCarrier",
                               GetOracleParameters(type)
                                   .Where(
                                       p =>
                                           ((p.ParameterName == "pPassBeginDate") || (p.ParameterName == "pPassEndDate")))
                                   .ToArray());
                case ReportType.ActivePass:
                case ReportType.ActivePassCommercial:
                case ReportType.ActivePassRegional:
                case ReportType.Privilege:
                
                
                case ReportType.Transaction:
                
                case ReportType.None:
                default:
                    return true;
            }
        }

        private bool CalcOutput(ReportType type, long idElement = -1, string nameElement = "")
        {
            try
            {
                string templateName = "";
                string outputName = "";
                string outputProcName = "";
                bool isColorize = chbColorizeExcelReport.Checked;
                bool isOpenAfterCreate = chbOpenExcelReport.Checked;
                OracleParameter[] parameters = {};
                switch (type)
                {
                    case ReportType.ActivePass:
                        templateName = "ActivePass.xlsx";
                        outputName = $@"Отчет инвеcтора-оператора_{dtActivePassPassBeginDate.Value.ToString("ddMMyyyy")}_{dtActivePassPassEndDate.Value.ToString("ddMMyyyy")}_{DateTime.Now.ToString("ddMMyyyyHHmmss")}.xlsx";

                        outputProcName = "cptt.pkg$trep_reports.fillReportActivePassExcel";
                        parameters = GetOracleParameters(type);
                        break;
                    case ReportType.ActivePassRegional:
                        templateName = "ActivePass.xlsx";
                        outputName = $@"Отчет инвеcтора-оператора(развернутые региональные льготники)_{dtActivePassPassBeginDate.Value.ToString("ddMMyyyy")}_{dtActivePassPassEndDate.Value.ToString("ddMMyyyy")}_{DateTime.Now.ToString("ddMMyyyyHHmmss")}.xlsx";
                        outputProcName = "cptt.pkg$trep_reports.fillReportActivePassExcel";
                        parameters = GetOracleParameters(type).Concat(new [] {new OracleParameter() {ParameterName = "pIsRegionalPrivilegeSplitted", OracleDbType = OracleDbType.Varchar2, Value = "Y"}}).ToArray();
                        break;
                    case ReportType.ActivePassCommercial:
                        templateName = "ActivePassCommercial.xltx";
                        outputName = $@"Отчет инвеcтора-оператора(коммерческие перевозчики)_{dtActivePassPassBeginDate.Value.ToString("ddMMyyyy")}_{dtActivePassPassEndDate.Value.ToString("ddMMyyyy")}_{DateTime.Now.ToString("ddMMyyyyHHmmss")}.xlsx";
                        outputProcName = "cptt.pkg$trep_reports.fillReportActivePassCommercial";
                        parameters = GetOracleParameters(type);
                        break;
                    case ReportType.ActiveAgents:
                        templateName = "ActiveAgents.xltx";
                        outputName = $@"Отчет по активации проездных агентами_{dtActivePassActivationBeginDate.Value.ToString("ddMMyyyy")}_{dtActivePassActivationEndDate.Value.ToString("ddMMyyyy")}_{DateTime.Now.ToString("ddMMyyyyHHmmss")}.xlsx";
                        outputProcName = "cptt.pkg$trep_reports.fillReportActiveAgents";
                        parameters = GetOracleParameters(type);
                        break;
                    case ReportType.Transaction:
                        templateName = "Transaction.xlsx";
                        outputName = $@"Отчет по транзакциям_{dtPassPassBeginDate.Value.ToString("ddMMyyyy")}_{dtPassPassEndDate.Value.ToString("ddMMyyyy")}_{DateTime.Now.ToString("ddMMyyyyHHmmss")}.xlsx";
                        outputProcName = "cptt.pkg$trep_reports.fillReportTransactionExcel";
                        parameters = GetOracleParameters(type);
                        break;
                    case ReportType.Privilege:
                        templateName = "Privilege.xlsx";
                        outputName = $@"Отчет по льготникам_{dtActivePassPassBeginDate.Value.ToString("ddMMyyyy")}_{dtActivePassPassEndDate.Value.ToString("ddMMyyyy")}_{DateTime.Now.ToString("ddMMyyyyHHmmss")}.xlsx";

                        outputProcName = "cptt.pkg$trep_reports.fillReportPrivilegeExcel";
                        parameters = GetOracleParameters(type);
                        break;
                    case ReportType.Route:
                        templateName = "Route.xltx";
                        outputName = $@"Отчет по маршруту_{nameElement}_{dtActivePassPassBeginDate.Value.ToString("ddMMyyyy")}_{dtActivePassPassEndDate.Value.ToString("ddMMyyyy")}_{DateTime.Now.ToString("ddMMyyyyHHmmss")}.xlsx";
                        outputProcName = "cptt.pkg$trep_reports.fillReportRouteExcel";
                        parameters = new[]
                        {
                            new OracleParameter()
                            {
                                ParameterName = "pIdRoute", OracleDbType = OracleDbType.Int64, Value = idElement
                            }
                        }.Concat(GetOracleParameters(type)).ToArray();
                        break;
                    case ReportType.Terminal:
                        templateName = "Terminal.xltx";
                        outputName = $@"Отчет по терминалу кондуктора_{nameElement}_{dtPassPassBeginDate.Value.ToString("ddMMyyyy")}_{dtPassPassEndDate.Value.ToString("ddMMyyyy")}_{DateTime.Now.ToString("ddMMyyyyHHmmss")}.xlsx";
                        outputProcName = "cptt.pkg$trep_reports.fillReportTerminalExcel";
                        parameters = new[]
                        {
                            new OracleParameter()
                            {
                                ParameterName = "pIdTerminal", OracleDbType = OracleDbType.Int64, Value = idElement
                            } 
                        }.Concat(GetOracleParameters(type)).ToArray();
                        break;
                    case ReportType.TransportCard:
                        templateName = "TransportCard.xltx";
                        outputName = $@"Отчет по транспортной карте_{nameElement}_{dtActivePassActivationBeginDate.Value.ToString("ddMMyyyy")}_{dtActivePassActivationEndDate.Value.ToString("ddMMyyyy")}_{DateTime.Now.ToString("ddMMyyyyHHmmss")}.xlsx";
                        outputProcName = "cptt.pkg$trep_reports.fillReportTransportCardExcel";
                        parameters = new[]
                        {
                            new OracleParameter()
                            {
                                ParameterName = "pCardNum", OracleDbType = OracleDbType.Int64, Value = idElement
                            }
                        }.Concat(GetOracleParameters(type)).ToArray();
                        break;
                    case ReportType.TransportVehicle:
                        templateName = "TransportVehicle.xltx";
                        outputName = $@"Отчет по транспортному средству_{nameElement}_{dtPassPassBeginDate.Value.ToString("ddMMyyyy")}_{dtPassPassEndDate.Value.ToString("ddMMyyyy")}_{DateTime.Now.ToString("ddMMyyyyHHmmss")}.xlsx";
                        outputProcName = "cptt.pkg$trep_reports.fillReportVehicleExcel";
                        parameters = new[]
                        {
                            new OracleParameter()
                            {
                                ParameterName = "pIdVehicle", OracleDbType = OracleDbType.Int64, Value = idElement
                            }
                        }.Concat(GetOracleParameters(type)).ToArray();
                        break;
                    case ReportType.Organisation:
                        templateName = "Organisation.xltx";
                        outputName = $@"Отчет по организации_{nameElement}_{dtActivePassPassBeginDate.Value.ToString("ddMMyyyy")}_{dtActivePassPassEndDate.Value.ToString("ddMMyyyy")}_{DateTime.Now.ToString("ddMMyyyyHHmmss")}.xlsx";
                        outputProcName = "cptt.pkg$trep_reports.fillReportOrganisationExcel";
                        parameters =
                            new[]
                            {
                                new OracleParameter()
                                {
                                    ParameterName = "pIdCarrier",
                                    OracleDbType = OracleDbType.Int64,
                                    Value = idElement
                                }
                            }.Concat(GetOracleParameters(type).Where(
                                p =>
                                    ((p.ParameterName == "pPassBeginDate") || (p.ParameterName == "pPassEndDate"))))
                                .ToArray();
                        break;
                    case ReportType.None:
                    default:
                        return false;
                }
                var templatePath = Path.Combine(Application.StartupPath, "Template", templateName);
                var outputPath = Path.Combine(Application.StartupPath, "Output", outputName);
                if (!File.Exists(templatePath))
                {
                    MessageBox.Show(this, "Не найден файл шаблона", "Ошибка загрузки шаблона", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return false;
                }
                if (!Directory.Exists(Path.GetDirectoryName(outputPath)))
                    Directory.CreateDirectory(Path.GetDirectoryName(outputPath));
                using (OracleConnection conn = DatabaseUtils.CreateConnection(_database, _login, _password))
                {
                    if (!DatabaseUtils.CallProcedure(conn, outputProcName, parameters)) return false;
                    DataTable dtRows = DatabaseUtils.FillDataTable(conn, Constants.ConstGetExcelReportRows);
                    DataTable dtFormat = DatabaseUtils.FillDataTable(conn, Constants.ConstGetExcelReportFormat);
                    ExcelUtils.OutloadExcelEpplus(templatePath, outputPath, dtRows, dtFormat, isColorize,
                        isOpenAfterCreate, (type==ReportType.ActivePassCommercial)? DatabaseUtils.FillDataTable(conn, Constants.ConstGetCarriersList):null);
                    conn.Close();
                }
                return true;
            }
            catch (Exception e)
            {
                MessageBox.Show($"При формировании выгрузки Excel произошла ошибка:\r\n{e.Message}");
                return false;
            }
        }

        private void SetDefaultValues()
        {
            dtActivePassActivationBeginDate.Value = new DateTime(DateTime.Now.AddMonths(-2).Year, DateTime.Now.AddMonths(-2).Month, 16);
            dtActivePassActivationEndDate.Value = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 15);
            dtActivePassPassBeginDate.Value = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 1, 3, 0, 0);
            dtActivePassPassEndDate.Value = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1, 3, 0, 0);

            dtPassPassBeginDate.Value = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 1, 3, 0, 0);
            dtPassPassEndDate.Value = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1, 3, 0, 0);

            dtActiveActivationBeginDate.Value = new DateTime(DateTime.Now.AddMonths(-2).Year, DateTime.Now.AddMonths(-2).Month, 16);
            dtActiveActivationEndDate.Value = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 15);
        }

        private void ShowTab(ReportType type)
        {
            TabPage tp;
            switch (type)
            {
                case ReportType.ActivePass:
                case ReportType.ActivePassRegional:
                case ReportType.ActivePassCommercial:
                case ReportType.Privilege:
                case ReportType.ActiveAgents:
                case ReportType.TransportCard:
                case ReportType.Organisation:
                    tp = tpActivePass;
                    break;
                case ReportType.Transaction:
                case ReportType.Route:
                case ReportType.Terminal:
                
                    tp = tpPass;
                    break;
                case ReportType.TransportVehicle:
                    tp = tpPass;
                    break;
                case ReportType.None:
                default:
                    tp = tpEmpty;
                    break;
            }
            btnRun.Enabled = !tpEmpty.Equals(tp);
            tcReportParams.SelectedTab = tp;
            tvReports.Focus();
        }

        private void tvReports_AfterSelect(object sender, TreeViewEventArgs e)
        {
            ShowTab(((ReportTreeNode) tvReports.SelectedNode).Type);
        }

        private void tvReports_DrawNode(object sender, DrawTreeNodeEventArgs e)
        {
            SolidBrush selectedTreeBrush = new SolidBrush(e.Node.TreeView.BackColor);
            if (e.Node == e.Node.TreeView.SelectedNode)
            {
                e.Graphics.FillRectangle(selectedTreeBrush, e.Bounds);
                ControlPaint.DrawBorder(e.Graphics, e.Bounds, Color.Black, ButtonBorderStyle.Dashed);
                //DrawFocusRectangle(e.Graphics, e.Bounds, e.Node.ForeColor, SystemColors.Highlight);
                TextRenderer.DrawText(e.Graphics, e.Node.Text, e.Node.TreeView.Font, e.Bounds, e.Node.ForeColor, TextFormatFlags.GlyphOverhangPadding);
            }
            else
            {
                e.DrawDefault = true;
            }
        }

        private OracleParameter[] GetOracleParameters(ReportType type)
        {
            switch (type)
            {
                case ReportType.ActivePass:
                case ReportType.ActivePassRegional:
                case ReportType.ActivePassCommercial:
                case ReportType.Privilege:
                case ReportType.ActiveAgents:
                case ReportType.TransportCard:
                case ReportType.Organisation:
                    return new[]
                    {
                        new OracleParameter
                        {
                            ParameterName = "pActivationBeginDate", OracleDbType = OracleDbType.Date, Value = dtActivePassActivationBeginDate.Value
                        },
                        new OracleParameter
                        {
                            ParameterName = "pActivationEndDate", OracleDbType = OracleDbType.Date, Value = dtActivePassActivationEndDate.Value
                        },
                        new OracleParameter
                        {
                            ParameterName = "pPassBeginDate", OracleDbType = OracleDbType.Date, Value = dtActivePassPassBeginDate.Value
                        },
                        new OracleParameter
                        {
                            ParameterName = "pPassEndDate", OracleDbType = OracleDbType.Date, Value = dtActivePassPassEndDate.Value
                        },
                    };
                case ReportType.Route:
                case ReportType.Transaction:
                case ReportType.Terminal:
                case ReportType.TransportVehicle:
                    return new[]
                    {
                        new OracleParameter
                        {
                            ParameterName = "pPassBeginDate", OracleDbType = OracleDbType.Date, Value = dtPassPassBeginDate.Value
                        },
                        new OracleParameter
                        {
                            ParameterName = "pPassEndDate", OracleDbType = OracleDbType.Date, Value = dtPassPassEndDate.Value
                        },
                    };
                case ReportType.None:
                default:
                    return new OracleParameter[] {};
            }
        }

        private void btnSetAgents_Click(object sender, EventArgs e)
        {
            new LockedAgents(_connection).ShowDialog(this);
        }

        private void btnSetDivisions_Click(object sender, EventArgs e)
        {
            new LockedDivisions(_connection).ShowDialog(this);
        }
    }
}
