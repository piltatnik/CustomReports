using System.Drawing;
using System.Windows.Forms;

namespace TransportReports
{
    class ReportUtils
    {
        public static void LoadReportList(TreeView tv)
        {
            ReportTreeNode root = new ReportTreeNode("Отчеты", ReportType.None, Color.Black);
            root.Nodes.AddRange(new TreeNode[]
            {
                new ReportTreeNode("Отчет по Инвестора-Оператора", ReportType.ActivePass, Color.DarkGreen),
                new ReportTreeNode("Отчет по Инвестора-Оператора (развернутые региональные льготники)", ReportType.ActivePassRegional, Color.DarkGreen),
                new ReportTreeNode("Отчет по Инвестора-Оператора (коммерческие перевозчики)", ReportType.ActivePassCommercial, Color.DarkGreen),
                new ReportTreeNode("Отчет по активации проездных агентами", ReportType.ActiveAgents, Color.DarkGreen), 
                new ReportTreeNode("Отчет по льготникам", ReportType.Privilege, Color.Black),
                new ReportTreeNode("Отчет по маршруту", ReportType.Route, Color.Black),
                new ReportTreeNode("Отчет по организации", ReportType.Organisation, Color.DarkGreen),
                new ReportTreeNode("Отчет по терминалу кондуктора", ReportType.Terminal, Color.Black),
                new ReportTreeNode("Отчет по транзакциям", ReportType.Transaction, Color.Black),
                new ReportTreeNode("Отчет по транспортной карте", ReportType.TransportCard, Color.Black),
                new ReportTreeNode("Отчет по транспортному средству", ReportType.TransportVehicle, Color.Black)
            });
            root.Expand();
            tv.Nodes.Add(root);
            tv.SelectedNode = root;
            tv.Focus();
        }

        public static string GetReaderQuery(ReportType type)
        {
            switch (type)
            {
                case ReportType.Route:
                    return Constants.ConstGetRouteList;
                case ReportType.Terminal:
                    return Constants.ConstGetTermList;
                case ReportType.TransportVehicle:
                    return Constants.ConstGetTransportVehicleList;
                case ReportType.TransportCard:
                    return Constants.ConstGetTransportCardList;
                case ReportType.Organisation:
                    return Constants.ConstGetOrganisationList;
                default:
                    return "";
            }
        }
    }
}
