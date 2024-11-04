using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Data;
using System.ServiceModel.Web;
using System.Web.Script.Serialization;
using System.Collections;
using System.Text;
using System.Configuration;
using System.IO;
using iTextSharp.text.html.simpleparser;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.tool.xml;
using Newtonsoft.Json;
using SpreadsheetLight;
using ClosedXML.Excel;
using DocumentFormat.OpenXml.Spreadsheet;
//using System.Drawing;
//using DocumentFormat.OpenXml.Spreadsheet;
//using DocumentFormat.OpenXml.Packaging;
//using DocumentFormat.OpenXml;

/// <summary>
/// Summary description for WebService
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class WebService : System.Web.Services.WebService
{

    public WebService()
    {


    }


    #region Assign


    [WebMethod]
    public void Assign_FillAssignment()
    {

        string StartDate = GetParams("StartDate");
        string EndDate = GetParams("EndDate");
        string OrgUnitCode = GetParams("OrgUnitCode");

        DataTable dt = Dal.ExeSp("Assign_FillAssignment", StartDate, EndDate, OrgUnitCode);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }

    [WebMethod]
    public void Assign_GetAssignment()
    {

        string Date = GetParams("Date");
        string OrgUnitCode = GetParams("OrgUnitCode");

        DataTable dt = Dal.ExeSp("Assign_GetAssignment", Date, OrgUnitCode);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }

    [WebMethod]
    public void Assign_GetAssignmentNew()
    {

        string Date = GetParams("Date");
        string OrgUnitCode = GetParams("OrgUnitCode");
        string Procedure = GetParams("Procedure");

        DataTable dt = Dal.ExeSp(Procedure, Date, OrgUnitCode);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }

    [WebMethod]
    public void Assign_GetAssignmentForPortal()
    {

        string Date = GetParams("Date");
        string OrgUnitCode = GetParams("OrgUnitCode");

        DataTable dt = Dal.ExeSp("Assign_GetAssignmentForPortal", Date, OrgUnitCode);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }

    [WebMethod]
    public void Assign_SetEmpForEmptyPosition()
    {

        string SearchDate = GetParams("SearchDate");
        string OrgUnitCode = GetParams("OrgUnitCode");

        DataTable dt = Dal.ExeSp("Assign_SetEmpForEmptyPosition", SearchDate, OrgUnitCode);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }

    [WebMethod]
    public void Assignment_GetRequiremntsNonAuto()
    {

        string ShiftDate = GetParams("ShiftDate");
        string ShiftCode = GetParams("ShiftCode");
        string OrgUnitCode = GetParams("OrgUnitCode");




        DataTable dt = Dal.ExeSp("Assignment_GetRequiremntsNonAuto", ShiftDate, ShiftCode, OrgUnitCode);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }

    [WebMethod]
    public void Assignment_InsertRequiremntsNonAutoToAssignment()
    {
        string RequirementId = GetParams("RequirementId");
        string ShiftDate = GetParams("ShiftDate");
        string ShiftCode = GetParams("ShiftCode");
        string OrgUnitCode = GetParams("OrgUnitCode");



        string HarigaId = GetParams("HarigaId");
        string HarigaFree = GetParams("HarigaFree");
        string HadId = GetParams("HadId");
        string HadFree = GetParams("HadFree");



        DataTable dt = Dal.ExeSp("Assignment_InsertRequiremntsNonAutoToAssignment", RequirementId,
            ShiftDate, ShiftCode, OrgUnitCode,
            HarigaId, HarigaFree, HadId, HadFree);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }

    [WebMethod]
    public void Assignment_SetNonAutoPosion()
    {
        string AssignmentId = GetParams("AssignmentId");
        string Type = GetParams("Type");





        DataTable dt = Dal.ExeSp("Assignment_SetNonAutoPosion", AssignmentId, Type);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }




    [WebMethod]
    public void Assignment_SetHoursForWorker()
    {


        string AssignmentId = GetParams("AssignmentId");
        string WorkerHours = GetParams("WorkerHours");
        string Seq = GetParams("Seq");


        DataTable dt = Dal.ExeSp("Assignment_SetHoursForWorker", AssignmentId, WorkerHours, Seq, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }

    [WebMethod]
    public void Assignment_InsertManualAssign()
    {
        string TargetAssignmentId = GetParams("TargetAssignmentId");
        string SourceAssignmentId = GetParams("SourceAssignmentId");
        string SourceEmpNo = GetParams("SourceEmpNo");
        string Type = GetParams("Type");


        DataTable dt = Dal.ExeSp("Assignment_InsertManualAssign", TargetAssignmentId, SourceAssignmentId, SourceEmpNo, Type, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }


    [WebMethod]
    public void Assignment_GetAddedHours()
    {
        string OrgUnitCode = GetParams("OrgUnitCode");
        string SearchDate = GetParams("SearchDate");

        DataTable dt = Dal.ExeSp("Assignment_GetAddedHours", SearchDate, OrgUnitCode);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }



    [WebMethod]
    public void Assignment_GetPrivateAssign()
    {
        string EmpNo = GetParams("EmpNo");

        DataTable dt = Dal.ExeSp("Assignment_GetPrivateAssign", EmpNo);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }



    //[WebMethod]
    //public void Assignment_Presence()
    //{


    //    StringBuilder sb = new StringBuilder();

    //    sb.Append(@"
    //                SELECT * FROM 
    //                TRNSACT_SYNEL WHERE 
    //                (TAG_DATE = trunc(sysdate - 1) And OUT_TIME IS NULL)
    //                Or
    //                (TAG_DATE = trunc(sysdate))
    //                order by WORK_ID,TAG_DATE,OUT_TIME 
    //                ");



    //    DataTable dt = OracleAPI.RunProcedureFromOracle(sb.ToString());

    //    HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));



    //}




    [WebMethod]
    public void Assignment_Presence()
    {

        string CurrentDate = DateTime.Now.ToString("yyyyMMdd");
        string PrevDate = DateTime.Now.AddDays(-1).ToString("yyyyMMdd");

        //string CurrentDate = "20200321"; //DateTime.Now.ToString("yyyyMMdd");
        //  string PrevDate = "20200320"; //DateTime.Now.AddDays(-1).ToString("yyyyMMdd");


        StringBuilder sb = new StringBuilder();

        sb.Append(@"
                    SELECT work_id as WORK_ID,tag_date AS TAG_DATE,out_time AS OUT_TIME  FROM 
                    VW_PAZ_SynelToMovements WHERE 
                    (tag_date = '" + PrevDate + @"' And out_time='')
                    Or
                    (tag_date = '" + CurrentDate + @"')
                    order by work_id,tag_date,out_time 
                    ");



       // DataTable dt = Dal.Harmony_GetDataTable(sb.ToString());

        DataTable dtApp = Dal.ExeSp("AppReport_Action", 0, "", "", DateTime.Now.AddDays(-1), "");


        //DataTable dtAll = dt.Copy();
        //dtAll.Merge(dtApp);


        HttpContext.Current.Response.Write(ConvertDataTabletoString(dtApp));

    }

    //[WebMethod]
    //public void Assignment_GetCurrentTime()
    //{

    //    string sql = "Select convert(VARCHAR(8),  GETDATE(), 4) as CurrentDate,"
    //    + "DATEPART(DW, DATEADD(dd,1,GETDATE())) CurrentDayInWeek,dbo.GetCurrentShift() as CurrentShift";

    //    DataTable dt = Dal.GetDataTable(sql);


    //    HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    //}









    #endregion

    #region Absence


    [WebMethod]
    public void Absence_SetAbsence()
    {


        string AssignmentId = GetParamsIfInt("AssignmentId");
        string CurrentDate = GetParams("CurrentDate");
        string AbsenceHour = GetParams("AbsenceHour");
        string StartDate = GetParams("StartDate");
        string EndDate = GetParams("EndDate");
        string AbsenceCode = GetParams("AbsenceCode");
        string EmpNo = GetParams("EmpNo");
        string IsPitzul = GetParams("IsPitzul");
        string IsCancel = GetParams("IsCancel");

        DataTable dt = Dal.ExeSp("Absence_SetAbsence", AssignmentId, CurrentDate, AbsenceHour, StartDate, EndDate,
            AbsenceCode, EmpNo, IsPitzul, IsCancel, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }

    private string GetParamsIfInt(string Param)
    {
        var res = HttpContext.Current.Request.Form[Param].ToString();
        int intres = 0;

        bool IsOk = Int32.TryParse(res, out intres);
        if (IsOk)
        {

            return intres.ToString();
        }

        return "0";

    }

    [WebMethod]
    public void Absence_CancelAbsence()
    {



        string StartDate = GetParams("StartDate");
        string EndDate = GetParams("EndDate");
        string EmpNo = GetParams("EmpNo");


        DataTable dt = Dal.ExeSp("Absence_CancelAbsence", EmpNo, StartDate, EndDate, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }



    #endregion

    #region Borrow
    [WebMethod]
    public void Borrow_InitialData()
    {

        string SearchDate = GetParams("SearchDate");
        string OrgUnitCode = GetParams("OrgUnitCode");
        DataTable dt = Dal.ExeSp("Borrow_InitialData", OrgUnitCode, SearchDate);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }

    [WebMethod]
    public void Borrow_SetDataDB()
    {

        string StartDate = GetParams("StartDate");
        string EndDate = GetParams("EndDate");
        string OrgUnitCode = GetParams("OrgUnitCode");

        string Type = GetParams("Type");
        string EmpNo = GetParams("EmpNo");
        string BorrowId = GetParams("BorrowId");

        string IsAdd = GetParams("IsAdd");

        if (Type == "11" || Type == "12" || Type == "2") IsAdd = "0";


        DataTable dt = Dal.ExeSp("Borrow_SetDataDB", OrgUnitCode, StartDate, EndDate, Type, EmpNo, BorrowId, IsAdd, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }







    #endregion

    #region Requirments


    [WebMethod]
    public void Requirments_GetRequiremntsByArea()
    {

        string OrgUnitCode = GetParams("OrgUnitCode");

        DataTable dt = Dal.ExeSp("Requirments_GetRequiremntsByArea", OrgUnitCode);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }

    [WebMethod]
    public void Requirments_SetRequiremntsTODB()
    {
        string RequirementId = GetParams("RequirementId");

        string OrgUnitCode = GetParams("OrgUnitCode");
        string DateTypeCode = GetParams("ddlDayCode");
        string ShiftCode = GetParams("ddlShift");

        string QualificationCode = GetParams("ddlQualification");

        string EmpQuantity = GetParams("txtEmpQuantity");
        string Seq = GetParams("txtSeq");
        string BeginDate = GetParams("txtStartDate");
        string EndDate = GetParams("txtEndDate");

        string RequirementDesc = GetParams("txtRequirementDesc");
        string RequirementAbb = GetParams("txtRequirementAbb");
        string RequirementType = GetParams("ddlRequirmentType");

        bool ObligatoryAssignment = GetParamsIfExist("chIsAuto");
        bool ObligatoryCheck = GetParamsIfExist("chIsMustCheck");

        bool IsAssignAuto = GetParamsIfExist("chIsAssignAuto");


        DataTable dt = Dal.ExeSp("Requirments_SetRequiremntsTODB", RequirementId, OrgUnitCode, DateTypeCode, ShiftCode, QualificationCode,
            EmpQuantity, Seq, BeginDate, EndDate, RequirementDesc, RequirementAbb, RequirementType, ObligatoryAssignment,
            ObligatoryCheck, IsAssignAuto);


        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }





    [WebMethod]
    public void Requirments_DeleteRequiremnts()
    {

        string RequirementId = GetParams("RequirementId");

        DataTable dt = Dal.ExeSp("Requirments_DeleteRequiremnts", RequirementId);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }

    [WebMethod]
    public void Requirments_GetQualificationData()
    {

        string OrgUnitCode = GetParams("OrgUnitCode");

        DataTable dt = Dal.ExeSp("Requirments_GetQualificationData", OrgUnitCode);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }







    #endregion

    #region Change

    [WebMethod]
    public void Change_GetRelvantsEmployee()
    {

        string EmpNo = GetParams("EmpNo");
        string ShiftDate = GetParams("ShiftDate");
        string AssignmentId = GetParams("AssignmentId");
        string OrgUnitCode = GetParams("OrgUnitCode");




        DataTable dt = Dal.ExeSp("Change_GetRelvantsEmployee", EmpNo, ShiftDate, AssignmentId, OrgUnitCode);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }

    [WebMethod]
    public void Change_SetChange()
    {

        string EmpNo = GetParams("EmpNo");
        string EmpNoChange = GetParams("EmpNoChange");
        string StartDate = GetParams("StartDate");
        string EndDate = GetParams("EndDate");
        string SwapCode = GetParams("SwapCode");
        string ChangeReason = GetParams("ChangeReason");
        string isNoValidation = GetParams("isNoValidation");

        DataTable dt = Dal.ExeSp("Change_SetChange", EmpNo, EmpNoChange, StartDate, EndDate, SwapCode, isNoValidation,
            HttpContext.Current.Request.Cookies["UserData"]["UserId"], ChangeReason);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }

    #endregion

    #region Users

    [WebMethod]
    public void User_GetUsers()
    {

        string AreaId = GetParams("AreaId");
        string FreeText = GetParams("FreeText");

        DataTable dt = Dal.ExeSp("User_GetUsers", AreaId, FreeText);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }






    [WebMethod]
    public void User_SetData()
    {




        string UserNumber = GetParams("UserNumber");
        string FirstName = GetParams("FirstName");
        string LastName = GetParams("LastName");
        string Password = GetParams("Password");
        string Email = GetParams("Email");
        string AreaId = GetParams("AreaId");
        string RoleId = GetParams("RoleId");
        string TafkidId = GetParams("TafkidId");
        string IsNew = GetParams("IsNew");



        DataTable dt = Dal.ExeSp("User_SetData", UserNumber, FirstName, LastName, Password, Email, AreaId, RoleId, TafkidId, IsNew);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));



    }


    #endregion

    #region Added
    /// <summary>
    /// שם כולל לקריאה מיוחדת הדרכות ועבודה חריגה
    /// </summary>
    [WebMethod]
    public void Added_SetData()
    {
        string Type = GetParams("Type");
        string IsOn = GetParams("IsOn");
        string ReasonId = GetParams("ReasonId");
        string Free = GetParams("Free");
        string AssignmentId = GetParams("AssignmentId");
        string UserId = GetParams("UserId");

        DataTable dt = Dal.ExeSp("Added_SetData", Type, IsOn, ReasonId, Free, AssignmentId, UserId);

        if (dt.Rows.Count > 0)
        {
            SendEmail.SendEmailExecute(dt.Rows[0][0].ToString(),
                dt.Rows[0][1].ToString(),
                dt.Rows[0][2].ToString(),
                dt.Rows[0][3].ToString(),
                dt.Rows[0][4].ToString(),
                dt.Rows[0][5].ToString(),
                dt.Rows[0][6].ToString(),
                dt.Rows[0][7].ToString(),
                dt.Rows[0][8].ToString(),
                dt.Rows[0][9].ToString()

                );

        }



        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }

    [WebMethod]
    public void Added_SetHerum()
    {

        string Date = GetParams("Date");
        string AssignmentId = GetParams("AssignmentId");
        string Type = GetParams("Type");


        DataTable dt = Dal.ExeSp("Added_SetHerum", Date, AssignmentId, Type);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }


    [WebMethod]
    public void Added_SetCapsula()
    {

        string AssignmentId = GetParams("AssignmentId");
        string Type = GetParams("Type");


        DataTable dt = Dal.ExeSp("Added_SetCapsula", AssignmentId, Type);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }


    /// <summary>
    ///מתודה חדשה שמביאה את
    /// </summary>
    [WebMethod]
    public void Assign_GetSymbolShiftWS()
    {

        string Date = GetParams("Date");


        DataTable dt = Dal.ExeSp("Assign_GetSymbolShiftWS", Date);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }


    [WebMethod]
    public void Added_SetAsterisk()
    {


        string AssignmentId = GetParams("AssignmentId");
        string Type = GetParams("Type");
        string NoAssignChangeReason = GetParams("NoAssignChangeReason");


        DataTable dt = Dal.ExeSp("Added_SetAsterisk", AssignmentId, Type, NoAssignChangeReason, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }





    [WebMethod]
    public void Added_SetAutoToranHerum()
    {

        string SearchDate = GetParams("SearchDate");
        string OrgUnitCode = GetParams("OrgUnitCode");



        DataTable dt = Dal.ExeSp("Added_SetAutoToranHerum", SearchDate, OrgUnitCode);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }









    #endregion

    #region User

    [WebMethod]
    public void User_GetUserEnter()
    {

        string UserName = GetParams("UserName");
        string Password = GetParams("Password");



        DataTable dt = Dal.ExeSp("User_GetUserEnter", UserName, Password);


        if (dt.Rows.Count > 0)
        {
            HttpCookie cookie = new HttpCookie("UserData");
            cookie["UserId"] = dt.Rows[0]["UserId"].ToString();
            cookie["RoleId"] = dt.Rows[0]["RoleId"].ToString();
            cookie["UserName"] = Server.UrlEncode(dt.Rows[0]["UserName"].ToString());

            cookie.Expires = DateTime.Now.AddYears(90);
            HttpContext.Current.Response.Cookies.Add(cookie);

        }


        //if (dt.Rows.Count > 0)
        //{
        //    Generic.UserId = dt.Rows[0]["UserId"].ToString();
        //    Generic.RoleId = dt.Rows[0]["RoleId"].ToString();


        //}
        //else
        //{
        //    Generic.UserId = "";
        //    Generic.RoleId = "";

        //}

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }

    [WebMethod]
    public void User_ExitUserEnter()
    {
        HttpCookie currentUserCookie = HttpContext.Current.Request.Cookies["UserData"];
        HttpContext.Current.Response.Cookies.Remove("UserData");
        currentUserCookie.Expires = DateTime.Now.AddDays(-10);
        currentUserCookie.Value = null;
        HttpContext.Current.Response.SetCookie(currentUserCookie);

    }


        #endregion

    #region Shift

        [WebMethod]
    public void Shift_GetRelvantShiftCombo()
    {

        string SearchDate = GetParams("SearchDate");
        string RoleId = GetParams("RoleId");



        DataTable dt = Dal.ExeSp("Shift_GetRelvantShiftCombo", SearchDate, RoleId);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }


    [WebMethod]
    public void Shift_CloseShift()
    {

        string ShiftCode = GetParams("ShiftCode");
        string ShiftDate = GetParams("ShiftDate");
        string UserId = GetParams("UserId");
        string FreeText = GetParams("FreeText");


        DataTable dt = Dal.ExeSp("Shift_CloseShift", ShiftDate, ShiftCode, UserId, FreeText);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }







    #endregion

    #region Validation
    [WebMethod]
    public void Validation_CheckAreasValidation()
    {
        string OrgUnitCode = GetParams("OrgUnitCode");
        string DateStart = GetParams("DateStart");

        DataTable dt = Dal.ExeSp("Validation_CheckAreasValidation", OrgUnitCode, DateStart);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }


    #endregion

    #region General





    [WebMethod]
    public void Gen_GetTable()
    {

        string TableName = GetParams("TableName");
        string Condition = GetParams("Condition");


        DataTable dt = Dal.ExeSp("Gen_GetTable", TableName, Condition);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    }

    [WebMethod]
    public void Gen_DeleteTable()
    {
        string TableName = GetParams("TableName");
        string ColName = GetParams("ColName");
        string Val = GetParams("Val");

        DataTable dt = Dal.ExeSp("Gen_DeleteTable", TableName, ColName, Val);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));

    }


    //[WebMethod]
    //public void Gen_GetJobsInArea()
    //{

    //    string AreaId = HttpContext.Current.Request.Form["AreaId"].ToString();

    //    DataTable dt = Dal.ExeSp("Gen_GetJobsInArea", AreaId);

    //    HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    //}


    //[WebMethod]
    //public void Gen_SetJobsInArea()
    //{

    //    string JobId = GetParams("JobId");
    //    string AreaId = GetParams("AreaId");

    //    string Alias = GetParams("Alias");
    //    string Desc = GetParams("Desc");

    //    DataTable dt = Dal.ExeSp("Gen_SetJobsInArea", JobId, AreaId, Desc, Alias);

    //    HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    //}

    //[WebMethod]
    //public void Gen_DeleteJobsInArea()
    //{

    //    string JobId = GetParams("JobId");


    //    DataTable dt = Dal.ExeSp("Gen_DeleteJobsInArea", JobId);

    //    HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    //}



    //[WebMethod]
    //public void Gen_GetShifts()
    //{

    //    string ShiftId = HttpContext.Current.Request.Form["ShiftId"].ToString();

    //    DataTable dt = Dal.ExeSp("Gen_GetShifts", ShiftId);

    //    HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    //}

    //[WebMethod]
    //public void Gen_GetAreaMessages()
    //{

    //    string AreaId = GetParams("AreaId");
    //    string Date = GetParams("Date");
    //    string Mode = GetParams("Mode");

    //    DataTable dt = Dal.ExeSp("Gen_GetAreaMessages", AreaId, Date, Mode);

    //    HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    //}

    //[WebMethod]
    //public void Gen_SetAreaMessages()
    //{

    //    string AreaId = GetParams("AreaId");
    //    string Message = GetParams("Message");
    //    string MessageRoutine = GetParams("MessageRoutine");
    //    string UserId = GetParams("UserId");

    //    DataTable dt = Dal.ExeSp("Gen_SetAreaMessages", AreaId, Message, MessageRoutine, UserId);

    //    HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    //}


    //[WebMethod]
    //public void Gen_GetAllTasksInArea()
    //{

    //    string AreaId = GetParams("AreaId");

    //    DataTable dt = Dal.ExeSp("Gen_GetAllTasksInArea", AreaId);

    //    HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));


    //}


    //[WebMethod]
    //public void Gen_GetUserConfirm()
    //{
    //    string Module = GetParams("Module");
    //    string AreaId = GetParams("AreaId");
    //    string type = GetParams("type");
    //    DataTable dt = Dal.ExeSp("Gen_GetUserConfirm", Module, AreaId, type);
    //    HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    //}
    //[WebMethod]
    //public void Gen_SetUserConfirm()
    //{
    //    string UserId = GetParams("UserId");
    //    string Module = GetParams("Module");
    //    string AreaId = GetParams("AreaId");
    //    DataTable dt = Dal.ExeSp("Gen_SetUserConfirm", UserId, Module, AreaId);
    //    HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    //}
    //[WebMethod]
    //public void Gen_GetAreas()
    //{

    //    string AreaId = GetParams("AreaId");
    //    DataTable dt = Dal.ExeSp("Gen_GetAreas", AreaId);
    //    HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    //}
    //[WebMethod]
    //public void Gen_GetUser()
    //{

    //    string AreaId = GetParams("AreaId");
    //    DataTable dt = Dal.ExeSp("Gen_GetUser", AreaId);
    //    HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    //}



    #endregion

    #region Employees


    [WebMethod]
    public void Employees_GetEmployeesList()
    {

        string EmpNo = GetParams("EmpNo");
        string Type = GetParams("Type");

        DataTable dt = Dal.ExeSp("Employees_GetEmployeesList", Type, EmpNo);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }




    #endregion


    #region Report
    [WebMethod]
    public void Report_GetReportLog()
    {

        string TransactId = GetParams("TransactId");
        string StartDate = GetParams("StartDate");
        string EndDate = GetParams("EndDate");

        string UserId = GetParams("UserId");
        string Area = GetParams("Area");
        string EmpNumber = GetParams("EmpNumber");

        DataTable dt = Dal.ExeSp("Report_GetReportLog", TransactId, StartDate, EndDate, UserId, Area, EmpNumber);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }
    [WebMethod]
    public void Report_GetUserTable()
    {



        DataTable dt = Dal.ExeSp("Report_GetUserTable");
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }


    #endregion


    #region  Hasot

    [WebMethod]
    public void Hasot_SetHasaForEmp()
    {

        string EmpNo = GetParams("EmpNo");
        string IsHasa = GetParamsValueIfExist("IsHasa");
        string IsImahot = GetParamsValueIfExist("IsImahot");
        string UserId = HttpContext.Current.Request.Cookies["UserData"]["UserId"];
        string IsYom = GetParamsValueIfExist("IsYom");
        string CityValueCode = GetParamsValueIfExist("CityValueCode");
        string StreetTemp = GetParamsValueIfExist("StreetTemp");



        //   bool IsImahotB = (IsImahot == "true") ? true : false;
        DataTable dt = Dal.ExeSp("Hasot_SetHasaForEmp", EmpNo, IsHasa, IsImahot, IsYom, CityValueCode, StreetTemp, UserId);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }


    [WebMethod]
    public void Hasot_GetHasot()
    {

        string Date = GetParams("SearchDate");
        string ShiftId = GetParams("ShiftId");

        string Dir = GetParams("Dir");
        string Mode = GetParams("Mode");

        DataSet ds = Dal.ExeDataSetSp("Hasot_GetHasot", Date, ShiftId, Dir, Mode);



        Hasot Hasa = new Hasot(ds, Dir, Date, ShiftId);



        //רק במידה וזה חדש תעשה עדכון 
        if (ds.Tables.Count > 5)
            Hasa.BindMaslulToTaxi();


        DataTable dt = Hasa.GetFINALDataFroMHasot();

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }

    [WebMethod]
    public void Hasot_GetShiftTimes()
    {

        string Date = GetParams("Date");
        string ShiftId = GetParams("ShiftId");


        //string Mode = GetParams("Mode");


        DataTable dt = Dal.ExeSp("Hasot_GetShiftTimes", Date, ShiftId);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }

    [WebMethod]
    public void Hasot_GetHasotShiftTimes()
    {

        string Date = GetParams("Date");
        string ShiftId = GetParams("ShiftId");
        string Mode = GetParams("Mode");


        DataTable dt = Dal.ExeSp("Hasot_GetHasotShiftTimes", Date, ShiftId, Mode);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }


    [WebMethod]
    public void Hasot_GetMaslulim()
    {
        DataSet ds = Dal.ExeDataSetSp("Hasot_GetHasot", "", "", "", "0");
        DataTable dt = ds.Tables[2];
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }


    [WebMethod]
    public void Hasot_GetSetMaslulim()
    {
        string Type = GetParamsValueIfExist("Type");
        string Id = GetParamsValueIfExist("Id");
        string Sap_Id = GetParamsValueIfExist("Sap_Id");

        string MaslulDesc = GetParamsValueIfExist("MaslulDesc");
        MaslulDesc = MaslulDesc.Replace(",", "+");
        string City1 = GetParamsValueIfExist("City1");
        string City2 = GetParamsValueIfExist("City2");
        string City3 = GetParamsValueIfExist("City3");
        string City4 = GetParamsValueIfExist("City4");
        string TimeBeforeTaxi = GetParamsValueIfExist("TimeBeforeTaxi");
        string Tarif = GetParamsValueIfExist("Tarif");
        string MaslulType = GetParamsValueIfExist("MaslulType");
        string IsOnlyMinibus = GetParamsValueIfExist("IsOnlyMinibus");
        bool bIsOnlyMinibus = false;
        if (IsOnlyMinibus == "true") bIsOnlyMinibus = true;
        DataTable dt = Dal.ExeSp("Hasot_GetSetMaslulim", Type, Id, Sap_Id, MaslulDesc, City1, City2, City3, City4, TimeBeforeTaxi, Tarif, bIsOnlyMinibus, MaslulType);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }

    [WebMethod]
    public void Hasot_GetSetAreas()
    {
        string Type = GetParamsValueIfExist("Type");
        string Id = GetParamsValueIfExist("Id");


        string Code = GetParamsValueIfExist("Code");
        string Name = GetParamsValueIfExist("Name");



        DataTable dt = Dal.ExeSp("Hasot_GetSetAreas", Type, Id, Name, Code);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }

    [WebMethod]
    public void Hasot_SetHasot()
    {



        string EmpId = GetParamsValueIfExist("EmpId");
        string Date = GetParamsValueIfExist("Date");
        string HasotTime = GetParamsValueIfExist("HasotTime");
        string ShiftId = GetParamsValueIfExist("ShiftId");
        string Dir = GetParamsValueIfExist("Dir");
        string City = GetParamsValueIfExist("City");
        string Mode = GetParamsValueIfExist("Mode");
        string MaslulId = GetParamsValueIfExist("MaslulId");
        string Comment = GetParamsValueIfExist("Comment");

        string CarTypeId = GetParamsValueIfExist("CarTypeId");
        string CarSymbol = GetParamsValueIfExist("CarSymbol");
        string Seq = GetParamsValueIfExist("Seq");
      
        string ExtraSapId = GetParamsValueIfExist("ExtraSapId");
       
        string TempStreet = GetParamsValueIfExist("TempStreet");
        string StartDate = GetParamsValueIfExist("StartDate");
        string EndDate = GetParamsValueIfExist("EndDate");
        string Mdest = GetParamsValueIfExist("Mdest");
        
        string Mprice = GetParamsValueIfExist("Mprice");
        string HasotId = GetParamsValueIfExist("HasotId");
        string Sap_Id = GetParamsValueIfExist("Sap_Id");

        string SourceSeq = GetParamsValueIfExist("SourceSeq");
        string SourceMaslulId = GetParamsValueIfExist("SourceMaslulId");
        string SourceCarTypeId = GetParamsValueIfExist("SourceCarTypeId");
        int ResMaslulId = 0; 

        if (Mode == "1")
        {
            DataSet dsAdd = Dal.ExeDataSetSp("Hasot_SetHasot", EmpId, Date, HasotTime, ShiftId, Dir, City, "15", MaslulId, Comment, CarTypeId, CarSymbol, Seq, ExtraSapId, TempStreet, StartDate, EndDate, Mdest, Mprice, HasotId, Sap_Id, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);
            bool IsAllHaveCity = false;
            ResMaslulId = CreateNewMaslulId(dsAdd,ref IsAllHaveCity, City);

            if (!IsAllHaveCity)
            {
               // DataTable dtRes = new DataTable("dtRes");
                DataTable dtRes = dsAdd.Tables[1];
                dtRes.Rows[0][0] = 0;
                HttpContext.Current.Response.Write(ConvertDataTabletoString(dtRes));


                return;
            }

          
        }

        if (Mode == "5")
        {

            string TitleIsuf = GetParamsValueIfExist("TitleIsuf");
            string TitlePizur = GetParamsValueIfExist("TitlePizur");

            string BodyTitle = TitleIsuf + "<br>" + TitlePizur;

            System.IO.DirectoryInfo di = new DirectoryInfo(HttpContext.Current.Server.MapPath("~/App_Data/"));

            foreach (FileInfo file in di.GetFiles())
            {
                file.Delete();
            }

            string Html = GetParamsValueIfExist("Html");
            string TaxiMail = ConfigurationManager.AppSettings["TaxiMail"].ToString();
            string Title = "מצורף קובץ של סידור מוניות:";
            if (CarTypeId == "2")
            {
                Title = "מצורף קובץ של סידור מיניבוסים:";
                TaxiMail = ConfigurationManager.AppSettings["BusMail"].ToString();
            }
                //BaseFont bf = BaseFont.CreateFont("c:/windows/fonts/arial.ttf", BaseFont.IDENTITY_H, true);
            //iTextSharp.text.Font font = new iTextSharp.text.Font(bf, 10, iTextSharp.text.Font.NORMAL);
            byte[] pdf; // result will be here
            var cssText = File.ReadAllText(HttpContext.Current.Server.MapPath("~/assets/css/send.css"));
            var html = "<div dir='rtl' style='font-family:arial;direction:rtl'>" + Html.Replace("<br>", "<br />").Replace("@", "").Replace("<hr>", "<br />") + "</div>"; //File.ReadAllText(MapPath("~/css/test.html"));
          
            
            
            using (var memoryStream = new MemoryStream())
            {
                var document = new Document(PageSize.A4, 50, 50, 60, 60);
                var writer = PdfWriter.GetInstance(document, memoryStream);
                document.Open();
                writer.PageEvent = new Footer();
                using (var cssMemoryStream = new MemoryStream(System.Text.Encoding.UTF8.GetBytes(cssText)))
                {
                    using (var htmlMemoryStream = new MemoryStream(System.Text.Encoding.UTF8.GetBytes(html)))
                    {
                        XMLWorkerHelper.GetInstance().ParseXHtml(writer, document, htmlMemoryStream, cssMemoryStream);

                    }
                }

              
                document.Close();

                pdf = memoryStream.ToArray();

                string FilePath = HttpContext.Current.Server.MapPath("~/App_Data/") + DateTime.Now.ToString("ddMMyyyyHHss") + ".pdf";
                System.IO.File.WriteAllBytes(FilePath, pdf);
                SendEmail.SendEmailExecuteTaxiWithAttach(Date, FilePath, TaxiMail, BodyTitle, Title);
               
            }


          
            if (CarTypeId == "2")
            {
                DataTable dtRes = new DataTable();
                HttpContext.Current.Response.Write(ConvertDataTabletoString(dtRes));

                return;
            }
        }

        if (Mode == "7")
        {
            System.IO.DirectoryInfo di = new DirectoryInfo(HttpContext.Current.Server.MapPath("~/Excel/"));

            foreach (FileInfo file in di.GetFiles())
            {
                file.Delete();
            }


            DataTable dtSummery = Dal.ExeSp("Hasot_SetHasot", EmpId, Date, HasotTime, ShiftId, Dir, City, 6, MaslulId, Comment, CarTypeId, CarSymbol, Seq, ExtraSapId, TempStreet, StartDate, EndDate, Mdest, Mprice, HasotId, Sap_Id, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);

            dtSummery.Columns.RemoveAt(0);

            dtSummery = SetDataTableManipulateDetails(dtSummery);
            while (dtSummery.Columns.Count > 7)
            {
                dtSummery.Columns.RemoveAt(7);
            }




            dtSummery.Columns[0].Caption = "כיוון";
            dtSummery.Columns[1].Caption = "מספר נסיעה";
            dtSummery.Columns[2].Caption = "תאריך נסיעה";
            dtSummery.Columns[3].Caption = "שעת נסיעה";
            dtSummery.Columns[4].Caption = "מספר מסלול";
            dtSummery.Columns[5].Caption = "מסלול";
            dtSummery.Columns[6].Caption = "תעריף";

            for (int i = 0; i < dtSummery.Rows.Count; i++)
            {


                string pad = string.Format("{0:0000}", Helper.ConvertToInt(dtSummery.Rows[i][1].ToString()));
                dtSummery.Rows[i][1] = pad;
                //  dtSummery.AcceptChanges();


            }


            string host = HttpContext.Current.Request.Url.AbsoluteUri;
            var currentDate = DateTime.Now.ToString("dd_MM_yyyy_HH_ss");
            string FilePath = HttpContext.Current.Server.MapPath("~/Excel/") + currentDate + ".xlsx";

            CreateNewExcelCloseXML(FilePath, dtSummery, StartDate, EndDate);
            // 
            //GeneratedClass ff = new GeneratedClass();
            //ff.CreatePackage(FilePath);

            //ImportDataTableIntoNewFile(FilePath, dtSummery, StartDate, EndDate);
            host = host.Replace("WebService.asmx/Hasot_SetHasot", "Excel/" + currentDate + ".xlsx");
            dtSummery.Rows[0][1] = host;

            //CreateSpreadsheetWorkbook(FilePath);



            HttpContext.Current.Response.Write(ConvertDataTabletoString(dtSummery));



            return;

        }

        //הורדה של אקסל
        if (Mode == "77")
        {
            System.IO.DirectoryInfo di = new DirectoryInfo(HttpContext.Current.Server.MapPath("~/Excel/"));

            foreach (FileInfo file in di.GetFiles())
            {
                file.Delete();
            }


            DataTable dtSummery = Dal.ExeSp("Hasot_SetHasot", EmpId, Date, HasotTime, ShiftId, Dir, City, 66, MaslulId, Comment, CarTypeId, CarSymbol, Seq, ExtraSapId, TempStreet, StartDate, EndDate, Mdest, Mprice, HasotId, Sap_Id, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);
            dtSummery = SetDataTableManipulate(dtSummery);

            dtSummery.Columns["MaslulDescClear"].SetOrdinal(2);
            dtSummery.Columns["MaslulDesc"].SetOrdinal(10);

            while (dtSummery.Columns.Count > 9)
            {
                dtSummery.Columns.RemoveAt(9);
            }




            dtSummery.Columns[0].Caption = "מס' מסלול";
            dtSummery.Columns[1].Caption = "שם מסלול";
            dtSummery.Columns[2].Caption = "כמות נסיעות";
            dtSummery.Columns[3].Caption = "תעריף";
            dtSummery.Columns[4].Caption = "סה''כ";
            dtSummery.Columns[5].Caption = "כמות נסיעות לילה/שבת/חג";
            dtSummery.Columns[6].Caption = "תעריף לילה/שבת/חג";
            dtSummery.Columns[7].Caption = "סה''כ";
            dtSummery.Columns[8].Caption = "סה''כ לתשלום";


            //for (int i = 0; i < dtSummery.Rows.Count; i++)
            //{


            //    string pad = string.Format("{0:0000}", Helper.ConvertToInt(dtSummery.Rows[i][1].ToString()));
            //    dtSummery.Rows[i][1] = pad;
            //    //  dtSummery.AcceptChanges();


            //}


            string host = HttpContext.Current.Request.Url.AbsoluteUri;
            var currentDate = DateTime.Now.ToString("dd_MM_yyyy_HH_ss");
            string FilePath = HttpContext.Current.Server.MapPath("~/Excel/") + currentDate + ".xlsx";

            CreateNewExcelCloseXMLOne(FilePath, dtSummery, StartDate, EndDate);
            // 
            //GeneratedClass ff = new GeneratedClass();
            //ff.CreatePackage(FilePath);

            //ImportDataTableIntoNewFile(FilePath, dtSummery, StartDate, EndDate);
            host = host.Replace("WebService.asmx/Hasot_SetHasot", "Excel/" + currentDate + ".xlsx");
            dtSummery.Rows[0][1] = host;

            //CreateSpreadsheetWorkbook(FilePath);



            HttpContext.Current.Response.Write(ConvertDataTabletoString(dtSummery));



            return;

        }

        DataSet ds = Dal.ExeDataSetSp("Hasot_SetHasot", EmpId, Date, HasotTime, ShiftId, Dir, City, Mode, MaslulId, Comment, CarTypeId, CarSymbol, Seq, ExtraSapId, TempStreet, StartDate, EndDate, Mdest, Mprice, HasotId, Sap_Id, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);
        DataTable dt = new DataTable();//ds.Tables[0];

        if (ds.Tables.Count > 0)
            dt = ds.Tables[0];

        // החזרת נתונים
        if (Mode == "66")
        {
            dt = SetDataTableManipulate(dt,true);

        }

        else if (Mode == "6")
        {
            dt = SetDataTableManipulateDetails(dt);

        }

        else
        {

           

        }

        if (Mode == "0" && CarTypeId == "1")
        {
            bool IsAllHaveCity = false;
            ResMaslulId = CreateNewMaslulId(ds, ref IsAllHaveCity);
           

        }

        if (ResMaslulId != 0 && ResMaslulId.ToString() != MaslulId)
        {
           

            Dal.ExeSp("Hasot_SetHasot", EmpId, Date, HasotTime, ShiftId, Dir, City, "143", ResMaslulId, Comment, CarTypeId, CarSymbol, Seq, ExtraSapId, TempStreet, StartDate, EndDate, Mdest, Mprice, HasotId, Sap_Id, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);
        }


        int CurrentSourceSeq = Helper.ConvertToInt(SourceSeq);

        if (CurrentSourceSeq != 0 && SourceCarTypeId == "1")
        {
            DataSet dsAdd = Dal.ExeDataSetSp("Hasot_SetHasot", EmpId, Date, HasotTime, ShiftId, Dir, City, "15", MaslulId, Comment, CarTypeId, CarSymbol, CurrentSourceSeq, ExtraSapId, TempStreet, StartDate, EndDate, Mdest, Mprice, HasotId, Sap_Id, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);
            bool IsAllHaveCity = false;
            ResMaslulId = CreateNewMaslulId(dsAdd, ref IsAllHaveCity);
            if (ResMaslulId != 0 && ResMaslulId.ToString() != SourceMaslulId)
            {
                Dal.ExeSp("Hasot_SetHasot", EmpId, Date, HasotTime, ShiftId, Dir, City, "144", ResMaslulId, Comment, CarTypeId, CarSymbol, CurrentSourceSeq, ExtraSapId, TempStreet, StartDate, EndDate, Mdest, Mprice, HasotId, Sap_Id, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);
            }

        }

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }

    private int CreateNewMaslulId(DataSet ds,ref bool IsAllHaveCity, string City = null)
    {
        List<Maslulim> Maslulim = new List<Maslulim>();
        List<HasotTemplate> HasotTemplateList = new List<HasotTemplate>();

        int CurrentMaslulId = 0;
        
        Maslulim CurrentMaslul = new Maslulim();
        foreach (DataRow row in ds.Tables[0].Rows)
        {
            HasotTemplate Obj = new HasotTemplate(row);
            HasotTemplateList.Add(Obj);

            CurrentMaslulId = (int)Obj.MaslulId;
        }



        foreach (DataRow row in ds.Tables[1].Rows)
        {
            Maslulim Obj = new Maslulim(row);
            Maslulim.Add(Obj);

            if (Obj.Id == CurrentMaslulId)
                CurrentMaslul = Obj;


        }
        int res = 0;

        if(HasotTemplateList.Count==1 && HasotTemplateList[0].EmpNo == "0" || CurrentMaslul.Sap_Id==99)
        {
            if (CurrentMaslul.AllCity.Contains(City) || CurrentMaslul.Sap_Id == 99)
            {
                IsAllHaveCity = true;
                return CurrentMaslulId;

            }
            else
            {
                return 0;

            }

        }




        var MaslulimSearch = Maslulim.Where(x => x.Type == CurrentMaslul.Type).ToList();
        var AllCityInSeq = HasotTemplateList.Where(x=>x.CityCode!="").Select(x => x.CityCode).ToList();
        if (!string.IsNullOrEmpty(City)) AllCityInSeq.Add(City);
        List<NewMaslulim> NewMaslulimList = new List<NewMaslulim>();
        foreach (var item in MaslulimSearch.OrderByDescending(x => x.AllCity.Count))
        {
            IEnumerable<string> both = item.AllCity.Intersect(AllCityInSeq.Distinct());

            if (both.Count() >= AllCityInSeq.Distinct().Count()) IsAllHaveCity = true;

            if (both.Count() > 0)
            {
                NewMaslulim nm = new NewMaslulim();
                nm.MaslulId = item.Id;
                nm.BothMaslulCount = both.Count();
                nm.MaslulCityCount = item.AllCity.Count;

                NewMaslulimList.Add(nm);
                //return item.Id;

            }

            //if (both.Count() > 1)
            //{
            //    return item.Id;
            //}

            //if (both.Count() == 1)
            //{
            //    res = item.Id;

            //}

        }

        if (NewMaslulimList.Count > 0)
        {
            var ResMaslul = NewMaslulimList.OrderByDescending(x=>x.BothMaslulCount).ThenBy(x => x.MaslulCityCount - x.BothMaslulCount).FirstOrDefault();

            return ResMaslul.MaslulId;

        }




        return res;


    }

    private DataTable SetDataTableManipulate(DataTable dt,bool isFromScreen=false)
    {
        DataTable NewDt = dt.Clone();
        NewDt.Clear();

        NewDt.Columns["Total"].DataType = typeof(string);
        NewDt.Columns["Total200"].DataType = typeof(string);

        NewDt.Columns.Add("TotalAll");
        NewDt.Columns.Add("TotalAllForReport");
        NewDt.Columns.Add("MamAllForReport");
        NewDt.Columns.Add("TashlumForReport");
        NewDt.Columns.Add("MaslulDescClear");



        float TotalAllForReport = 0;
        double MamAllForReport = 0;
        double TashlumForReport = 0;

        DataView view = new DataView(dt);
        DataTable distinctValues = view.ToTable(true, "Sap_Id");

        foreach (DataRow item in distinctValues.Rows)
        {

            if (Helper.ConvertToInt(item[0].ToString()) > 199) break;
            //string Sap_Id = dt.Select("Sap_Id=" + item[0])[]
            //int TaxiCount =Helper.ConvertToInt(dt.Compute("SUM(TaxiCount)", "Sap_Id=" + item[0]).ToString());
            //Decimal Total = Convert.ToDecimal(dt.Compute("SUM(Total)", "Sap_Id=" + item[0]));
            int Sap_Id = Helper.ConvertToInt(item[0].ToString());
            string MaslulDesc = "";
            string MaslulDescClear = "";
            int TaxiCount = 0;
            float Total = 0;
            float Tarif = 0;
            int TaxiCount200 = 0;
            float Total200 = 0;
            float Tarif200 = 0;


            DataRow[] SapRows = dt.Select("Sap_Id=" + Sap_Id);
            foreach (DataRow row in SapRows)
            {
                string CurrentSap_Id = row["Sap_Id"].ToString();
                string RowMaslulDesc = row["MaslulDesc"].ToString();

                if (CurrentSap_Id != "20")
                {

                    if (string.IsNullOrEmpty(MaslulDesc))
                    {
                        MaslulDesc = RowMaslulDesc;
                        MaslulDescClear = RowMaslulDesc;
                    }
                    else
                    {

                        MaslulDesc = MaslulDesc + " <span style='font-weight:bold;font-size:18px;text-decoration:underline'> או </span>" + RowMaslulDesc;


                        MaslulDescClear = MaslulDescClear + " או " + RowMaslulDesc;

                    }

                }
                else
                {
                    MaslulDesc = "אשקלון";
                    MaslulDescClear = "אשקלון";

                }
                TaxiCount += Helper.ConvertToInt(row["TaxiCount"].ToString());
                Total += Helper.ConvertToFloat(row["Total"].ToString());
                Tarif = Helper.ConvertToFloat(row["Tarif"].ToString());
            }

            SapRows = dt.Select("Sap_Id=" + (Sap_Id + 200));
            foreach (DataRow row in SapRows)
            {


                TaxiCount200 += Helper.ConvertToInt(row["TaxiCount"].ToString());
                Total200 += Helper.ConvertToFloat(row["Total"].ToString());
                Tarif200 = Helper.ConvertToFloat(row["Tarif"].ToString());

            }


            
            DataRow NewRow = NewDt.NewRow();
            NewRow["Sap_Id"] = Sap_Id;
            NewRow["MaslulDesc"] = "<a href='#' onclick='RedirectToDetails(" + Sap_Id + ")'>" + MaslulDesc + "</a>";
            NewRow["MaslulDescClear"] = MaslulDescClear;
            NewRow["TaxiCount"] = TaxiCount;

            
            NewRow["Total"] = Total.ToString("N2");
            NewRow["Tarif"] = Tarif.ToString("N2");

            NewRow["TaxiCount200"] = TaxiCount200;
            NewRow["Total200"] = Total200.ToString("N2");
            NewRow["Tarif200"] = Tarif200.ToString("N2");

            if(isFromScreen)
               NewRow["TotalAll"] = (Total + Total200).ToString("N2");//.ToString("N2");
            else
                NewRow["TotalAll"] =  (Total + Total200);//.ToString("N2");


            NewDt.Rows.Add(NewRow);

            TotalAllForReport += Total + Total200;


        }
        MamAllForReport = TotalAllForReport * 0.17;
        TashlumForReport = MamAllForReport + TotalAllForReport;
        NewDt.Rows[0]["TotalAllForReport"] = TotalAllForReport.ToString("N2");
        NewDt.Rows[0]["MamAllForReport"] = MamAllForReport.ToString("N2");
        NewDt.Rows[0]["TashlumForReport"] = TashlumForReport.ToString("N2");
        //  var TotalAllForReport = NewDt.Select("Sum(cast(TotalAll as float))");

        return NewDt;
    }

    private DataTable SetDataTableManipulateDetails(DataTable dt)
    {


        dt.Columns.Add("TotalAllForReport");
        dt.Columns.Add("MamAllForReport");
        dt.Columns.Add("TashlumForReport");


        float TotalAllForReport = 0;
        double MamAllForReport = 0;
        double TashlumForReport = 0;

        var varTotalAllForReport = dt.Compute("Sum(Tarif)", "");

        TotalAllForReport = Helper.ConvertToFloat(varTotalAllForReport.ToString());
        if (TotalAllForReport > 0)
        {

            MamAllForReport = TotalAllForReport * 0.17;
            TashlumForReport = MamAllForReport + TotalAllForReport;


            dt.Rows[0]["TotalAllForReport"] = TotalAllForReport.ToString("N2");
            dt.Rows[0]["MamAllForReport"] = MamAllForReport.ToString("N2");
            dt.Rows[0]["TashlumForReport"] = TashlumForReport.ToString("N2");
            //  var TotalAllForReport = NewDt.Select("Sum(cast(TotalAll as float))");
        }
        //else
        //{
        //    dt.Rows[0]["TotalAllForReport"] = 0;
        //    dt.Rows[0]["MamAllForReport"] = 0;
        //    dt.Rows[0]["TashlumForReport"] = 0;



        //}
        return dt;
    }

    private void CreateNewExcelCloseXML(string FilePath, DataTable dataTable, string StartDate, string EndDate)
    {
        using (var workbook = new XLWorkbook() { RightToLeft = true })
        {




            var worksheet = workbook.Worksheets.Add(" סיכום חודשי מפורט ");

            worksheet.Cell("A2").Value = "דוח מפורט לתאריכים: " + StartDate + " - " + EndDate + " " + "    כמות מוניות: " + dataTable.Rows.Count;
            var range = worksheet.Range("A2:G2");
            range.Merge();

            // worksheet.Cell("A2").FormulaA1 = "=MID(A1, 7, 5)";
            //worksheet.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
            //worksheet.Style.Font.Bold = true;
            //worksheet.Style.Fill.BackgroundColor.SetColor(Color.LightGreen);
            range.Style.Fill.BackgroundColor = XLColor.Goldenrod;
            range.Style.Border.OutsideBorder = XLBorderStyleValues.Thin;
            range.Style.Font.Bold = true;
            range.Style.Font.FontSize = 15;
            range.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            //var rangeTitles = worksheet.Range("A4:G4");
            // rangeTitles.Style.Fill.BackgroundColor = XLColor.LightGoldenrodYellow;
            // rangeTitles.Style.Border.OutsideBorder = XLBorderStyleValues.Thin;
            // rangeTitles.Style.Font.Bold = true;
            // rangeTitles.Style.Font.FontSize = 13;
            // rangeTitles.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
            //  var ws = workbook.Worksheets.Add("Column Settings");

            for (int index = 0; index < dataTable.Columns.Count; index++)
            {
                worksheet.Cell(4, index + 1).Value = dataTable.Columns[index].Caption;

                worksheet.Cell(4, index + 1).Style.Fill.BackgroundColor = XLColor.LightGoldenrodYellow;
                worksheet.Cell(4, index + 1).Style.Border.OutsideBorder = XLBorderStyleValues.Thin;
                worksheet.Cell(4, index + 1).Style.Font.Bold = true;
                worksheet.Cell(4, index + 1).Style.Font.FontSize = 13;
                worksheet.Cell(4, index + 1).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                worksheet.Cell(4, index + 1).WorksheetColumn().Width = 18;
                //var col1 = workbook.ColumnWidth( .Column("A");
                //col1.Width = 30;

                //document.SetCellValue(SLConvert.ToCellReference(4, index + 1), dataTable.Columns[index].Caption);

                //document.SetCellStyle(4, index + 1, styleTable);



            }


            for (int i = 0; i < dataTable.Rows.Count; i++)
            {
                worksheet.Cell(5 + i, 1).Value = dataTable.Rows[i][0].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 1));
                worksheet.Cell(5 + i, 2).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                worksheet.Cell(5 + i, 2).Style.NumberFormat.Format = "@";
                worksheet.Cell(5 + i, 2).Value = dataTable.Rows[i][1].ToString();

                SetStyleToCell(worksheet.Cell(5 + i, 2));


                worksheet.Cell(5 + i, 3).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                worksheet.Cell(5 + i, 3).Value = dataTable.Rows[i][2].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 3));

                worksheet.Cell(5 + i, 4).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                worksheet.Cell(5 + i, 4).Style.NumberFormat.Format = "@";
                worksheet.Cell(5 + i, 4).Value = dataTable.Rows[i][3].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 4));
                worksheet.Cell(5 + i, 5).Value = dataTable.Rows[i][4].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 5));


                worksheet.Cell(5 + i, 6).Value = dataTable.Rows[i][5].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 6));

                worksheet.Cell(5 + i, 7).Value = dataTable.Rows[i][6].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 7));

                worksheet.Cell(5 + i, 7).Style.Font.Bold = true;
            }


            var rngTotals = worksheet.Range(6 + dataTable.Rows.Count, 6, 8 + dataTable.Rows.Count, 7);
            SetRangeStyle(rngTotals);


            worksheet.Cell(6 + dataTable.Rows.Count, 6).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left);
            worksheet.Cell(6 + dataTable.Rows.Count, 6).Value = "סה''כ:";
            worksheet.Cell(6 + dataTable.Rows.Count, 6).Style.Font.Bold = true;

            worksheet.Cell(7 + dataTable.Rows.Count, 6).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left);
            worksheet.Cell(7 + dataTable.Rows.Count, 6).Value = "מע''מ:";
            worksheet.Cell(7 + dataTable.Rows.Count, 6).Style.Font.Bold = true;

            worksheet.Cell(8 + dataTable.Rows.Count, 6).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left);
            worksheet.Cell(8 + dataTable.Rows.Count, 6).Value = "סה''כ כללי לתשלום:";
            worksheet.Cell(8 + dataTable.Rows.Count, 6).Style.Font.Bold = true;

            var Sum = worksheet.Evaluate("SUM(G5:G" + (5 + dataTable.Rows.Count) + ")");
            var Maam = (double)Sum * 0.17;
            var Total = (double)Sum + Maam;


            worksheet.Cell(6 + dataTable.Rows.Count, 7).Value = Sum;
            worksheet.Cell(6 + dataTable.Rows.Count, 7).Style.Font.Bold = true;
            worksheet.Cell(6 + dataTable.Rows.Count, 7).Style.NumberFormat.Format = "#,##0.00";

            worksheet.Cell(7 + dataTable.Rows.Count, 7).Value = Maam;
            worksheet.Cell(7 + dataTable.Rows.Count, 7).Style.Font.Bold = true;
            worksheet.Cell(7 + dataTable.Rows.Count, 7).Style.NumberFormat.Format = "#,##0.00";

            worksheet.Cell(8 + dataTable.Rows.Count, 7).Value = Total;
            worksheet.Cell(8 + dataTable.Rows.Count, 7).Style.Font.Bold = true;
            worksheet.Cell(8 + dataTable.Rows.Count, 7).Style.NumberFormat.Format = "#,##0.00";

            worksheet.Columns().AdjustToContents();
            //  ws.Columns().AdjustToContents();


            workbook.SaveAs(FilePath);
        }
    }

    private void CreateNewExcelCloseXMLOne(string FilePath, DataTable dataTable, string StartDate, string EndDate)
    {
        using (var workbook = new XLWorkbook() { RightToLeft = true })
        {


            Decimal TotalPrice = Convert.ToDecimal(dataTable.Compute("SUM(TaxiCount) + SUM(TaxiCount200)", string.Empty));

            var worksheet = workbook.Worksheets.Add(" סיכום חודשי ");

            worksheet.Cell("A2").Value = "דוח לתאריכים: " + StartDate + " - " + EndDate + " " + "    כמות נסיעות: " + TotalPrice;
            var range = worksheet.Range("A2:I2");
            range.Merge();

            // worksheet.Cell("A2").FormulaA1 = "=MID(A1, 7, 5)";
            //worksheet.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
            //worksheet.Style.Font.Bold = true;
            //worksheet.Style.Fill.BackgroundColor.SetColor(Color.LightGreen);
            range.Style.Fill.BackgroundColor = XLColor.Goldenrod;
            range.Style.Border.OutsideBorder = XLBorderStyleValues.Thin;
            range.Style.Font.Bold = true;
            range.Style.Font.FontSize = 15;
            range.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            //var rangeTitles = worksheet.Range("A4:G4");
            // rangeTitles.Style.Fill.BackgroundColor = XLColor.LightGoldenrodYellow;
            // rangeTitles.Style.Border.OutsideBorder = XLBorderStyleValues.Thin;
            // rangeTitles.Style.Font.Bold = true;
            // rangeTitles.Style.Font.FontSize = 13;
            // rangeTitles.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
            //  var ws = workbook.Worksheets.Add("Column Settings");

            for (int index = 0; index < dataTable.Columns.Count; index++)
            {
                worksheet.Cell(4, index + 1).Value = dataTable.Columns[index].Caption;

                worksheet.Cell(4, index + 1).Style.Fill.BackgroundColor = XLColor.LightGoldenrodYellow;
                worksheet.Cell(4, index + 1).Style.Border.OutsideBorder = XLBorderStyleValues.Thin;
                worksheet.Cell(4, index + 1).Style.Font.Bold = true;
                worksheet.Cell(4, index + 1).Style.Font.FontSize = 13;
                worksheet.Cell(4, index + 1).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                worksheet.Cell(4, index + 1).WorksheetColumn().Width = 18;
                //var col1 = workbook.ColumnWidth( .Column("A");
                //col1.Width = 30;

                //document.SetCellValue(SLConvert.ToCellReference(4, index + 1), dataTable.Columns[index].Caption);

                //document.SetCellStyle(4, index + 1, styleTable);



            }


            for (int i = 0; i < dataTable.Rows.Count; i++)
            {
                worksheet.Cell(5 + i, 1).Value = dataTable.Rows[i][0].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 1));


                worksheet.Cell(5 + i, 2).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);
                // worksheet.Cell(5 + i, 2).Style.NumberFormat.Format = "@";
                worksheet.Cell(5 + i, 2).Value = dataTable.Rows[i][1].ToString();

                SetStyleToCell(worksheet.Cell(5 + i, 2));


                worksheet.Cell(5 + i, 3).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                worksheet.Cell(5 + i, 3).Value = dataTable.Rows[i][2].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 3));

                worksheet.Cell(5 + i, 4).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                worksheet.Cell(5 + i, 4).Style.NumberFormat.Format = "@";
                worksheet.Cell(5 + i, 4).Value = dataTable.Rows[i][3].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 4));
                worksheet.Cell(5 + i, 5).Value = dataTable.Rows[i][4].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 5));
                worksheet.Cell(5 + i, 5).Style.NumberFormat.Format = "#,##0.00";

                worksheet.Cell(5 + i, 6).Value = dataTable.Rows[i][5].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 6));

                worksheet.Cell(5 + i, 7).Value = dataTable.Rows[i][6].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 7));






                worksheet.Cell(5 + i, 8).Value = dataTable.Rows[i][7].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 8));
                worksheet.Cell(5 + i, 8).Style.NumberFormat.Format = "@";
                worksheet.Cell(5 + i, 8).Style.NumberFormat.Format = "#,##0.00";
                //   worksheet.Cell(5 + i, 8).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

                worksheet.Cell(5 + i, 9).Value = dataTable.Rows[i][8].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 9));
                //worksheet.Cell(5 + i, 9).Style.NumberFormat.Format = "@";
                worksheet.Cell(5 + i, 9).Style.NumberFormat.Format = "#,##0.00";

                worksheet.Cell(5 + i, 5).Style.Font.Bold = true;
                worksheet.Cell(5 + i, 8).Style.Font.Bold = true;
                worksheet.Cell(5 + i, 9).Style.Font.Bold = true;
            }


            var rngTotals = worksheet.Range(6 + dataTable.Rows.Count, 8, 8 + dataTable.Rows.Count, 9);
            SetRangeStyle(rngTotals);


            worksheet.Cell(6 + dataTable.Rows.Count, 8).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left);
            worksheet.Cell(6 + dataTable.Rows.Count, 8).Value = "סה''כ:";
            worksheet.Cell(6 + dataTable.Rows.Count, 8).Style.Font.Bold = true;

            worksheet.Cell(7 + dataTable.Rows.Count, 8).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left);
            worksheet.Cell(7 + dataTable.Rows.Count, 8).Value = "מע''מ:";
            worksheet.Cell(7 + dataTable.Rows.Count, 8).Style.Font.Bold = true;

            worksheet.Cell(8 + dataTable.Rows.Count, 8).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left);
            worksheet.Cell(8 + dataTable.Rows.Count, 8).Value = "סה''כ כללי לתשלום:";
            worksheet.Cell(8 + dataTable.Rows.Count, 8).Style.Font.Bold = true;


        

            var Sum = worksheet.Evaluate("SUM(I5:I" + (5 + dataTable.Rows.Count) + ")");
            var Maam = (double)Sum * 0.17;
            var Total = (double)Sum + Maam;


            worksheet.Cell(6 + dataTable.Rows.Count, 9).Value = Sum;
            worksheet.Cell(6 + dataTable.Rows.Count, 9).Style.Font.Bold = true;
            worksheet.Cell(6 + dataTable.Rows.Count, 9).Style.NumberFormat.Format = "#,##0.00";

            worksheet.Cell(7 + dataTable.Rows.Count, 9).Value = Maam;
            worksheet.Cell(7 + dataTable.Rows.Count, 9).Style.Font.Bold = true;
            worksheet.Cell(7 + dataTable.Rows.Count, 9).Style.NumberFormat.Format = "#,##0.00";

            worksheet.Cell(8 + dataTable.Rows.Count, 9).Value = Total;
            worksheet.Cell(8 + dataTable.Rows.Count, 9).Style.Font.Bold = true;
            worksheet.Cell(8 + dataTable.Rows.Count, 9).Style.NumberFormat.Format = "#,##0.00";

            worksheet.Columns().AdjustToContents();
            //  ws.Columns().AdjustToContents();


            workbook.SaveAs(FilePath);
        }
    }
    private void SetRangeStyle(IXLRange rngTotals)
    {
        rngTotals.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right; rngTotals.Style.Border.TopBorder = XLBorderStyleValues.Thin; rngTotals.Style.Border.InsideBorder = XLBorderStyleValues.Dotted; rngTotals.Style.Border.OutsideBorder = XLBorderStyleValues.Thin; rngTotals.Style.Border.LeftBorder = XLBorderStyleValues.Thin; rngTotals.Style.Border.RightBorder = XLBorderStyleValues.Thin; rngTotals.Style.Border.TopBorder = XLBorderStyleValues.Thin;
        rngTotals.Style.Fill.BackgroundColor = XLColor.LightGoldenrodYellow;
    }

    private void SetStyleToCell(IXLCell iXLCell)
    {
        iXLCell.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right; iXLCell.Style.Border.TopBorder = XLBorderStyleValues.Thin; iXLCell.Style.Border.InsideBorder = XLBorderStyleValues.Dotted; iXLCell.Style.Border.OutsideBorder = XLBorderStyleValues.Thin; iXLCell.Style.Border.LeftBorder = XLBorderStyleValues.Thin; iXLCell.Style.Border.RightBorder = XLBorderStyleValues.Thin; iXLCell.Style.Border.TopBorder = XLBorderStyleValues.Thin;
    }



    /// <summary>
    /// Create new Excel file or overwrite existing file
    /// </summary>
    /// <param name="fileName"></param>
    /// <param name="dataTable"></param>
    //public static void ImportDataTableIntoNewFile(string fileName, DataTable dataTable, string StartDate, string EndDate)
    //{

    //    using (var document = new SLDocument())
    //    {
    //        /*
    //         * Set header style
    //         */



    //        var styleBody = document.CreateStyle();
    //        var styleTable = document.CreateStyle();
    //        var style = document.CreateStyle();
    //        style.Border.BottomBorder.BorderStyle = BorderStyleValues.Thin;
    //        style.Border.BottomBorder.Color = System.Drawing.Color.Black;
    //        style.Border.TopBorder.BorderStyle = BorderStyleValues.Thin;
    //        style.Border.TopBorder.Color = System.Drawing.Color.Black;
    //        style.Border.RightBorder.BorderStyle = BorderStyleValues.Thin;
    //        style.Border.RightBorder.Color = System.Drawing.Color.Black;
    //        style.Border.LeftBorder.BorderStyle = BorderStyleValues.Thin;
    //        style.Border.LeftBorder.Color = System.Drawing.Color.Black;



    //        styleBody = style.Clone();

    //        style.Font.FontSize = 15;
    //        style.Font.Bold = true;
    //        style.Font.FontColor = System.Drawing.Color.Black;
    //        style.Fill.SetPattern(PatternValues.Solid,
    //            System.Drawing.Color.Goldenrod, System.Drawing.Color.Black);

    //        style.Alignment.Horizontal = HorizontalAlignmentValues.Center;
    //        document.SetCellValue("A2", "דוח לתאריכים: " + StartDate + " - " + EndDate + " " + "    כמות מוניות: " + dataTable.Rows.Count);
    //        //  document.SetCellValue("B2", StartDate);
    //        //document.SetCellValue("C2", "-");
    //        //document.SetCellValue("D2", EndDate);
    //        //document.SetCellValue("E2", "כמות מוניות:");
    //        //document.SetCellValue("F2", dataTable.Rows.Count);


    //        document.SetCellStyle(2, 1, style);
    //        document.SetCellStyle(2, 2, style);
    //        document.SetCellStyle(2, 3, style);
    //        document.SetCellStyle(2, 4, style);
    //        document.SetCellStyle(2, 5, style);
    //        document.SetCellStyle(2, 6, style);
    //        document.SetCellStyle(2, 7, style);
    //        document.MergeWorksheetCells("A2", "G2");

    //        for (int i = 0; i < 6; i++)
    //        {
    //            document.SetColumnWidth(i + 1, 15);
    //        }



    //        /*
    //         * Here I set the Caption property of each column
    //         * Here I set the Caption property of each column
    //         */
    //        styleTable = style.Clone();
    //        styleTable.Fill.SetPattern(PatternValues.Solid,
    //           System.Drawing.Color.LightGoldenrodYellow, System.Drawing.Color.Black);
    //        styleTable.Font.FontSize = 12;

    //        document.ImportDataTable(5, 1, dataTable, false);
    //        for (int index = 0; index < dataTable.Columns.Count; index++)
    //        {
    //            document.SetCellValue(SLConvert.ToCellReference(4, index + 1), dataTable.Columns[index].Caption);

    //            document.SetCellStyle(4, index + 1, styleTable);



    //        }

    //        for (int index = 0; index < dataTable.Columns.Count; index++)
    //        {
    //            for (int i = 5; i < dataTable.Rows.Count + 5; i++)
    //            {
    //                if (index == 0 || index == 5 || index == 6)
    //                    styleBody.Alignment.Horizontal = HorizontalAlignmentValues.Right;
    //                else
    //                    styleBody.Alignment.Horizontal = HorizontalAlignmentValues.Center;

    //                if (index == 6) styleBody.Font.Bold = true;
    //                document.SetCellStyle(i, index + 1, styleBody);
    //            }
    //        }

    //        document.SetCellValue(SLConvert.ToCellReference(dataTable.Rows.Count + 6, 6), "סך הכל:");
    //        document.SetCellValue(SLConvert.ToCellReference(dataTable.Rows.Count + 6, 7), "=Sum(G5:G" + (dataTable.Rows.Count + 5) + ")");
    //        document.SetCellStyle(dataTable.Rows.Count + 6, 6, styleTable);

    //        var Currencystyle = styleTable.Clone();
    //        Currencystyle.FormatCode = "₪ #,##0.00";
    //        // Currencystyle.Alignment.Horizontal = HorizontalAlignmentValues.Left;
    //        document.SetCellStyle(dataTable.Rows.Count + 6, 6, styleTable);
    //        document.SetCellStyle(dataTable.Rows.Count + 6, 7, Currencystyle);
    //        //document.MergeWorksheetCells(dataTable.Rows.Count + 6,6, dataTable.Rows.Count + 6,7);

    //        //  document.SetColumnWidth(7, 15);



    //        document.RenameWorksheet("Sheet1", "בדיקה של צחי");

    //        //document.AddWorksheet("צחי");

    //        //document.ImportDataTable(5, 1, dataTable, false);

    //        document.SaveAs(fileName);
    //    }
    //}



    public static void ToCSV(DataTable dtDataTable, string strFilePath)
    {
        StreamWriter sw = new StreamWriter(strFilePath, false, Encoding.GetEncoding(0));
        //headers    
        for (int i = 0; i < dtDataTable.Columns.Count; i++)
        {
            sw.Write(dtDataTable.Columns[i]);
            if (i < dtDataTable.Columns.Count - 1)
            {
                sw.Write(",");
            }
        }
        sw.Write(sw.NewLine);
        foreach (DataRow dr in dtDataTable.Rows)
        {
            for (int i = 0; i < dtDataTable.Columns.Count; i++)
            {
                if (!Convert.IsDBNull(dr[i]))
                {
                    string value = dr[i].ToString();
                    if (value.Contains(','))
                    {
                        value = String.Format("\"{0}\"", value);
                        sw.Write(value);
                    }
                    else
                    {
                        sw.Write(dr[i].ToString());
                    }
                }
                if (i < dtDataTable.Columns.Count - 1)
                {
                    sw.Write(",");
                }
            }
            sw.Write(sw.NewLine);
        }
        sw.Close();
    }

    [WebMethod]
    public void Hasot_SetGetMaps()
    {


        string TypeAction = GetParamsValueIfExist("TypeAction");
        string Id = GetParamsValueIfExist("Id");
        string MapsId = GetParamsValueIfExist("MapsId");
        string Type = GetParamsValueIfExist("Type");
        string ShiftId = GetParamsValueIfExist("ShiftId");
        string DayInWeek = GetParamsValueIfExist("DayInWeek");
        string Hour = GetParamsValueIfExist("Hour");
        string OnlyDays = GetParamsValueIfExist("OnlyDays");
        string IsOvdeYom = GetParamsValueIfExist("IsOvdeYom");
        string IsImahot = GetParamsValueIfExist("IsImahot");
        string City = GetParamsValueIfExist("City");
        string CarType = GetParamsValueIfExist("CarType");
        string CarSymbol = GetParamsValueIfExist("CarSymbol");
        string UpdateBy = GetParamsValueIfExist("UpdateBy");

        string StartDate = GetParamsValueIfExist("StartDate");
        string EndDate = GetParamsValueIfExist("EndDate");
        string CopyStartDate = GetParamsValueIfExist("CopyStartDate");
        string CopyEndDate = GetParamsValueIfExist("CopyEndDate");



        DataTable dt = Dal.ExeSp("Hasot_SetGetMaps", TypeAction, Id, MapsId, Type, ShiftId, DayInWeek, Hour, OnlyDays,
        IsOvdeYom, IsImahot, City, CarType, CarSymbol, StartDate, EndDate, CopyStartDate, CopyEndDate, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }

    //public static void CreateSpreadsheetWorkbook(string filepath)
    //{

    //  //  SpreadsheetDocument mySpreadsheet = SpreadsheetDocument.Open(filepath, true);


    //    // Create a spreadsheet document by supplying the filepath.
    //    // By default, AutoSave = true, Editable = true, and Type = xlsx.
    //    SpreadsheetDocument spreadsheetDocument = SpreadsheetDocument.
    //        Create(filepath, SpreadsheetDocumentType.Workbook);

    //    // Add a WorkbookPart to the document.
    //    WorkbookPart workbookpart = spreadsheetDocument.AddWorkbookPart();
    //    workbookpart.Workbook = new Workbook();

    //    // Add a WorksheetPart to the WorkbookPart.
    //    WorksheetPart worksheetPart = workbookpart.AddNewPart<WorksheetPart>();
    //    worksheetPart.Worksheet = new Worksheet(new SheetData());

    //    // Add Sheets to the Workbook.
    //    Sheets sheets = spreadsheetDocument.WorkbookPart.Workbook.
    //        AppendChild<Sheets>(new Sheets());

    //    // Append a new worksheet and associate it with the workbook.
    //    Sheet sheet = new Sheet()
    //    {
    //        Id = spreadsheetDocument.WorkbookPart.
    //        GetIdOfPart(worksheetPart),
    //        SheetId = 1,
    //        Name = "בדיקה צחי"
    //    };
    //    sheets.Append(sheet);




    //    workbookpart.Workbook.Save();

    //    // Close the document.
    //    spreadsheetDocument.Close();
    //}



    //public static void CreateSpreadsheetWorkbook(string filepath)
    //{

    //    // SpreadsheetDocument mySpreadsheet = SpreadsheetDocument.Open(filepath, true);


    //    // Create a spreadsheet document by supplying the filepath.
    //    // By default, AutoSave = true, Editable = true, and Type = xlsx.
    //    SpreadsheetDocument spreadsheetDocument = SpreadsheetDocument.
    //        Create(filepath, SpreadsheetDocumentType.Workbook);

    //    // Add a WorkbookPart to the document.
    //    WorkbookPart workbookpart = spreadsheetDocument.AddWorkbookPart();
    //    workbookpart.Workbook = new Workbook();

    //    // Add a WorksheetPart to the WorkbookPart.
    //    WorksheetPart worksheetPart = workbookpart.AddNewPart<WorksheetPart>();
    //    worksheetPart.Worksheet = new Worksheet(new SheetData());

    //    // Add Sheets to the Workbook.
    //    Sheets sheets = spreadsheetDocument.WorkbookPart.Workbook.
    //        AppendChild<Sheets>(new Sheets());

    //    // Append a new worksheet and associate it with the workbook.
    //    Sheet sheet = new Sheet()
    //    {
    //        Id = spreadsheetDocument.WorkbookPart.
    //        GetIdOfPart(worksheetPart),
    //        SheetId = 1,
    //        Name = "בדיקה צחי"
    //    };
    //    sheets.Append(sheet);

    //    workbookpart.Workbook.Save();

    //    // Close the document.
    //    spreadsheetDocument.Close();
    //}

    #endregion

    #region Foods

    [WebMethod]
    public void Food_GetShiftTimes()
    {

        string Date = GetParams("Date");
        string ShiftId = GetParams("ShiftId");


        string Mode = GetParams("Mode");


        DataTable dt = Dal.ExeSp("Food_GetShiftTimes", Date, ShiftId, Mode);
        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }



    [WebMethod]
    public void Food_GetSetProcedure()
    {
        string Type = GetParamsValueIfExist("Type");
        string SearchDate = GetParamsValueIfExist("SearchDate");
        string SearchDateEnd = GetParamsValueIfExist("SearchDateEnd");


        string ShiftId = GetParamsValueIfExist("ShiftId");

        string EmpNo = GetParamsValueIfExist("EmpNo");
        string AreaId = GetParamsValueIfExist("AreaId");
        string FoodHeadersId = GetParamsValueIfExist("FoodHeadersId");

        string TotalGC1 = GetParamsValueIfExist("TotalGC1");
        string TotalWorker = GetParamsValueIfExist("TotalWorker");


        //string MaslulDesc = GetParamsValueIfExist("MaslulDesc");
        //string City1 = GetParamsValueIfExist("City1");
        //string City2 = GetParamsValueIfExist("City2");
        //string City3 = GetParamsValueIfExist("City3");
        //string City4 = GetParamsValueIfExist("City4");
        if (Type == "66")
        {
            System.IO.DirectoryInfo di = new DirectoryInfo(HttpContext.Current.Server.MapPath("~/ExcelFood/"));

            foreach (FileInfo file in di.GetFiles())
            {
                file.Delete();
            }


            DataTable dtSummery = Dal.ExeSp("Food_GetSetProcedure", 6, SearchDate, SearchDateEnd, ShiftId, EmpNo, AreaId, FoodHeadersId, TotalGC1, TotalWorker, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);


            foreach (DataRow row in dtSummery.Rows)
            {
                row["ShiftCode"] = GetDescForEXCEL(row["ShiftCode"].ToString(), 1);
                row["DayId"] = GetDescForEXCEL(row["Date"].ToString(), 2);
                row["EmpType"] = GetDescForEXCEL(row["FoodCubesAreaId"].ToString(), 3);
            }

            dtSummery.AcceptChanges();
            while (dtSummery.Columns.Count > 7)
            {
                dtSummery.Columns.RemoveAt(7);
            }


            dtSummery.Columns[0].Caption = "תאריך";
            dtSummery.Columns[1].Caption = "משמרת";
            dtSummery.Columns[2].Caption = "יום בשבוע";
            dtSummery.Columns[3].Caption = "מס' עובד";
            dtSummery.Columns[4].Caption = "שם עובד";
            dtSummery.Columns[5].Caption = "אזור חלוקה";
            dtSummery.Columns[6].Caption = "סוג עובד";



            //for (int i = 0; i < dtSummery.Rows.Count; i++)
            //{


            //    string pad = string.Format("{0:0000}", Helper.ConvertToInt(dtSummery.Rows[i][1].ToString()));
            //    dtSummery.Rows[i][1] = pad;
            //    //  dtSummery.AcceptChanges();


            //}


            string host = HttpContext.Current.Request.Url.AbsoluteUri;
            var currentDate = DateTime.Now.ToString("dd_MM_yyyy_HH_ss");
            string FilePath = HttpContext.Current.Server.MapPath("~/ExcelFood/") + currentDate + ".xlsx";

            CreateNewExcelCloseXMLFood(FilePath, dtSummery, SearchDate, SearchDateEnd);
            // 
            //GeneratedClass ff = new GeneratedClass();
            //ff.CreatePackage(FilePath);

            //ImportDataTableIntoNewFile(FilePath, dtSummery, StartDate, EndDate);
            host = host.Replace("WebService.asmx/Food_GetSetProcedure", "ExcelFood/" + currentDate + ".xlsx");
            dtSummery.Rows[0][4] = host;

            //CreateSpreadsheetWorkbook(FilePath);



            HttpContext.Current.Response.Write(ConvertDataTabletoString(dtSummery));



            return;

        }

        DataTable dt = Dal.ExeSp("Food_GetSetProcedure", Type, SearchDate, SearchDateEnd, ShiftId, EmpNo, AreaId, FoodHeadersId, TotalGC1, TotalWorker, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);

        HttpContext.Current.Response.Write(ConvertDataTabletoString(dt));
    }

    private String GetDescForEXCEL(string v1, int v2)
    {
        if (v2 == 1)
        {
            switch (v1)
            {
                case "1":
                    return "בוקר";

                case "2":
                    return "צהריים";

                case "3":
                    return "לילה";

                default:
                    break;
            }



        }


        if (v2 == 2)
        {
            DateTime dateValue = DateTime.Parse(v1);
            int DayId = (int)dateValue.DayOfWeek;


            switch (DayId)
            {
                case 0:
                    return "ראשון";

                case 1:
                    return "שני";

                case 2:
                    return "שלישי";
                case 3:
                    return "רביעי";

                case 4:
                    return "חמישי";

                case 5:
                    return "שישי";
                case 6:
                    return "שבת";

                default:
                    break;
            }


        }

        if (v2 == 3)
        {
            if (v1 == "3") return "יום";
            else return "משמרת";
        }

        return "";
    }

    private void CreateNewExcelCloseXMLFood(string FilePath, DataTable dataTable, string StartDate, string EndDate)
    {
        using (var workbook = new XLWorkbook() { RightToLeft = true })
        {


            // Decimal TotalPrice = Convert.ToDecimal(dataTable.Compute("SUM(TaxiCount) + SUM(TaxiCount200)", string.Empty));

            var worksheet = workbook.Worksheets.Add(" סיכום מנות אוכל ");

            worksheet.Cell("A2").Value = "דוח לתאריכים: " + StartDate + " - " + EndDate + " " + "    כמות מנות אוכל: " + dataTable.Rows.Count;
            var range = worksheet.Range("A2:G2");
            range.Merge();

            // worksheet.Cell("A2").FormulaA1 = "=MID(A1, 7, 5)";
            //worksheet.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
            //worksheet.Style.Font.Bold = true;
            //worksheet.Style.Fill.BackgroundColor.SetColor(Color.LightGreen);
            range.Style.Fill.BackgroundColor = XLColor.Goldenrod;
            range.Style.Border.OutsideBorder = XLBorderStyleValues.Thin;
            range.Style.Font.Bold = true;
            range.Style.Font.FontSize = 15;
            range.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

            //var rangeTitles = worksheet.Range("A4:G4");
            // rangeTitles.Style.Fill.BackgroundColor = XLColor.LightGoldenrodYellow;
            // rangeTitles.Style.Border.OutsideBorder = XLBorderStyleValues.Thin;
            // rangeTitles.Style.Font.Bold = true;
            // rangeTitles.Style.Font.FontSize = 13;
            // rangeTitles.Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
            //  var ws = workbook.Worksheets.Add("Column Settings");

            for (int index = 0; index < dataTable.Columns.Count; index++)
            {
                worksheet.Cell(4, index + 1).Value = dataTable.Columns[index].Caption;

                worksheet.Cell(4, index + 1).Style.Fill.BackgroundColor = XLColor.LightGoldenrodYellow;
                worksheet.Cell(4, index + 1).Style.Border.OutsideBorder = XLBorderStyleValues.Thin;
                worksheet.Cell(4, index + 1).Style.Font.Bold = true;
                worksheet.Cell(4, index + 1).Style.Font.FontSize = 13;
                worksheet.Cell(4, index + 1).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                worksheet.Cell(4, index + 1).WorksheetColumn().Width = 18;
                //var col1 = workbook.ColumnWidth( .Column("A");
                //col1.Width = 30;

                //document.SetCellValue(SLConvert.ToCellReference(4, index + 1), dataTable.Columns[index].Caption);

                //document.SetCellStyle(4, index + 1, styleTable);



            }


            for (int i = 0; i < dataTable.Rows.Count; i++)
            {
                worksheet.Cell(5 + i, 1).Value = dataTable.Rows[i][0].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 1));


                worksheet.Cell(5 + i, 2).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);
                // worksheet.Cell(5 + i, 2).Style.NumberFormat.Format = "@";
                worksheet.Cell(5 + i, 2).Value = dataTable.Rows[i][1].ToString();

                SetStyleToCell(worksheet.Cell(5 + i, 2));


                worksheet.Cell(5 + i, 3).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                worksheet.Cell(5 + i, 3).Value = dataTable.Rows[i][2].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 3));

                worksheet.Cell(5 + i, 4).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                worksheet.Cell(5 + i, 4).Style.NumberFormat.Format = "@";
                worksheet.Cell(5 + i, 4).Value = dataTable.Rows[i][3].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 4));
                worksheet.Cell(5 + i, 5).Value = dataTable.Rows[i][4].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 5));


                worksheet.Cell(5 + i, 6).Value = dataTable.Rows[i][5].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 6));

                worksheet.Cell(5 + i, 7).Value = dataTable.Rows[i][6].ToString();
                SetStyleToCell(worksheet.Cell(5 + i, 7));






                //worksheet.Cell(5 + i, 8).Value = dataTable.Rows[i][7].ToString();
                //SetStyleToCell(worksheet.Cell(5 + i, 8));
                //worksheet.Cell(5 + i, 8).Style.NumberFormat.Format = "@";
                ////   worksheet.Cell(5 + i, 8).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

                //worksheet.Cell(5 + i, 9).Value = dataTable.Rows[i][8].ToString();
                //SetStyleToCell(worksheet.Cell(5 + i, 9));
                //worksheet.Cell(5 + i, 9).Style.NumberFormat.Format = "@";
                //// worksheet.Cell(5 + i, 8).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right);

                //worksheet.Cell(5 + i, 5).Style.Font.Bold = true;
                //worksheet.Cell(5 + i, 8).Style.Font.Bold = true;
                //worksheet.Cell(5 + i, 9).Style.Font.Bold = true;
            }


            //var rngTotals = worksheet.Range(6 + dataTable.Rows.Count, 8, 8 + dataTable.Rows.Count, 9);
            //SetRangeStyle(rngTotals);


            //worksheet.Cell(6 + dataTable.Rows.Count, 8).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left);
            //worksheet.Cell(6 + dataTable.Rows.Count, 8).Value = "סה''כ:";
            //worksheet.Cell(6 + dataTable.Rows.Count, 8).Style.Font.Bold = true;

            //worksheet.Cell(7 + dataTable.Rows.Count, 8).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left);
            //worksheet.Cell(7 + dataTable.Rows.Count, 8).Value = "מע''מ:";
            //worksheet.Cell(7 + dataTable.Rows.Count, 8).Style.Font.Bold = true;

            //worksheet.Cell(8 + dataTable.Rows.Count, 8).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left);
            //worksheet.Cell(8 + dataTable.Rows.Count, 8).Value = "סה''כ כללי לתשלום:";
            //worksheet.Cell(8 + dataTable.Rows.Count, 8).Style.Font.Bold = true;

            //var Sum = worksheet.Evaluate("SUM(I5:I" + (5 + dataTable.Rows.Count) + ")");
            //var Maam = (double)Sum * 0.17;
            //var Total = (double)Sum + Maam;


            //worksheet.Cell(6 + dataTable.Rows.Count, 9).Value = Sum;
            //worksheet.Cell(6 + dataTable.Rows.Count, 9).Style.Font.Bold = true;
            //worksheet.Cell(6 + dataTable.Rows.Count, 9).Style.NumberFormat.Format = "#,##0.00";

            //worksheet.Cell(7 + dataTable.Rows.Count, 9).Value = Maam;
            //worksheet.Cell(7 + dataTable.Rows.Count, 9).Style.Font.Bold = true;
            //worksheet.Cell(7 + dataTable.Rows.Count, 9).Style.NumberFormat.Format = "#,##0.00";

            //worksheet.Cell(8 + dataTable.Rows.Count, 9).Value = Total;
            //worksheet.Cell(8 + dataTable.Rows.Count, 9).Style.Font.Bold = true;
            //worksheet.Cell(8 + dataTable.Rows.Count, 9).Style.NumberFormat.Format = "#,##0.00";

            worksheet.Columns().AdjustToContents();
            //  ws.Columns().AdjustToContents();


            workbook.SaveAs(FilePath);
        }
    }


    #endregion

    private bool GetParamsIfExist(string Param)
    {
        try
        {
            HttpContext.Current.Request.Form[Param].ToString();
            return true;

        }
        catch (Exception ex)
        {


            return false;
        }
    }

    private string GetParamsValueIfExist(string Param)
    {
        try
        {
            var ValueForm = HttpContext.Current.Request.Form[Param];
            if (ValueForm != null)
                return ValueForm.ToString();

            else
                return "";

        }
        catch (Exception ex)
        {


            return "";
        }
    }

    private string GetParams(string Param)
    {
        return HttpContext.Current.Request.Form[Param].ToString();
    }

    public static string ConvertDataTabletoString(DataTable dt)
    {


        System.Web.Script.Serialization.JavaScriptSerializer serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
        List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();
        Dictionary<string, object> row;
        foreach (DataRow dr in dt.Rows)
        {
            row = new Dictionary<string, object>();
            foreach (DataColumn col in dt.Columns)
            {
                row.Add(col.ColumnName, dr[col]);
            }
            rows.Add(row);
        }
        return serializer.Serialize(rows);

    }

}


