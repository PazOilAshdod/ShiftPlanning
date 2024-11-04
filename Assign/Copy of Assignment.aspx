<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage/MasterPage.master" AutoEventWireup="true"
    CodeFile="Copy of Assignment.aspx.cs" Inherits="Assign_Assignment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        var mydata;
        var SelectedAssignmentId;



        $(document).ready(function () {
            //  $(".panel-body").collapse({ toggle: false });

            // new Date(date);
            //  var res = addDays("23.02.16", 3, 1);

            //alert(("02.02.16").split('.')[1] - 1);

            alert(datediff("23.02.16", "23.02.16"));

            ///  var mydata = Ajax("Assign_GetAssignment", "Date=05052015&OrgUnitCode=1");
            // alert(mydata[0].EmpNo);

        });




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
        function RemoveWorker(WorkerId, IsAuto) {


            bootbox.confirm("<b> האם אתה בטוח שברצונך למחוק העובד מהרשימה ?</b> ", function (result) {
                if (result) {

                    // אם זה שיבוץ אוטמטי תסיר רק את השם
                    if (IsAuto) {
                        $("#spWorkerName" + WorkerId).html("&nbsp;");
                        $("#spWorkAddTime" + WorkerId).html("&nbsp;&nbsp;&nbsp;");
                        //TO DO - SEND TO SERVER

                    }
                    // אם הוא ידני צריך להסיר הכל
                    else {

                        $(".dvWorkerContainer" + WorkerId).remove();
                    }
                }

            });


        }



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

        //
        function EditRequirmentPosition(AssignmentId, WorkerId, date, shift, workname, FirstHourAdd, SecHourAdd) {

            $(".spAddTime").html("&nbsp;&nbsp;&nbsp;");
            var Workers = WorkerId.split("_");

            if (FirstHourAdd) {

                //  Workers[0]  
                $("#spWorkAddTime" + Workers[0]).html("+" + FirstHourAdd);
            }

            if (SecHourAdd) {
                $("#spWorkAddTime" + Workers[1]).html("+" + SecHourAdd);

            }



            // alert(res[1]);

            //  
            //   alert(shift);
            // כאן בונים את המסך עם הנתונים המתאימים

            //   if (!workname) alert();
            //    alert(SecHourAdd);
            //    if (isDuplicate) {


            //        bootbox.alert("אם ברצונך לשנות שיבוץ כפול עליך למחוק קודם...");
            //                return;
            //            }



            SelectedAssignmentId = AssignmentId;

            $("#spAddWorkerToPosition").html(date + " " + shift + " - " + workname);

            $("#ModalAssign").modal();
        }


        function RemoveWorkerOrRequirment(AssignmentId, IsAuto, e) {
            //  alert('Remove');


            bootbox.confirm("<b> האם אתה בטוח שברצונך למחוק העובד מהרשימה ?</b> ", function (result) {
                if (result) {

                    // אם זה שיבוץ אוטמטי תסיר רק את השם
                    if (IsAuto) {
                        $("#AssignmentId .spJobSign").html("&nbsp;");
                        $("#AssignmentId .spWorkerName").html("&nbsp;");
                        $("#AssignmentId .spAddHour").html("&nbsp;");


                    }
                    // אם הוא ידני צריך להסיר הכל
                    else {
                        $("#AssignmentId").remove();
                    }




                    //TO DO - SEND TO SERVER
                }

            });


            if (!e) e = window.event;
            e.stopPropagation();



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

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    
</asp:Content>
