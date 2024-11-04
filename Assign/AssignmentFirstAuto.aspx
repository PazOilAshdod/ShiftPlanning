<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage/MasterPage.master" AutoEventWireup="true"
    CodeFile="AssignmentFirstAuto.aspx.cs" Inherits="Assignment_AssignmentFirstAuto" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

         var mydata;
         var SelectedAssignmentId;



         $(document).ready(function () {
          
             $(".dvSucceedFill").hide();

             GetComboItems("Codes", "TableId=5", "#ddlArea", "ValueCode", "ValueDesc");

            $('#txtStartDate,#txtEndDate').datetimepicker(
            {
                value: getDateTimeNowFormat(),
                minDate: 0,
                timepicker: false,
                format: 'd.m.Y',
                mask: true,
                validateOnBlur: false

            });



         });




         function FillAssignment() {

             var StartDate = $('#txtStartDate').val();
             var EndDate = $('#txtEndDate').val();
             var OrgUnitCode = $('#ddlArea').val();


             if (OrgUnitCode == "-1") {
                 alert("בחר יחידה לשיבוץ");
                 return;
             }


             var mydata = Ajax("Assign_FillAssignment", "StartDate=" + StartDate + "&EndDate=" + EndDate + "&OrgUnitCode=" + OrgUnitCode);


             $(".dvSucceedFill").show();
           

         }

        

     

      



    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="col-md-12">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-th-list"></i>&nbsp; שיבוץ ראשוני אוטומטי
                    </h3>
                </div>
                <div class="panel-body" style="padding: 0px">
                  <div class="col-md-5">
                        <span class="help-block m-b-none">אזור</span>
                        <select id="ddlArea" class="form-control">
                           <option value="-1">-- בחר יחידה --</option>
                        </select>
                    </div>
                    <div class="clear">&nbsp;</div>


                    <div class="col-md-5">
                        <span class="help-block m-b-none">הכנס תאריך תחילה לשיבוץ</span>
                        <div class="input-group ls-group-input">
                            <input type="text" class="form-control" id="txtStartDate">
                            <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>
                    <div class="col-md-5" style="">
                        <span class="help-block m-b-none">הכנס תאריך סיום לשיבוץ</span>
                        <div class="input-group ls-group-input">
                            <input type="text" class="form-control" id="txtEndDate">
                            <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <span class="help-block m-b-none">&nbsp; </span>
                        <button type="button" class="btn btn-info btn-round" onclick="FillAssignment()">
                            <i class="glyphicon glyphicon-user"></i>&nbsp; <span class="btnAssign">שבץ </span>
                        </button>
                    </div>
                    
                    <div class="col-md-12 dvSucceedFill">
                        השיבוץ בוצע לתאריכים הנ"ל!
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