public partial class Footer : PdfPageEventHelper
{
    public override void OnEndPage(PdfWriter writer, Document document)
    {

       // string Path = "~/assets/images/ZikukH.gif";
        string Path = "~/assets/images/Baza.png";
        Image image = Image.GetInstance(HttpContext.Current.Server.MapPath(Path));
        //image.WidthPercentage = 250;
        //image.SetAbsolutePosition(12, 300);
        //writer.DirectContent.AddImage(image, false);

        Rectangle page = document.PageSize;
        // String path = "C:\\Images\\logo.jpg";
        // Step 2 - create two column table;
        PdfPTable head = new PdfPTable(1);
        head.TotalWidth = page.Width / 5;

        // add header image; PdfPCell() overload sizes image to fit cell
        PdfPCell imghead = new PdfPCell(image, true);

        imghead.HorizontalAlignment = Element.ALIGN_RIGHT;

        imghead.Border = Rectangle.NO_BORDER;

        head.AddCell(imghead);

        // write (write) table to PDF document; 
        // WriteSelectedRows() requires you to specify absolute position!
        head.WriteSelectedRows(0, -1, page.Width / 8, page.Height - document.TopMargin - 10, writer.DirectContent);






        // Paragraph footer = new Paragraph("THANK YOU", FontFactory.GetFont(FontFactory.TIMES, 10, iTextSharp.text.Font.NORMAL));
        // footer.Alignment = Element.ALIGN_RIGHT;
        // PdfPTable footerTbl = new PdfPTable(1);
        // footerTbl.TotalWidth = 300;
        // footerTbl.HorizontalAlignment = Element.ALIGN_CENTER;

        // PdfPCell cell = new PdfPCell(footer);
        // cell.Border = 0;
        // cell.PaddingLeft = 10;

        // footerTbl.AddCell(cell);
        //// footerTbl.WriteSelectedRows(0, -1, 415, 30, writer.DirectContent);
        // Rectangle page = doc.PageSize;
        // footerTbl.WriteSelectedRows(0, -1, page.Width / 8, page.Height - doc.TopMargin + footerTbl.TotalHeight, writer.DirectContent);

    }



}
