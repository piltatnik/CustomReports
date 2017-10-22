using System;

namespace TransportReports
{
    class Routines
    {
        public static int GetInt(Object obj)
        {
            int value;
            if (!int.TryParse(obj.ToString(), out value))
                throw new Exception("Ошибка преобразования в целое число");
            return value;
        }

        public static long GetLong(Object obj)
        {
            long value;
            if (!long.TryParse(obj.ToString(), out value))
                throw new Exception("Ошибка преобразования в long");
            return value;
        }

        public static int? TryGetInt(Object obj)
        {
            int value;
            if (!int.TryParse(obj.ToString(), out value))
                return null;
            return value;
        }

        public static string GetString(Object obj)
        { 
            try
            {
                return obj.ToString();
            }
            catch (Exception)
            {
                return "";
            }
        }
    }
}
