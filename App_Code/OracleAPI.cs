using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using System.Data.Odbc;
using System.Data.OleDb;


//using Oracle.DataAccess.Client; // ODP.NET Oracle managed provider 
//using Oracle.DataAccess.Types;
using System.Text;
using System.Data;
using Oracle.ManagedDataAccess.Client;

/// <summary>
/// Summary description for OracleAPI
/// </summary>
public class OracleAPI
{
    public OracleAPI()
    {
        //
        // TODO: Add constructor logic here


        //
    }

    public static DataTable RunProcedureFromOracle(string Sql)
    {

        DataTable dt = new DataTable();

        string connectionString = GetConnectionString();
        using (OracleConnection connection = new OracleConnection())
        {
            connection.ConnectionString = connectionString;
            connection.Open();

            OracleCommand command = connection.CreateCommand();


            command.CommandText = Sql;

            OracleDataReader reader = command.ExecuteReader();

            dt.Load(reader);


        }







        return dt;


    }

    public static string GetSqlString(string start_date_oracle, string end_date_oracle)
    {



        StringBuilder sb = new StringBuilder();

        sb.Insert(0, @"SELECT * FROM TRNSACT_SYNEL");


        return sb.ToString();
    }

    public static string GetConnectionString()
    {
        string connString = System.Web.Configuration.WebConfigurationManager.ConnectionStrings["dbNipukimConnectionString"].ToString();

        return connString;

        //return "User Id=mpreport;Password=mpreport;Data Source=(DESCRIPTION="
        //         + "(ADDRESS=(PROTOCOL=TCP)(HOST=sdbm1)(PORT=1521))"
        //         + "(CONNECT_DATA=(SID=PRODA)));";

        //return "User Id=mpreport;Password=mpreport;Data Source=(DESCRIPTION="
        //        + "(ADDRESS=(PROTOCOL=TCP)(HOST=172.22.11.78)(PORT=1521))"
        //        + "(CONNECT_DATA=(SID=NIPUKIMA)));";

    }



}