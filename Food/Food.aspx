<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage/MasterPage.master" AutoEventWireup="true"
    CodeFile="Food.aspx.cs" Inherits="Food_Food" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
    <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
    <link href="../assets/css/rtl-css/typeahead.js-bootstrap.css" rel="stylesheet" type="text/css" />
    <script src="../assets/js/bootstrap3-typeahead.min.js" type="text/javascript"></script>

    <script type="text/javascript">

        var mydata;

        //var MaslulimData;
        //var TaxiCounter;

        $(document).ready(function () {


            InitDateTimePickerPlugin('#txtSearchDate', getDateTimeNowFormat(), false, true);

            $(".modal").draggable({
                handle: ".modal-header"
            });

            FillData("init");

            $("input.typeahead").click(function () {
                $(this).select();
            });

        });


        var Holiday = "";
        var ddlShiftCount = 1;
        function setShiftCombo(selectedID) {
            $('#ddlShift').empty();

            var SearchDate = $('#txtSearchDate').val();
            var data = Ajax("Food_GetShiftTimes", "Date=" + SearchDate + "&ShiftId=&Mode=0");

            ddlShiftCount = data.length;
            Holiday = data[0].ValueDesc;
            BuildCombo(data, "#ddlShift", "ShiftId", "ShiftName");

            if (selectedID) {
                $("#ddlShift").val(selectedID);
                return;
            }

            var Selected = data.filter(x => x.SelectedId == 1);
            if (Selected.length > 0)
                $("#ddlShift").val(Selected[0].ShiftId);
            else
                $("#ddlShift").val(data[0].ShiftId);

        }


        function InitTypeHead() {
            $('#input_11.typeahead').typeahead({
                items: 15,
                source: function (query, process) {
                    states = [];
                    map = {};

                    var data = Ajax("Employees_GetEmployeesList", "Type=4&EmpNo=");

                    //data.push(
                    //    { EmpNo: "00000", FullText: "00000 - אורח" }
                    //);

                    //  states.push("אורח");
                    //  map["אורח"] = 
                    $.each(data, function (i, state) {

                        // map[state.EmpNo] = state;
                        map[state.FullText] = state;
                        if (state.GroupCode.substring(0, 3) == "YOM" && state.GroupCode != "YOM12") states.push(state.FullText);
                    });

                    process(states);
                },

                updater: function (item) {

                    var Obj = $(this);

                    var AreaId = Obj[0].$element[0].id;
                    EmpNo = map[item].EmpNo;
                    FullName = map[item].FullName;

                    SearchEmp(EmpNo, FullName, AreaId);

                    return item;
                }

                // onselect: function (obj) { AlertSystem(); }


            });

            $('#input_10.typeahead').typeahead({
                items: 15,
                source: function (query, process) {
                    states = [];
                    map = {};

                    var data = Ajax("Employees_GetEmployeesList", "Type=4&EmpNo=");

                    //data.push(
                    //    { EmpNo: "00000", FullText: "00000 - אורח" }
                    //);

                    //  states.push("אורח");
                    //  map["אורח"] = 
                    $.each(data, function (i, state) {

                        // map[state.EmpNo] = state;
                        map[state.FullText] = state;
                        if (state.GroupCode == "YOM12") states.push(state.FullText);
                    });

                    process(states);
                },

                updater: function (item) {

                    var Obj = $(this);

                    var AreaId = Obj[0].$element[0].id;
                    EmpNo = map[item].EmpNo;
                    FullName = map[item].FullName;

                    SearchEmp(EmpNo, FullName, AreaId);

                    return item;
                }

                // onselect: function (obj) { AlertSystem(); }


            });
            //$('input.typeahead').on('change', function (event) {
            //    $('.typeahead').focus();
            //});

        }

        function OnDateChange() {

            FillData("init");
        }

        function SearchEmp(EmpNo, FullName, AreaId) {

            var RealAreaId = "#" + AreaId;

            $(RealAreaId).focus();


            var ExistEmp = mydata.filter(x => x.EmpNo == EmpNo);
            if (ExistEmp.length > 0) {


                AlertSystem("עובד זה כבר משובץ!");
                window.setTimeout(function () {

                    $(RealAreaId).select(); // או val("")
                }, 100);
                return;

            }




            window.setTimeout(function () {

                $(RealAreaId).select(); // או val("")
            }, 100);





            AreaId = AreaId.replace("input_", "");



            var Counter = $("#divContainerArea_" + AreaId + " .dvEmp").length;
            Counter++;
            var EmpHtml = $("#dvEmpTemplate").html();
            EmpHtml = EmpHtml.replace(/@EmpNo/g, EmpNo);
            EmpHtml = EmpHtml.replace(/@Seq/g, Counter + ".");
            EmpHtml = EmpHtml.replace(/@EmpName/g, FullName);
            EmpHtml = EmpHtml.replace(/@Isdelete/g, "");
            $("#divContainerArea_" + AreaId).append(EmpHtml);

            var SearchDate = $('#txtSearchDate').val();
            mydata = Ajax("Food_GetSetProcedure", "SearchDate=" + SearchDate + "&Type=2&EmpNo="
                + EmpNo + "&AreaId=" + AreaId + "&FoodHeadersId=" + FoodHeadersId);

            SetTotal();


            //  $('.typeahead').typeahead('val', '');

            //AlertSystem(EmpNo);
            //$("#dvNonMaslulEmp").html("");
            //var NonMaslulEmpHtml = $("#dvNonMaslulEmpTemplate").html();
            //var data = Ajax("Employees_GetEmployeesList", "Type=1&EmpNo=" + EmpNo);
            //if (data[0]) {

            //    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpNo/g, data[0].EmpNo);
            //    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpName/g, data[0].FirstName + ' ' + data[0].LastName);
            //    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpCity/g, data[0].City);

            //    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@City/g, data[0].CityCode);

            //    $("#dvNonMaslulEmp").append(NonMaslulEmpHtml);

            //}


            //if (EmpNo == "00000") {
            //    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpNo/g, "0");
            //    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpName/g, "אורח");
            //    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpCity/g, "נסיעה מיוחדת");

            //    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@City/g, "99");

            //    $("#dvNonMaslulEmp").append(NonMaslulEmpHtml);


            //}






            ////
            //DefineDragAndDropEvents();

            //$('input.typeahead').val("");
            // AlertSystem(EmpNo);

        }

        function SetTotal() {

            $("#spTotalFood").text(mydata.filter(x => x.EmpNo).length);

            $("#txtG1").val(mydata[0].TotalGC1);


        }

        var FoodHeadersId = "";

        function FillData(IsComboChange, Type) {

            $("#spAkmash").text("");

            if (!Type) Type = 1;

            if (IsComboChange == "init") setShiftCombo();
            if (IsComboChange != "refresh" && (!IsComboChange || IsComboChange == 3)) setShiftCombo(3);

            var SearchDate = $('#txtSearchDate').val();

            var DayName = getDayfromDate(SearchDate);

            var ShiftId = $('#ddlShift').val();

            // var DirectionText = $("#ddlDirection option:selected").text().replace(/--/g, "");

            var ShiftText = $("#ddlShift option:selected").text().replace(/--/g, "");

            $("#spDirection").text(SearchDate + " ( " + DayName + ") - " + ShiftText + ((Holiday) ? ("-" + Holiday) : ""));


            mydata = Ajax("Food_GetSetProcedure", "SearchDate=" + SearchDate + "&ShiftId=" + ShiftId + "&Type=" + Type);
            FoodHeadersId = mydata[0].FoodHeadersId;

            SetTotal();


            $("#dvContainer").html("");
            // $("#dvNonMaslulEmpFromDB").html("");

            //var PrevMaslulId = "";
            //var TaxiId = "";
            //TaxiCounter = 0;
            //var PassengerInTaxi = 0;
            var PrevId = "";

            var Counter = 0;

            for (var i = 0; i < mydata.length; i++) {
                var AreaId = mydata[i].Id;

                if (PrevId != AreaId) {

                    var Html = $("#dvAreaTemplate").html();
                    var IsEdit = mydata[i].IsEdit;
                    Html = Html.replace(/@Name/g, mydata[i].Name);
                    Html = Html.replace(/@Title/g, mydata[i].Title);
                    Html = Html.replace(/@Id/g, AreaId);
                    // Html = Html.replace(/@AreaId/g, mydata[i].AreaId);
                    Html = Html.replace(/@Isdelete/g, (IsEdit) ? "" : "none");
                    $("#dvContainer").append(Html);

                    PrevId = AreaId;

                    $("#divContainerArea_" + AreaId).html("");

                    Counter = 0;

                }




                //var DefaultSize = mydata[i].DefaultSize;
                // $("#divContainerArea_" + AreaId).html("");
                // for (var j = 0; j < DefaultSize; j++) {


                var EmpName = mydata[i].EmpName;
                if (EmpName) {
                    Counter++;
                    var EmpHtml = $("#dvEmpTemplate").html();
                    EmpHtml = EmpHtml.replace(/@Seq/g, Counter + ".");

                    // אחמש של בטחון
                    if (mydata[i].RequirementAbb == "=" && mydata[i].Id == 7) {
                        $("#spAkmash").text(mydata[i].EmpName);
                    }

                    EmpHtml = EmpHtml.replace(/@EmpNo/g, mydata[i].EmpNo);
                    EmpHtml = EmpHtml.replace(/@EmpName/g, mydata[i].EmpName);
                    EmpHtml = EmpHtml.replace(/@Isdelete/g, (IsEdit) ? "" : "none");
                    $("#divContainerArea_" + AreaId).append(EmpHtml);
                }
                //}



            }






            InitTypeHead();
            //  DefineDragAndDropEvents();

        }

        function PageAction(Type) {

            var SearchDate = $('#txtSearchDate').val();
            var ShiftId = $('#ddlShift').val();




            // נסיעה לפני
            if (Type == 0) {




                if (ShiftId == 1) {

                    $('#ddlShift').val(3);
                    $('#txtSearchDate').val(ConvertHebrewDateToJSDATE(SearchDate, -1, "Heb"));
                    FillData();
                }



                if (ShiftId == 2) {
                    $('#ddlShift').val(1);
                    FillData(true);
                }



                if (ShiftId == 3) {
                    if (ddlShiftCount > 1) {
                        $('#ddlShift').val(2);
                        FillData(true);
                    }
                    else {
                        $('#txtSearchDate').val(ConvertHebrewDateToJSDATE(SearchDate, -1, "Heb"));
                        FillData(3);
                    }
                }





                // FillData(true);


            }


            // נסיעה אחרי
            if (Type == 1) {


                if (ShiftId == 1) {

                    $('#ddlShift').val(2);
                    FillData(true);
                }

                if (ShiftId == 2) {
                    $('#ddlShift').val(3);
                    FillData(true);
                }


                if (ShiftId == 3) {


                    $('#txtSearchDate').val(ConvertHebrewDateToJSDATE(SearchDate, 1, "Heb"));
                    setShiftCombo();
                    if (ddlShiftCount > 1) {
                        $('#ddlShift').val(1);
                        FillData(1);
                    } else {
                        FillData(true);

                    }

                }




            }



        }

        function deleteFromFood(EmpNo) {

            // AlertSystem(EmpNo);

            var SearchDate = $('#txtSearchDate').val();
            mydata = Ajax("Food_GetSetProcedure", "SearchDate=" + SearchDate + "&Type=3&EmpNo="
                + EmpNo + "&FoodHeadersId=" + FoodHeadersId);

            FillData(true);


        }

        function SaveData() {

            var TotalGC1 = $('#txtG1').val();
            var TotalWorker = $('#spTotalFood').text();
            var SearchDate = $('#txtSearchDate').val();

            mydata = Ajax("Food_GetSetProcedure", "SearchDate=" + SearchDate + "&TotalGC1=" + TotalGC1 + "&Type=4&TotalWorker=" + TotalWorker + "&FoodHeadersId=" + FoodHeadersId);
            debugger


            AlertSystem("הנתונים נשמרו בהצלחה!");
        }


        function PrintDoc() {


            mydata.map(function (x) {
                x.IsPrint = false;
                x.SeqNew = null;
                return x
            });

            var FirstDataIsSave = mydata[0].IsSave;

            if (!FirstDataIsSave) {

                $("#ModalAlertRefresh").modal();

                return;
            }


            var Page = 1;

            $("#printContainerDiv").html("");

            var printtemplate = "";

            var printmydata = mydata.filter(x => !x.IsPrint);

            //div[id ^= "player_"]


            while (printmydata.length > 0) {
                // $("#printContainerDiv").html("");

                $("div[id^='Area_']").html("");
                $("#printContainerDiv").html("");
                var PrevId = "";

                var Counter = 0;

                for (var i = 0; i < printmydata.length; i++) {
                    var AreaId = printmydata[i].Id;

                    if (PrevId != AreaId) {


                        if (PrevId == 1 && Counter > 9) $("#Area_" + PrevId).addClass("ExtraH");


                        var Html = $("#printHideAreaTemplate").html();
                        var PageSeq = "";
                        if (Page > 1) PageSeq = " - " + Page;

                        Html = Html.replace(/@Name/g, printmydata[i].Name + PageSeq);
                        //   Html = Html.replace(/@Title/g, printmydata[i].Title);
                        Html = Html.replace(/@Id/g, AreaId);

                        // Html = Html.replace(/@Isdelete/g, (IsEdit) ? "" : "none");
                        $("#printContainerDiv").append(Html);

                        PrevId = AreaId;



                        Counter = 0;

                    }





                    var EmpName = printmydata[i].EmpName;
                    if (EmpName) {
                        Counter++;
                        if (AreaId != 1 && Counter > 9) {
                            printmydata[i].SeqNew = Counter;

                            // if (AreaId == 1) $("#Area_" + AreaId).addClass("ExtraH");
                            continue;
                        }

                        if (AreaId == 1 && Counter > 12) {
                            printmydata[i].SeqNew = Counter;

                            // if (AreaId == 1) $("#Area_" + AreaId).addClass("ExtraH");
                            continue;
                        }
                        //     if (printmydata[i].SeqNew) alert(printmydata[i].SeqNew);

                        var EmpHtml = $("#printHideWorkerTemplate").html();
                        EmpHtml = EmpHtml.replace(/@Seq/g, ((printmydata[i].SeqNew) ? (printmydata[i].SeqNew) : Counter) + ".");
                        printmydata[i].IsPrint = true;

                        //EmpHtml = EmpHtml.replace(/@EmpNo/g, printmydata[i].EmpNo);
                        EmpHtml = EmpHtml.replace(/@EmpName/g, printmydata[i].EmpName);
                        //EmpHtml = EmpHtml.replace(/@Isdelete/g, (IsEdit) ? "" : "none");
                        $("#Area_" + AreaId).append(EmpHtml);


                    }




                }


                var SearchDate = $('#txtSearchDate').val();
                var DayName = getDayfromDate(SearchDate);
                var ShiftText = $("#ddlShift option:selected").text().replace(/--/g, "");
                var AshmashName = $("#spAkmash").text();
                var TotalFood = $("#spTotalFood").text();
                var TotalG1 = $("#txtG1").val();

                var Template = $("#dvPrintTemplate").html();

                Template = Template.replace(/@Day/g, DayName);
                Template = Template.replace(/@ShiftText/g, ShiftText);
                Template = Template.replace(/@Date/g, SearchDate);


                Template = Template.replace(/@TotalFood/g, TotalFood);
                Template = Template.replace(/@TotalG1/g, TotalG1);
                Template = Template.replace(/@AshmashName/g, AshmashName);

                if (!printtemplate)
                    printtemplate = Template;
                else
                    printtemplate = printtemplate + "<div class='footer'>" + Template + "</div>";

                
                printmydata = mydata.filter(x => !x.IsPrint && x.EmpName);

                Page++;

            }



            PrintDivFood(printtemplate, $(".spToolBarTitle").text());


        }


        function RefreshAndSave() {
            FillData("refresh", 5);
            SaveData();
            $("#ModalAlertRefresh").modal('hide');
            $("#ModalAlertSystem").modal('hide');

        }


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <div class="col-md-12">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading" style="text-align: center;">
                    <div style="float: left; margin-right: 2px" class="btn btn-info btn-xs btn-round" onclick='PageAction(1)'>
                        חלוקה הבאה <i class="fa fa-arrow-circle-left"></i>
                    </div>
                    <div style="float: left; margin-right: 50px" class="btn btn-info btn-xs btn-round" onclick='PageAction(0)'>
                        <i class="fa fa-arrow-circle-right"></i>&nbsp;חלוקה קודמת &nbsp;
                    </div>





                    <div style="float: left; margin-right: 12px" class="btn btn-success btn-round btn-xs" onclick="FillData('refresh',5)">
                        <i class="glyphicon glyphicon-refresh"></i>&nbsp; <span class="btnAssign">רענן נתונים
                        </span>
                    </div>
                    <div style="float: left; margin-right: 2px" class="btn btn-primary btn-round btn-xs" onclick="FillData()">
                        <i class="glyphicon glyphicon-search"></i>&nbsp; <span class="btnAssign">חפש </span>
                    </div>

                    <div style="float: left; margin-right: 2px;" class="input-group ls-group-input">
                        <select id="ddlShift" style="background: white; height: 25px" onchange="FillData(true)">
                        </select>
                    </div>




                    <div style="float: left; margin-right: 2px; width: 150px;" class="input-group ls-group-input" id="parentdiv">
                        <input type="text" class="form-control" id="txtSearchDate" style="background: white; height: 25px" />
                        <%--   <span class="input-group-addon"  ><i  class="fa fa-calendar"></i></span>--%>
                    </div>



                    <h3 class="panel-title" style="text-align: right">
                        <i class="fa fa-cutlery"></i><b>&nbsp; תכנון חלוקת אוכל לתאריך <span id="spDirection"></span><span class="spAreaName"></span></b>
                    </h3>





                </div>
                <div class="panel-body" style="padding: 10px">
                    <div class="droppable" id="dvContainer">
                    </div>
                    <div class="clear">
                    </div>

                    <style>
                        .spSummery {
                            font-size: 20px
                        }

                        .spTotal {
                            font-size: 20px;
                        }
                    </style>

                    <div class="alert alert-danger">
                        <span class="spSummery" style=""><u>סיכום-</u> </span>
                        <span class="spSummery">סה"כ כמות מנות שחולקה:</span><span id="spTotalFood" class="badge spTotal"></span>,
                         <span class="spSummery">כמות מנות לעובדי אבטחה G1: </span>
                        <input type="number" style="width: 50px; font-weight: bold" id="txtG1" />,
                        <span class="spSummery">שם אחמ"ש:</span><span class="badge spTotal" id="spAkmash"></span>





                        <div style="float: left; margin-right: 20px; font-weight: bold" class="btn btn-success  btn-round" onclick='PrintDoc()'>
                            הדפס חלוקה <i class="fa fa-print"></i>
                        </div>

                        <div style="float: left; margin-right: 2px" class="btn btn-primary btn-round " onclick="SaveData()">
                            <i class="glyphicon glyphicon-floppy-save"></i>&nbsp; <span class="btnAssign">שמור חלוקה
                            </span>
                        </div>



                    </div>

                </div>
            </div>
        </div>
    </div>


    <%-- טמפלט של אזור חלוקה --%>
    <div id="dvAreaTemplate" style="display: none">

        <div class="col-md-2">
            <div class="row">
                <div class="panel panel-primary" style="margin: 10px; height: 260px; overflow: auto">
                    <div class="panel-heading">

                        <h3 class="panel-title" title="@Title">
                            <i class="fa fa-cutlery"></i>&nbsp;<b>@Name</b>
                        </h3>
                    </div>
                    <div class="panel-body" id="@Id" city1="@City1" city2="@City2" hasottime="@HasotTime"
                        hasotdate="@HasotDate" dirtaxi="@Dir" maslulid="@MaslulId" comment="@Comment"
                        style="padding: 2px;">

                        <div class="" style="margin-bottom: 10px; margin-top: 10px; display: @Isdelete">
                            <input type="text" id="input_@Id" class="form-control typeahead" spellcheck="false" autocomplete="off"
                                placeholder=" מספר עובד או שם" />
                        </div>

                        <div id="divContainerArea_@Id"></div>

                    </div>
                </div>
            </div>
        </div>

    </div>

    <%-- טמפלט של עובד  btn-primary--%>
    <div id="dvEmpTemplate" style="display: none">
        <div class="col-md-1" style="font-weight: bold">
            @Seq
        </div>
        <div class="col-md-9 btn btn-info btn-xs btn-round dvBtnWorker dvEmp" citycode="@CityCode"
            id="dv_@EmpNo">
            @EmpName <span class="badge" onclick="deleteFromFood(@EmpNo)" style="float: left; margin-top: 1px; display: @Isdelete">x</span>

        </div>
        <div class="clear">
        </div>



    </div>
    <%-- טמפלט של ריק --%>
    <div id="dvEmptyTemplate" style="display: none">
        <div class="col-md-6 btn btn-danger btn-xs btn-round dvBtnWorker droppable">
            &nbsp;
        </div>
        <div class="clear">
        </div>
    </div>


    <div class="modal fade" id="ModalAlertRefresh" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">הודעת מערכת
                    </h4>
                </div>
                <div class="modal-body" id="Div2">
                    <div class="col-md-12" style="font-size: 20px">
                        שים לב!<br />
                        עליך לרענן נתונים ולשמור לפני הדפסה.
                    </div>
                    <div class="col-md-6"></div>
                    <div class="col-md-6" style="text-align: left">

                        <div class="btn btn-primary btn-round" onclick="RefreshAndSave()">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>רענון ושמירה</span>
                        </div>
                    </div>
                    <div class="clear">
                        &nbsp;
                    </div>
                </div>
                <div class="modal-footer ">

                    <div class="col-md-12">
                        <button type="button" class="btn btn-info btn-round" data-dismiss="modal">

                            <i class="glyphicon glyphicon-eject"></i>&nbsp; <span>סגור</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <%-- טמפלט של הדפסה --%>
    <div id="dvPrintTemplate" style="display: none">
        <style>
            @media print {
                .footer {
                    page-break-before: always;
                }
                /*  table
                {
                    table-layout: fixed;
                }
                .shiftTitle
                {
                    text-align: center;
                    background-color: silver !important;
                    border: solid 1px gray;
                    -webkit-print-color-adjust: exact;
                }*/

                .divContainerPrint {
                    border: solid 1px black;
                    font-size: 14px;
                    margin-left: 12px;
                    margin-bottom: 10px;
                    width: 22.5%;
                    float: right;
                }

                .ParentdivTitle {
                    width: 100%;
                    height: 30px;
                    font-size: 20px;
                    padding: 3px;
                }

                .divTitle {
                    background-color: lightblue !important;
                    -webkit-print-color-adjust: exact;
                    width: 95%;
                    overflow: hidden;
                    height: 30px;
                    /* float:right;*/
                }



                .dvWorkerListPrint {
                    border-top: solid 1px black;
                    height: 230px;
                    /* float:right;
                     width:100%;
                    */
                }

                .divWorkerContainer {
                    padding: 3px;
                    font-size: 16px;
                }

                .spWorkerName {
                    font-weight: bold;
                }

                .divPrintText {
                    font-size: 20px;
                    margin-bottom: 10px;
                }

                .spPrintText {
                    text-decoration: underline;
                }

                .ExtraH {
                    height: 508px !important;
                }
            }
        </style>


        <table width="100%" style="padding: 0px; margin: 0px">
            <tr>
                <td style="width:50%">
                    <div class="divPrintText" style="">חלוקת מנות אוכל:&nbsp;<span class="spPrintText"> @Day</span>  &nbsp;&nbsp; משמרת:&nbsp;<span class="spPrintText"> @ShiftText</span> </div>

                </td>
                <td></td>
                <td>
                    <div class="divPrintText" style="text-align: left; margin-left: 27px;">תאריך:&nbsp;<span class="spPrintText"> @Date</span> </div>


                </td>

            </tr>

            <tr>
                <td colspan="3">
                    <div id="printContainerDiv">
                    </div>

                </td>


            </tr>
              <tr>
                  <td>
                        <div class="divPrintText" style="">סה"כ כמות מנות שחולקה:&nbsp;<span class="spPrintText">@TotalFood</span> </div>

                  </td>
                 
              </tr>
            <tr>
                  <td>
                        <div class="divPrintText" style="direction: rtl"><span style="float: right">כמות מנות לעובדי אבטחה G1: &nbsp;</span>  <span class="spPrintText">@TotalG1</span> </div>

                  </td>
                  
                 
              </tr>
             <tr>
                  <td>
                         <div class="divPrintText" style="">שם האחמ"ש במשמרת:&nbsp;<span class="spPrintText">@AshmashName</span> </div>

                  </td>
                   <td>
                         

                  </td>
                  <td>
                        <div class="divPrintText" style=" text-align: left; margin-left: 27px;">חתימה:&nbsp;<span class="spPrintText">____________________</span> </div>

                  </td>
                 
              </tr>



        </table>

    </div>

    <div id="printHideAreaTemplate" style="display: none">
        <div class="divContainerPrint">
            <div class="ParentdivTitle">
                <div class="divTitle">@Name</div>

            </div>

            <div class="dvWorkerListPrint" id="Area_@Id">
            </div>
        </div>
    </div>

    <div id="printHideWorkerTemplate" style="display: none">
        <div class="divWorkerContainer"><span class="spWorkerSeq">@Seq</span><span class="spWorkerName">@EmpName</span> </div>
    </div>

</asp:Content>
