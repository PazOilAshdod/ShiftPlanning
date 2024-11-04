using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Text;

public partial class MasterPage_MasterPage : System.Web.UI.MasterPage
{

    public string ShiftDate = "";
    public string ShiftCode = "";
    public string CurrentDay = "";
    public string UserName;
    public string UserId;
    public string RoleId;







    protected void Page_Load(object sender, EventArgs e)
    {

        string sql = "Select convert(VARCHAR(8),  GETDATE(), 4) as CurrentDate,"
            + "DATEPART(DW, DATEADD(dd,1,GETDATE())) CurrentDayInWeek,dbo.GetCurrentShift() as CurrentShift";

      //  string sql = "Select convert(VARCHAR(8),  GETDATE(), 4) as CurrentDate,dbo.GetCurrentShift() as CurrentShift";

        DataTable dt = Dal.GetDataTable(sql);


        ShiftDate = dt.Rows[0][0].ToString();
        CurrentDay = dt.Rows[0][1].ToString();
        ShiftCode = dt.Rows[0][2].ToString();



        HttpCookie cookie = null;

        if (HttpContext.Current.Request.Cookies["UserData"] != null)
        {
           cookie = HttpContext.Current.Request.Cookies["UserData"];

        }


     
        try
        {
            UserId = cookie["UserId"];
            RoleId = cookie["RoleId"];

            UserName = Server.UrlDecode(cookie["UserName"]);



        }
        catch (Exception ex)
        {
            UserId = "";
            RoleId = "";
            UserName = "";
        }


    
    }




    



    public string GetSafeRequest(string requestField)
    {
        string tmpField = Request.QueryString[requestField];
        if (tmpField != null)
        {
            if (tmpField != "")
            {
                return tmpField;
            }
            else
            {
                return "";
            }
        }
        else
        {
            return "";
        }

    }
}
