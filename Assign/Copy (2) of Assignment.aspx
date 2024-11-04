<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage/MasterPage.master" AutoEventWireup="true"
    CodeFile="Copy (2) of Assignment.aspx.cs" Inherits="Assign_Assignment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        var mydata;
        var SelectedAssignmentId;



        $(document).ready(function () {


            $('#txtSearchDate').datetimepicker(
            {
                value: getDateTimeNowFormat(),
                timepicker: false,
                format: 'd.m.Y',
                mask: true
            });




            //            $('.spDateIcon').click(function () {
            //                $('#txtSearchDate').datetimepicker('show');

            //            });


            $("#ddlAbsenceCode").append(GetComboItems("Codes", "TableId=8", "ValueCode", "ValueDesc"));


            $.mask.definitions['h'] = "[1-7]";
            $("#txtNumberAbsence,#txtNumberEdit").mask("h");
            BuildPageFromDATA();

        });



        function RefreshAbsenceDates() {



            $('#txtStartDate,#txtEndDate').datetimepicker(
            {
                //  minDate: 0,
                timepicker: false,
                format: 'd.m.Y',
                mask: true,
                validateOnBlur: false

            });




        }


        // פונקציה בונה את הסידור השבועי מנתוני בסיס

        var IsTwoTogether = false;
        function BuildPageFromDATA() {

            var SearchDate = $('#txtSearchDate').val();
            mydata = Ajax("Assign_GetAssignment", "Date=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode);

            var CurrentShiftCode = "";
            var CurrentShiftDate = "";
            var DayHtml = "";
            var ShiftEmployeeHtml = "";
            $("#dvMainContainer").html("");

            for (var i = 0; i < mydata.length; i++) {


                if (mydata[i].ShiftDate != CurrentShiftDate) {
                    DayHtml = $("#dvDayTemplate").html();
                    DayHtml = DayHtml.replace(/@Date/g, mydata[i].ShiftDate).replace(/@Day/g, mydata[i].DayInWeek);
                    $("#dvMainContainer").append(DayHtml);
                    CurrentShiftDate = mydata[i].ShiftDate;
                }


                IsTwoTogether = false;
                $("#dvEmpInShift_" + mydata[i].DayInWeek + "_" + mydata[i].ShiftCode).append(GetEmployeeHtml(mydata[i], mydata[i + 1])); //.FullName + "<br>");
                if (IsTwoTogether) {
                    i = i + 1;

                }




            }



        }

        function GetEmployeeHtml(row, nextRow) {




            var DayInWeek = row.DayInWeek;
            var FullName = row.FullName;
            var AddedHours = row.AddedHours;

            var RequirementLine = row.RequirementLine;
            var QualificationCode = row.QualificationCode;

            // var nextRequirementLine = "";
            // var nextQualificationCode = "";





            var IsNextExsit = nextRow && RequirementLine && nextRow.RequirementLine == RequirementLine && nextRow.QualificationCode == QualificationCode;

            var Template = "";

            if (FullName || IsNextExsit) {
                if (row.ShiftCode == 0 || row.ShiftCode == 99) {
                    Template = $("#dvAbsenceTemplate").html();
                } else {
                    Template = $("#dvEmployeeTemplate").html();
                }

                // בדיקת תקינות שיש 8 שעות בעמדה
                var btnTheme = "btn-primary";
                var TotalHourInPos = eval(AddedHours) + ((IsNextExsit) ? eval(nextRow.AddedHours) : 0);
                if (TotalHourInPos != 0 && TotalHourInPos != 8) {

                    btnTheme = "ls-red-btn";
                }


                // במידה ויש תוספת שעות זה יוצג 
                if (eval(AddedHours) > 0) {
                    AddedHours = "+" + AddedHours;
                }


                if (IsNextExsit) {

                    Template = Template.replace(/@2AssignmentId/g, nextRow.AssignmentId);
                    Template = Template.replace(/@2EmpNo/g, nextRow.EmpNo);
                    Template = Template.replace(/@2Symbol/g, nextRow.Symbol);
                    Template = Template.replace(/@2EmpName/g, nextRow.FullName);
                    Template = Template.replace(/@2SourceAssignmentId/g, nextRow.SourceAssignmentId);
                    Template = Template.replace(/@2AddedHours/g, (nextRow.AddedHours) ? ("+" + nextRow.AddedHours) : "");
                    // Template = Template.replace(/@2spRemoveX/g, "");
                    //  Template = Template.replace(/@2spRemove/g, "");

                    IsTwoTogether = true;


                } else {

                    Template = Template.replace(/@2Symbol/g, "");
                    Template = Template.replace(/@2EmpName/g, "");
                    Template = Template.replace(/@2AddedHours/g, "");
                    //  Template = Template.replace(/@2spRemoveX/g, "");
                    //  Template = Template.replace(/@2spRemove/g, "");

                }

                Template = Template.replace(/@btnTheme/g, btnTheme);
                Template = Template.replace(/@Symbol/g, (row.Symbol) ? row.Symbol : '&nbsp;');
                Template = Template.replace(/@AssignmentId/g, row.AssignmentId);
                Template = Template.replace(/@Date/g, row.ShiftDate);
                Template = Template.replace(/@ShiftCode/g, row.ShiftCode);
                Template = Template.replace(/@EmpNo/g, (row.EmpNo) ? row.EmpNo : "");
                Template = Template.replace(/@EmpName/g, (FullName) ? FullName : "");
                Template = Template.replace(/@AddedHours/g, (AddedHours) ? AddedHours : "");
                Template = Template.replace(/@IsAuto/g, row.ObligatoryAssignment);
                Template = Template.replace(/@SourceAssignmentId/g, (row.SourceAssignmentId) ? row.SourceAssignmentId : "");
                return Template;

            }

            // במידה ואין שיבוץ לעמדה
            else {

                Template = $("#dvEmptyTemplate").html();
                Template = Template.replace(/@Symbol/g, (row.Symbol) ? row.Symbol : '&nbsp;');
                Template = Template.replace(/@AssignmentId/g, row.AssignmentId);
                Template = Template.replace(/@Date/g, row.ShiftDate);
                Template = Template.replace(/@ShiftCode/g, row.ShiftCode);
                Template = Template.replace(/@EmpNo/g, row.EmpNo);
                Template = Template.replace(/@EmpName/g, FullName);
                Template = Template.replace(/@AddedHours/g, row.AddedHours);
                Template = Template.replace(/@IsAuto/g, row.ObligatoryAssignment);
                return Template;

            }



        }




        //        function FillWorkerList(Obj, JobId) {

        //            $("#imgLoader").show();
        //            $(".btnContainer").removeClass("btn-info");
        //            $(Obj).addClass("btn-info");
        //         //   Ajax("Tzahi", "", "SucceedTest");

        //        }



        //        function SucceedTest(data) {
        //            $("#dvWorkerList").html("לווחי אליקלציה");
        //            $("#imgLoader").hide();
        //            $("#dvUsers").show();
        //            mydata = data;
        //        }


        function OpenShiftDetails(e) {




            if (!e) e = window.event;
            e.stopPropagation();






            $("#modalTitle").html("איזור א' -- 24.05.1979 -- משמרת בוקר");
            $("#ModalAssign").modal();



        }

        function Addhour(IsAdd, WorkerId, e) {

            if (!e) e = window.event;
            e.stopPropagation();

            var numToAssign = "";
            var currentNumStr = $("#spWorkAddTime" + WorkerId).text();
            var IsPlus = currentNumStr.indexOf('+');
            var currentNumInt = parseInt(currentNumStr);

            //  alert(currentNumInt);
            // if (IsPlus == "-1") currentNumInt = -1 * currentNumInt;

            if (currentNumInt) {

                if (IsAdd) {
                    numToAssign = (currentNumInt + 1);
                } else {
                    numToAssign = (currentNumInt - 1);
                }

            }

            else {
                if (IsAdd) {
                    numToAssign = "1";
                } else {
                    numToAssign = "-1";
                }
            }



            if (numToAssign == "0") numToAssign = "&nbsp;&nbsp;&nbsp;";
            if (numToAssign > 0) numToAssign = "+" + numToAssign;
            $("#spWorkAddTime" + WorkerId).html(numToAssign);

        }

        function AddJobToShift() {
            $("#ModalJobs").modal();
        }

        function ChooseJob(JobId) {
            $("#ModalJobs").modal("hide");
            //   $($("#dvAddTemplate").html()).insertBefore("#btnAdd");

            // GET FROM SERVER TOP WORKER ID

            var str = $("#dvAddTemplate").html();
            var dvTemplate = str.replace(/@WorkerId/gi, "10");


            $(dvTemplate).insertBefore("#btnAdd");






        }

        //הסרת עובד מעמדת שיבוץ
        //        function RemoveWorker(WorkerId, IsAuto) {


        //            bootbox.confirm("<b> האם אתה בטוח שברצונך למחוק העובד מהרשימה ?</b> ", function (result) {
        //                if (result) {

        //                    // אם זה שיבוץ אוטמטי תסיר רק את השם
        //                    if (IsAuto) {
        //                        $("#spWorkerName" + WorkerId).html("&nbsp;");
        //                        $("#spWorkAddTime" + WorkerId).html("&nbsp;&nbsp;&nbsp;");
        //                        //TO DO - SEND TO SERVER

        //                    }
        //                    // אם הוא ידני צריך להסיר הכל
        //                    else {

        //                        $(".dvWorkerContainer" + WorkerId).remove();
        //                    }
        //                }

        //            });


        //        }

        function OpenTitleClick(Type) {
            //Type 1.שיבוץ חוסרים אוטמטי
            //Type 2.חיפוש שבוע

            if (Type == "1") {


                bootbox.alert("כל החוסרים שובצו לכל שבוע זה");
                return;

            }


            // $("#dvTasksModalInputs input").val('');

            //            if (Type == "1") {
            //                $("#dvAssign").show();
            //                $("#dvSearchWeek").hide();
            //                $("#dvCheckValid").hide();

            //            }
            //            if (Type == "2") {
            //                $("#dvAssign").hide();
            //                $("#dvSearchWeek").show();
            //                $("#dvCheckValid").hide();

            //            }

            //            if (Type == "3") {
            //                $("#dvAssign").hide();
            //                $("#dvSearchWeek").hide();
            //                $("#dvCheckValid").show();

            //            }

            $("#ModalTasks").modal();

        }
        // פותח מסך מודלי
        function OpenRequiremntsForNonAuto(ShiftCode, ShiftDate) {

            // הוספת דרישה...
            // בהנתן סוג משרת נוכחית וכן תאריך משמרת נוכחית נוכל להביא את כל הדרישות שאינם 
            // שיבוץ אוטמטי  


            // כאן להביא מהבסיס נתונים את הדרישות הרלוונטיות ואז לשפוך הכל לתוך המודלי של הדרישות....
            $("#ModalRequires").modal();
        }
        //בחירה של דרישה מסוימת 
        function ChooseRequirement(RequirementId, JobSign) {

            // הוספה של הדרישה לתוך הרובריקה המתאימה
            $("#TempBtnWorker .spJobSign").text("}#");
            var btnWorkerHTML = $("#TempBtnWorker").html();






            $("#Shift_ShiftCode_ShiftDate .btn-primary:last").after(btnWorkerHTML);
            $("#ModalRequires").modal("hide");



        }
     


        function AddWorkerToAssignment(WorkerId, AssignmentId, FullName) {


        }

        function AddJobToShift() {




            var FirstWorkerId = "";
            var SeqWorkerId = "";

            var sum = 0;
            var counter = 0;

            $('.spAddTime').each(function () {

                var val = $.trim($(this).text());


                if (val != "") {

                    sum += Number(val);

                    if (counter == 0) {
                        FirstWorkerId = $(this).parent().attr("id");

                    }


                    if (counter == 1) {
                        SeqWorkerId = $(this).parent().attr("id");

                    }

                    counter++;

                }
            });


            var message = "";

            if (counter == 0) {
                message = "לא ניתן לשבץ ללא הוספת שעות";
            }

            if (sum > 8) {
                message = "לא ניתן לשבץ ליותר מ8 שעות";
            }

            if (counter > 2) {

                message = "לא ניתן לשבץ יותר מ2 אנשים";

            }


            if (message) {


                bootbox.alert(message);
                return;
            }


            // TO DO - 1.Update Assignment TB 
            // 2.update button html.


            //  alert(SeqWorkerId);


            // $("#" + SelectedAssignmentId + ".spWorkerName").html("דוד טל");
            // alert();
        }

        //הסרת עובד מעמדת שיבוץ
        var SelectedRemove_EmpNo = "";
        var SelectedRemove_Date = "";
        var Selected_AssignmentId = "";


        function EditRequirmentPosition(e, AssignmentId, IsAuto, Date, ShiftCode, EmpNo, EmpName, AddHour, SourceAssignmentId) {

            e.cancelBubble = true;


            if (!EmpNo) return;

            if (!SourceAssignmentId) {
                RemoveWorkerOrRequirment(AssignmentId, IsAuto, Date, ShiftCode, EmpNo, EmpName);

            } else {
                 EditPosion(AssignmentId, IsAuto, Date, ShiftCode, EmpNo, EmpName); 
            }
        }



        function EditPosion(AssignmentId, IsAuto, Date, ShiftCode, EmpNo, EmpName) {

            Selected_AssignmentId = AssignmentId;
            $("#spEditTitle").text(EmpName + ' - ' + Date + ' - משמרת ' + ShiftCode);
            $("#ModalPosition").modal();
        }

        

        function RemoveWorkerOrRequirment(AssignmentId, IsAuto, Date, ShiftCode, EmpNo, EmpName) {




            // מאפס את הפרטים בחלון המודלי
            $("#txtNumberAbsence").val("");
            $('#txtStartDate,#txtEndDate').val("");

            RefreshAbsenceDates();
            $('#ddlAbsenceCode :nth-child(1)').prop('selected', true);
            // $("#ddlAbsenceCode").val("");
            SelectedRemove_EmpNo = EmpNo;
            SelectedRemove_Date = Date;
            Selected_AssignmentId = AssignmentId;

            $("#spAbsenceTitle").text(EmpName + ' - ' + Date + ' - משמרת ' + ShiftCode);
            $("#ModalAbsence").modal();






        }

        function SaveAbsence() {

            var AbsenceHour = $("#txtNumberAbsence").val();
            var AbsenceCode = $("#ddlAbsenceCode").val();
            var StartDate = $('#txtStartDate').val();
            var EndDate = $('#txtEndDate').val();




            mydata = Ajax("Absence_SetAbsence", "AssignmentId=" + Selected_AssignmentId + "&CurrentDate=" + SelectedRemove_Date
            + "&AbsenceHour=" + AbsenceHour + "&StartDate=" + StartDate + "&EndDate=" + EndDate
            + "&AbsenceCode=" + AbsenceCode + "&EmpNo=" + SelectedRemove_EmpNo
            );

            $("#ModalAbsence").modal("hide");
            BuildPageFromDATA();
            //alert(SelectedRemoveEmpNo);


        }


        function SaveWorkerHours() {
            var WorkerHours = $("#txtNumberEdit").val();

            Ajax("Assignment_SetHoursForWorker", "AssignmentId=" + Selected_AssignmentId + "&WorkerHours=" + WorkerHours);
            $("#ModalPosition").modal("hide");
            BuildPageFromDATA();


        }




    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="col-md-12">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-th-list"></i>&nbsp;ניהול שיבוצי עובדים- <span class="spToolBarTitle">
                            אזור א'</span> <a class="note-plus menuAssign" onclick="OpenTitleClick(1)"><i class="glyphicon glyphicon-user">
                            </i>&nbsp;שיבוץ חוסרים אוטמטי&nbsp;</a> <a class="note-plus menuAssign" onclick="OpenTitleClick(2)">
                                <i class="fa fa-search"></i>&nbsp;חיפוש שבוע &nbsp;</a>
                        <%--<a class="note-plus menuAssign"
                                    onclick="OpenTitleClick(3)"><i class="glyphicon glyphicon-check"></i>&nbsp;בדיקת
                                    תקינות &nbsp;</a>--%>
                    </h3>
                </div>
                <div id="dvMainContainer" class="panel-body" style="padding: 0px">
                </div>
            </div>
        </div>
    </div>
    <%--  חלון מודלי--%>
    <div class="modal fade" id="ModalTasks" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title " id="spModalTasksTitle">
                        שיבוץ אוטמטי
                    </h4>
                </div>
                <div class="modal-body" id="dvTasksModalInputs">
                    <div class="col-md-5">
                        <span class="help-block m-b-none">חיפוש שבוע שיבוץ </span>
                        <div class="input-group ls-group-input">
                            <input type="text" id="txtSearchDate" class="form-control">
                            <span class="input-group-addon spDateIcon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>
                    <div class="col-md-7" style="padding: 0px">
                        <span class="help-block m-b-none">&nbsp; </span>
                        <button type="button" class="btn btn-info btn-round">
                            <i class="glyphicon glyphicon-search"></i>&nbsp; <span>חפש </span>
                        </button>
                    </div>
                    <%--   <div id="dvCheckValid">
                        <div class="col-md-12">
                            <button type="button" class="btn btn-info btn-round">
                                <i class="glyphicon glyphicon-check"></i>&nbsp; <span>בדוק תקינות לאיזור זה </span>
                            </button>
                        </div>
                    </div>--%>
                    <div class="clear">
                        &nbsp;</div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-info btn-xs" data-dismiss="modal">
                        סגור</button>
                </div>
            </div>
        </div>
    </div>
    <%--   עריכת עובד - הוספת עובד לשיבוץ או החלפה--%>
    <div class="modal fade" id="ModalAssign" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header label-primary white">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title" id="modalTitle">
                        שיבוץ עובדים - <span id="spAddWorkerToPosition"></span>
                    </h4>
                </div>
                <div class="modal-body">
                    <%--  משמרות סמוכות--%>
                    <div class="col-md-4">
                        <div class="col-md-12 dvWorkerList">
                            שיבוצים ממשמרות סמוכות
                        </div>
                        <div class="col-md-12 dvRelvantWorker">
                            <div class="col-md-12">
                                <div class="panel panel-info">
                                    <div class="panel-heading" style="padding: 1px; cursor: pointer">
                                        <h3 class="panel-title">
                                            24.05.1979 - <b>בוקר</b>
                                        </h3>
                                    </div>
                                    <div class="panel-body collapse in" id="Div4" style="padding: 0px">
                                        <button class="btn btn-primary btnWorker" type="button" id="WorkerId2">
                                            <span class="spJobSign">{{+#</span> <span class="spWorkerName">ד.חמו</span>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(true,'WorkerId2',event)">
                                                +</div>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(false,'WorkerId2',event)">
                                                -</div>
                                            <span id="spWorkAddTimeWorkerId2" class="spAddTime badge badge-red"></span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button" id="WorkerId0">
                                            <span class="spJobSign">&nbsp;</span> <span class="spWorkerName">דוד אלקסלסי </span>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(true,'WorkerId0',event)">
                                                +</div>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(false,'WorkerId0',event)">
                                                -</div>
                                            <span id="spWorkAddTimeWorkerId0" class="spAddTime badge badge-red"></span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">נאור בוטרשווילי </span>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(true,'9',event)">
                                                +</div>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(false,'9',event)">
                                                -</div>
                                            <span id="spWorkAddTime9" class="spAddTime badge badge-red"></span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{+#</span> <span class="spWorkerName">דוד עמר </span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">אסף לוי </span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">ניסן אלקסלסי </span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button" onclick="" id="Button2">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">דוד אלקסלסי </span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-12">
                                <div class="panel panel-info">
                                    <div class="panel-heading" style="padding: 1px; cursor: pointer">
                                        <h3 class="panel-title">
                                            24.05.1979 - <b>ערב</b>
                                        </h3>
                                    </div>
                                    <div class="panel-body collapse in" id="Div5" style="padding: 0px">
                                        <button class="btn btn-primary btnWorker" type="button" id="Button3">
                                            <span class="spJobSign">{{+#</span> <span class="spWorkerName">דוד אלקסלסי</span>
                                        </button>
                                        <button class="btn btn-primary btnWorker" type="button" id="WorkerId3">
                                            <span class="spJobSign">{{+#</span> <span class="spWorkerName">ב.אפללו</span>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(true,'WorkerId3',event)">
                                                +</div>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(false,'WorkerId3',event)">
                                                -</div>
                                            <span id="spWorkAddTimeWorkerId3" class="spAddTime badge badge-red"></span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">ב.אפללו </span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{+#</span> <span class="spWorkerName">דוד עמר </span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">אסף לוי </span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">ניסן אלקסלסי </span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button" onclick="" id="Button4">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">דוד אלקסלסי </span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <%--עובדים לא משובצים או בחופש--%>
                    <div class="col-md-8">
                        <div id="dvWorkerList" class="col-md-12 dvWorkerList">
                            עובדים לא משובצים
                        </div>
                        <div class="col-md-12 dvRelvantWorker">
                            <div class="col-md-6">
                                <div class="panel panel-info">
                                    <div class="panel-heading" style="padding: 1px; cursor: pointer">
                                        <h3 class="panel-title">
                                            <b>מושאלים</b>
                                        </h3>
                                    </div>
                                    <div class="panel-body collapse in" id="Div6" style="padding: 0px">
                                        <button class="btn btn-primary btnWorker" type="button" id="WorkerId11">
                                            <span class="spJobSign">{{+#</span> <span class="spWorkerName">משה פרץ</span>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(true,'11',event)">
                                                +</div>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(false,'11',event)">
                                                -</div>
                                            <span id="spWorkAddTime11" class="spAddTime badge badge-red"></span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button" id="WorkerId_88">
                                            <span class="spJobSign">&nbsp;</span> <span class="spWorkerName">דוד אלקסלסי </span>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(true,'88',event)">
                                                +</div>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(false,'88',event)">
                                                -</div>
                                            <span id="spWorkAddTime88" class="spAddTime badge badge-red"></span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">נאור בוטרשווילי </span>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(true,'9',event)">
                                                +</div>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(false,'9',event)">
                                                -</div>
                                            <span id="Span3" class="spAddTime badge badge-red"></span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{+#</span> <span class="spWorkerName">דוד עמר </span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">אסף לוי </span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">ניסן אלקסלסי </span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button" onclick="" id="Button6">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">דוד אלקסלסי </span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="panel panel-info">
                                    <div class="panel-heading" style="padding: 1px; cursor: pointer">
                                        <h3 class="panel-title">
                                            סתם עייפים
                                        </h3>
                                    </div>
                                    <div class="panel-body collapse in" id="Div7" style="padding: 0px">
                                        <button class="btn btn-primary btnWorker" type="button" id="Button7">
                                            <span class="spJobSign">{{+#</span> <span class="spWorkerName">דוד אלקסלסי</span>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(true,'7',event)">
                                                +</div>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(false,'7',event)">
                                                -</div>
                                            <span id="Span4" class="spAddTime badge badge-red"></span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">&nbsp;</span> <span class="spWorkerName">דוד אלקסלסי </span>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(true,'8',event)">
                                                +</div>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(false,'8',event)">
                                                -</div>
                                            <span id="Span5" class="spAddTime badge badge-red"></span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">נאור בוטרשווילי </span>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(true,'9',event)">
                                                +</div>
                                            <div class="dvAddHour btn btn-info btn-xs" onclick="Addhour(false,'9',event)">
                                                -</div>
                                            <span id="Span6" class="spAddTime badge badge-red"></span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{+#</span> <span class="spWorkerName">דוד עמר </span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">אסף לוי </span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">ניסן אלקסלסי </span>
                                        </button>
                                        <button class="btn btn-primary  btnWorker" type="button" onclick="" id="Button8">
                                            <span class="spJobSign">{{</span> <span class="spWorkerName">דוד אלקסלסי </span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-12" id="btnAdd" style="text-align: left; padding-top: 3px">
                            <button type="button" class="btn btn-info btn-round" style="font-weight: bold;" onclick="AddJobToShift()">
                                <i class="fa fa-github-alt"></i>&nbsp;הוסף שיבוץ</button>
                        </div>
                    </div>
                    <div style="clear: both">
                        &nbsp;</div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary " data-dismiss="modal" style="margin-left: 10px">
                        סגור</button>
                </div>
            </div>
        </div>
    </div>
    <%--  חלון מודלי של דרישות שאינם אוטמטיות--%>
    <div class="modal fade" id="ModalRequires" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        דרישות
                    </h4>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-4">
                            <button type="button" class="btn btn-info btn-round" onclick="ChooseRequirement('RequirementId','JobSign')">
                                <i class="glyphicon glyphicon-check"></i>&nbsp; <span>נהג אמבולנס </span>
                            </button>
                        </div>
                        <div class="col-md-4">
                            <button type="button" class="btn btn-info btn-round">
                                <i class="glyphicon glyphicon-check"></i>&nbsp; <span>נהג אמבולנס </span>
                            </button>
                        </div>
                        <div class="col-md-4">
                            <button type="button" class="btn btn-info btn-round">
                                <i class="glyphicon glyphicon-check"></i>&nbsp; <span>נהג כבאית </span>
                            </button>
                        </div>
                        <div class="col-md-4">
                            <button type="button" class="btn btn-info btn-round">
                                <i class="glyphicon glyphicon-check"></i>&nbsp; <span>נהג אמבולנס </span>
                            </button>
                        </div>
                    </div>
                    <div class="clear">
                        &nbsp;</div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-info btn-xs" data-dismiss="modal">
                        סגור</button>
                </div>
            </div>
        </div>
    </div>
    <%--   חלון מודלי של הגדרת העדרות--%>
    <div class="modal fade" id="ModalAbsence" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        היעדרויות לעובד - <span id="spAbsenceTitle"></span>
                    </h4>
                </div>
                <div class="modal-body" id="Div3">
                    <div class="col-md-12">
                        <b style="text-decoration: underline">העדרות שעות משמרת נוכחית </b>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>
                                מספר שעות היעדרות למשמרת</label>
                            <input type="text" placeholder="מספר שעות  (1-7) " id="txtNumberAbsence" name="txtNumberAbsence"
                                class="form-control">
                        </div>
                    </div>
                    <div class="col-md-6">
                        &nbsp;
                    </div>
                    <div class="col-md-12">
                        <b style="text-decoration: underline">העדרות בימים </b>
                    </div>
                    <div class="col-md-6">
                        <span class="help-block m-b-none">תאריך התחלת העדרות </span>
                        <div class="input-group ls-group-input">
                            <input type="text" id="txtStartDate" class="form-control">
                            <span class="input-group-addon spDateIcon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <span class="help-block m-b-none">תאריך סיום העדרות</span>
                        <div class="input-group ls-group-input">
                            <input type="text" id="txtEndDate" class="form-control">
                            <span class="input-group-addon spDateIcon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <b style="text-decoration: underline">סיבת היעדרות</b>
                    </div>
                    <div class="col-md-6">
                        <select id="ddlAbsenceCode" class="form-control">
                        </select>
                    </div>
                    <div class="col-md-6" style="text-align: left">
                        <button type="button" class="btn btn-info btn-round" onclick="SaveAbsence()">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>עדכן היעדרות</span>
                        </button>
                    </div>
                
                    <div class="clear">
                        &nbsp;</div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-info btn-xs" data-dismiss="modal">
                        סגור</button>
                </div>
            </div>
        </div>
    </div>

      <%--   חלון מודלי של הגדרת עובד--%>
    <div class="modal fade" id="ModalPosition" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        עדכון עמדת עובד - <span id="spEditTitle"></span>
                    </h4>
                </div>
                <div class="modal-body" id="Div8">
                   <%-- <div class="col-md-12">
                        <b style="text-decoration: underline">העדרות שעות משמרת נוכחית </b>
                    </div>--%>
                    <div class="col-md-6">
                        <div class="form-group">
                          
                            <input type="text" placeholder="מספר שעות  (1-7) " id="txtNumberEdit" name="txtNumberEdit"
                                class="form-control">
                        </div>
                    </div>
                  
                    <div class="col-md-6" style="text-align: left">
                        <div  class="btn btn-info btn-round" onclick="SaveWorkerHours()">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>עדכן שעות </span>
                        </div>
                    </div>
                
                    <div class="clear">
                        &nbsp;</div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-info btn-xs" data-dismiss="modal">
                        סגור</button>
                </div>
            </div>
        </div>
    </div>


    <%--  טמפלט של יום מסויים --%>
    <div id="dvDayTemplate" style="display: none">
        <div class="dvDayContainer">
            <div class="panel panel-info">
                <div class="panel-heading" style="padding: 1px;">
                    <h3 class="panel-title">
                        <b>בוקר</b> - @Date
                    </h3>
                </div>
                <div class="panel-body" style="padding: 1px">
                    <div class="dvPanelShift" id="dvEmpInShift_@Day_1">
                    </div>
                    <button class="btn btn-info  btnWorker" type="button" onclick="OpenRequiremntsForNonAuto('1','@Date')">
                        הוסף דרישה
                    </button>
                </div>
            </div>
            <div class="panel panel-info">
                <div class="panel-heading" data-toggle="collapse" data-target="#collapseOne" style="padding: 1px;
                    cursor: pointer">
                    <h3 class="panel-title">
                        <b>צהריים</b> - @Date
                    </h3>
                </div>
                <div class="panel-body" id="Div1" style="padding: 1px">
                    <div class="dvPanelShift" id="dvEmpInShift_@Day_2">
                    </div>
                    <button class="btn btn-info  btnWorker" type="button" onclick="OpenRequiremntsForNonAuto('2','@Date')">
                        הוסף דרישה
                    </button>
                </div>
            </div>
            <div class="panel panel-info">
                <div class="panel-heading" style="padding: 1px;">
                    <h3 class="panel-title">
                        <b>לילה</b> - @Date
                    </h3>
                </div>
                <div class="panel-body" style="padding: 1px">
                    <div class="dvPanelShift" id="dvEmpInShift_@Day_3">
                    </div>
                    <button class="btn btn-info  btnWorker" type="button" onclick="OpenRequiremntsForNonAuto('3','ShiftDate')">
                        הוסף דרישה
                    </button>
                </div>
            </div>
            <div class="panel panel-success">
                <div class="panel-heading" style="padding: 1px;">
                    <h3 class="panel-title">
                        <b>מנוחה</b> - @Date
                    </h3>
                </div>
                <div class="panel-body dvPanelShift" id="dvEmpInShift_@Day_0" style="padding: 1px">
                </div>
            </div>
            <div class="panel panel-success">
                <div class="panel-heading" style="padding: 1px;">
                    <h3 class="panel-title">
                        <b>העדרויות</b> - @Date
                    </h3>
                </div>
                <div class="panel-body dvPanelShift" id="dvEmpInShift_@Day_99" style="padding: 1px">
                    <%--  @ShiftAbsenceWorker--%>
                </div>
            </div>
        </div>
    </div>
    <%--  טמפלט של עובד --%>
    <div id="dvEmployeeTemplate" style="display: none">
        <div class="btn @btnTheme btnWorker" type="button" id="@AssignmentId" onclick="EditRequirmentPosition(event,'@AssignmentId',@IsAuto,'@Date','@ShiftCode','@EmpNo','@EmpName','@AddedHours','@SourceAssignmentId')">
            <span class="spJobSign">@Symbol</span> <span class="spWorkerName">@EmpName</span>
            <span class="spAddHour">@AddedHours</span>
            <br />
            <span class="spJobSign">@2Symbol</span> <span class="spWorkerName" onclick="EditRequirmentPosition(event,'@2AssignmentId',@IsAuto,'@Date','@ShiftCode','@2EmpNo','@2EmpName','@2AddedHours','@2SourceAssignmentId')">
                @2EmpName</span> <span class="spAddHour">@2AddedHours</span>
        </div>
    </div>
    <%--  טמפלט של עמדה ריקה --%>
    <div id="dvEmptyTemplate" style="display: none">
        <div class="btn btn-danger btnWorker" type="button" id="Button10" onclick="EditRequirmentPosition('@AssignmentId','@Date','@ShiftCode','','','')">
            <span class="spJobSign">@Symbol</span><span class="spWorkerName"></span>
        </div>
    </div>
    <%--  טמפלט של מנוחה --%>
    <div id="dvAbsenceTemplate" style="display: none">
        <div class="btn btn-info btnWorker" type="button" id="Button1">
            <span class="spJobSign">@Symbol</span> <span class="spWorkerName">@EmpName</span>
        </div>
    </div>
</asp:Content>
<%--    //            bootbox.confirm("<b> האם אתה בטוח שברצונך למחוק העובד מהרשימה ?</b> ", function (result) {
            //                if (result) {

            //                    // אם זה שיבוץ אוטמטי תסיר רק את השם
            //                    if (IsAuto) {
            //                        $("#AssignmentId .spJobSign").html("&nbsp;");
            //                        $("#AssignmentId .spWorkerName").html("&nbsp;");
            //                        $("#AssignmentId .spAddHour").html("&nbsp;");

            //                        // הופך את הכפתור לאדום היות והוא ריק!
            //                        $("#AssignmentId").removeClass();
            //                        $("#AssignmentId").addClass("btn ls-red-btn btnWorker");



            //                    }
            //                    // אם הוא ידני צריך להסיר הכל
            //                    else {
            //                        $("#AssignmentId").remove();
            //                    }




            //                    //TO DO - SEND TO SERVER
            //                }

            //            });


--%>