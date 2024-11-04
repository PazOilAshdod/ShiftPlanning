<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage/MasterPage.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Hasot_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
 <script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
    <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
    <link href="../assets/css/rtl-css/typeahead.js-bootstrap.css" rel="stylesheet" type="text/css" />
    <script src="../assets/js/bootstrap3-typeahead.min.js" type="text/javascript"></script>
 <script type="text/javascript">

        var mydata;

        var MaslulimData;
        var TaxiCounter;

        $(document).ready(function () {
          

            InitDateTimePickerPlugin('#txtSearchDate',getDateTimeNowFormat(), false, true);


            var data = Ajax("Hasot_GetHasotShiftTimes", "Date=&ShiftId=&Mode=0");

            $("#ddlShift").val(data[0].ShiftId);
         
            //for dev
            // $("#ddlShift").val(1);

            $("#ddlDirection").val(1);


            MaslulimData = Ajax("Hasot_GetMaslulim");
            BuildCombo(MaslulimData, "#ddlMaslulim", "Id", "MaslulDesc");


            for (var i = 0; i < MaslulimData.length; i++) {
                var Items = "";

                if (!MaslulimData[i].City2) {

                    var MaslulDesc = MaslulimData[i].MaslulDesc;

                    if (MaslulimData[i].Sap_Id == "99") {
                        MaslulDesc = "נסיעה מיוחדת";

                    }
                    Items += '<option value="' + MaslulimData[i].City1 + '">' + MaslulDesc + '</option>';
                }


                $("#ddlCity").append(Items);

            }



            $('#txtHourForTaxi').datetimepicker(
            {

                datepicker: false,
                format: 'H:i',
                mask: true,
                step: 15
            });


            $(".modal").draggable({
                handle: ".modal-header"
            });






            $("#ddlShift,#ddlDirection").change(function () {
                FillData();
            });






            FillData();


            $("input.typeahead").click(function () {
                $(this).select();
            });
        });

        function InitTypeHead() {
            $('input.typeahead').typeahead({
                items: 15,
                source: function (query, process) {
                    states = [];
                    map = {};

                    var data = Ajax("Employees_GetEmployeesList", "Type=0&EmpNo=");

                    data.push(
                             { EmpNo: "00000", FullText: "00000 - אורח" }
                        );

                    //  states.push("אורח");
                    //  map["אורח"] = 
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

        }

        function OnDateChange() {

            FillData();
        }

        function SearchEmp(EmpNo) {

            $("#dvNonMaslulEmp").html("");
            var NonMaslulEmpHtml = $("#dvNonMaslulEmpTemplate").html();
            var data = Ajax("Employees_GetEmployeesList", "Type=1&EmpNo=" + EmpNo);
            if (data[0]) {
                NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpNo/g, data[0].EmpNo);
                NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpName/g, data[0].FirstName + ' ' + data[0].LastName);
                NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpCity/g, data[0].City);

                NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@City/g, data[0].CityCode);

                $("#dvNonMaslulEmp").append(NonMaslulEmpHtml);

            }


            if (EmpNo == "00000") {
                NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpNo/g, "0");
                NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpName/g, "אורח");
                NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpCity/g, "נסיעה מיוחדת");

                NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@City/g, "99");

                $("#dvNonMaslulEmp").append(NonMaslulEmpHtml);


            }






            //
            DefineDragAndDropEvents();

            //$('input.typeahead').val("");
            // alert(EmpNo);

        }



        function FillData(Mode) {

            var SearchDate = $('#txtSearchDate').val();


            var DayName = getDayfromDate(SearchDate);

            var ShiftId = $('#ddlShift').val();
            var Dir = $('#ddlDirection').val();

            var DirectionText = $("#ddlDirection option:selected").text().replace(/--/g, "");
            var ShiftText = $("#ddlShift option:selected").text().replace(/--/g, "");

            $("#spDirection").text(SearchDate + " ( " + DayName + ") - " + DirectionText + " - " + ShiftText);

            if (!Mode) Mode = "0";
            mydata = Ajax("Hasot_GetHasot", "SearchDate=" + SearchDate + "&ShiftId=" + ShiftId + "&Dir=" + Dir + "&Mode=" + Mode);



            $("#dvTaxisContainer").html("");
            $("#dvNonMaslulEmpFromDB").html("");

            var PrevMaslulId = "";
            var TaxiId = "";
            TaxiCounter = 0;
            var PassengerInTaxi = 0;
            var PrevHasotTime = "";



            for (var i = 0; i < mydata.length; i++) {
                var MaslulId = mydata[i].MaslulId;

                if (!MaslulId) {

                    var NonMaslulEmpHtml = $("#dvNonMaslulEmpTemplate").html();

                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpNo/g, mydata[i].EmpNo);
                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpName/g, mydata[i].EmpName);
                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpCity/g, mydata[i].City);
                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@City/g, mydata[i].CityCode);

                    $("#dvNonMaslulEmpFromDB").append(NonMaslulEmpHtml);

                    PrevMaslulId = MaslulId;

                    continue;


                }



                if (MaslulId != PrevMaslulId || PassengerInTaxi == 4 || PrevHasotTime != mydata[i].HasotTime) {

                    var TaxiHtml = $("#dvTaxiTemplate" + Dir).html();
                    TaxiHtml = TaxiHtml.replace(/@MaslulDesc/g, mydata[i].MaslulDesc);


                    TaxiHtml = TaxiHtml.replace(/@HasotDate/g, mydata[i].HasotDate);
                    TaxiHtml = TaxiHtml.replace(/@DirTaxi/g, mydata[i].Dir);
                    TaxiHtml = TaxiHtml.replace(/@MaslulId/g, mydata[i].MaslulId);
                    TaxiHtml = TaxiHtml.replace(/@Comment/g, mydata[i].Comment);


                    TaxiHtml = TaxiHtml.replace(/@HasotTime/g, mydata[i].HasotTime);
                    TaxiHtml = TaxiHtml.replace(/@Sap_Id/g, mydata[i].Sap_Id);

                    TaxiHtml = TaxiHtml.replace(/@City1/g, mydata[i].City1);
                    TaxiHtml = TaxiHtml.replace(/@City2/g, mydata[i].City2);

                    TaxiCounter++;
                    TaxiId = "dvTaxi_" + TaxiCounter;
                    TaxiHtml = TaxiHtml.replace(/@TaxiId/g, TaxiId);



                    if (TaxiCounter % 2 == 0) {
                        TaxiHtml += "<div class='col-md-12'><br/></div>";

                    }


                    if (TaxiCounter == 1) {
                        var NoMaslulHtml = $("#dvNoMaslulTemplate").html();

                        TaxiHtml += NoMaslulHtml;

                    }


                    $("#dvTaxisContainer").append(TaxiHtml);




                    PrevMaslulId = MaslulId;
                    PrevHasotTime = mydata[i].HasotTime;
                    PassengerInTaxi = 0;

                }


                var EmpHtml = $("#dvEmpTemplate").html();
                EmpHtml = EmpHtml.replace(/@EmpNo/g, mydata[i].EmpNo);
                EmpHtml = EmpHtml.replace(/@EmpName/g, mydata[i].EmpName);
                EmpHtml = EmpHtml.replace(/@EmpCity/g, mydata[i].City);
                EmpHtml = EmpHtml.replace(/@CityCode/g, mydata[i].CityCode);

                $("#" + TaxiId).append(EmpHtml);

                PassengerInTaxi++;


                if (!mydata[i + 1] || mydata[i + 1].MaslulId != PrevMaslulId || PrevHasotTime != mydata[i + 1].HasotTime) {


                    var EmptyHtml = $("#dvEmptyTemplate").html();

                    for (var j = 0; j < 4 - PassengerInTaxi; j++) {


                        $("#" + TaxiId).append(EmptyHtml);

                    }

                }

            }


            InitTypeHead();
            DefineDragAndDropEvents();

        }

         function PageAction(Type) {

            var SearchDate = $('#txtSearchDate').val();
            var ShiftId = $('#ddlShift').val();
            var Dir = $('#ddlDirection').val();



            // נסיעה לפני
            if (Type == 0) {


                if (ShiftId == 1 && Dir == 0) {

                    $('#ddlDirection').val(1);
                    $('#ddlShift').val(3);

                    $('#txtSearchDate').val(ConvertHebrewDateToJSDATE(SearchDate, -1, "Heb"));
                }

                if (ShiftId == 1 && Dir == 1) {
                    $('#ddlDirection').val(0);
                }

                if (ShiftId == 2 && Dir == 0) {
                    $('#ddlDirection').val(1);
                    $('#ddlShift').val(1);
                }

                if (ShiftId == 2 && Dir == 1) {
                    $('#ddlDirection').val(0);
                }

                if (ShiftId == 3 && Dir == 0) {
                    $('#ddlDirection').val(1);
                    $('#ddlShift').val(2);

                }

                if (ShiftId == 3 && Dir == 1) {
                    $('#ddlDirection').val(0);

                }



                FillData();


            }


            // נסיעה אחרי
            if (Type == 1) {


                if (ShiftId == 1 && Dir == 0) {

                    $('#ddlDirection').val(1);
                    //  $('#ddlShift').val(3);

                    // $('#txtSearchDate').val(ConvertHebrewDateToJSDATE(SearchDate, -1, "Heb"));
                }

                if (ShiftId == 1 && Dir == 1) {
                    $('#ddlDirection').val(0);
                    $('#ddlShift').val(2);
                }

                if (ShiftId == 2 && Dir == 0) {
                    $('#ddlDirection').val(1);

                }

                if (ShiftId == 2 && Dir == 1) {
                    $('#ddlDirection').val(0);
                    $('#ddlShift').val(3);
                }

                if (ShiftId == 3 && Dir == 0) {
                    $('#ddlDirection').val(1);


                }

                if (ShiftId == 3 && Dir == 1) {
                    $('#ddlDirection').val(0);
                    $('#ddlShift').val(1);

                    $('#txtSearchDate').val(ConvertHebrewDateToJSDATE(SearchDate, 1, "Heb"));

                }
                FillData();


            }

            // הוסף מונית
            if (Type == 2) {

                $("#ddlMaslulim").val(0);


                var SearchDate = $('#txtSearchDate').val();


                var DayName = getDayfromDate(SearchDate);

                var ShiftId = $('#ddlShift').val();
                var Dir = $('#ddlDirection').val();

                var DirectionText = $("#ddlDirection option:selected").text().replace(/--/g, "");
                var ShiftText = $("#ddlShift option:selected").text().replace(/--/g, "");

                $("#spDirectionForTaxi").text(SearchDate + " ( " + DayName + ") - " + DirectionText + " - " + ShiftText);




                var data = Ajax("Hasot_GetHasotShiftTimes", "Date=" + SearchDate + "&ShiftId=" + ShiftId + "&Mode=1");


                if (Dir == 0)
                    $('#txtHourForTaxi').val(data[0].StartTime);
                if (Dir == 1)
                    $('#txtHourForTaxi').val(data[0].EndTime);

                $("#spStartTimeShift").text(data[0].StartTime);
                $("#spEndTimeShift").text(data[0].EndTime);

                $("#dvAddAlert").html("");
                $("#ModalTaxi").modal();





            }

        }


        </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="col-md-12">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-th-list"></i>&nbsp; <b>חיפוש קו נסיעה</b>
                    </h3>
                </div>
                <div class="panel-body" style="padding: 8px">
                    <div class="col-md-2">
                        <select id="ddlDirection" class="form-control">
                            <option value="0">-- הלוך --</option>
                            <option value="1">-- חזור --</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <select id="ddlShift" class="form-control">
                            <option value="1">-- בוקר --</option>
                            <option value="2">-- צהריים --</option>
                            <option value="3">-- ערב --</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <div class="input-group ls-group-input" id="parentdiv">
                            <input type="text" class="form-control" id="txtSearchDate">
                            <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <button type="button" class="btn btn-info btn-round" onclick="FillData()">
                            <i class="glyphicon glyphicon-search"></i>&nbsp; <span class="btnAssign">חפש </span>
                        </button>
                    </div>
                    <div class="col-md-2">
                        <div class="btn btn-success btn-round" onclick="ClearData()">
                            <i class="glyphicon glyphicon-user"></i>&nbsp; <span class="btnAssign">אפס נתונים
                            </span>
                        </div>
                    </div>
                    <div class="col-md-1">
                        <div class="btn btn-primary btn-round" onclick="FillData()">
                            <i class="glyphicon glyphicon-floppy-save"></i>&nbsp; <span class="btnAssign">שמור סידור
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-12">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading" style="text-align: center;">
                    <div style="float: left" class="btn btn-info btn-xs btn-round" onclick='PageAction(1)'>
                        נסיעה הבאה <i class="fa fa-arrow-circle-left"></i>
                    </div>
                    <div style="float: LEFT" class="btn btn-info btn-xs btn-round" onclick='PageAction(0)'>
                        <i class="fa fa-arrow-circle-right"></i>&nbsp;נסיעה לפני&nbsp;</div>
                    <div style="float: left" class="btn btn-success btn-xs btn-round" onclick='PageAction(2)'>
                        הוסף מונית <i class="fa fa-taxi"></i>
                    </div>
                    <h3 class="panel-title">
                        <i class="fa fa-taxi"></i><b>&nbsp; תכנון נסיעות לתאריך <span id="spDirection">14.02.2017
                            הלוך - צהריים</span> <span class="spAreaName"></span></b>
                    </h3>
                </div>
                <div class="panel-body" style="padding: 10px">
                    <div class="droppable" id="dvTaxisContainer">
                    </div>
                </div>
            </div>
        </div>
    </div>
    <%-- חלון מודלי של מונית--%>
    <div class="modal fade" id="ModalTaxi" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        הוספת מונית חדשה ל <span id="spDirectionForTaxi"></span>
                    </h4>
                </div>
                <div class="modal-body" id="Div4">
                    <div class="col-md-12" style="padding: 5px">
                        <select id="ddlMaslulim" class="form-control">
                            <option value="0">-- בחר מסלול --</option>
                        </select>
                    </div>
                    <div class="col-md-12" style="padding: 5px">
                        <div class="btn ls-red-btn btn-round">
                            שים לב! השעות הם בין&nbsp; <b><u><span id="spStartTimeShift"></span></u></b>&nbsp;לבין
                            &nbsp;<b><u><span id="spEndTimeShift"></span></u> </b>
                        </div>
                    </div>
                    <div class="col-md-12" style="padding: 5px">
                        שעה
                        <br />
                        <div class="input-group ls-group-input">
                            <input type="text" id="txtHourForTaxi" placeholder="שעה" class="form-control">
                        </div>
                    </div>
                    <div class="col-md-12" style="padding: 5px">
                        הערות
                        <br />
                        <div class="input-group ls-group-input">
                            <input type="text" id="txtComment" placeholder="הערות" class="form-control">
                        </div>
                    </div>
                    <div class="col-md-12" style="text-align: left">
                        <button type="button" class="btn btn-info btn-round" onclick="AddTaxi()">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>הוסף מונית</span>
                        </button>
                    </div>
                    <div class="col-md-12 dvMessageRed" id="dvAddAlert">
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
    <div class="modal fade" id="ModalChangeCity" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        עדכון עיר <span id="Span1"></span>
                    </h4>
                </div>
                <div class="modal-body" id="Div2">
                    <div class="col-md-12" style="padding: 5px">
                        <select id="ddlCity" class="form-control">
                            <option value="0">-- בחר עיר --</option>
                        </select>
                    </div>
                    <div class="col-md-12" style="text-align: left">
                        <button type="button" class="btn btn-info btn-round" onclick="ChangeCityAction()">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>עדכן עיר</span>
                        </button>
                    </div>
                    <div class="col-md-12 dvMessageRed" id="Div3">
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
    <%-- טמפלט של מונית --%>
    <div id="dvTaxiTemplate1" style="display: none">
        <div class="col-md-2">
            <div class="dvTaxiImage">
                <span class="spRightDir">>>>>>>>>>>></span><br />
                <span class="spCityName">-- @Sap_Id --
                    <br />
                    <br />
                    @MaslulDesc </span>
                <div>
                    @Comment</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="row">
                <div class="panel panel-primary" style="margin: 2px">
                    <div class="panel-heading">
                        <div style="float: left" class="btn btn-danger btn-xs btn-round" onclick='DeleteTaxi("@TaxiId")'>
                            הסר מונית</div>
                        <h3 class="panel-title">
                            <i class="fa fa-taxi"></i>&nbsp; שעה: <b>@HasotTime</b>
                        </h3>
                    </div>
                    <div class="panel-body" id="@TaxiId" city1="@City1" city2="@City2" hasottime="@HasotTime"
                        hasotdate="@HasotDate" dirtaxi="@Dir" maslulid="@MaslulId" comment="@Comment"
                        style="padding: 2px;">
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div id="dvTaxiTemplate0" style="display: none">
        <div class="col-md-3">
            <div class="row">
                <div class="panel panel-primary" style="margin: 2px">
                    <div class="panel-heading">
                        <h3 class="panel-title">
                            <div style="float: left" class="btn btn-danger btn-xs btn-round" onclick='DeleteTaxi("@TaxiId")'>
                                הסר מונית</div>
                            <i class="fa fa-taxi"></i>&nbsp; שעה: <b>@HasotTime</b>
                        </h3>
                    </div>
                    <div class="panel-body" id="@TaxiId" city1="@City1" city2="@City2" hasottime="@HasotTime"
                        hasotdate="@HasotDate" dirtaxi="@Dir" maslulid="@MaslulId" comment="@Comment"
                        style="padding: 2px;">
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-2">
            <div class="dvTaxiImage">
                <span class="spRightDir"><<<<<<<<<<<</span><br />
                <span class="spCityName">-- @Sap_Id --
                    <br />
                    <br />
                    @MaslulDesc </span>
                <div>
                    @Comment</div>
            </div>
        </div>
    </div>
    <%-- טמפלט של עובד  --%>
    <div id="dvEmpTemplate" style="display: none">
        <div class="col-md-6 btn btn-info btn-xs btn-round dvBtnWorker dvEmpInTaxi" citycode="@CityCode"
            id="dv_@EmpNo" onclick="DeleteEmpFromTaxi(@EmpNo)">
            @EmpName <span class="badge" onclick="alert();" style="float: left; margin-top: 1px">
                x</span>
        </div>
        <div class="col-md-5">
            <span class="spCity">@EmpCity </span>
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
    <div id="dvNoMaslulTemplate" style="display: none">
        <div class="col-md-2" style="float: left; position: absolute; left: 5px">
            <div class="row">
                <div class="panel panel-primary" style="margin: 2px">
                    <div class="panel-heading">
                        <h3 class="panel-title">
                            <i class="fa fa-taxi"></i>&nbsp; עובדים ללא הסעה
                        </h3>
                    </div>
                    <div class="panel-body" style="padding: 2px;">
                        <div class="col-md-12" style="margin-bottom: 10px; margin-top: 10px;">
                            <input type="text" class="form-control typeahead" spellcheck="false" autocomplete="off"
                                placeholder=" מספר עובד או שם">
                        </div>
                        <div id="dvNonMaslulEmp">
                            &nbsp;
                        </div>
                        <div id="dvNonMaslulEmpFromDB" style="border: solid 1px gray; padding-top: 10px;">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <%-- טמפלט של עובד  --%>
    <div id="dvNonMaslulEmpTemplate" style="display: none">
        <div class="col-md-12 btn btn-info btn-xs btn-round dvBtnWorker draggable" onclick="ChangeCity(@EmpNo)"
            empno="@EmpNo" city="@City">
            @EmpName - <u id="uNonMaslul_@EmpNo" empno="@EmpNo" city="@City">@EmpCity</u>
        </div>
        <%-- <div class="col-md-6">
            <span class="spCity">@EmpCity</span>
        </div>
        --%>
        <div class="clear">
        </div>
    </div>
</asp:Content>