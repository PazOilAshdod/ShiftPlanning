<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage/MasterPage.master" AutoEventWireup="true"
    CodeFile="Assignment.aspx.cs" Inherits="Assign_Assignment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="../assets/js/jquery-ui.js"></script>
    <link href="../assets/css/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">

        var mydata;
        var SelectedAssignmentId;

        var OrgUnitCode = '20000058';
        var WorkSchedule = "";
        $(document).ready(function () {

            InitDatesControls();


            if (getCookie("OrgUnitCode") != "") {
                OrgUnitCode = getCookie("OrgUnitCode");
                $(".spToolBarTitle").text(decodeURIComponent(getCookie('OrgUnitName')));
            }

     

            $(".modal").draggable({
                handle: ".modal-header"
            });


            var docWidth = $(document).width() - 75;
            $('.dvDayContainer').css({ "width": docWidth / 7 });


            SearchByWeek();

            GetComboItems("Codes", "TableId=8 Order By ValueCode", "#ddlAbsenceCode", "ValueCode", "ValueDesc");
            GetComboItems("Codes", "TableId=10 Order By ValueCode", "#ddlCreateChange", "ValueCode", "ValueDesc");
            GetComboItems("Codes", "TableId=20 Order By ValueCode", "#ddlSpecial", "ValueCode", "ValueDesc");
            GetComboItems("Codes", "TableId=21 Order By ValueCode", "#ddlHariga", "ValueCode", "ValueDesc");
            GetComboItems("Codes", "TableId=22 Order By ValueCode", "#ddlHad", "ValueCode", "ValueDesc");

            DefineIsPitzulEvent();




            //  SetCurrentPresence();


        });

        // נוכחות מסינל
        function SetCurrentPresence() {
            var DataforPresence = Ajax("Assignment_Presence");
          
            for (var i = 0; i < DataforPresence.length; i++) {


                

                if (DataforPresence[i].OUT_TIME) {
                    $(".presence_" + DataforPresence[i].WORK_ID + "_" + CurrentMainDayInWeek + "_"
                   + CurrentMainShiftCode).html("");

                }

                else {

                    //if (DataforPresence[i].WORK_ID == "52546") {

                    //    debugger
                    //}

                    $(".presence_" + DataforPresence[i].WORK_ID + "_" + CurrentMainDayInWeek + "_"
                   + CurrentMainShiftCode).html('<i class="glyphicon glyphicon-user"></i>');
                }
            }

        }


        function SearchByWeek() {

            setCookie("CurrentSearch", $('#txtSearchDate').val(), 2147483647);
            WorkSchedule = Ajax("Assign_GetSymbolShiftWS", "Date=" + $('#txtSearchDate').val());
            BuildPageFromDATA();
            CheckAreasValidation();

        }


        // בדיקת תקינה 
        function CheckAreasValidation(OnlyArea) {
            debugger
            $("div[id^= 'btnArea_']").removeClass("btn-success").addClass("ls-red-btn");


            var SearchOrgUnit = (OnlyArea) ? OrgUnitCode : "";
            var SearchDate = $('#txtSearchDate').val();
            var AreasNotValid = Ajax("Validation_CheckAreasValidation", "OrgUnitCode=" + SearchOrgUnit + "&DateStart=" + SearchDate);

            for (var i = 0; i < AreasNotValid.length; i++) {
                $("#btnArea_" + AreasNotValid[i].OrgUnitCode).removeClass("ls-red-btn").addClass("btn-success");
            }



        }

        function InitDatesControls() {



            $('#txtStartDate,#txtEndDate').datetimepicker(
            {
                minDate: 0,
                timepicker: false,
                format: 'd.m.Y',
                // mask: true,
                validateOnBlur: false

            });


            $('#txtStartDateAbsence,#txtEndDateAbsence,#txtStartDateChange,#txtEndDateChange').datetimepicker(
            {
                minDate: 0,
                timepicker: false,
                format: 'd.m.Y',
                //  mask: true,
                validateOnBlur: false

            });

            $('#txtSearchDate').datetimepicker(
            {
                value: (getCookie("CurrentSearch") != "") ? getCookie("CurrentSearch") : getDateTimeNowFormat(),
                timepicker: false,
                format: 'd.m.Y',
                mask: true
            });





        }

        // פונקציה בונה את הסידור השבועי מנתוני בסיס
        var IsTwoTogether = false;

        function BuildPageFromDATA() {

            //  CheckAreasValidation(true);

            //  var IsDisableShift = true;
            //  var LastDisableShift = ""; 
            var SearchDate = $('#txtSearchDate').val();

            AjaxAsync("Assign_GetAssignmentNew", "Date=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode + "&Procedure=Assign_GetAssignment_OnlyMishmar", function (px) { BuildPage(SearchDate,px)});
            //AjaxAsync("Assign_GetAssignmentNew", "Date=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode + "&Procedure=Assign_GetAssignment_OnlyHashalot", function (px) { BuildPageNoMishmar(px) });
            //AjaxAsync("Assign_GetAssignmentNew", "Date=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode + "&Procedure=Assign_GetAssignment_OnlyHeadrut", function (px) { BuildPageNoMishmar(px) });

          
            //var mydata = Ajax("Assign_GetAssignment", "Date=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode);
            //BuildPage(SearchDate,mydata);
           
            //var Tzahi = [];
           //  var mydata =  Ajax("Assign_GetAssignmentNew", "Date=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode + "&Procedure=Assign_GetAssignment_OnlyMishmar");
           // BuildPage(mydata);



            //for (var i = 0; i < mydata.length; i++) {
            //    Tzahi.push(mydata[i]);
            //}
            

            //mydata = Ajax("Assign_GetAssignmentNew", "Date=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode + "&Procedure=Assign_GetAssignment_OnlyHashalot");
            //for (var i = 0; i < mydata.length; i++) {
            //    Tzahi.push(mydata[i]);
            //}
            //mydata = Ajax("Assign_GetAssignmentNew", "Date=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode + "&Procedure=Assign_GetAssignment_OnlyHeadrut");
            //// הסרת אפשרות לגרירה עובדים שהושאלו לאזור אחר
            //for (var i = 0; i < mydata.length; i++) {
            //    Tzahi.push(mydata[i]);
            //}

          //  Tzahi = Tzahi.sort((a, b) => (a.DayDate > b.DayDate) ? 1 : -1);

          

        }

        function BuildPage(SearchDate,mydata) {

            var CurrentShiftCode = "";
            var CurrentShiftDate = "";
            var DayHtml = "";
            var ShiftEmployeeHtml = "";

            $("#dvMainContainer").html("");

            for (var i = 0; i < mydata.length; i++) {


                if (mydata[i].ShiftDate != CurrentShiftDate) {



                    DayHtml = $("#dvDayTemplate").html();



                    var WorkSchedular = WorkSchedule.filter(x => x.ShiftDate == mydata[i].ShiftDate);

                    debugger

                    DayHtml = DayHtml.replace("@LoozSymbol1", "(" + WorkSchedular[0].WorkScheduleRuleCode + ")");
                    DayHtml = DayHtml.replace("@LoozSymbol2", "(" + WorkSchedular[1].WorkScheduleRuleCode + ")");
                    DayHtml = DayHtml.replace("@LoozSymbol3", "(" + WorkSchedular[2].WorkScheduleRuleCode + ")");
                   

                    DayHtml = DayHtml.replace(/@Date/g, mydata[i].ShiftDate).replace(/@Day/g, mydata[i].DayInWeek);
                    DayHtml = DayHtml.replace("@InWeekDay", getDayInWeekString(mydata[i].DayInWeek));




                    $("#dvMainContainer").append(DayHtml);
                    CurrentShiftDate = mydata[i].ShiftDate;
                }


                IsTwoTogether = false;

                $("#dvEmpInShift_" + mydata[i].DayInWeek + "_" + mydata[i].ShiftCode).append(GetEmployeeHtml(mydata[i], mydata[i + 1])); //.FullName + "<br>");

                if (IsTwoTogether) {
                    i = i + 1;
                }


            }

            if (OrgUnitCode == "20000057") {
                $(".Boker").css("height", "250px");
                $(".AfterBoker").css("height", "110px");
                $("#menuAssignAuto").hide();


            }

            // אם מדובר במשמרת של מפקחים
            if (RoleId == "4" || RoleId == "5") {

                var root = $("div[date][dayshiftcode]");
                root.each(function (index, element) {
                    var selectDate = $(this).attr("date");
                    var selectShift = $(this).attr("dayshiftcode");

                    // 15.02.2016        // 13.02.2016
                    var diff = datediff(CurrentMainShiftDate, selectDate);

                    // בדיקת כל האפשרויות של דיסבול משמרות למפקחים אחורה 
                    //                   if (diff > 1 ||
                    //                      (diff == 1 && CurrentMainShiftCode != 1) ||
                    //                      (diff == 1 && CurrentMainShiftCode == 1 && (selectShift == 1 || selectShift == 2)))


                    if (diff > 1 || RoleId == "5") {
                        $(this).addClass("disabledbutton");
                        $(this).find('*').removeClass("droppable");

                    }

                });

            }

            $("#ModalSearch").modal('hide');

            DefineDragAndDropEvents();

            // הגדרת סמן ימני 
            $(".spContextMenu").contextMenu({
                menuSelector: "#contextMenu",
                menuSelected: function (invokedOn, selectedMenu) {

                    // e.cancelBubble = true;
                    var Obj = invokedOn;
                    var MenuId = selectedMenu[0].id;
                    switch (MenuId) {
                        case "li1": // קריאה מיוחדת
                            OpenSpecialPosition(Obj);
                            break;

                        case "li2": // תורן צוות חירום
                            SetToranHerum(Obj, 1);
                            break;
                        case "li3": // ביטול צוות חירום
                            SetToranHerum(Obj, 0);
                            break;

                        case "li4": // השמת כוכבית
                            SetAsterisk(Obj, 1);
                            break;

                        case "li5": // ביטול כוכבית
                            SetAsterisk(Obj, 0);
                            break;

                        case "li6": // פרטי עובד
                            OpenEmpDetails(Obj);
                            break;
                        case "li7": // פרטי עובד
                            OpenEmpOrder(Obj);
                            break;

                        case "li8": // השמת קפסולה לעובד
                            SetCapsula(Obj, 1, "primary");
                            break;
                        case "li9": // ביטול קפסולה לעובד
                            SetCapsula(Obj, 0, "primary");
                            break;


                        default:
                            break;


                    }

                }
            });

            $(".spContextMenuAbsence").contextMenu({
                menuSelector: "#contextMenuAbsence",
                menuSelected: function (invokedOn, selectedMenu) {

                    //e.cancelBubble = true;
                    var Obj = invokedOn;
                    var MenuId = selectedMenu[0].id;

                    switch (MenuId) {
                        case "liAbsence1": // פרטי עובד
                            OpenEmpDetails(Obj);
                            break;
                        case "liAbsence2": // פרטי עובד
                            OpenEmpOrder(Obj);
                            break;

                        default:
                            break;


                    }

                }
            });

            AjaxAsync("Assign_GetAssignmentNew", "Date=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode + "&Procedure=Assign_GetAssignment_OnlyHashalot", function (px) { BuildPageNoMishmar(px) });

            AjaxAsync("Assign_GetAssignmentNew", "Date=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode + "&Procedure=Assign_GetAssignment_OnlyHeadrut", function (px) { BuildPageNoMishmar(px) });
        }


        function BuildPageNoMishmar(mydata) {

            var CurrentShiftCode = "";
            var CurrentShiftDate = "";
            var DayHtml = "";
            var ShiftEmployeeHtml = "";

          //  $("#dvMainContainer").html("");

            for (var i = 0; i < mydata.length; i++) {

                IsTwoTogether = false;

                $("#dvEmpInShift_" + mydata[i].DayInWeek + "_" + mydata[i].ShiftCode).append(GetEmployeeHtml(mydata[i], mydata[i + 1])); //.FullName + "<br>");

                if (IsTwoTogether) {
                    i = i + 1;
                }


            }

            if (OrgUnitCode == "20000057") {
                $(".Boker").css("height", "250px");
                $(".AfterBoker").css("height", "110px");
                $("#menuAssignAuto").hide();


            }

            // אם מדובר במשמרת של מפקחים
            if (RoleId == "4" || RoleId == "5") {

                var root = $("div[date][dayshiftcode]");
                root.each(function (index, element) {
                    var selectDate = $(this).attr("date");
                    var selectShift = $(this).attr("dayshiftcode");

                    // 15.02.2016        // 13.02.2016
                    var diff = datediff(CurrentMainShiftDate, selectDate);

                    // בדיקת כל האפשרויות של דיסבול משמרות למפקחים אחורה 
                    //                   if (diff > 1 ||
                    //                      (diff == 1 && CurrentMainShiftCode != 1) ||
                    //                      (diff == 1 && CurrentMainShiftCode == 1 && (selectShift == 1 || selectShift == 2)))


                    if (diff > 1 || RoleId == "5") {
                        $(this).addClass("disabledbutton");
                        $(this).find('*').removeClass("droppable");

                    }

                });

            }

            $("#ModalSearch").modal('hide');

            DefineDragAndDropEvents();

            // הגדרת סמן ימני 
            $(".spContextMenu").contextMenu({
                menuSelector: "#contextMenu",
                menuSelected: function (invokedOn, selectedMenu) {

                    // e.cancelBubble = true;
                    var Obj = invokedOn;
                    var MenuId = selectedMenu[0].id;
                    switch (MenuId) {
                        case "li1": // קריאה מיוחדת
                            OpenSpecialPosition(Obj);
                            break;

                        case "li2": // תורן צוות חירום
                            SetToranHerum(Obj, 1);
                            break;
                        case "li3": // ביטול צוות חירום
                            SetToranHerum(Obj, 0);
                            break;

                        case "li4": // השמת כוכבית
                            SetAsterisk(Obj, 1);
                            break;

                        case "li5": // ביטול כוכבית
                            SetAsterisk(Obj, 0);
                            break;

                        case "li6": // פרטי עובד
                            OpenEmpDetails(Obj);
                            break;
                        case "li7": // פרטי עובד
                            OpenEmpOrder(Obj);
                            break;

                        case "li8": // השמת קפסולה לעובד
                            SetCapsula(Obj, 1, "primary");
                            break;
                        case "li9": // ביטול קפסולה לעובד
                            SetCapsula(Obj, 0, "primary");
                            break;


                        default:
                            break;


                    }

                }
            });

            $(".spContextMenuAbsence").contextMenu({
                menuSelector: "#contextMenuAbsence",
                menuSelected: function (invokedOn, selectedMenu) {

                    //e.cancelBubble = true;
                    var Obj = invokedOn;
                    var MenuId = selectedMenu[0].id;

                    switch (MenuId) {
                        case "liAbsence1": // פרטי עובד
                            OpenEmpDetails(Obj);
                            break;
                        case "liAbsence2": // פרטי עובד
                            OpenEmpOrder(Obj);
                            break;

                        default:
                            break;


                    }

                }
            });


        }

        function OpenEmpDetails(Obj) {

            var Obj0 = Obj[0];
            var Name = $(Obj0).text();
            var EmpNo = $(Obj0).attr("EmpNo");
            var PhoneNum = $(Obj0).attr("PhoneNum");

            var Mess = "<b>" + "מס' עובד: " + EmpNo + "<br>טל': " + PhoneNum + "</b>";


            $.amaran({
                content: {
                    img: '../assets/images/demo/avatar-80.png',
                    user: Name,
                    message: Mess
                },
                theme: 'user green',
                inEffect: 'slideRight',
                outEffect: 'slideBottom',
                delay: 1000000
            });


        }

        //כאן עשיתי שינוי ב24.06.2020
        function GetEmployeeHtml(row, nextRow) {


            var IsCapsula = row.IsCapsula;

            var DayInWeek = row.DayInWeek;
            var FullName = row.FullName;
            var AddedHours = row.AddedHours;

            var RequirementLine = row.RequirementLine;
            var QualificationCode = row.QualificationCode;

            // var nextRequirementLine = "";
            var ObligatoryAssignment = row.ObligatoryAssignment;
            var ObligatoryCheck = row.ObligatoryCheck;
            var Seq = row.Seq;
            var ShiftCode = row.ShiftCode;




            var IsNextExsit = nextRow && RequirementLine && nextRow.RequirementLine == RequirementLine && nextRow.QualificationCode == QualificationCode && nextRow.Seq == Seq && nextRow.ShiftCode == ShiftCode;

            var Template = "";

            if (FullName || IsNextExsit) {

                if (row.ShiftCode == 0) {
                    Template = $("#dvMenuaTemplate").html();
                }
                else if (row.ShiftCode == 99) {
                    Template = $("#dvAbsenceTemplate").html();
                }

                else if (row.ShiftCode == 100) {

                    Template = $("#dvNoAssignTemplate").html();
                }
                else {
                    Template = $("#dvEmployeeTemplate").html();

                }



                // בדיקת תקינות שיש 8 שעות בעמדה
                var btnTheme = ((IsCapsula == 1) ? " btn-primary spCapsula " : " btn-primary ") + " draggable";



                var TotalHourInPos = eval(AddedHours) + ((IsNextExsit) ? eval(nextRow.AddedHours) : 0);
                if (TotalHourInPos != 0 && TotalHourInPos != 8) {

                    //רק במידה ויש רק אחד והוא לא תקין תנתן אפשרות לגרור אליו עובד 
                    if (!IsNextExsit) {
                        btnTheme = "ls-red-btn droppable";
                    }
                    else {
                        btnTheme = "ls-red-btn";
                    }

                    //במידה ואין חובת תקינות לא מופיע צמע אדום אלא כחול רגיל
                    if (ObligatoryCheck == "0") btnTheme = "btn-primary droppable";


                }

                //  



                // במידה ומדובר באינו אוטמטי 
                //  if (ObligatoryAssignment == "0") btnTheme = "ls-light-blue-btn draggable";

                var btnThemeForOther = (IsCapsula == 1) ? "btn-info spCapsula" : "btn-info"; //"";


                // השאלות
                if (row.Borrow) {

                    btnThemeForOther = (IsCapsula == 1) ? " borrowStyle spCapsula" : "borrowStyle";

                    //  במידה והוא מושאל לאזור אחר והוא הועבר ולא התווסף
                    if ((row.Borrow).indexOf("!") != "-1") {
                        btnThemeForOther = (IsCapsula == 1) ? " borrowStyleNoDrag spCapsula" : "borrowStyleNoDrag";
                    }


                    //  במידה והוא מושאל לאזור אחר והוא התווסף ולא הועבר
                    if ((row.Borrow).indexOf("S") != "-1") {
                        btnThemeForOther = (IsCapsula == 1) ? " borrowStyleSource spCapsula" : "borrowStyleSource";
                    }




                }






                // במידה ויש תוספת שעות זה יוצג 
                if (eval(AddedHours) > 0) {
                    AddedHours = "+" + AddedHours;
                }

                if (IsNextExsit) {

                    Template = Template.replace(/@2spJobSign/g, (nextRow.IsToranHerum) ? "spJobSignToranHerum" : "spJobSign");
                    Template = Template.replace(/@2AssignmentId/g, nextRow.AssignmentId);
                    Template = Template.replace(/@Day/g, nextRow.DayInWeek);

                    Template = Template.replace(/@2EmpNo/g, (nextRow.EmpNo) ? nextRow.EmpNo : "");
                    Template = Template.replace(/@2EmpId/g, (nextRow.EmpId) ? nextRow.EmpId : "");
                    Template = Template.replace(/@2PhoneNum/g, (nextRow.PhoneNum) ? nextRow.PhoneNum : "");
                    Template = Template.replace(/@2Symbol/g, ($.trim(nextRow.Symbol)) ? nextRow.Symbol : '&nbsp;');
                    Template = Template.replace(/@2EmpName/g, nextRow.FullName);
                    Template = Template.replace(/@2SourceAssignmentId/g, nextRow.SourceAssignmentId);

                    var NextAddedHours = nextRow.AddedHours;
                    if (eval(NextAddedHours) > 0) {
                        NextAddedHours = "+" + NextAddedHours;
                    }



                    Template = Template.replace(/@2AddedHours/g, ((NextAddedHours) ? NextAddedHours : "") + ((nextRow.IsSpecial) ? " ק" : ""));
                    // Template = Template.replace(/@2AddedHours/g, ((nextRow.AddedHours) ? ("+" + nextRow.AddedHours) : "") + ((nextRow.IsSpecial) ? " ק" : ""));

                    Template = Template.replace(/@Seq/g, "2");
                    Template = Template.replace(/@TotalHourInPos/g, TotalHourInPos);

                    Template = Template.replace(/@2IsSpecial/g, nextRow.IsSpecial);
                    Template = Template.replace(/@2SpecialId/g, nextRow.SpecialId);
                    Template = Template.replace(/@2SpecialFree/g, nextRow.SpecialFree);
                    IsTwoTogether = true;


                } else {
                    Template = Template.replace(/@Seq/g, "1");
                    Template = Template.replace(/@2Symbol/g, "");
                    Template = Template.replace(/@2EmpName/g, "");
                    Template = Template.replace(/@2AddedHours/g, "");
                    Template = Template.replace(/@TotalHourInPos/g, "");
                    //  Template = Template.replace(/@2spRemoveX/g, "");
                    //  Template = Template.replace(/@2spRemove/g, "");

                }


                // 




                Template = Template.replace(/@ReqSymbol/g, row.ReqSymbol);

                Template = Template.replace(/@spJobSign/g, (row.IsToranHerum) ? "spJobSignToranHerum" : "spJobSign");
                Template = Template.replace(/@IsSpecial/g, row.IsSpecial);
                Template = Template.replace(/@Day/g, row.DayInWeek);
                Template = Template.replace(/@SpecialId/g, row.SpecialId);
                Template = Template.replace(/@SpecialFree/g, row.SpecialFree);
                Template = Template.replace(/@privateSymbol/g, row.PrivateSymbol);

                Template = Template.replace(/@btnThemeForOther/g, btnThemeForOther);
               



                //   if (row.EmpNo == "52139") alert(row.Symbol);

                var CurrentSymbol = ($.trim(row.Symbol)) ? row.Symbol : '&nbsp;';
                if (CurrentSymbol.indexOf('ה') > -1) {

                    btnTheme = "hadrchaBg";

                }
                Template = Template.replace(/@btnTheme/g, btnTheme);

                Template = Template.replace(/@Symbol/g, CurrentSymbol);
                Template = Template.replace(/@AssignmentId/g, row.AssignmentId);
                Template = Template.replace(/@Date/g, row.ShiftDate);
                Template = Template.replace(/@ShiftCode/g, row.ShiftCode);
                Template = Template.replace(/@EmpNo/g, (row.EmpNo) ? row.EmpNo : "");
                Template = Template.replace(/@EmpId/g, (row.EmpId) ? row.EmpId : "");


                Template = Template.replace(/@PhoneNum/g, (row.PhoneNum) ? row.PhoneNum : "");



                // מוסיף את המשמרת שהיה אמור להיות קומבינה לסמן
                if (FullName && row.ShiftCode == 100) {
                    FullName = FullName + "<b>&nbsp;(" + row.RequirementId + ")</b>";
                    Template = Template.replace(/@Shift/g, row.RequirementId);

                }
                Template = Template.replace(/@EmpName/g, (FullName) ? FullName : "");
                Template = Template.replace(/@AddedHours/g, ((AddedHours) ? AddedHours : "") + ((row.IsSpecial) ? " ק" : ""));
                Template = Template.replace(/@IsAuto/g, row.ObligatoryAssignment);
                Template = Template.replace(/@SourceAssignmentId/g, (row.SourceAssignmentId) ? row.SourceAssignmentId : "");
                return Template;

            }

            // במידה ואין שיבוץ לעמדה
            else {

                var btnTheme = "btn-danger";

                //במידה ואין חובת תקינות לא מופיע צמע אדום אלא כחול רגיל
                if (ObligatoryCheck == "0") btnTheme = "btn-primary droppable";

                //במידה וזה בא לא מאוטמטי תן לו צבע מיוחד 
                if (ObligatoryAssignment == "0") btnTheme = "ls-light-blue-btn";

                //צחי משנה לוורוד
                //if (ObligatoryAssignment == "0") btnTheme = "hadrchaBg";


                Template = $("#dvEmptyTemplate").html();

                Template = Template.replace(/@ReqSymbol/g, row.ReqSymbol);
                Template = Template.replace(/@spJobSign/g, (row.IsToranHerum) ? "spJobSignToranHerum" : "spJobSign");
                Template = Template.replace(/@Day/g, row.DayInWeek);



                var CurrentSymbol = ($.trim(row.Symbol)) ? row.Symbol : '&nbsp;';
                if (CurrentSymbol.indexOf('ה') > -1) {

                    btnTheme = "hadrchaBg";

                }
                Template = Template.replace(/@btnTheme/g, btnTheme);

                Template = Template.replace(/@Symbol/g, CurrentSymbol);



                //Template = Template.replace(/@btnTheme/g, btnTheme);
                //Template = Template.replace(/@Symbol/g, ($.trim(row.Symbol)) ? row.Symbol : '&nbsp;');
                Template = Template.replace(/@AssignmentId/g, row.AssignmentId);
                Template = Template.replace(/@Date/g, row.ShiftDate);
                Template = Template.replace(/@ShiftCode/g, row.ShiftCode);
                Template = Template.replace(/@EmpNo/g, row.EmpNo);
                Template = Template.replace(/@EmpName/g, FullName);
                Template = Template.replace(/@AddedHours/g, row.AddedHours);
                Template = Template.replace(/@IsAuto/g, row.ObligatoryAssignment);
                Template = Template.replace(/@privateSymbol/g, row.PrivateSymbol);


                return Template;

            }



        }

       

        function SetCapsula(Obj, Type, Mod) {

            var Obj0 = Obj[0];

            var AssignmentId = (Obj0.id).replace("spWorkerName_", "");

            var resObj = Ajax("Added_SetCapsula", "AssignmentId=" + AssignmentId + "&Type=" + Type);

           
            if (Type == 1) {
                $("span[id='spWorkerName_" + AssignmentId + "']").parent().addClass(" spCapsula ");
            } else {

                $("span[id='spWorkerName_" + AssignmentId + "']").parent().removeClass(" spCapsula ");

            }


        }

        function SetToranHerum(Obj, Type) {

            var Obj0 = Obj[0];
            var Date = $(Obj0).attr("Date");
            var AssignmentId = (Obj0.id).replace("spWorkerName_", "");

            var resObj = Ajax("Added_SetHerum", "Date=" + Date + "&AssignmentId=" + AssignmentId + "&Type=" + Type);

            var res = resObj[0].res;

            if (res == "1" || res == "2")
                var SymbolEle = $(Obj0).prev();
            if (Type == 1) {
                $(SymbolEle).removeClass("spJobSign");
                $(SymbolEle).addClass("spJobSignToranHerum");
            } else {
                $(SymbolEle).removeClass("spJobSignToranHerum");
                $(SymbolEle).addClass("spJobSign");

            }



            if (res == "0")
                alert("אין כישור חירום לעובד");
        }

        // הוספה או ביטול כוכבית
        function SetAsterisk(Obj, Type) {

            var Obj0 = Obj[0];
            var Date = $(Obj0).attr("Date");


            var SymbolHtml = $(Obj0).prev().html();
            if (SymbolHtml.indexOf("*") == "-1" && Type == "1") {
                $(Obj0).prev().html(SymbolHtml + "*");
            }

            if (SymbolHtml.indexOf("*") != "-1" && Type == "0") {
                $(Obj0).prev().html(SymbolHtml.replace("*", "&nbsp;"));
            }

            // alert(SymbolEle.html());

            var AssignmentId = (Obj0.id).replace("spWorkerName_", "");
            var resObj = Ajax("Added_SetAsterisk", "AssignmentId=" + AssignmentId + "&Type=" + Type + "&NoAssignChangeReason=");



            // BuildPageFromDATA();

        }


        // פותח חלון מודלי של קריאה מיוחדת.
        var Added_AssignmentId = "";

        function OpenSpecialPosition(Obj) {


            var Obj0 = Obj[0];
            Added_AssignmentId = (Obj0.id).replace("spWorkerName_", "");
            var WorkerName = Obj.text();

            var IsSpecial = $(Obj0).attr("IsSpecial");
            var SpecialFree = $(Obj0).attr("SpecialFree");
            var SpecialId = $(Obj0).attr("SpecialId");
            SpecialFree = SpecialFree.replace(/&16/g, '"');





            $("#chIsSpecial").prop("checked", eval(IsSpecial));
            $("#ddlSpecial").val(SpecialId);
            $("#txtFree").val(SpecialFree);



            // alert(SpecialFree);
            $("#spSpecialTitle").text(WorkerName);
            $("#ModalSpeciel").modal();


        }

        function OpenEmpOrder(Obj) {

           
            var Obj0 = Obj[0];
            // Added_AssignmentId = (Obj0.id).replace("spWorkerName_", "");
            var WorkerName = Obj.text();

            var EmpNo = $(Obj0).attr("EmpNo");

            var Data = Ajax("Assignment_GetPrivateAssign", "EmpNo=" + EmpNo);
            

           
            $("#olPrivate").html("");

            var IsNext = false;
            for (var i = 0; i < Data.length; i++) {


                if (!IsNext) 
                {

                        var AssignShiftCode = Data[i].ShiftCode;
                        var Date = Data[i].Date;
                        var SourceShift = Data[i].SourceShift;
                        var AbsenceRes = Data[i].AbsenceRes;
                        var AddedHours = Data[i].AddedHours;
                        var DayDate = Data[i].DayDate;
                      
                      
                      
                                  

                        var Html = $("#dvPrivateOrderTemplate").html();
                        Html = Html.replace("@Date", Date);
                        Html = Html.replace("@StringDate", Data[i].StringDate);
                        Html = Html.replace("@Day", (getDayInWeekString(Data[i].DayInWeek)).replace("יום", ""));

                       


                        // קידום ציר הזמן לפי תאריך היום
                        if (DayDate == CurrentMainShiftDate) {
                            Html = Html.replace("@selected", "selected");
                        }

                        Html = Html.replace("@selected", "");


                       
                        var Source = ((SourceShift == "0") ? "מנוחה" : SourceShift.toString()).replace("1", "בוקר").replace("2", "צהריים").replace("3", "לילה");
                       
                        Html = Html.replace(/@SourceShift/g, Source);

                        

                        if (AssignShiftCode) {
                            AssignShiftCode = (AssignShiftCode.toString()).replace("1", "בוקר").replace("2", "צהריים").replace("3", "לילה");
                        }

                        // מנוחה ולא משובץ אז הוא במנוחה
                        if (!AssignShiftCode && SourceShift == "0") {
                            AssignShiftCode = "מנוחה";
                        }
                      
                        //לא משובץ ואמור לעבוד 
                        if (!AssignShiftCode && SourceShift != "0" && !AbsenceRes) {
                             AssignShiftCode = "לא משובץ";
                        }





                        // הוא משובץ רק שנעדר שעות
                        if (AbsenceRes) {

                            if (AddedHours) {
                                var strAddedHours = (AddedHours.toString()).replace("-", "");

                                AssignShiftCode = AssignShiftCode + " (" + strAddedHours + "-)";
                            }
                            else
                                AssignShiftCode = AbsenceRes;

                        }

                        Html = Html.replace("@Shift1", AssignShiftCode);

                        var Shift2 = "&nbsp;";
                    
                        if (Data[i + 1] && Data[i + 1].Date == Date) {


                            var AddedHour2 = Data[i + 1].AddedHours;
                            if (AddedHour2)
                                Shift2 = "<b> ש.נ - </b>" + ((Data[i + 1].ShiftCode).toString()).replace("1", "בוקר").replace("2", "צהריים").replace("3", "לילה") + " - " + Data[i + 1].AddedHours + "+";


                            if (Data[i + 2] && Data[i + 2].Date == Date) {

                                Shift2 = Shift2 +" "+ ((Data[i + 2].ShiftCode).toString()).replace("1", "בוקר").replace("2", "צהריים").replace("3", "לילה") + " - " + Data[i + 2].AddedHours + "+";
                            }


                            IsNext = true;
                        }

                        Html = Html.replace("@Shift2", Shift2);


                        if (SourceShift == 0 && Data[i].ShiftCode != null) {

                            Html = Html.replace("@Color", "red;font-weight:bold");  

                        }
                    
                        $("#olPrivate").append(Html);
                }
                else 
                {
                        IsNext = false;
                        if (Data[i + 1] && Data[i + 1].Date == Date) {

                            IsNext = true;
                        }
                }


            }



            InitTime();


            // ביקשו לראות את השעות נוספות של העובד
            var SearchDate = $('#txtSearchDate').val();
            var mydata = Ajax("Assignment_GetAddedHours", "OrgUnitCode=" + OrgUnitCode + "&SearchDate=" + SearchDate);
           
            for (var i = 0; i < mydata.length; i++) {



                if (mydata[i].EmpNo == EmpNo) {
                    $("#spWeekAddedHours").text((mydata[i].AddedWeek) ? mydata[i].AddedWeek:0);
                    $("#spMonthAddedHours").text((mydata[i].AddedMonth) ? mydata[i].AddedMonth:0);
                    break;


                }
                //ReqHtml = $("#dvAddedHoursTemplate").html();
                //ReqHtml = ReqHtml.replace("@FullName", mydata[i].FullName);
                //ReqHtml = ReqHtml.replace("@Week", (mydata[i].AddedWeek) ? mydata[i].AddedWeek : "&nbsp;");
                //ReqHtml = ReqHtml.replace("@Month", (mydata[i].AddedMonth) ? mydata[i].AddedMonth : "&nbsp;");

                //ReqHtml = ReqHtml.replace("@SourceMenuha", (mydata[i].SourceMenuha) ? mydata[i].SourceMenuha : "&nbsp;");
                //ReqHtml = ReqHtml.replace("@NightShift", (mydata[i].NightShift) ? mydata[i].NightShift : "&nbsp;");
                //ReqHtml = ReqHtml.replace("@AbsenceDay", (mydata[i].AbsenceDay) ? mydata[i].AbsenceDay : "&nbsp;");

                //$("#dvAddedHoursContainer").append(ReqHtml);



            }


            // ********************************************************************************************
           

            $("#spPrivateTitle").text(WorkerName);
            $("#ModalPrivate").modal();


        }

        function SaveSpecial() {


            var IsSpecial = $("#chIsSpecial").prop("checked");
            var SpecialId = $("#ddlSpecial").val();
            var SpecialFree = $("#txtFree").val();


            if (SpecialId == "0") {

                alert("חובה לבחור סיבה");
                return;
            }



            Ajax("Added_SetData", "Type=1&AssignmentId=" + Added_AssignmentId + "&IsOn=" + IsSpecial
               + "&ReasonId=" + SpecialId + "&Free=" + SpecialFree + "&UserId=" + UserId);

            $("#ModalSpeciel").modal("hide");

            BuildPageFromDATA();

        }

        function OpenTitleClick(Type) {
            //Type 1.שיבוץ חוסרים אוטמטי
            //Type 2.חיפוש שבוע

            if (Type == "1") {
               
                var SearchDate = $('#txtSearchDate').val();
                var res = Ajax("Assign_SetEmpForEmptyPosition", "SearchDate=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode);
                BuildPageFromDATA();
                bootbox.alert("כל החוסרים שובצו לכל שבוע זה");
                return;

            }

            if (Type == "2") {
                $("#ModalSearch").modal();
            }


            if (Type == "3") {

                PrintPage();

            }


            if (Type == "4") {

                OpenAddedHoursModal();

            }

            // שיבוץ תורנים שבועי
            if (Type == "5") {
                var SearchDate = $('#txtSearchDate').val();
                var res = Ajax("Added_SetAutoToranHerum", "SearchDate=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode);
                BuildPageFromDATA();
                if (res[0].res == "1") bootbox.alert("מוגדרים תורנים באזור אחר");
                if (res[0].res == "2") bootbox.alert("כל התורנים נמחקו לכל שבוע זה");
                if (res[0].res == "3") bootbox.alert("כל התורנים שובצו לכל שבוע זה");


            }

            // חתימת משמרת
            if (Type == "6") {
                var SearchDate = $('#txtSearchDate').val();
                var resData = Ajax("Shift_GetRelvantShiftCombo", "SearchDate=" + SearchDate + "&RoleId=" + RoleId);
                $('#ddlRelvantDates').html(GetComboItemsByData(resData, "Value", "Text"));
                $('#txtCloseShift').val("");
                $("#ModalEndShift").modal();
            }



            // רענן נוכחות
            if (Type == "7") {

                SetCurrentPresence();

            }


        }

        function CloseShift() {

            var DateVal = $('#ddlRelvantDates').val();
            var index = DateVal.indexOf("_");
            var ShiftCode = DateVal.substring(index + 1);
            var ShiftDate = DateVal.replace("_" + ShiftCode, "");
            var FreeText = $('#txtCloseShift').val();
            var resData = Ajax("Shift_CloseShift", "ShiftCode=" + ShiftCode + "&ShiftDate=" + ShiftDate + "&UserId=" + UserId + "&FreeText=" + FreeText);

            $("#ModalEndShift").modal("hide");

            // alert(DateVal);

        }

        function OpenAddedHoursModal() {
            var SearchDate = $('#txtSearchDate').val();
            var mydata = Ajax("Assignment_GetAddedHours", "OrgUnitCode=" + OrgUnitCode + "&SearchDate=" + SearchDate);
            $("#dvAddedHoursContainer").html("");
            var ReqHtml = "";
            for (var i = 0; i < mydata.length; i++) {

                ReqHtml = $("#dvAddedHoursTemplate").html();
                ReqHtml = ReqHtml.replace("@FullName", mydata[i].FullName);
                ReqHtml = ReqHtml.replace("@Week", (mydata[i].AddedWeek) ? mydata[i].AddedWeek : "&nbsp;");
                ReqHtml = ReqHtml.replace("@Month", (mydata[i].AddedMonth) ? mydata[i].AddedMonth : "&nbsp;");

                ReqHtml = ReqHtml.replace("@SourceMenuha", (mydata[i].SourceMenuha) ? mydata[i].SourceMenuha : "&nbsp;");
                ReqHtml = ReqHtml.replace("@NightShift", (mydata[i].NightShift) ? mydata[i].NightShift : "&nbsp;");
                ReqHtml = ReqHtml.replace("@AbsenceDay", (mydata[i].AbsenceDay) ? mydata[i].AbsenceDay : "&nbsp;");

                $("#dvAddedHoursContainer").append(ReqHtml);



            }



            $("#ModalAddedHours").modal();

        }

        // פותח מסך מודלי
        function OpenRequiremntsForNonAuto(ShiftCode, ShiftDate) {

            // הוספת דרישה...
            // בהנתן סוג משרת נוכחית וכן תאריך משמרת נוכחית נוכל להביא את כל הדרישות שאינם 
            // שיבוץ אוטמטי


            $("#dvNonAutoRequirements").html("");
            // כאן להביא מהבסיס נתונים את הדרישות הרלוונטיות ואז לשפוך הכל לתוך המודלי של הדרישות....
            var requiremntsNonAutoData = Ajax("Assignment_GetRequiremntsNonAuto", "ShiftCode=" + ShiftCode + "&ShiftDate="
            + ShiftDate + "&OrgUnitCode=" + OrgUnitCode);


            for (var i = 0; i < requiremntsNonAutoData.length; i++) {
                var Html = $("#dvNonAutoAssignTemplate").html();
                Html = Html.replace("@RequirementId", requiremntsNonAutoData[i].RequirementId); //.replace(/@Day/g, requiremntsNonAutoData[i].DayInWeek);
                Html = Html.replace("@EmpQuantity", requiremntsNonAutoData[i].EmpQuantity);
                Html = Html.replace("@RequirementDesc", requiremntsNonAutoData[i].RequirementDesc);
                Html = Html.replace("@RequirementType", requiremntsNonAutoData[i].RequirementType);


                Html = Html.replace("@ShiftDate", ShiftDate);
                Html = Html.replace("@ShiftCode", ShiftCode);

                $("#dvNonAutoRequirements").append(Html);


            }


            if (i > 0)
                $("#spTitleForNonAuto").html(" לחץ על דרישה להוספה ל  " + ShiftDate + " משמרת " + ShiftCode);


            $("#ModalRequires").modal();
        }

        //הסרת עובד מעמדת שיבוץ
        var Selected_EmpNo = "";
        var Selected_Date = "";
        var Selected_AssignmentId = "";
        var Selected_Seq = "";

        function EditRequirmentPosition(e, AssignmentId, IsAuto, Date, ShiftCode, EmpNo, EmpName, AddHour, SourceAssignmentId, Seq, AddedHours, TotalHourInPos) {

            e.cancelBubble = true;

            // עריכת עמדה שאינה אוטמטית
            if (!IsAuto && !EmpNo) {

                Selected_AssignmentId = AssignmentId;
                $("#ModalNonAuto").modal();
                return;
            }

            if (!EmpNo) return;




            //&& SourceAssignmentId != "0"

            AddedHours = AddedHours.replace("ק", "");


            if ((SourceAssignmentId && SourceAssignmentId != "0") || (AddedHours > 0)) {
                EditPosion(AssignmentId, IsAuto, Date, ShiftCode, EmpNo, EmpName, Seq, AddedHours, TotalHourInPos);


                //  if ((!SourceAssignmentId || SourceAssignmentId == "0") && ()  ) {
                //  if ((!SourceAssignmentId && SourceAssignmentId == "0") &&  ) {


            }
            else {
                RemoveWorkerOrRequirment(AssignmentId, IsAuto, Date, ShiftCode, EmpNo, EmpName, Seq, AddedHours, TotalHourInPos);

            }
        }

        function EditPosion(AssignmentId, IsAuto, Date, ShiftCode, EmpNo, EmpName, Seq, AddedHours, TotalHourInPos) {

            Selected_AssignmentId = AssignmentId;
            Selected_Seq = Seq;


            // בדיקה שלא יעבור את ה8 שעות
            if (TotalHourInPos) {

                var AnotherTot = TotalHourInPos - eval(AddedHours);
                var Number = eval(AddedHours) + 8 - eval(TotalHourInPos);

                // במידה וצד אחד מינוס...
                if (AnotherTot < 0) Number = -1 * AnotherTot;
                $("#txtNumberEdit").mask(GetMaskCharByNumber(Number));

            }
            else {
                $("#txtNumberEdit").mask(GetMaskCharByNumber("8"));

            }

            $("#txtNumberEdit").val("");
            $("#txtTitleForAddHour").text(AddedHours + " שעות נוספות ");
            $("#spEditTitle").text(EmpName + ' - ' + Date + ' - משמרת ' + ShiftCode);

            $("#ModalPosition").modal();
        }

        var Selected_TotalHourInPos;

        var Selected_AddHours;

        function RemoveWorkerOrRequirment(AssignmentId, IsAuto, Date, ShiftCode, EmpNo, EmpName, Seq, AddedHours, TotalHourInPos) {

            $('#liChangeTab,.toHide').show();
            $("#txtStartDate,#txtEndDate,#txtStartDateChange,#txtEndDateChange").val(Date);
            $("#txtNumberAbsence").mask(GetMaskCharByNumber("7"));

            // בדיקה שלא יעבור את ה8 שעות

            $("#dvEmpSwap1").html(EmpName);

            // alert();
            if (TotalHourInPos) {
                Selected_TotalHourInPos = TotalHourInPos;
                Selected_AddHours = AddedHours;

                var AnotherTot = Selected_TotalHourInPos - eval(Selected_AddHours);
                $("#txtNumberAbsence").mask(GetMaskCharByNumber(AnotherTot));



            } else {

                Selected_TotalHourInPos = "";
                Selected_AddHours = "";
            }






            // מפעיל את הטאב הראשון
            $("#afirstTab").trigger("click");


            // מאפס את הפרטים בחלון המודלי
            $("#txtNumberAbsence").val("");

            // $('#txtStartDate,#txtEndDate,#txtStartDateChange,#txtEndDateChange').val("");
            $('#chIsPitzul,#chCancel').prop('checked', false);

            // איפוס קומבו העדרות
            $('#ddlAbsenceCode :nth-child(1)').prop('selected', true);







            if (Seq == "1" && !AddedHours) {
                $('#liChangeTab').show();

                // איפוס יוזם ההחלפה קומבו
                $('#ddlCreateChange :nth-child(1)').prop('selected', true);

                // מילוי עובדים אפשריים להחלפה
                var EmpsChangeData = Ajax("Change_GetRelvantsEmployee", "EmpNo=" + EmpNo + "&ShiftDate=" + Date
                                        + "&AssignmentId=" + AssignmentId + "&OrgUnitCode=" + OrgUnitCode);
                $('#ddlWorkerChange').html("" + GetComboItemsByData(EmpsChangeData, "EmpNo", "FullName"));

                // איפוס התראות
                $("#dvChangeAlert").html("");


                // איפוס התראות
                $("#txtChangeReason").val("");



                //$('#ddlWorkerChange :nth-child(1)').prop('selected', true);
            }
            else {

                $('#liChangeTab').hide();
            }

            Selected_EmpNo = EmpNo;
            Selected_Date = Date;
            Selected_AssignmentId = AssignmentId;

            $("#spWorkerTitle").text(EmpName + ' - ' + Date + ' - משמרת ' + ShiftCode);
            $("#ModalWorkerWork").modal();






        }

        function OpenModalAbsensce(AssignmentId, IsAuto, Date, ShiftCode, EmpNo, EmpName, Seq, AddedHours, TotalHourInPos) {

            Selected_EmpNo = EmpNo;
            Selected_Date = Date;
            Selected_AssignmentId = AssignmentId;


            //alert(Date + ' ' + EmpNo + ' ' + EmpName);
            $('#chIsPitzul,#chCancel').prop('checked', false);
            $('#liChangeTab,.toHide').hide();
            $("#spWorkerTitle").text(EmpName.replace("<b>", "").replace("</b>", "") + ' - ' + Date);
            $("#txtStartDate,#txtEndDate").val(Date);


            // איפוס קומבו העדרות
            $('#ddlAbsenceCode :nth-child(1)').prop('selected', true);
            // מפעיל את הטאב הראשון
            $("#afirstTab").trigger("click");
            $("#ModalWorkerWork").modal();
        }

        function DefineIsPitzulEvent() {
            $('#chIsPitzul').change(function () {
                if ($(this).is(":checked")) {

                    if (Selected_TotalHourInPos) {
                        // var AnotherTot = Selected_TotalHourInPos - eval(Selected_AddHours);
                        var Number = eval(Selected_AddHours) + 8 - eval(Selected_TotalHourInPos);
                        $("#txtNumberAbsence").mask(GetMaskCharByNumber(Number));


                        //  var Number = eval(Selected_AddHours) + 8 - eval(Selected_TotalHourInPos);
                        //  $("#txtNumberAbsence").mask(GetMaskCharByNumber(Number));
                    }
                }
                else {

                    if (Selected_TotalHourInPos) {
                        var AnotherTot = Selected_TotalHourInPos - eval(Selected_AddHours);
                        $("#txtNumberAbsence").mask(GetMaskCharByNumber(AnotherTot));
                    }

                }

            });

        }

        function SaveAbsence() {

            var AbsenceHour = $("#txtNumberAbsence").val();
            var AbsenceCode = $("#ddlAbsenceCode").val();
            var StartDate = $('#txtStartDate').val();
            var EndDate = $('#txtEndDate').val();
            var IsPitzul = $('#chIsPitzul').prop("checked");
            var IsCancel = "false"; //$('#chCancel').prop("checked");



            if (AbsenceCode == "0" && !IsPitzul) {
                alert("חובה לבחור סיבה להעדרות");
                return;
            }


            mydata = Ajax("Absence_SetAbsence", "AssignmentId=" + Selected_AssignmentId + "&CurrentDate=" + Selected_Date
            + "&AbsenceHour=" + AbsenceHour + "&StartDate=" + StartDate + "&EndDate=" + EndDate
            + "&AbsenceCode=" + AbsenceCode + "&EmpNo=" + Selected_EmpNo + "&IsPitzul=" + IsPitzul + "&IsCancel=" + IsCancel
            );

            $("#ModalWorkerWork").modal("hide");
            BuildPageFromDATA();


        }

        function SaveWorkerHours() {
            var WorkerHours = $("#txtNumberEdit").val();

            Ajax("Assignment_SetHoursForWorker", "AssignmentId=" + Selected_AssignmentId
            + "&WorkerHours=" + WorkerHours
            + "&Seq=" + Selected_Seq);

            $("#ModalPosition").modal("hide");
            BuildPageFromDATA();


        }

        function DefineDragAndDropEvents() {
            $(".draggable").draggable({
                cancel: ".borrowStyleNoDrag",
                helper: "clone",
                cursor: "move",
                revert: true,
                start: function (event, ui) {
                    // alert($(this).attr("class"));
                    ui.helper.width($(this).width());
                }


            });
            $(".droppable").droppable({

                accept: ".draggable",
                drop: function (event, ui) {

                   debugger
                    var TargetId = $(this).attr("id");
                    var SourceId = ui.draggable.attr("id");



                    var SourceShiftDate = $(ui.draggable).attr("date");
                    var SourceShiftCode = $(ui.draggable).attr("shift");


                    //                    
                    var TargetShiftDate = $(this).attr("date");
                    var TargetShiftCode = $(this).attr("shift");

                    var SourcePrivateQualificationCodes = $(ui.draggable).attr("privateSymbol");
                    var TargetSymbol = $(this).attr("symbol");


                    var SourceDay = $(ui.draggable).attr("day");
                    var TargetDay = $(this).attr("day");


                    var TargetReqQualificationCode = $(this).attr("reqSymbol");



                    // אזהרות לשיבוצים
                    var WorkerName = $("#" + SourceId + '>.spWorkerName:first').text();
                    $("#spWorkerName").text(WorkerName);
                    $("#alert1,#alert2,#alert3,#alert4,#alert5,#alert6,#alert7,#alert8,#alert9").hide();

                  

                    // בא מפעילות ללא שובץ
                    if (TargetId.indexOf("100") != -1 && TargetId.indexOf("dvEmpInShift_") != -1 && SourceId.indexOf("Assignment_") != -1) {

                       
                      
                        SourceId = SourceId.replace("Assignment_", "");
                        var SourceEmpNo = ui.draggable.attr("empno");
                      
                        Ajax("Assignment_InsertManualAssign", "TargetAssignmentId=" + SourceId + "&SourceAssignmentId=&SourceEmpNo=" + SourceEmpNo + "&Type=3");
                        BuildPageFromDATA();

                    }




                    // רק אם יש לעובד כישור מתאים לדרישה
                    if (SourcePrivateQualificationCodes.indexOf(TargetReqQualificationCode) == "-1" && TargetReqQualificationCode != "99999999") {
                        //alert();
                        return;
                    }

                    // בא מלא שובץ לריק
                    if (TargetId.indexOf("Empty") != -1 && SourceId.indexOf("NoAssign") != -1) {

                        // רק לאותו היום 
                        if (TargetShiftDate != SourceShiftDate) {
                            return;
                        }



                        //    alert($(ui.draggable).attr("shiftCode") + "  " + TargetShiftCode);



                        TargetId = TargetId.replace("Empty_", "");
                        SourceId = SourceId.replace("NoAssign_", "");



                        // אם בא מלא שובץ לכיוון משמרת לא שלו יפתח מודלי אם השיבוץ ביוזמת העובד
                        if ($(ui.draggable).attr("shiftCode") != TargetShiftCode) {
                            NoAssign_AssignmentId = TargetId;
                            NoAssign_SourceId = SourceId;
                            $("#spEmpName").text(WorkerName);
                            $("#txtNoAssignChangeReason").val("");
                            $("#ModalChangeType").modal();

                            return;

                        }


                        var Res = Ajax("Assignment_InsertManualAssign", "TargetAssignmentId=" + TargetId + "&SourceAssignmentId=&SourceEmpNo=" + SourceId + "&Type=11");
                        if (Res[0]) {
                            UpdateAlertModal(Res, TargetId, "", SourceId, 1);
                        } else {
                            BuildPageFromDATA();

                        }
                    }

                    // בא ממנוחה לריק
                    if (TargetId.indexOf("Empty") != -1 && SourceId.indexOf("Menua") != -1) {

                        // רק לאותו היום 
                        if (TargetShiftDate != SourceShiftDate) {
                            return;
                        }

                        TargetId = TargetId.replace("Empty_", "");
                        SourceId = SourceId.replace("Menua_", "");

                        var Res = Ajax("Assignment_InsertManualAssign", "TargetAssignmentId=" + TargetId + "&SourceAssignmentId=&SourceEmpNo=" + SourceId + "&Type=12");
                        if (Res[0]) {
                            UpdateAlertModal(Res, TargetId, "", SourceId, 2);
                        } else {
                            BuildPageFromDATA();

                        }

                    }




                    // בא ממנוחה להשלים חצי
                    if (TargetId.indexOf("Assignment") != -1 && SourceId.indexOf("Menua") != -1) {

                        // רק לאותו היום 
                        if (TargetShiftDate != SourceShiftDate) {
                            return;
                        }

                        TargetId = TargetId.replace("Assignment_", "");
                        SourceId = SourceId.replace("Menua_", "");

                        var Res = Ajax("Assignment_InsertManualAssign", "TargetAssignmentId=" + TargetId + "&SourceAssignmentId=&SourceEmpNo=" + SourceId + "&Type=17");
                        if (Res[0]) {
                            UpdateAlertModal(Res, TargetId, "", SourceId, 7);
                        } else {
                            BuildPageFromDATA();

                        }

                    }


                    // בא מלא שובץ להשלים חצי
                    if (TargetId.indexOf("Assignment") != -1 && SourceId.indexOf("NoAssign") != -1) {

                        // רק לאותו היום 
                        if (TargetShiftDate != SourceShiftDate) {
                            return;
                        }

                        TargetId = TargetId.replace("Assignment_", "");
                        SourceId = SourceId.replace("NoAssign_", "");

                        var Res = Ajax("Assignment_InsertManualAssign", "TargetAssignmentId=" + TargetId + "&SourceAssignmentId=&SourceEmpNo=" + SourceId + "&Type=18");
                        if (Res[0]) {
                            UpdateAlertModal(Res, TargetId, "", SourceId, 8);
                        } else {
                            BuildPageFromDATA();

                        }

                    }








                    



                    var IsInnerShift = false;

                    // לא ניתן לגרור מאותו משמרת לעצמה.
                    if (TargetShiftDate == SourceShiftDate && SourceShiftCode == TargetShiftCode) {
                        IsInnerShift = true;
                    }


                    // בא ממלא להשלים חצי
                    if (TargetId.indexOf("Assignment") != -1 && SourceId.indexOf("Assignment") != -1 && !IsInnerShift) {

                        // רק מאותו יום או יום לפני משמרת לילה 
                        if (TargetShiftDate == SourceShiftDate ||
                           (TargetShiftDate != SourceShiftDate &&
                            Math.abs(TargetShiftCode - SourceShiftCode) == 2 &&
                            (Math.abs(SourceDay - TargetDay) == 1 || Math.abs(SourceDay - TargetDay) == 6)
                           )

                           ) {

                            var SourceEmpNo = $(ui.draggable).attr("EmpNo");
                            TargetId = TargetId.replace("Assignment_", "");
                            SourceId = SourceId.replace("Assignment_", "");
                            var Res = Ajax("Assignment_InsertManualAssign", "TargetAssignmentId=" + TargetId + "&SourceAssignmentId=" + SourceId + "&SourceEmpNo=" + SourceEmpNo + "&Type=14");
                            if (Res[0]) {
                                UpdateAlertModal(Res, TargetId, SourceId, SourceEmpNo, 4);
                            } else {
                                BuildPageFromDATA();

                            }

                        }

                    }

                    // בתוך עצמו בא ממלא להשלים ריק
                    if (TargetId.indexOf("Empty") != -1 && SourceId.indexOf("Assignment") != -1 && IsInnerShift) {

                        var SourceEmpNo = $(ui.draggable).attr("EmpNo");
                        TargetId = TargetId.replace("Empty_", "");
                        SourceId = SourceId.replace("Assignment_", "");
                        var Res = Ajax("Assignment_InsertManualAssign", "TargetAssignmentId=" + TargetId + "&SourceAssignmentId=" + SourceId + "&SourceEmpNo=" + SourceEmpNo + "&Type=6");
                        BuildPageFromDATA();



                    }


                    //  בא ממלא להשלים ריק
                    if (TargetId.indexOf("Empty") != -1 && SourceId.indexOf("Assignment") != -1 && !IsInnerShift) {


                        // רק מאותו יום או יום לפני משמרת לילה 
                        if (TargetShiftDate == SourceShiftDate ||
                           (TargetShiftDate != SourceShiftDate &&
                            Math.abs(TargetShiftCode - SourceShiftCode) == 2 &&
                            (Math.abs(SourceDay - TargetDay) == 1 || Math.abs(SourceDay - TargetDay) == 6)
                           )

                           ) {


                            var SourceEmpNo = $(ui.draggable).attr("EmpNo");
                            TargetId = TargetId.replace("Empty_", "");
                            SourceId = SourceId.replace("Assignment_", "");



                            var Res = Ajax("Assignment_InsertManualAssign", "TargetAssignmentId=" + TargetId + "&SourceAssignmentId=" + SourceId + "&SourceEmpNo=" + SourceEmpNo + "&Type=15");
                            if (Res[0]) {
                                UpdateAlertModal(Res, TargetId, SourceId, SourceEmpNo, 5);
                            } else {
                                BuildPageFromDATA();

                            }

                        }

                    }

                }
            });
        }


        var NoAssign_AssignmentId = "";
        var NoAssign_SourceId = "";
        //*****************************************

       

        //הגיע מלא שובץ למשמרת לא לו ביוזמת החברה
        function InsertAsterisk(){

            $("#ModalChangeType").modal('hide');
          
            var Res = Ajax("Assignment_InsertManualAssign", "TargetAssignmentId=" + NoAssign_AssignmentId + "&SourceAssignmentId=&SourceEmpNo=" + NoAssign_SourceId + "&Type=11");
            if (Res[0]) {
              
                UpdateAlertModal(Res, NoAssign_AssignmentId, "", NoAssign_SourceId, 1,"1");
            } 
            else {


                var NoAssignChangeReason = $("txtNoAssignChangeReason").val();
                var resObj = Ajax("Added_SetAsterisk", "AssignmentId=" + NoAssign_AssignmentId + "&Type=1&NoAssignChangeReason=" + NoAssignChangeReason);
                BuildPageFromDATA();
             
            }
       
        }

        //הגיע מלא שובץ למשמרת לא לו ביוזמת העובד
        function SetCreatorWorker() {

            $("#dvUserCreatorChange").html("&nbsp;");
           
            if (RoleId > 3) {
                var NoAssignChangeReason = $("#txtNoAssignChangeReason").val();
                
                if (!NoAssignChangeReason) {
                    $("#dvUserCreatorChange").html("חובה להזין סיבה");
                    return;
                }                    


            }



            var Res = Ajax("Assignment_InsertManualAssign", "TargetAssignmentId=" + NoAssign_AssignmentId + "&SourceAssignmentId=&SourceEmpNo=" + NoAssign_SourceId + "&Type=11");
            if (Res[0]) {
                UpdateAlertModal(Res, NoAssign_AssignmentId, "", NoAssign_SourceId, 1, "2");
            }
            else 
            {


                // עדכון אך ורק רשומה ביוזמת העובד עם סיבה
                var resObj = Ajax("Added_SetAsterisk", "AssignmentId=" + NoAssign_AssignmentId + "&Type=77&NoAssignChangeReason=" + NoAssignChangeReason);
                BuildPageFromDATA();

                $("#ModalChangeType").modal('hide');

            }
       


           
//            var NoAssignChangeReason = $("txtNoAssignChangeReason").val();
//            var resObj = Ajax("Added_SetAsterisk", "AssignmentId=" + NoAssign_AssignmentId + "&Type=1");
//            $("#ModalChangeType").modal('hide');
//            BuildPageFromDATA();

        }

        //***************************************** 

        var Alert_TargetId = "";
        var Alert_SourceAssignmentId = "";
        var Alert_SourceId = "";
        var Alert_Type = "";
        var Alert_IsFromModalChangeType = "";

        function UpdateAlertModal(Res, TargetId, SourceAssignmentId, SourceId, Type, IsFromModalChangeType) {
          
            // if (Res[0]) {
            Alert_TargetId = TargetId;
            Alert_SourceAssignmentId = SourceAssignmentId;
            Alert_SourceId = SourceId;
            Alert_Type = Type;
            Alert_IsFromModalChangeType = IsFromModalChangeType; 

            for (var i = 0; i < Res.length; i++) {
             
                $("#alert" + Res[i].ResId).show();
            }

            $("#ModalChangeType").modal('hide');

            $("#ModalAlert").modal();

            

        }

        function InsertAlertManualAssign() {
           
            Ajax("Assignment_InsertManualAssign", "TargetAssignmentId=" + Alert_TargetId + "&SourceAssignmentId=" + Alert_SourceAssignmentId + "&SourceEmpNo=" + Alert_SourceId + "&Type=" + Alert_Type);

            //1 ביוזמת חברה
            if (Alert_IsFromModalChangeType == "1") {
                var NoAssignChangeReason = $("#txtNoAssignChangeReason").val();
                var resObj = Ajax("Added_SetAsterisk", "AssignmentId=" + Alert_TargetId + "&Type=1&NoAssignChangeReason=" + NoAssignChangeReason);

            }

            //2 ביוזמת עובד
            if (Alert_IsFromModalChangeType == "2") {
               
                var NoAssignChangeReason = $("#txtNoAssignChangeReason").val();
                var resObj = Ajax("Added_SetAsterisk", "AssignmentId=" + Alert_TargetId + "&Type=77&NoAssignChangeReason=" + NoAssignChangeReason);
                $("#ModalChangeType").modal('hide');


            }
            
            
            
            BuildPageFromDATA();
            $("#ModalAlert").modal('hide');


        }

        function OpenAbsenceDetails(EmpNo, EmpName, Date) {

            $('#txtStartDateAbsence,#txtEndDateAbsence').val(Date);
            Selected_EmpNo = EmpNo;
            $("#spEmpDetails").text(EmpName);
            $("#ModalAbsence").modal();



        }

        function SaveCancelAbsence() {
            var StartDate = $('#txtStartDateAbsence').val();
            var EndDate = $('#txtEndDateAbsence').val();

            mydata = Ajax("Absence_CancelAbsence", "EmpNo=" + Selected_EmpNo + "&StartDate=" + StartDate
            + "&EndDate=" + EndDate);

            $("#ModalAbsence").modal("hide");
            BuildPageFromDATA();

        }

        function SaveChange(isNoValidation) {

        
            $("#dvEmpSwap2").html($('#ddlWorkerChange option:selected').text());
             
            var SwapCode = $('#ddlCreateChange').val();
            var EmpNoChange = $('#ddlWorkerChange').val();
            var StartDate = $('#txtStartDateChange').val();
            var EndDate = $('#txtEndDateChange').val();
            var ChangeReason = $('#txtChangeReason').val();



            // אם ביוזמת העובד וגם יוזר שהוא מפקח וגם אין סיבה
            if (EmpNoChange == "0" || !StartDate || !EndDate || (SwapCode == "1" && !ChangeReason && RoleId > 3)) {
                $("#dvChangeAlert").html(" נא למלא את כל השדות");
            }
            else 
            {


             

                $("#dvChangeAlert").html("");
                var changeRes = Ajax("Change_SetChange", "EmpNo=" + Selected_EmpNo + "&EmpNoChange=" + EmpNoChange
                    + "&StartDate=" + StartDate + "&EndDate=" + EndDate + "&SwapCode=" + SwapCode + "&ChangeReason=" + ChangeReason + "&isNoValidation=" + isNoValidation );

             

                var res = changeRes[0].res;



                if (res == 1) {
                    $("#ModalWorkerWork").modal("hide");
                    BuildPageFromDATA();
                }
                if (res == 2) {
                    $("#dvChangeAlert").html("לא ניתן להחליף עובד עם סידור שאינו זהה");
                }

                if (res == 3) {
                    $("#dvChangeAlert").html(" לא ניתן להחליף עובד יותר מפעם אחת");
                }


                if (isNoValidation) {

                    $("#ModalAlertSwap").modal("hide");
                    return;
                }

                // צחי הוסיף בדיקה של כל הוולידציות בעת החלפה

                $("[id^='swapAlert']").hide();
                $("[id^='dvEmpSwap']").hide();
                var isSwapAlert = false;
                for (var i = 0; i < changeRes.length; i++) {

                    if (changeRes[i].EmpNoErrors != "0") {
                        isSwapAlert = true;
                        $("#dvEmpSwap1").show();
                        var err1 = changeRes[i].EmpNoErrors.split(",");
                        for (var j = 1; j < err1.length; j++) {
                           
                            var datePrefix = "<b>" + changeRes[i].ShiftDate + "</b> - "; 
                           
                            $("#swapAlert1" + err1[j]).html(datePrefix + ($("#swapAlert1" + err1[j]).html()).replace(datePrefix,"")); 
                            $("#swapAlert1" + err1[j]).show();
                           
                        }

                    }

                    if (changeRes[i].EmpNo2Errors != "0") {
                        isSwapAlert = true;
                        $("#dvEmpSwap2").show();
                        var err2 = changeRes[i].EmpNo2Errors.split(",");
                        for (var j = 1; j < err2.length; j++) {
                            var datePrefix2 = "<b>" + changeRes[i].ShiftDate2 + "</b> - "; 
                            $("#swapAlert2" + err2[j]).html(datePrefix2 + ($("#swapAlert2" + err2[j]).html()).replace(datePrefix2,""));
                            $("#swapAlert2" + err2[j]).show();

                        }
                    }

                }




                if (isSwapAlert) {
                
                    $("#ModalAlertSwap").modal();
                    return;
                }



                


            


            }

        }

        // בחירה של אחת הדרישות שאינה אוטמטי
        var Added_RequirementId = "";
        var Added_ShiftDate = "";
        var Added_ShiftCode = "";
        // var Added_RequirementId = "";

        function ChooseRequirementNonAuto(RequirementId, ShiftDate, ShiftCode, RequirementType) {


            Added_RequirementId = RequirementId;
            Added_ShiftDate = ShiftDate;
            Added_ShiftCode = ShiftCode;


            // RequirementType - 1 עבודת חריגה
            // RequirementType - 2 הדרכות פנים

            if (RequirementType == "1") {

                $("#ddlHariga").val("0");
                $("#txtFreeHariga").val("");
                $("#ModalHariga").modal();

            }

            else if (RequirementType == "2") {

                $("#ddlHad").val("0");
                $("#txtFreeHad").val("");
                $("#ModalHad").modal();

            }


            else {

                SaveAllAddNonAuto("", "", "", "");

            }

        }

        function SaveAllAddNonAuto(HarigaId, HarigaFree, HadId, HadFree) {


            var reqNonAutoData = Ajax("Assignment_InsertRequiremntsNonAutoToAssignment",
                    "RequirementId=" + Added_RequirementId + "&ShiftCode=" + Added_ShiftCode + "&ShiftDate="
                   + Added_ShiftDate + "&OrgUnitCode=" + OrgUnitCode
                   + "&HarigaId=" + HarigaId + "&HarigaFree=" + HarigaFree
                   + "&HadId=" + HadId + "&HadFree=" + HadFree

                   );


            if (reqNonAutoData[0].res == "1") {
                $("#ModalRequires").modal("hide");
                BuildPageFromDATA();

            }


        }

        function SaveHariga() {


            var HarigaId = $("#ddlHariga").val();
            var HarigaFree = $("#txtFreeHariga").val();


            if (HarigaId == "0") {

                alert("חובה לבחור סיבה");
                return;
            }



            SaveAllAddNonAuto(HarigaId, HarigaFree, "", "");
            $("#ModalHariga").modal("hide");

        }

        function SaveHad() {
            var HadId = $("#ddlHad").val();
            var HadFree = $("#txtFreeHad").val();


            if (HadId == "0") {

                alert("חובה לבחור סיבה");
                return;
            }



            SaveAllAddNonAuto("", "", HadId, HadFree);
            $("#ModalHad").modal("hide");


        }

        function SaveNonAutoPosion(Type) {
            var resUpdate = Ajax("Assignment_SetNonAutoPosion", "AssignmentId=" + Selected_AssignmentId + "&Type=" + Type);
            //   if (resUpdate[0].res == "1") {
            $("#ModalNonAuto").modal("hide");
            BuildPageFromDATA();

            // }
        }

        function PrintPage() {


            var Template = $("#dvPrintTemplate").html();

            var root = $(".dvDayContainer");

            root.each(function (index, element) {

                if (index == 7) return;

                var DayElement = $(this).find(".spDayTitle"); //.html();
                var DayDate = $(DayElement).attr("date");
                var Day = $(DayElement).html();

                //alert(Day);
                Template = Template.replace("@Day" + index, Day.replace('יום', '') + ' - <b>' + DayDate + '<b>');


                var ShiftWorkersPanels = $(this).find(".dvPanelShift");

                ShiftWorkersPanels.each(function (indexShift, elementS) {

                    var names = "";
                    var ShiftWorkersNames = $(this).find(".spWorkerName");
                    ShiftWorkersNames.each(function (indexEMP, elementEMP) {

                        var name = $(this).text();
                        var prev = $(this).prev().text();
                        var next = $(this).next().next().text();


                        var prevClass = $(this).prev().attr('class');

                        if (name && $.trim(name) != "") {



                            if (indexShift < 3) {

                                var addClass = "";
                                if (prevClass == "spJobSignToranHerum") {

                                    addClass = "spToran";
                                }


                                prev = prev.replace("E", "").replace("כ", "");

                                names = names + "<div class='spJobSign'>" + prev + "</div><div class='spName " + addClass + "'>"
                                + name + "<span class='addHours'>" + next + "</span></div>";

                            }
                            else {

                                names = names + "<div class='spJobSign' style='width:28%'>" + prev + "</div>"
                               + " <div class='spName' style='width:65%'>" + name + "</div>";


                            }







                        }

                    });


                    Template = Template.replace("@ShiftWorker" + indexShift + index, names);

                });



            });

            PrintDiv(Template, $(".spToolBarTitle").text());


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
                            אזור א'</span> <a class="note-plus menuAssign" onclick="OpenTitleClick(3)"><i class="fa fa-print">
                            </i>&nbsp;הדפסה &nbsp; </a>
                            <a class="note-plus menuAssign" id="menuAssignAuto" onclick="OpenTitleClick(1)">
                                <i class="glyphicon glyphicon-ok-circle"></i>שיבוץ חוסרים אוטמטי </a><a class="note-plus menuAssign"
                                    onclick="OpenTitleClick(2)"><i class="fa fa-search"></i>&nbsp;חיפוש שבוע &nbsp;
                                </a><a class="note-plus menuAssign" onclick="OpenTitleClick(4)"><i class="glyphicon glyphicon-dashboard">
                                </i>&nbsp;שעות נוספות &nbsp; </a><a class="note-plus menuAssign" onclick="OpenTitleClick(5)">
                                    <i class="glyphicon glyphicon-volume-up"></i>&nbsp;שיבוץ תורנים &nbsp;
                        </a><a class="note-plus menuAssign" onclick="OpenTitleClick(6)"><i class="glyphicon glyphicon-ok-circle">
                        </i>&nbsp;חתימת משמרת &nbsp; </a><a class="note-plus menuAssign" onclick="OpenTitleClick(7)">
                            <i class="glyphicon glyphicon-user"></i>&nbsp;רענן נוכחות &nbsp; </a>
                        <%--<a class="note-plus menuAssign" onclick="OpenTitleClick(2)">
                                   <i class="fa fa-search"></i>&nbsp;חיפוש שבוע &nbsp;
                            </a>
                        --%>
                    </h3>
                </div>
                <div id="dvMainContainer" class="panel-body" style="padding: 0px">
                </div>
            </div>
        </div>
    </div>
    <%--  חלון מודלי--%>
    <div class="modal fade" id="ModalSearch" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title " id="spModalTasksTitle">
                        חיפוש שבוע
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
                        <button type="button" class="btn btn-info btn-round" onclick="SearchByWeek();">
                            <i class="glyphicon glyphicon-search"></i>&nbsp; <span>חפש</span>
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
    <%--  חלון מודלי של דרישות שאינם אוטמטיות--%>
    <div class="modal fade" id="ModalRequires" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        <span id="spTitleForNonAuto">אין דרישות מתאימות למשמרת ותאריך זה</span>
                    </h4>
                </div>
                <div class="modal-body">
                    <div class="row" id="dvNonAutoRequirements">
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
    <div class="modal fade" id="ModalWorkerWork" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        עובד - <span id="spWorkerTitle"></span>
                    </h4>
                </div>
                <div class="modal-body" id="Div3">
                    <!-- Nav tabs -->
                    <ul class="nav nav-tabs icon-tab">
                        <li class="active"><a id="afirstTab" href="#tab1Absence" data-toggle="tab"><i class="fa fa-home">
                        </i><span>&nbsp;העדרויות&nbsp; </span></a></li>
                        <li id="liChangeTab"><a href="#tab2Change" data-toggle="tab"><i class="fa fa-user"></i>
                            <span>&nbsp;החלפות&nbsp; </span></a></li>
                        <%-- <li><a href="#tab3Special" data-toggle="tab"><i class="fa fa-envelope-o"></i><span>&nbsp;קריאה
                            מיוחדת&nbsp;</span></a></li>--%>
                    </ul>
                    <!-- Tab panes -->
                    <div class="tab-content tab-border" style="float: right">
                        <div class="tab-pane fade in active" id="tab1Absence">
                            <div class="col-md-12 toHide">
                                <b style="text-decoration: underline">העדרות שעות משמרת נוכחית </b>
                            </div>
                            <div class="col-md-6 toHide">
                                <div class="form-group">
                                    <label>
                                        מספר שעות היעדרות למשמרת</label>
                                    <input type="text" placeholder="מספר שעות  (1-7) " id="txtNumberAbsence" name="txtNumberAbsence"
                                        class="form-control">
                                </div>
                            </div>
                            <div class="col-md-3 toHide">
                                <br />
                                <label class="checkbox">
                                    <input type="checkbox" id="chIsPitzul" value="1">
                                    פיצול משמרת
                                </label>
                            </div>
                            <div class="col-md-3 toHide">
                                <br />
                                <%-- <label class="checkbox">
                                    <input type="checkbox" id="chCancel" value="1"> ביטול שעות העדרות
                                </label>--%>
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
                                <b style="text-decoration: underline">סיבת העדרות</b>
                            </div>
                            <div class="col-md-6">
                                <select id="ddlAbsenceCode" class="form-control">
                                    <option value="0">-- בחר סיבה --</option>
                                </select>
                            </div>
                            <div class="col-md-6" style="text-align: left">
                                <button type="button" class="btn btn-info btn-round" onclick="SaveAbsence()">
                                    <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>עדכן היעדרות</span>
                                </button>
                            </div>
                        </div>
                        <div class="tab-pane fade" id="tab2Change">
                            <div class="col-md-6">
                                <span class="help-block m-b-none">תאריך התחלת החלפה </span>
                                <div class="input-group ls-group-input">
                                    <input type="text" id="txtStartDateChange" class="form-control">
                                    <span class="input-group-addon spDateIcon"><i class="fa fa-calendar"></i></span>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <span class="help-block m-b-none">תאריך סיום החלפה</span>
                                <div class="input-group ls-group-input">
                                    <input type="text" id="txtEndDateChange" class="form-control">
                                    <span class="input-group-addon spDateIcon"><i class="fa fa-calendar"></i></span>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <b style="text-decoration: underline">שם עובד להחלפה</b>
                            </div>
                            <div class="col-md-6">
                                <b style="text-decoration: underline">יוזם החלפה</b>
                            </div>
                            <div class="col-md-6">
                                <select id="ddlWorkerChange" class="form-control">
                                </select>
                            </div>
                            <div class="col-md-6">
                                <select id="ddlCreateChange" class="form-control">
                                </select>
                            </div>
                                        <div class="col-md-12">
                                &nbsp;</div>
                                  <div class="col-md-12">
                               <b style="text-decoration: underline">סיבת החלפה</b></div>
                            <div class="col-md-12" >
                              <textarea id="txtChangeReason" class="form-control" ></textarea>
                            </div>


                            <div class="col-md-12">
                                &nbsp;</div>
                            <div class="col-md-9 dvMessageRed" id="dvChangeAlert">
                                &nbsp;
                            </div>
                            <div class="col-md-3" style="text-align: left">
                                <button type="button" class="btn btn-info btn-round" onclick="SaveChange()">
                                    <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>עדכן החלפה</span>
                                </button>
                            </div>
                        </div>
                        <%--     <div class="tab-pane fade" id="tab3Special">
                            <div class="col-md-9" style="padding-right: 25px">
                                <label class="checkbox">
                                    <input type="checkbox" id="ch" value="1">קריאה מיוחדת
                                </label>
                            </div>
                            <div class="col-md-6" style="padding: 5px">
                                <select id="ddlSpecial" class="form-control">
                                    <option value="0">-- בחר סיבה --</option>
                                </select>
                            </div>
                            <div class="col-md-12" style="padding: 5px">
                                <textarea placeholder="טקסט חופשי" class="form-control" id="bio" name="bio"></textarea>
                            </div>
                            <div class="col-md-12" style="text-align: left">
                                <button type="button" class="btn btn-info btn-round" onclick="SaveSpecial()">
                                    <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>עדכן קריאה מיוחדת</span>
                                </button>
                            </div>
                        </div>--%>
                        <div class="clear">
                            &nbsp;</div>
                    </div>
                    <div class="modal-footer">
                        <div class="col-md-12">
                            &nbsp;</div>
                        <div class="btn btn-info" data-dismiss="modal">
                            סגור</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <%-- חלון מודלי של הגדרת העדרות--%>
    <div class="modal fade" id="ModalAbsence" tabindex="3" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        ביטול העדרויות לעובד - <span id="spEmpDetails"></span>
                    </h4>
                </div>
                <div class="modal-body" id="Div9">
                    <div class="col-md-12">
                        <b style="text-decoration: underline">ביטול העדרות בימים </b>
                    </div>
                    <div class="col-md-6">
                        <span class="help-block m-b-none">תאריך התחלת העדרות </span>
                        <div class="input-group ls-group-input">
                            <input type="text" id="txtStartDateAbsence" class="form-control">
                            <span class="input-group-addon spDateIcon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <span class="help-block m-b-none">תאריך סיום העדרות</span>
                        <div class="input-group ls-group-input">
                            <input type="text" id="txtEndDateAbsence" class="form-control">
                            <span class="input-group-addon spDateIcon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>
                    <div class="col-md-6">
                        &nbsp;
                    </div>
                    <div class="col-md-6" style="text-align: left">
                        <button type="button" class="btn btn-info btn-round" onclick="SaveCancelAbsence()">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>בטל היעדרות</span>
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
    <%-- חלון מודלי של הגדרת עובד--%>
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
                    <div class="col-md-12">
                        <div style="text-decoration: underline; direction: ltr; text-align: right" id="txtTitleForAddHour">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <input type="text" placeholder="מספר שעות (1-7) " id="txtNumberEdit" name="txtNumberEdit"
                                class="form-control">
                        </div>
                    </div>
                    <div class="col-md-6" style="text-align: left">
                        <div class="btn btn-info btn-round" onclick="SaveWorkerHours()">
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
    <%-- חלון מודלי של הגדרת עמדה לא אוטמטית--%>
    <div class="modal fade" id="ModalNonAuto" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        עדכון עמדה - ריקה
                    </h4>
                </div>
                <div class="modal-body" id="Div10">
                    <div class="col-md-12">
                        <div style="text-decoration: underline; direction: ltr; text-align: right" id="Div11">
                        </div>
                    </div>
                    <div class="col-md-6" style="padding-bottom: 15px">
                        <div class="btn btn-info btn-round" onclick="SaveNonAutoPosion(1)">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>הסר עמדה זו </span>
                        </div>
                    </div>
                    <div class="col-md-6" style="padding-bottom: 15px">
                        <div class="btn btn-info btn-round" onclick="SaveNonAutoPosion(2)">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>הסר כל העמדות מסוג זה </span>
                        </div>
                    </div>
                    <%--   <div class="col-md-6">
                        <div class="form-group">
                            <input type="text" placeholder="מספר שעות (1-7) " id="txtNumberEditNonAuto" name="txtNumberEditNonAuto"
                                class="form-control">
                        </div>
                    </div>
                    <div class="col-md-6" style="">
                        <div class="btn btn-info btn-round" onclick="SaveWorkerHoursNonAuto(3)">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>עדכן שעות </span>
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
    <%-- חלון מודלי של קריאה מיוחדת--%>
    <div class="modal fade" id="ModalSpeciel" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        קריאה מיוחדת לעובד - <span id="spSpecialTitle"></span>
                    </h4>
                </div>
                <div class="modal-body" id="Div12">
                    <div class="col-md-9" style="padding-right: 25px">
                        <label class="checkbox">
                            <input type="checkbox" id="chIsSpecial" value="1">קריאה מיוחדת
                        </label>
                    </div>
                    <div class="col-md-6" style="padding: 5px">
                        <select id="ddlSpecial" class="form-control">
                            <option value="0">-- בחר סיבה --</option>
                        </select>
                    </div>
                    <div class="col-md-12" style="padding: 5px">
                        <textarea placeholder="טקסט חופשי" class="form-control" autocomplete="on" id="txtFree" name="txtFree"></textarea>
                    </div>
                    <div class="col-md-12" style="text-align: left">
                        <button type="button" class="btn btn-info btn-round" onclick="SaveSpecial()">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>עדכן קריאה מיוחדת</span>
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
    <%-- חלון מודלי של סידור אישי--%>
    <div class="modal fade" id="ModalPrivate" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog modal-lg" style="width:98%">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        סידור אישי לעובד - <span id="spPrivateTitle"></span>
                    </h4>
                </div>
                <div class="modal-body" id="Div15">
                    <div class="col-md-12">
                        <section class="cd-horizontal-timeline" >
                            <div class="timeline" >
                                <div class="events-wrapper" >
                                    <div class="events" >
                                        <ol style="direction: rtl" id="olPrivate">
                                        
                                        </ol>
                                        <span class="filling-line" aria-hidden="true" style="transform: scaleX(1);"></span>
                                    </div>
                                    <!-- .events -->
                                </div>
                                <!-- .events-wrapper -->
                                <ul class="cd-timeline-navigation">
                                    <li><a href="#0" class="prev inactive">Prev</a></li>
                                    <li><a href="#0" class="next">Next</a></li>
                                </ul>
                                <!-- .cd-timeline-navigation -->
                            </div>
                            <!-- .timeline -->
                            <!-- .events-content -->
                        </section>
                        <hr />
                        <div style="text-align:center;font-size:20px;">שעות נוספות <u>שבועי</u> - <span id="spWeekAddedHours" style="color:#428bca;font-size:24px;font-weight:bold">0</span></div>
                        <div style="text-align:center;font-size:20px">שעות נוספות <u>חודשי</u> - <span id="spMonthAddedHours" style="color:#428bca;font-size:24px;font-weight:bold">0</span></div>
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
    <%-- חלון מודלי של עבודה חריגה --%>
    <div class="modal fade" id="ModalHariga" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        הוספת עבודה חריגה
                    </h4>
                </div>
                <div class="modal-body" id="Div13">
                    <div class="col-md-6" style="padding: 5px">
                        <select id="ddlHariga" class="form-control">
                            <option value="0">-- בחר סיבה --</option>
                        </select>
                    </div>
                    <div class="col-md-12" style="padding: 5px">
                        <textarea placeholder="טקסט חופשי" class="form-control" id="txtFreeHariga" name="txtFreeHariga"></textarea>
                    </div>
                    <div class="col-md-12" style="text-align: left">
                        <button type="button" class="btn btn-info btn-round" onclick="SaveHariga()">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>הוסף עבודה חריגה</span>
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
    <%-- חלון מודלי של הדרכות --%>
    <div class="modal fade" id="ModalHad" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        הוספת הדרכה
                    </h4>
                </div>
                <div class="modal-body" id="Div14">
                    <div class="col-md-6" style="padding: 5px">
                        <select id="ddlHad" class="form-control">
                            <option value="0">-- בחר סיבה --</option>
                        </select>
                    </div>
                    <div class="col-md-12" style="padding: 5px">
                        <textarea placeholder="טקסט חופשי" class="form-control" id="txtFreeHad" name="txtFreeHad"></textarea>
                    </div>
                    <div class="col-md-12" style="text-align: left">
                        <button type="button" class="btn btn-info btn-round" onclick="SaveHad()">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>הוסף הדרכה</span>
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
    <%--  חלון מודלי של שעות נוספות--%>
    <div class="modal fade" id="ModalAddedHours" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        <span id="Span1">סיכום שעות נוספות לאזור</span>
                    </h4>
                </div>
                <div class="modal-body">
                    <div>
                        <div class="col-md-2 dvRequireTitle">
                            שם עובד
                        </div>
                        <div class="col-md-2 dvRequireTitle">
                            ש.נ שבועי
                        </div>
                        <div class="col-md-2 dvRequireTitle">
                            ש.נ חודשי
                        </div>
                        <div class="col-md-2 dvRequireTitle">
                            מנוחה
                        </div>
                        <div class="col-md-2 dvRequireTitle">
                            לילות
                        </div>
                        <div class="col-md-2 dvRequireTitle">
                            העדרות
                        </div>
                        <div id="dvAddedHoursContainer" class="dvPanelAddedHours clear">
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-info btn-xs" data-dismiss="modal">
                        סגור</button>
                </div>
            </div>
        </div>
    </div>
    <%-- חלון מודלי של חתימת משמרת --%>
    <div class="modal fade" id="ModalEndShift" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        חתימת משמרת
                    </h4>
                </div>
                <div class="modal-body" id="Div4">
                    <div class="col-md-12" style="padding: 5px">
                        <select id="ddlRelvantDates" class="form-control">
                            <%--<option value="0">-- בחר תאריך --</option>--%>
                        </select>
                    </div>
                    <div class="col-md-12" style="padding: 5px">
                        <textarea placeholder="טקסט חופשי" class="form-control" id="txtCloseShift" name="txtCloseShift"></textarea>
                    </div>
                    <div class="col-md-12" style="text-align: left">
                        <button type="button" class="btn btn-info btn-round" onclick="CloseShift()">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>חתום משמרת!</span>
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
    <%-- חלון מודלי של אזהרות לשיבוץ--%>
    <div class="modal fade" id="ModalAlert" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        <span>אזהרות לשיבוץ העובד - </span><span id="spWorkerName"></span>
                    </h4>
                </div>
                <div class="modal-body" id="Div2">
                    <div class="col-md-12">
                        <div style="text-decoration: underline; font-size: 24px; text-align: right" id="Div5">
                            <h3>
                                שים לב!
                            </h3>
                            <ul>
                                <li id="alert1">עובד זה עבד לילה קודם.</li>
                                <li id="alert2">עובד זה עבד 8 לילות בשבועיים האחרונים .</li>
                                <li id="alert3">עובד זה עבד 7 ימים רצופים.</li>
                                <li id="alert4">עובד זה שובץ יותר מ12 שעות ביממה האחרונה.</li>
                                <li id="alert5">עובד זה נעדר ב3 ימים הקודמים.</li>
                                <li id="alert6">עובד זה משובץ למשמרת בוקר הבאה .</li>
                                <li id="alert7">עובד זה משובץ כבר למשמרת הנוכחית .</li>
                                <li id="alert8">העובד שובץ ליותר מ – 16 שעות נוספות השבוע, נא שבץ עובד אחר.</li>
                                <li id="alert9"> נדרשת הפסקה מינימלית של 8 שעות בין משמרת למשמרת,נא שבץ למשמרת אחרת .</li>

                               


                            </ul>
                        </div>
                    </div>
                    <div class="col-md-6">
                        &nbsp;
                    </div>
                    <div class="col-md-6" style="text-align: left">
                        <div class="btn ls-red-btn btn-round" data-dismiss="modal">
                            <i class="glyphicon glyphicon-remove-sign"></i>&nbsp; <span>ביטול שיבוץ</span>
                        </div>
                        <div class="btn btn-info btn-round" onclick="InsertAlertManualAssign()">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>שבץ בכל זאת</span>
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
  
      <div class="modal fade" id="ModalAlertSwap" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        <span>אזהרות להחלפות העובד </span><span></span>
                    </h4>
                </div>
                <div class="modal-body" id="Div2">

                    <div class="col-md-12">
                         <h3>
                               שים לב, פירוט של אזהרות בהחלפת 2 העובדים

                           </h3>

                    </div>
                    <div class="col-md-12">
                        <div style="text-decoration: underline; font-size: 16px; text-align: right" id="Div5">
                           <h3 id="dvEmpSwap1">
                                אטלי חיים

                           </h3>
                            <ul>
                                <li id="swapAlert11">עובד זה עבד לילה קודם.</li>
                                <li id="swapAlert12">עובד זה עבד 8 לילות בשבועיים האחרונים .</li>
                                <li id="swapAlert13">עובד זה עבד 7 ימים רצופים.</li>
                                <li id="swapAlert14">עובד זה שובץ יותר מ12 שעות ביממה האחרונה.</li>
                                <li id="swapAlert15">עובד זה נעדר ב3 ימים הקודמים.</li>
                                <li id="swapAlert16">עובד זה משובץ למשמרת בוקר הבאה .</li>
                                <li id="swapAlert17">עובד זה משובץ כבר למשמרת הנוכחית .</li>
                                <li id="swapAlert18">העובד שובץ ליותר מ – 16 שעות נוספות השבוע, נא שבץ עובד אחר.</li>
                                <li id="swapAlert19"> נדרשת הפסקה מינימלית של 8 שעות בין משמרת למשמרת,נא שבץ למשמרת אחרת .</li>

                            </ul>
                        </div>
                    </div>
                    <div class="col-md-12">
                     <div style="text-decoration: underline; font-size: 16px; text-align: right" id="Div5">
                           
                           <h3 id="dvEmpSwap2">
                                אטלי שמעון

                           </h3>


                            <ul>
                                <li id="swapAlert21">עובד זה עבד לילה קודם.</li>
                                <li id="swapAlert22">עובד זה עבד 8 לילות בשבועיים האחרונים .</li>
                                <li id="swapAlert23">עובד זה עבד 7 ימים רצופים.</li>
                                <li id="swapAlert24">עובד זה שובץ יותר מ12 שעות ביממה האחרונה.</li>
                                <li id="swapAlert25">עובד זה נעדר ב3 ימים הקודמים.</li>
                                <li id="swapAlert26">עובד זה משובץ למשמרת בוקר הבאה .</li>
                                <li id="swapAlert27">עובד זה משובץ כבר למשמרת הנוכחית .</li>
                                <li id="swapAlert28">העובד שובץ ליותר מ – 16 שעות נוספות השבוע, נא שבץ עובד אחר.</li>
                                <li id="swapAlert29"> נדרשת הפסקה מינימלית של 8 שעות בין משמרת למשמרת,נא שבץ למשמרת אחרת .</li>

                            </ul>
                        </div>
                    </div>
                    <div class="col-md-12" style="text-align: left">
                        <div class="btn ls-red-btn btn-round" data-dismiss="modal">
                            <i class="glyphicon glyphicon-remove-sign"></i>&nbsp; <span>ביטול החלפה</span>
                        </div>
                        <div class="btn btn-info btn-round" onclick="SaveChange(true)">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>החלף בכל זאת</span>
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

    <%-- חלון מודלי של האם ביוזמת עובד או הנהלנ--%>
    <div class="modal fade" id="ModalChangeType" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        <span>הגדרת מי יוזם השיבוץ לעובד - </span><span id="spEmpName"></span>
                    </h4>
                </div>
                <div class="modal-body" id="Div7">
                    <div class="col-md-12">
                        <h4>
                            שים לב!
                            <br />
                            עובד זה לא משובץ למשמרת שלו, אנא בחר האם ביוזמת עובד או החברה.
                        </h4>
                    </div>
                    <div class="col-md-6">
                        <div class="btn btn-info btn-round" onclick="InsertAsterisk()">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>ביוזמת החברה</span>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="btn ls-red-btn btn-round"  onclick="SetCreatorWorker()">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>ביוזמת העובד</span>
                        </div>
                    </div>

                     <div class="col-md-12">
                        &nbsp;</div>
                            <div class="col-md-12">
                               <b style="text-decoration: underline">סיבת הבאת עובד למשמרת שלא שייכת לו</b></div>
                            <div class="col-md-12" >
                              <textarea id="txtNoAssignChangeReason" class="form-control" ></textarea>
                            </div>


                            <div class="col-md-9 dvMessageRed" id="dvUserCreatorChange">
                                &nbsp;
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
    <%-- טמפלט של יום מסויים --%>
    <div id="dvDayTemplate" style="display: none">
        <div class="dvDayContainer">
            <div class="spDayTitle" date="@Date">
                @InWeekDay</div>
            <div class="panel panel-info " date="@Date" dayshiftcode="1">
                <div class="panel-heading" style="padding: 1px;">
                    <h3 class="panel-title">
                        <b>בוקר</b> - @Date  &nbsp;<b style="color:red">@LoozSymbol1</b>
                    </h3>
                </div>
                <div class="panel-body" style="padding: 1px">
                    <div class="dvPanelShift Boker" id="dvEmpInShift_@Day_1">
                    </div>
                    <button class="btn btn-info btnWorker" type="button" onclick="OpenRequiremntsForNonAuto('1','@Date')">
                        הוסף דרישה
                    </button>
                </div>
            </div>
            <div class="panel panel-info" date="@Date" dayshiftcode="2">
                <div class="panel-heading" data-toggle="collapse" data-target="#collapseOne" style="padding: 1px;
                    cursor: pointer">
                    <h3 class="panel-title">
                         <b>צהריים</b> - @Date  &nbsp;<b style="color:red">@LoozSymbol2</b>
                    </h3>
                </div>
                <div class="panel-body" id="Div1" style="padding: 1px">
                    <div class="dvPanelShift AfterBoker" id="dvEmpInShift_@Day_2">
                    </div>
                    <button class="btn btn-info btnWorker" type="button" onclick="OpenRequiremntsForNonAuto('2','@Date')">
                        הוסף דרישה
                    </button>
                </div>
            </div>
            <div class="panel panel-info " date="@Date" dayshiftcode="3">
                <div class="panel-heading" style="padding: 1px;">
                    <h3 class="panel-title">
                       <b>לילה</b> - @Date  &nbsp;<b style="color:red">@LoozSymbol3</b>
                    </h3>
                </div>
                <div class="panel-body" style="padding: 1px">
                    <div class="dvPanelShift AfterBoker" id="dvEmpInShift_@Day_3">
                    </div>
                    <button class="btn btn-info btnWorker" type="button" onclick="OpenRequiremntsForNonAuto('3','@Date')">
                        הוסף דרישה
                    </button>
                </div>
            </div>
            <div class="panel panel-success" date="@Date" dayshiftcode="100">
                <div class="panel-heading" style="padding: 1px;">
                    <h3 class="panel-title">
                        <b>לא שובץ</b> - @Date
                    </h3>
                </div>
                <div class="panel-body dvPanelShift droppable" id="dvEmpInShift_@Day_100" style="padding: 1px">
                </div>
            </div>
            <div class="panel panel-success" date="@Date" dayshiftcode="0">
                <div class="panel-heading" style="padding: 1px;">
                    <h3 class="panel-title">
                        <b>מנוחה</b> - @Date
                    </h3>
                </div>
                <div class="panel-body dvPanelShift" id="dvEmpInShift_@Day_0" style="padding: 1px">
               
                </div>
            </div>
            <div class="panel panel-success" date="@Date" dayshiftcode="99">
                <div class="panel-heading" style="padding: 1px;">
                    <h3 class="panel-title">
                        <b>העדרות</b> - @Date
                    </h3>
                </div>
                <div class="panel-body dvPanelShift" id="dvEmpInShift_@Day_99" style="padding: 1px">
                    <%-- @ShiftAbsenceWorker--%>
                </div>
            </div>
        </div>
    </div>
    <%-- טמפלט של עובד --%>
    <div id="dvEmployeeTemplate" style="display: none">
        <div class="btn @btnTheme btnWorker" date="@Date" reqsymbol="@ReqSymbol" symbol="@Symbol"
            day="@Day" privatesymbol="@privateSymbol" shift="@ShiftCode" empno="@EmpNo" id="Assignment_@AssignmentId"
            onclick='EditRequirmentPosition(event,"@AssignmentId",@IsAuto,"@Date","@ShiftCode","@EmpNo","@EmpName","@AddedHours","@SourceAssignmentId",@Seq,"@AddedHours","@TotalHourInPos")'>
            <span class="@spJobSign">@Symbol</span><span date="@Date" isspecial="@IsSpecial"
                specialfree="@SpecialFree" specialid="@SpecialId" id="spWorkerName_@AssignmentId"
                empno="@EmpNo" phonenum="@PhoneNum" class="spWorkerName spContextMenu ">@EmpName</span>
            <span class="spAddHour presence_@EmpNo_@Day_@ShiftCode presence_@EmpId_@Day_@ShiftCode"></span><span class="spAddHour">
                @AddedHours</span>
            <br />
            <span class="@2spJobSign">@2Symbol</span> <span reqsymbol="@ReqSymbol" date="@Date"
                day="@Day" isspecial="@2IsSpecial" specialfree="@2SpecialFree" specialid="@2SpecialId"
                id="spWorkerName_@2AssignmentId" empno="@2EmpNo" phonenum="@2PhoneNum" class="spWorkerName spContextMenu"
                onclick='EditRequirmentPosition(event,"@2AssignmentId",@IsAuto,"@Date","@ShiftCode","@2EmpNo","@2EmpName","@2AddedHours","@2SourceAssignmentId",@Seq,"@2AddedHours","@TotalHourInPos")'>
                @2EmpName</span> <span class="spAddHour presence_@2EmpNo_@Day_@ShiftCode presence_@2EmpId_@Day_@ShiftCode"></span>
            <span class="spAddHour" onclick='EditRequirmentPosition(event,"@2AssignmentId",@IsAuto,"@Date","@ShiftCode","@2EmpNo","@2EmpName","@2AddedHours","@2SourceAssignmentId",@Seq,"@2AddedHours","@TotalHourInPos")'>
                @2AddedHours</span>
        </div>
    </div>
    <%--טמפלט של עמדה ריקה --%>
    <div id="dvEmptyTemplate" style="display: none">
        <div class="btn @btnTheme templateEmpty btnWorker droppable" reqsymbol="@ReqSymbol"
            symbol="@Symbol" date="@Date" day="@Day" shift="@ShiftCode" id="Empty_@AssignmentId"
            onclick="EditRequirmentPosition(event,'@AssignmentId',@IsAuto,'','','','','','','','','')">
            <span class="@spJobSign">@Symbol</span><span class=""></span>
        </div>
    </div>
    <%-- טמפלט של מנוחה --%>
    <div id="dvMenuaTemplate" style="display: none">
        <div class="btn @btnThemeForOther btnWorker draggable" privatesymbol="@privateSymbol"
            onclick='OpenModalAbsensce("@AssignmentId",@IsAuto,"@Date","@ShiftCode","@EmpNo","@EmpName","@AddedHours","@SourceAssignmentId",@Seq,"@AddedHours","@TotalHourInPos")'
            date="@Date" id="Menua_@EmpNo">
            <span class="spJobSign">@Symbol</span> <span empno="@EmpNo" phonenum="@PhoneNum"
                class="spWorkerName spContextMenuAbsence">@EmpName</span>
        </div>
    </div>
    <%-- טמפלט של לא שובצו--%>
    <div id="dvNoAssignTemplate" style="display: none">
        <div class="btn @btnThemeForOther btnWorker draggable" shiftcode="@Shift" date="@Date"
            privatesymbol="@privateSymbol" onclick='OpenModalAbsensce("@AssignmentId",@IsAuto,"@Date","@ShiftCode","@EmpNo","@EmpName","@AddedHours","@SourceAssignmentId",@Seq,"@AddedHours","@TotalHourInPos");'
            date="@Date" id="NoAssign_@EmpNo">
            <span class="spJobSign">@Symbol</span> <span empno="@EmpNo" phonenum="@PhoneNum"
                class="spWorkerName spContextMenuAbsence">@EmpName</span>
        </div>
    </div>
    <%-- טמפלט של העדרות --%>
    <div id="dvAbsenceTemplate" style="display: none">
        <div class="btn @btnThemeForOther btnWorker" id="Absence_@EmpNo" date="@Date" onclick='OpenAbsenceDetails("@EmpNo","@EmpName","@Date")'>
            <span class="spJobSign">@Symbol</span> <span empno="@EmpNo" phonenum="@PhoneNum"
                class="spWorkerName spContextMenuAbsence">@EmpName</span>
        </div>
    </div>
    <%-- טמפלט של הוספת דרישה לא אוטמטית --%>
    <div id="dvNonAutoAssignTemplate" style="display: none">
        <div class="col-md-6" style="padding: 5px">
            <div class="btn btn-info btn-round" onclick="ChooseRequirementNonAuto('@RequirementId','@ShiftDate','@ShiftCode',@RequirementType)">
                <i class="glyphicon glyphicon-check"></i>&nbsp;<span>@EmpQuantity</span> - &nbsp;<span>@RequirementDesc</span>
            </div>
        </div>
    </div>
    <%-- טמפלט של סידור אישי --%>
    <div id="dvPrivateOrderTemplate" style="display: none">
        <li><a style="font-family: Arial;color:@Color" data-date="@Date" class="older-event @selected">
            <div style="font-weight: bold">
                @StringDate(@Day)</div>
            <div style="font-size:16px;">
               <b> מקור -</b> @SourceShift <br /><b> בפועל -</b> @Shift1</div>
            <div style="font-size:16px;">
                 @Shift2</div>
        </a></li>
    </div>
    <%-- מבנה סמו ימני --%>
    <ul id="contextMenu" class="dropdown-menu dropdown-menu-right" role="menu" style="display: none;">
        <li><a id="li6" tabindex="-1" href="#">פרטי עובד </a></li>
        <li><a id="li7" tabindex="-1" href="#">סידור אישי </a></li>
        <li><a id="li8" tabindex="-1" href="#">סמן קפסולה לעובד</a></li>
        <li><a id="li9" tabindex="-1" href="#">ביטול קפסולה לעובד </a></li>
        <li><a id="li1" tabindex="-1" href="#">קריאה מיוחדת</a></li>
        <li><a id="li2" tabindex="-1" href="#">תורן צוות חירום</a></li>
        <li><a id="li3" tabindex="-1" href="#">ביטול תורן צוות חירום </a></li>
        <li><a id="li4" tabindex="-1" href="#">הוסף * לעובד</a></li>
        <li><a id="li5" tabindex="-1" href="#">ביטול * לעובד </a></li>
        <li class="divider"></li>
        <li><a tabindex="-1" href="#">סגור</a></li>
    </ul>
    <ul id="contextMenuAbsence" class="dropdown-menu dropdown-menu-right" role="menu"
        style="display: none;">
        <li><a id="liAbsence1" tabindex="-1" href="#">פרטי עובד</a></li>
         <li><a id="liAbsence2" tabindex="-1" href="#">סידור אישי </a></li>
        
        <%--  <li><a id="A2" tabindex="-1" href="#"><b>טל'</b>: <span id="spA2EmpPhone">050-5913817</span></a></li>--%>
        <li class="divider"></li>
        <li><a tabindex="-1" href="#">סגור</a></li>
    </ul>
    <%-- טמפלט של הדפסה --%>
    <div id="dvPrintTemplate" style="display: none">
        <style>
            @media print
            {
            
                table
                {
                    table-layout: fixed;
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
            
                .shiftWorker
                {
                    vertical-align: top;
                    padding-bottom: 10px;
                    border: solid 1px gray;
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
        <table cellpadding="1" cellspacing="0" width="100%">
            <tr>
                <td class="tdTitle">
                    @Day0
                </td>
                <td class="tdTitle">
                    @Day1
                </td>
                <td class="tdTitle">
                    @Day2
                </td>
                <td class="tdTitle">
                    @Day3
                </td>
                <td class="tdTitle">
                    @Day4
                </td>
                <td class="tdTitle">
                    @Day5
                </td>
                <td class="tdTitle">
                    @Day6
                </td>
            </tr>
            <tr>
                <td class="shiftTitle">
                    בוקר
                </td>
                <td class="shiftTitle">
                    בוקר
                </td>
                <td class="shiftTitle">
                    בוקר
                </td>
                <td class="shiftTitle">
                    בוקר
                </td>
                <td class="shiftTitle">
                    בוקר
                </td>
                <td class="shiftTitle">
                    בוקר
                </td>
                <td class="shiftTitle">
                    בוקר
                </td>
            </tr>
            <tr>
                <td class="shiftWorker">
                    @ShiftWorker00
                </td>
                <td class="shiftWorker">
                    @ShiftWorker01
                </td>
                <td class="shiftWorker">
                    @ShiftWorker02
                </td>
                <td class="shiftWorker">
                    @ShiftWorker03
                </td>
                <td class="shiftWorker">
                    @ShiftWorker04
                </td>
                <td class="shiftWorker">
                    @ShiftWorker05
                </td>
                <td class="shiftWorker">
                    @ShiftWorker06
                </td>
            </tr>
            <tr>
                <td class="shiftTitle">
                    צהריים
                </td>
                <td class="shiftTitle">
                    צהריים
                </td>
                <td class="shiftTitle">
                    צהריים
                </td>
                <td class="shiftTitle">
                    צהריים
                </td>
                <td class="shiftTitle">
                    צהריים
                </td>
                <td class="shiftTitle">
                    צהריים
                </td>
                <td class="shiftTitle">
                    צהריים
                </td>
            </tr>
            <tr>
                <td class="shiftWorker">
                    @ShiftWorker10
                </td>
                <td class="shiftWorker">
                    @ShiftWorker11
                </td>
                <td class="shiftWorker">
                    @ShiftWorker12
                </td>
                <td class="shiftWorker">
                    @ShiftWorker13
                </td>
                <td class="shiftWorker">
                    @ShiftWorker14
                </td>
                <td class="shiftWorker">
                    @ShiftWorker15
                </td>
                <td class="shiftWorker">
                    @ShiftWorker16
                </td>
            </tr>
            <tr>
                <td class="shiftTitle">
                    לילה
                </td>
                <td class="shiftTitle">
                    לילה
                </td>
                <td class="shiftTitle">
                    לילה
                </td>
                <td class="shiftTitle">
                    לילה
                </td>
                <td class="shiftTitle">
                    לילה
                </td>
                <td class="shiftTitle">
                    לילה
                </td>
                <td class="shiftTitle">
                    לילה
                </td>
            </tr>
            <tr>
                <td class="shiftWorker">
                    @ShiftWorker20
                </td>
                <td class="shiftWorker">
                    @ShiftWorker21
                </td>
                <td class="shiftWorker">
                    @ShiftWorker22
                </td>
                <td class="shiftWorker">
                    @ShiftWorker23
                </td>
                <td class="shiftWorker">
                    @ShiftWorker24
                </td>
                <td class="shiftWorker">
                    @ShiftWorker25
                </td>
                <td class="shiftWorker">
                    @ShiftWorker26
                </td>
            </tr>
            <tr>
                <td class="shiftTitle">
                    מנוחה
                </td>
                <td class="shiftTitle">
                    מנוחה
                </td>
                <td class="shiftTitle">
                    מנוחה
                </td>
                <td class="shiftTitle">
                    מנוחה
                </td>
                <td class="shiftTitle">
                    מנוחה
                </td>
                <td class="shiftTitle">
                    מנוחה
                </td>
                <td class="shiftTitle">
                    מנוחה
                </td>
            </tr>
            <tr>
                <td class="menuaWorker">
                    @ShiftWorker40
                </td>
                <td class="menuaWorker">
                    @ShiftWorker41
                </td>
                <td class="menuaWorker">
                    @ShiftWorker42
                </td>
                <td class="menuaWorker">
                    @ShiftWorker43
                </td>
                <td class="menuaWorker">
                    @ShiftWorker44
                </td>
                <td class="menuaWorker">
                    @ShiftWorker45
                </td>
                <td class="menuaWorker">
                    @ShiftWorker46
                </td>
            </tr>
            <tr>
                <td class="shiftTitle">
                    העדרויות
                </td>
                <td class="shiftTitle">
                    העדרויות
                </td>
                <td class="shiftTitle">
                    העדרויות
                </td>
                <td class="shiftTitle">
                    העדרויות
                </td>
                <td class="shiftTitle">
                    העדרויות
                </td>
                <td class="shiftTitle">
                    העדרויות
                </td>
                <td class="shiftTitle">
                    העדרויות
                </td>
            </tr>
            <tr>
                <td class="menuaWorker">
                    @ShiftWorker50
                </td>
                <td class="menuaWorker">
                    @ShiftWorker51
                </td>
                <td class="menuaWorker">
                    @ShiftWorker52
                </td>
                <td class="menuaWorker">
                    @ShiftWorker53
                </td>
                <td class="menuaWorker">
                    @ShiftWorker54
                </td>
                <td class="menuaWorker">
                    @ShiftWorker55
                </td>
                <td class="menuaWorker">
                    @ShiftWorker56
                </td>
            </tr>
        </table>
    </div>
    <%-- טמפלט של שעות נוספות --%>
    <div id="dvAddedHoursTemplate" style="display: none">
        <div class="col-md-2 dvRequireDetails">
            <b>@FullName </b>
        </div>
        <div class="col-md-2 dvRequireDetails">
            <b>@Week </b>
        </div>
        <div class="col-md-2 dvRequireDetails">
            <b>@Month </b>
        </div>
        <div class="col-md-2 dvRequireDetails">
            <b>@SourceMenuha </b>
        </div>
        <div class="col-md-2 dvRequireDetails">
            <b>@NightShift </b>
        </div>
        <div class="col-md-2 dvRequireDetails">
            <b>@AbsenceDay </b>
        </div>
    </div>
    <script src="../assets/timeline/main.js" type="text/javascript"></script>
</asp:Content>
