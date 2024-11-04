<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage/MasterPage.master" AutoEventWireup="true"
    CodeFile="Employees.aspx.cs" Inherits="Employees_Employees" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <!--bootstrap validation Library Script End-->
    <!--Demo form validation  Script Start-->
    <link href="../assets/css/rtl-css/typeahead.js-bootstrap.css" rel="stylesheet" type="text/css" />
    <script src="../assets/js/bootstrap3-typeahead.min.js" type="text/javascript"></script>
    <script type="text/javascript">




        var OrgUnitCode = "";
        var selectedEmp = "";
        var CityList;
        var CityValueCode="";
        var CityValueDesc="";

        $(document).ready(function () {

            $("#btnSaveHasa").hide();
            CityList = Ajax("Gen_GetTable", "TableName=Codes&Condition=TableId=17");

            InitTypeHead();


            // מעדכן אך ורק את העדכון של המשתמש בקשר לזכאות להסעה
            $("#chIsHasa").change(function () {

                var IsYom = true;
                var Looz = $("#txtLooz").val();
                if (Looz.indexOf("YOM") == -1) {
                    IsYom = false;
                }

                if (!selectedEmp) {
                    this.checked = false;
                    return;
                }
                if (this.checked) {
                    var data = Ajax("Hasot_SetHasaForEmp", "EmpNo=" + selectedEmp + "&IsHasa=1&IsYom=" + IsYom);

                } else {
                    var data = Ajax("Hasot_SetHasaForEmp", "EmpNo=" + selectedEmp + "&IsHasa=0");
                    $("#chIsImahot")[0].checked = false;

                }
            });

            // מעדכן אך ורק את העדכון של המשתמש בקשר לזכאות להסעה
            $("#chIsImahot").change(function () {
                debugger
                if (!selectedEmp || !$("#chIsHasa")[0].checked) {
                    this.checked = false;
                    return;
                }
                if (this.checked) {

                    var IsImahot = 3;

                    if (SelectedCityCode =="000000000070") {
                        IsImahot = 4;

                    }
                    var data = Ajax("Hasot_SetHasaForEmp", "EmpNo=" + selectedEmp + "&IsHasa=10&IsImahot=" + IsImahot);

                } else {
                    var data = Ajax("Hasot_SetHasaForEmp", "EmpNo=" + selectedEmp + "&IsHasa=10&IsImahot=0");

                }
            });


            

        });
        function InitTypeHead() {

            $('input.typeahead').typeahead({
                items: 15,
                source: function (query, process) {
                    states = [];
                    map = {};

                    var data = Ajax("Employees_GetEmployeesList", "Type=0&EmpNo=");

                    $.each(data, function (i, state) {
                        map[state.FullText] = state;
                        states.push(state.FullText);
                    });

                    process(states);
                },

                updater: function (item) {

                    EmpNo = map[item].EmpNo;
                    SearchEmp(EmpNo);
                    return item;
                }


            });

            $('#txtCityTemp').typeahead({
                items: 15,
                source: function (query, process) {
                    states = [];
                    map = {};



                    $.each(CityList, function (i, state) {

                        // map[state.EmpNo] = state;
                        map[state.ValueDesc] = state;
                        states.push(state.ValueDesc);
                    });

                    process(states);
                },

                updater: function (item) {


                    CityValueCode = map[item].ValueCode;
                    CityValueDesc = map[item].ValueDesc;


                    return item;
                }




            });



        }

        var SelectedCityCode = "";
        function SearchEmp(EmpNo) {
            var data = Ajax("Employees_GetEmployeesList", "Type=1&EmpNo=" + EmpNo);

            if (data[0]) {
               
                $("#btnSaveHasa").show();
                selectedEmp = EmpNo;
                $("#txtEmpNo").val(data[0].EmpNo);
                $("#txtFirstName").val(data[0].FirstName);
                $("#txtLastName").val(data[0].LastName);
                $("#txtArea").val(data[0].OrgUnitCode);
                $("#txtStartDate").val(data[0].StartDate);
                $("#txtEndDate").val(data[0].EndDate);
                $("#txtPhone").val(data[0].PhoneNum);
                $("#txtCity").val(data[0].City);
                $("#txtAddress").val(data[0].Address);
                $("#txtLooz").val(data[0].GroupCode);
                $("#txtTaz").val(data[0].EmpId);

                
                CityValueCode = data[0].CityCodeTemp;
                $("#txtCityTemp").val(data[0].CityTemp);
                $("#txtStreetTemp").val(data[0].StreetTemp);
               
                SelectedCityCode = (CityValueCode)?CityValueCode : data[0].CityCode;
                if (data[0].IsHasa == "1") {

                    $('#chIsHasa').prop('checked', true);
                } else {

                    $('#chIsHasa').prop('checked', false);
                }

                if (data[0].IsImahot == "1") {

                    $('#chIsImahot').prop('checked', true);
                } else {

                    $('#chIsImahot').prop('checked', false);
                }



                


            }



            $("#dvQualContainer").html("");
            var mydata = Ajax("Employees_GetEmployeesList", "Type=2&EmpNo=" + EmpNo);

            for (var i = 0; i < mydata.length; i++) {
                QualHtml = $("#dvQualTemplate").html();
                QualHtml = QualHtml.replace("@Text", mydata[i].Text);
                $("#dvQualContainer").append(QualHtml);

            }


            SetAbsence(EmpNo);


        }


        function SetAbsence(EmpNo) {

            $("#dvAbsenceContainer").html("");
            var mydata = Ajax("Employees_GetEmployeesList", "Type=3&EmpNo=" + EmpNo);

            var DateNum = 0;
            var DateStart = "";
            var DateEnd = "";
            var AbsenceCode = 0;
            var AbsenceDesc = "";
            var EmpNo = "";

            for (var i = 0; i < mydata.length; i++) {

                if (DateNum - 1 != mydata[i].DateNum || mydata[i].AbsenceCode != AbsenceCode) {

                    BuildAbsenceHTML(DateStart, DateEnd, EmpNo, AbsenceDesc);
                    DateEnd = mydata[i].DateStr;
                    DateStart = mydata[i].DateStr;

                }
                else {
                    DateStart = mydata[i].DateStr;
                }




                DateNum = mydata[i].DateNum;
                AbsenceCode = mydata[i].AbsenceCode;
                AbsenceDesc = mydata[i].ValueDesc;
                EmpNo = mydata[i].EmpNo;

            }




            BuildAbsenceHTML(DateStart, DateEnd, EmpNo, AbsenceDesc);
            // alert(mydata[mydata.length - 1].ValueDesc);



        }


        function BuildAbsenceHTML(DateStart, DateEnd, EmpNo, AbsenceDesc) {




            if (!DateStart || !DateEnd) return;


            AbsenceHtml = $("#dvAbsenceTemplate").html();
            AbsenceHtml = AbsenceHtml.replace("@Text", DateEnd + ' - ' + DateStart + ' -- ' + "<b>" + AbsenceDesc + "</b>");

            AbsenceHtml = AbsenceHtml.replace("@StartDate", DateStart);
            AbsenceHtml = AbsenceHtml.replace("@EndDate", DateEnd);
            AbsenceHtml = AbsenceHtml.replace("@EmpNo", EmpNo);
            $("#dvAbsenceContainer").append(AbsenceHtml);


        }


        function CancelAbsence(StartDate, EndDate, EmpNo) {



            bootbox.confirm("האם אתה בטוח שברצונך למחוק את ההיעדרות?", function (result) {
                if (result) {

                    Ajax("Absence_CancelAbsence", "EmpNo=" + EmpNo + "&StartDate=" + StartDate + "&EndDate=" + EndDate);
                    SetAbsence(EmpNo);
                    // FillData();
                }

            });

        }


        function FillData() {

            $("#dvReqContainer").html("");
            OrgUnitCode = $('#ddlArea').val();

            mydata = Ajax("Requirments_GetRequiremntsByArea", "OrgUnitCode=" + OrgUnitCode);




            //var Area = "";
            var ReqHtml = "";
            for (var i = 0; i < mydata.length; i++) {

                ReqHtml = $("#dvReqTemplate").html();
                ReqHtml = ReqHtml.replace("@RequirementDescTable", mydata[i].MainDesc);
                ReqHtml = ReqHtml.replace("@DayDesc", mydata[i].DayDesc);
                ReqHtml = ReqHtml.replace("@ShiftDesc", mydata[i].ShiftDesc);
                ReqHtml = ReqHtml.replace(/@QualificationDesc/g, mydata[i].QualificationDesc);
                ReqHtml = ReqHtml.replace(/@EmpQuantity/g, mydata[i].EmpQuantity);
                ReqHtml = ReqHtml.replace("@ObligatoryAssignmentTable", (mydata[i].ObligatoryAssignment == 1) ? "כן" : "לא");
                ReqHtml = ReqHtml.replace("@ObligatoryCheckTable", (mydata[i].ObligatoryCheck == 1) ? "כן" : "לא");


                ReqHtml = ReqHtml.replace("@Dates", mydata[i].Dates);



                ReqHtml = ReqHtml.replace(/@RequirementId/g, mydata[i].RequirementId);
                ReqHtml = ReqHtml.replace("@DateTypeCode", mydata[i].DateTypeCode);
                ReqHtml = ReqHtml.replace("@ShiftCode", mydata[i].ShiftCode);
                ReqHtml = ReqHtml.replace("@QualificationCode", mydata[i].QualificationCode);
                ReqHtml = ReqHtml.replace("@RequirementAbb", mydata[i].RequirementAbb);

                ReqHtml = ReqHtml.replace("@ObligatoryAssignment", mydata[i].ObligatoryAssignment);
                ReqHtml = ReqHtml.replace("@ObligatoryCheck", mydata[i].ObligatoryCheck);
                ReqHtml = ReqHtml.replace("@BeginDate", mydata[i].BeginDate);
                ReqHtml = ReqHtml.replace("@EndDate", mydata[i].EndDate);

                ReqHtml = ReqHtml.replace("@RequirementDesc", mydata[i].RequirementDesc);

                $("#dvReqContainer").append(ReqHtml);


            }


        }


        function SaveData() {
            var StreetTemp = $("#txtStreetTemp").val();
            var CityTemp = $("#txtCityTemp").val();

            if (!$.trim(CityTemp)) {
                CityValueCode = "";
            }
            //if (!CityValueCode || !StreetTemp) {
            //    bootbox.alert("חובה למלא עיר יעד או כתובת");
            //    return;
            //}

          
            var data = Ajax("Hasot_SetHasaForEmp", "EmpNo=" + selectedEmp + "&IsHasa=101&CityValueCode=" + CityValueCode + "&StreetTemp=" + StreetTemp);
            bootbox.alert("יעד נסיעה נשמר בהצלחה!");
        }





    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="col-md-12">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-th-list"></i>&nbsp; חיפוש עובד
                    </h3>
                </div>
                <div class="panel-body" style="padding: 8px">
                    <%-- <div class="col-md-4">
                        <select id="ddlArea" class="form-control">
                            <option value="0">-- בחר אזור --</option>
                        </select>
                    </div>
                    --%>
                    <div class="col-md-10">
                        <input type="text" class="form-control typeahead" spellcheck="false" autocomplete="off"
                            placeholder="חיפוש לפי מספר עובד או שם פרטי או שם משפחה">
                    </div>
                    <div class="col-md-2">
                        <button type="button" class="btn btn-info btn-round" onclick="FillData()">
                            <i class="glyphicon glyphicon-user"></i>&nbsp; <span class="btnAssign">חפש </span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-12">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-th-list"></i>&nbsp; פרטי עובד
                    </h3>
                </div>
                <div class="panel-body" style="">
                    <form action="" class="form-horizontal ls_form">
                        <div class="form-group">
                            <label class="col-md-1 control-label">
                                מס' עובד</label>
                            <div class="col-md-2">
                                <input type="text" id="txtEmpNo" disabled="" class="form-control rounded">
                            </div>
                            <label class="col-md-1 control-label">
                                שם פרטי</label>
                            <div class="col-md-2">
                                <input type="text" id="txtFirstName" disabled="" class="form-control rounded">
                            </div>
                            <label class="col-md-1 control-label">
                                משפחה</label>
                            <div class="col-md-2">
                                <input type="text" id="txtLastName" disabled="" class="form-control rounded">
                            </div>

                            <label class="col-md-1 control-label">
                                ת"ז</label>
                            <div class="col-md-2">
                                <input type="text" id="txtTaz" disabled="" class="form-control rounded">
                            </div>



                        </div>
                        <div class="form-group">
                            <label class="col-md-1 control-label">
                                אזור</label>
                            <div class="col-md-2">
                                <input type="text" id="txtArea" disabled="" class="form-control rounded">
                            </div>
                            <label class="col-md-1 control-label">
                                ת. התחלה</label>
                            <div class="col-md-2">
                                <input type="text" id="txtStartDate" disabled="" class="form-control rounded">
                            </div>
                            <label class="col-md-1 control-label">
                                ת. סיום</label>
                            <div class="col-md-2">
                                <input type="text" id="txtEndDate" disabled="" class="form-control rounded">
                            </div>
                            <label class="col-md-1 control-label">
                                לו"ז עבודה</label>
                            <div class="col-md-2">
                                <input type="text" id="txtLooz" disabled="" class="form-control rounded">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-md-1 control-label">
                                טלפון</label>
                            <div class="col-md-2">
                                <input type="text" id="txtPhone" disabled="" class="form-control rounded">
                            </div>
                            <label class="col-md-1 control-label">
                                עיר</label>
                            <div class="col-md-2">
                                <input type="text" id="txtCity" disabled="" class="form-control rounded">
                            </div>
                            <label class="col-md-1 control-label">
                                כתובת</label>
                            <div class="col-md-2">
                                <input type="text" id="txtAddress" disabled="" class="form-control rounded">
                            </div>
                             
                            <div class="col-md-3" style="padding-right:35px;background-color:lemonchiffon"">
                                <input type="checkbox" id="chIsHasa" style="width:20px;height:20px" name="chIsHasa" value="1" />
                              &nbsp;זכאי/ת להסעה? &nbsp;
                              
                                <input type="checkbox" id="chIsImahot" style="width:20px;height:20px" name="chIsImahot"  value="1" />
                                &nbsp;אמא עובדת? &nbsp;
                            </div>

                          
                        </div>


                          <div class="form-group" style="background-color:lemonchiffon">
                               <label class="col-md-1 control-label">
                                </label>
                               <div class="col-md-2" style="text-align:left">
                              <label class="control-label">
                                <b>הסעות (יעד להסעה):</b>  
                                </label>
                            </div>
                            
                           
                            <label class="col-md-1 control-label">
                                עיר</label>
                            <div class="col-md-2">
                                <input type="text" id="txtCityTemp"  class="form-control rounded" style="background:white;"/>
                            </div>
                            <label class="col-md-1 control-label">
                                כתובת</label>
                            <div class="col-md-2">
                                <input type="text" id="txtStreetTemp"  class="form-control rounded" style="background:white;"/>
                            </div>
                                <div class="col-md-1">
                        <button type="button" id="btnSaveHasa" class="btn btn-info btn-round " onclick="SaveData()">
                            <i class="fa fa-save"></i>&nbsp; <span class="btnAssign">שמור </span>
                        </button>
                    </div>
                             
                             
                          
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-th-list"></i>&nbsp; כישורי עובד
                    </h3>
                </div>
                <div class="panel-body dvPanelEmp" style="padding: 3px">
                    <ul class="slippylist" id="dvQualContainer">
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-th-list"></i>&nbsp; היעדרויות עובד
                    </h3>
                </div>
                <div class="panel-body dvPanelEmp" style="padding: 3px">
                    <ul class="slippylist" id="dvAbsenceContainer">
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <div id="dvQualTemplate" style="display: none">
        <li><i class="fa fa-circle-o"></i><span>@Text</span>
            <button class="btn btn-info removeTask">
                <i class="fa fa-plus-square-o"></i>
            </button>
        </li>
    </div>
    <div id="dvAbsenceTemplate" style="display: none">
        <li><i class="fa fa-circle-o"></i><span>@Text</span>
            <button class="btn ls-red-btn removeTask" onclick="CancelAbsence('@StartDate','@EndDate','@EmpNo' )">
                <i class="fa fa-trash-o"></i>
            </button>
        </li>
    </div>
    <%--  <div class="col-md-12">
        <div class="row" style="padding: 4px">
            <div class="btn btn-primary" onclick='EditRequirement("", "","", "", "", "", "","", "","", "")'>
                <i class="fa fa-plus-circle"></i>&nbsp;הוסף דרישה חדשה
            </div>
        </div>
    </div>--%>
</asp:Content>
