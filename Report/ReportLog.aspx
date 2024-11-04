<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage/MasterPage.master" AutoEventWireup="true"
    CodeFile="ReportLog.aspx.cs" Inherits="Report_ReportLog" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <!--bootstrap validation Library Script End-->
    <!--Demo form validation  Script Start-->
    <style>
        .tableData
        {
            width: 100%;
            height: 40px;
            overflow: hidden;
        }
    </style>
    <script type="text/javascript">

        var mydata;


        var OrgUnitCode = "";

        $(document).ready(function () {
            GetComboItems("Transact", "", "#ddlTransact", "TransactId", "Name");

            var UserData = Ajax("Report_GetUserTable");
            BuildCombo(UserData, "#ddlUsers", "UserId", "fullName");
            GetComboItems("Codes", "TableId=5 And AddedValue=1", "#ddlAreas", "ValueCode", "ValueDesc");


            $('#txtStartDate').datetimepicker(
            {
                value: ConvertHebrewDateToJSDATE(getDateTimeNowFormat(), -1, "Heb"),
                timepicker: false,
                format: 'd.m.Y',
                mask: true
            });

            $('#txtEndDate').datetimepicker(
            {
                value: getDateTimeNowFormat(),
                timepicker: false,
                format: 'd.m.Y',
                mask: true
            });


            //  FillData();


        });

        function FillData() {

            $("#dvReqContainer").html("");

            var StartDate = $("#txtStartDate").val();
            var EndDate = $("#txtEndDate").val();
            var TransactId = $("#ddlTransact").val();

            var UserId = $("#ddlUsers").val();
            var Area = $("#ddlAreas").val();
            var EmpNumber = $("#txtEmpNumber").val();


            mydata = Ajax("Report_GetReportLog", "TransactId=" + TransactId + "&StartDate=" + StartDate
            + "&EndDate=" + EndDate + "&UserId=" + UserId + "&Area=" + Area + "&EmpNumber=" + EmpNumber);



            //var Area = "";
            var ReqHtml = "";
            for (var i = 0; i < mydata.length; i++) {






                ReqHtml = $("#dvReqTemplate").html();
                ReqHtml = ReqHtml.replace("@Name", IsNullDB(mydata[i].Name));
                ReqHtml = ReqHtml.replace("@Area", IsNullDB(mydata[i].ValueDesc));

                ReqHtml = ReqHtml.replace("@CreateOn", IsNullDB(mydata[i].CreateOn));
                ReqHtml = ReqHtml.replace("@fullName", IsNullDB(mydata[i].fullName));

                ReqHtml = ReqHtml.replace("@TransactShiftCode", IsNullDB(mydata[i].TransactShiftCode));
                ReqHtml = ReqHtml.replace("@fullNameEmp", IsNullDB(mydata[i].fullNameEmp));


                ReqHtml = ReqHtml.replace("@StartDate", IsNullDB(mydata[i].StartDate));
                ReqHtml = ReqHtml.replace("@EndDate", IsNullDB(mydata[i].EndDate));

                ReqHtml = ReqHtml.replace("@TransactHours", IsNullDB(mydata[i].TransactHours));




                $("#dvReqContainer").append(ReqHtml);


            }


        }


        function PrintLog() {

            var html = $("#dvPrintHeaderTemplate").html();

         

            var ReqHtml = "";
            for (var i = 0; i <mydata.length; i++) {


                ReqHtml = "<tr><td>"+IsNullDB(mydata[i].Name)+"</td>";   //$("#dvPrintTemplate").html();
                ReqHtml = ReqHtml + "<td>" +  IsNullDB(mydata[i].ValueDesc)+"</td>";
                ReqHtml = ReqHtml + "<td>" + IsNullDB(mydata[i].CreateOn) + "</td>";
                ReqHtml = ReqHtml + "<td>" + IsNullDB(mydata[i].fullName) + "</td>";
                ReqHtml = ReqHtml + "<td>" + IsNullDB(mydata[i].TransactShiftCode) + "</td>";
                ReqHtml = ReqHtml + "<td>" + IsNullDB(mydata[i].fullNameEmp) + "</td>";

                ReqHtml = ReqHtml + "<td>" + IsNullDB(mydata[i].StartDate) + "</td>";
                ReqHtml = ReqHtml + "<td>" + IsNullDB(mydata[i].EndDate) + "</td>";

                ReqHtml = ReqHtml + "<td>" + IsNullDB(mydata[i].TransactHours) + "</td></tr>";



                $("#tbPrint").append(ReqHtml);

                // ReqHtml;

            }

          //  $("#dvReqContainer").html();

            PrintDiv($("#dvPrintHeaderTemplate").html(), " - רשימת היסטוריה -");

        }

        

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="col-md-12">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-th-list"></i>&nbsp; חיפוש היסטוריה
                    </h3>
                </div>
                <div class="panel-body" style="padding: 8px">
                    <div class="col-md-2">
                        <span class="help-block m-b-none">מבצע</span>
                        <select id="ddlUsers" class="form-control">
                            <option value="0">-- כל המבצעים --</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <span class="help-block m-b-none">אזור</span>
                        <select id="ddlAreas" class="form-control">
                            <option value="0">-- כל האזורים --</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <span class="help-block m-b-none">מס' עובד</span>
                        <input type="text" id="txtEmpNumber" class="form-control">
                    </div>
                    <div class="col-md-2">
                        <span class="help-block m-b-none">תאריך מ </span>
                        <div class="input-group ls-group-input">
                            <input type="text" id="txtStartDate" class="form-control">
                            <span class="input-group-addon spDateIcon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <span class="help-block m-b-none">תאריך עד </span>
                        <div class="input-group ls-group-input">
                            <input type="text" id="txtEndDate" class="form-control">
                            <span class="input-group-addon spDateIcon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <span class="help-block m-b-none">פעולה</span>
                        <select id="ddlTransact" class="form-control">
                            <option value="0">-- כל הפעולות --</option>
                        </select>
                    </div>
                    <div class="clear">
                    </div>
                    <div class="col-md-9">
                    </div>
                    <div class="col-md-1">
                        <button type="button" class="btn btn-info btn-round" onclick="FillData()">
                            <i class="glyphicon glyphicon-search"></i>&nbsp; <span class="btnAssign">חפש </span>
                        </button>
                    </div>
                    <div class="col-md-2">
                        <button type="button" class="btn btn-info btn-round" onclick="PrintLog()">
                            <i class="fa fa-print"></i>&nbsp; <span class="btnAssign">הדפס </span>
                        </button>
                    </div>
                    <%--  <form id="formID"  method="post" action="">
                        <input type="text" id="Text1" class="form-control validate[required] text-input">
                        <div class="submit btn-primary btn" type="submit" name="submit" onclick="SaveDataTODB()">Save</div>
                    </form>--%>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-12">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-th-list"></i>&nbsp; תוצאות חיפוש היסטוריה שינויים
                    </h3>
                </div>
                <div class="panel-body" style="padding: 0px">
                    <br />
                    <div>
                        <div class="col-md-2 dvRequireTitle">
                            תאור פעולה
                        </div>
                        <div class="col-md-1 dvRequireTitle">
                            אזור
                        </div>
                        <div class="col-md-1 dvRequireTitle">
                            ת.ביצוע
                        </div>
                        <div class="col-md-2 dvRequireTitle">
                            מבצע הפעולה
                        </div>
                        <div class="col-md-1 dvRequireTitle">
                            משמרת
                        </div>
                        <div class="col-md-1 dvRequireTitle">
                            עובד
                        </div>
                        <div class="col-md-1 dvRequireTitle">
                            ת.פעולה
                        </div>
                        <div class="col-md-2 dvRequireTitle">
                            ת.סיום פעולה
                        </div>
                        <div class="col-md-1 dvRequireTitle">
                            שעות
                        </div>
                        <div id="dvReqContainer" class="dvPanelReq clear">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <%--  <div class="col-md-12">
        <div class="row" style="padding: 4px">
            <div class="btn btn-primary" onclick='EditRequirement("", "","", "", "", "", "","", "","","", "","","")'>
                <i class="fa fa-plus-circle"></i>&nbsp;הוסף דרישה חדשה
            </div>
        </div>
    </div>--%>
    <%-- טמפלט של עובד --%>
    <div id="dvReqTemplate" style="display: none">
        <div class="col-md-2 dvRequireDetails ">
            <div class="tableData">
                @Name</div>
        </div>
        <div class="col-md-1 dvRequireDetails ">
            <div class="tableData">
                @Area
            </div>
        </div>
        <div class="col-md-1 dvRequireDetails ">
            <div class="tableData">
                @CreateOn</div>
        </div>
        <div class="col-md-2 dvRequireDetails ">
            <div class="tableData">
                @fullName</div>
        </div>
        <div class="col-md-1 dvRequireDetails ">
            <div class="tableData">
                @TransactShiftCode
            </div>
           
        </div>
        <div class="col-md-1 dvRequireDetails ">
            <div class="tableData">
                @fullNameEmp
            </div>
        </div>
        <div class="col-md-1 dvRequireDetails ">
            <div class="tableData">
                @StartDate
            </div>
        </div>
        <div class="col-md-2 dvRequireDetails ">
            <div class="tableData">
                @EndDate
            </div>
        </div>
        <div class="col-md-1 dvRequireDetails ">
            <div class="tableData">
                @TransactHours
            </div>
        </div>
        <%--<div class="btn btn-primary btn-xs" onclick="EditRequirement('@RequirementId, '@DateTypeCode','@ShiftCode', '@QualificationCode', '@EmpQuantity', '@RequirementDesc', '@RequirementAbb','@ObligatoryAssignment', '@ObligatoryCheck','@BeginDate', '@EndDate')">
                <i class="fa fa-edit"></i>&nbsp;ערוך</div>
        --%>
    </div>
    <div id="dvPrintHeaderTemplate" style="display: none">

     <style>
            @media print
            {
            
                table
                {
                   
                }
                .shiftTitle
                {
                    text-align: center;
                    background-color: silver !important;
                    border: solid 1px gray;
                    -webkit-print-color-adjust: exact;
                }
            
                .tdTitle
                {
                    border: solid 1px gray;
                    font-size: 14px;
                }
            
                #tbPrint td
                {
                    vertical-align: top;
                    padding-bottom: 10px;
                    border-bottom: solid 1px gray;
                    font-size: 12px;
                }
            
                .menuaWorker
                {
                    vertical-align: top;
                    padding-bottom: 10px;
                    border: solid 1px gray;
                    font-size: 12px;
                }
            
                .spJobSign
                {
                    background-color: yellow !important;
                    -webkit-print-color-adjust: exact;
                    float: right;
                    width: 30%;
                    text-align: right;
                    border: solid 1px gray;
                    height: 17px;
                }
            
                .spName
                {
                    padding: 1px;
                    width: 63%;
                    float: right;
                    text-align: right;
                    border: solid 1px gray;
                }
            
                .addHours
                {
                    font-weight: bold;
                    float: left;
                    direction: ltr;
                }
            
            
                .spToran
                {
                    background-color: orange !important;
                    -webkit-print-color-adjust: exact;
                }
            
            }
        </style>



        <table id="tbPrint" border="0" width="100%">
            <tr>
                <td class="shiftTitle">
                    תאור פעולה
                </td>
                <td class="shiftTitle">
                    אזור
                </td>
                <td class="shiftTitle">
                    ת.ביצוע
                </td>
                <td class="shiftTitle">
                    מבצע הפעולה
                </td>
                <td class="shiftTitle">
                    משמרת
                </td>
                <td class="shiftTitle">
                    עובד
                </td>
                <td class="shiftTitle">
                    ת.פעולה
                </td>
                <td class="shiftTitle">
                    ת.סיום פעולה
                </td>
                <td class="shiftTitle">
                    שעות
                </td>
            </tr>
            

            </table>
          
    </div>
   <%-- <div id="dvPrintTemplate" style="display: none">
         
         <table width="100%" border="1">
         <tr>
            <td class="tableData">
                @Name
            </td>
            <td class="tableData">
                @Area
            </td>
            <td class="tableData">
                @CreateOn
            </td>
            <td class="tableData">
                @fullName
            </td>
            <td class="tableData">
                @TransactShiftCode
            </td>
            <td class="tableData">
                @fullNameEmp
            </td>
            <td class="tableData">
                @StartDate
            </td>
            <td class="tableData">
                @EndDate
            </td>
            <td class="tableData">
                @TransactHours
            </td>
        </tr>
        </table>
    </div>--%>
    <%-- <script src="../assets/js/pages/formValidation.js"></script>--%>
</asp:Content>
