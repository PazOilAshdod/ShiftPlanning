<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage/MasterPage.master" AutoEventWireup="true"
    CodeFile="Hasot.aspx.cs" Inherits="Hasot_Hasot" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
    <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
    <link href="../assets/css/rtl-css/typeahead.js-bootstrap.css" rel="stylesheet" type="text/css" />
    <script src="../assets/js/bootstrap3-typeahead.min.js" type="text/javascript"></script>
    <script type="text/javascript">

        var mydata;

        var MaslulimData;
        var TaxiCounter;
        var Hasot_Configure;
        var CityList;
        var CityList;
        var CityValueCode;
        var CityValueDesc;
        var DayConfigureWithShift;
        var IsShowEmpNo = false;

        $(document).ready(function () {



            if (RoleId == 6)
                $('#dvBtnLoadNew').hide();

          

            InitDateTimePickerPlugin('#txtSearchDate', getDateTimeNowFormat(), false, true); //"05.01.2023"   "
            CityList = Ajax("Gen_GetTable", "TableName=Codes&Condition=TableId=17");
            // alert(CurrentMainShiftCode);

            var SearchDate = $('#txtSearchDate').val();






            //בתחילה טוען את המשמרת הנוכחית
            $("#ddlShift").val(CurrentMainShiftCode);//CurrentMainShiftCode
            //for dev
            // $("#ddlShift").val(1);
            // טוען כיוון רק חזור
            $("#ddlDirection").val(1);

            ////fordev
            //InitDateTimePickerPlugin('#txtSearchDate', "02.04.2024", false, true);
            //$("#ddlShift").val(2);
            //$("#ddlDirection").val(0);



            MaslulimData = Ajax("Gen_GetTable", "TableName=Hasot_Maslulim&Condition=");// Ajax("Hasot_GetMaslulim");




            //for (var i = 0; i < MaslulimData.length; i++) {
            //    var Items = "";

            //    if (!MaslulimData[i].City2) {

            //        var MaslulDesc = MaslulimData[i].MaslulDesc;

            //        if (MaslulimData[i].Sap_Id == "99") {
            //            MaslulDesc = "נסיעה מיוחדת";

            //        }
            //        Items += '<option value="' + MaslulimData[i].City1 + '">' + MaslulDesc + '</option>';
            //    }


            //    $("#ddlCity").append(Items);

            //}

            $('#txtHourForTaxi').datetimepicker(
                {

                    datepicker: false,
                    format: 'H:i',
                    mask: true,
                    step: 15,
                    onChangeDateTime: SetRelvantMaslulimOptions
                });







            $(".modal").draggable({
                handle: ".modal-header"
            });






            $("#ddlShift,#ddlDirection").change(function () {
                // FillData();
                OnDateChange();
            });


            Hasot_Configure = Ajax("Gen_GetTable", "TableName=Hasot_Configure&Condition=");



            OnDateChange();


            $("input.typeahead").click(function () {
                $(this).select();
            });


            $(window).scroll(function () {
                $(".dvNoMaslulTemplate").css({
                    "top": ($(window).scrollTop() + 50) + "px",
                    "left": ($(window).scrollLeft() + 20) + "px"
                });

                DefineDragAndDropEvents();
            });
            // debugger
            //  InitTypeHeadOthers();

            //            $("input.typeahead").focus(function () {
            //                // alert("Handler for .focus() called.");
            //              //  $('input.typeahead').typeahead('val', "");
            //            });
        });





        function InitTypeHeadOthers() {

            $('#txtNewOved').typeahead({
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


        function OnDateChange() {


            //var SearchDate = $('#txtSearchDate').val();
            //var ShiftId = $('#ddlShift').val();



            FillData();
        }

        function SearchEmp(EmpNo) {

            $("#dvNonMaslulEmp").html("");
            var NonMaslulEmpHtml = $("#dvNonMaslulEmpTemplate").html();
            var data = Ajax("Employees_GetEmployeesList", "Type=1&EmpNo=" + EmpNo);
            if (data[0]) {

                NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpNo/g, data[0].EmpNo);
                NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpName/g, data[0].FirstName + ' ' + data[0].LastName);

                if (!data[0].CityCodeTemp) {
                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpCity/g, data[0].City);
                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@City/g, data[0].CityCode);
                } else {

                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpCity/g, data[0].CityTemp);
                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@City/g, data[0].CityCodeTemp);

                }


                NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@btnStyle/g, "btn-info");
                NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@TextChange/g, "");



                NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@TempStreet/g, "");
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
            //if (Dir == 0)
            //    $('#dvHazmana').hide();
            //else
            //    $('#dvHazmana').show();

            var DirectionText = $("#ddlDirection option:selected").text().replace(/--/g, "");
            var ShiftText = $("#ddlShift option:selected").text().replace(/--/g, "");

            DayConfigureWithShift = Ajax("Hasot_GetShiftTimes", "Date=" + SearchDate + "&ShiftId=" + ShiftId);


           
            $("#spDirection").text(SearchDate + " ( " + DayName + ") - " + DirectionText + " - " + ShiftText);

            if (!Mode) Mode = "0";
            mydata = Ajax("Hasot_GetHasot", "SearchDate=" + SearchDate + "&ShiftId=" + ShiftId + "&Dir=" + Dir + "&Mode=" + Mode);


            BuildScreen();



        }

        function BuildScreen() {


            $("#dvTaxisContainer").html("");
            $("#dvNonMaslulEmpFromDB").html("");

            var PrevMaslulId = "";
            var TaxiId = "";
            TaxiCounter = 0;
            var PassengerInTaxi = 0;
            var PrevHasotTime = "";
            // var PrevSeq = "";
            var PassengerInCar = 0;
            var ArrayList = [];
            for (var i = 0; i < mydata.length; i++) {
                var MaslulId = mydata[i].MaslulId;

                if (!MaslulId || mydata[i].Status == 2) {

                    var NonMaslulEmpHtml = $("#dvNonMaslulEmpTemplate").html();

                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpNo/g, mydata[i].EmpNo);
                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpName/g, mydata[i].EmpName);

                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@EmpCity/g, mydata[i].City);
                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@City/g, mydata[i].CityCode);
                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@SourceEmpCity/g, mydata[i].City);
                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@SourceCity/g, mydata[i].CityCode);

                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@TempStreet/g, mydata[i].TempStreet);

                    if (mydata[i].TextChange) {
                        NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@btnStyle/g, "btn-warning");
                        NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@TextChange/g, mydata[i].TextChange);
                        //NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@blink_me/g, "blink_me");

                    }

                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@btnStyle/g, "btn-info");
                    NonMaslulEmpHtml = NonMaslulEmpHtml.replace(/@TextChange/g, "");
                    $("#dvNonMaslulEmpFromDB").append(NonMaslulEmpHtml);

                    PrevMaslulId = MaslulId;

                    if (mydata[i].StatusDelete != 1)
                        continue;


                }

                if (ArrayList.indexOf(mydata[i].Seq) == -1) {

                    ArrayList.push(mydata[i].Seq);

                    var SelectedHasot = mydata.filter(x => x.Seq == mydata[i].Seq && (x.Status != 2 || x.StatusDelete == 1));

                    for (var j = 0; j < SelectedHasot.length; j++) {
                        // בניה של המונית או מיניבוס
                        if (j == 0) {
                            var TaxiHtml = $("#dvTaxiTemplate0").html();


                            TaxiHtml = TaxiHtml.replace(/@MaslulDesc/g, SelectedHasot[j].MaslulDesc);
                            TaxiHtml = TaxiHtml.replace(/@HasotDate/g, SelectedHasot[j].HasotDate);
                            TaxiHtml = TaxiHtml.replace(/@DirTaxi/g, SelectedHasot[j].Dir);
                            TaxiHtml = TaxiHtml.replace(/@MaslulId/g, SelectedHasot[j].MaslulId);
                            TaxiHtml = TaxiHtml.replace(/@Comment/g, SelectedHasot[j].Comment);
                            TaxiHtml = TaxiHtml.replace(/@CarSymbol/g, SelectedHasot[j].CarSymbol);

                            TaxiHtml = TaxiHtml.replace(/@mdest/g, SelectedHasot[j].mdest);
                            TaxiHtml = TaxiHtml.replace(/@mprice/g, SelectedHasot[j].mprice);


                            TaxiHtml = TaxiHtml.replace(/@HasotTime/g, SelectedHasot[j].HasotTime);
                            TaxiHtml = TaxiHtml.replace(/@Seq/g, SelectedHasot[j].Seq);
                            TaxiHtml = TaxiHtml.replace(/@CarTypeId/g, SelectedHasot[j].CarTypeId);
                            TaxiHtml = TaxiHtml.replace(/@ExtraSapId/g, SelectedHasot[j].ExtraSapId);




                            var CarTypeId = SelectedHasot[j].CarTypeId;
                            var CarTypeIcon = "taxi";
                            var CarTypeHebrew = "מונית";
                            PassengerInCar = Hasot_Configure[0].TaxiNumber;


                            if (SelectedHasot[j].StatusDelete == 1) {


                                TaxiHtml = TaxiHtml.replace(/@displayChecboxRemove/g, "none");
                                TaxiHtml = TaxiHtml.replace(/@displayChecbox/g, "none");

                                TaxiHtml = TaxiHtml.replace(/@back/g, "silver");



                            } else {
                                TaxiHtml = TaxiHtml.replace(/@displayDeleted/g, "none");

                            }

                            if (CarTypeId == 2) {
                                CarTypeIcon = "bus";
                                CarTypeHebrew = "מיניבוס";
                                PassengerInCar = Hasot_Configure[0].MinibusNumber;

                                if (SelectedHasot[j].CarSymbol)
                                    TaxiHtml = TaxiHtml.replace(/@badge/g, "badge");

                                TaxiHtml = TaxiHtml.replace(/@displayChecbox/g, "none");
                                TaxiHtml = TaxiHtml.replace(/@back/g, "#cc3399");
                                TaxiHtml = TaxiHtml.replace(/@Sap_Id/g, "");

                                TaxiHtml = TaxiHtml.replace(/@HasaNumber/g, "");
                            }

                            if (SelectedHasot[j].Sap_Id == 99) {

                                TaxiHtml = TaxiHtml.replace(/@back/g, "Orange");
                                // TaxiHtml = TaxiHtml.replace(/@Sap_Id/g, "");
                            }

                            TaxiHtml = TaxiHtml.replace(/@HasaNumber/g, pad(SelectedHasot[j].HasaNumber, 4));


                            TaxiHtml = TaxiHtml.replace(/@CarTypeHebrew/g, CarTypeHebrew);
                            TaxiHtml = TaxiHtml.replace(/@CarType/g, CarTypeIcon);


                            TaxiHtml = TaxiHtml.replace(/@Sap_Id/g, SelectedHasot[j].Sap_Id);

                            TaxiHtml = TaxiHtml.replace(/@City1/g, SelectedHasot[j].City1);
                            TaxiHtml = TaxiHtml.replace(/@City2/g, SelectedHasot[j].City2);
                            TaxiHtml = TaxiHtml.replace(/@City3/g, SelectedHasot[j].City3);
                            TaxiHtml = TaxiHtml.replace(/@City4/g, SelectedHasot[j].City4);

                            TaxiCounter++;
                            TaxiId = "dvTaxi_" + TaxiCounter;
                            TaxiHtml = TaxiHtml.replace(/@TaxiId/g, TaxiId);



                            if (TaxiCounter % 3 == 0) {
                                TaxiHtml += "<div class='col-md-12'><br/></div>";

                            }


                            if (TaxiCounter == 1) {
                                var NoMaslulHtml = $("#dvNoMaslulTemplate").html();

                                TaxiHtml += NoMaslulHtml;

                            }


                            $("#dvTaxisContainer").append(TaxiHtml);




                            PrevMaslulId = MaslulId;
                            PrevHasotTime = SelectedHasot[j].HasotTime;
                            PassengerInTaxi = 0;

                        }

                        if (SelectedHasot[j].EmpNo != "0" && SelectedHasot[j].StatusDelete != 1) {

                            var EmpHtml = $("#dvEmpTemplate").html();
                            EmpHtml = EmpHtml.replace(/@HasotId/g, SelectedHasot[j].HasotId);
                            EmpHtml = EmpHtml.replace(/@EmpNo/g, SelectedHasot[j].EmpNo);
                            EmpHtml = EmpHtml.replace(/@EmpName/g, SelectedHasot[j].EmpName + (IsShowEmpNo ? (" " + SelectedHasot[j].EmpNo) : ""));
                            EmpHtml = EmpHtml.replace(/@EmpCity/g, SelectedHasot[j].City);
                            EmpHtml = EmpHtml.replace(/@CityCode/g, SelectedHasot[j].CityCode);
                            EmpHtml = EmpHtml.replace(/@CarTypeId/g, SelectedHasot[j].CarTypeId);
                            EmpHtml = EmpHtml.replace(/@displayNew/g, (SelectedHasot[j].Status >= 3) ? '' : 'none');
                            EmpHtml = EmpHtml.replace(/@TempStreet/g, SelectedHasot[j].TempStreet);
                            EmpHtml = EmpHtml.replace(/@TextChange/g, SelectedHasot[j].TextChange);

                            if (SelectedHasot[j].TextChange) {
                                EmpHtml = EmpHtml.replace(/@btnStyle/g, "btn-warning");
                                EmpHtml = EmpHtml.replace(/@blink_me/g, "blink_me");

                            }

                            if (SelectedHasot[j].IsYom == 1) {
                                EmpHtml = EmpHtml.replace(/@btnStyle/g, "btn-primary");

                            } else {

                                EmpHtml = EmpHtml.replace(/@btnStyle/g, "btn-info");
                            }


                            $("#" + TaxiId).append(EmpHtml);

                            PassengerInTaxi++;
                        }
                        if (SelectedHasot[j].EmpNo != "0" && SelectedHasot[j].StatusDelete == 1) {

                            var Seq = SelectedHasot[j].Seq;
                            //  var TaxiId = $("div[seq='" + Seq + "']").attr("id");

                            var EmpHtml = $("#dvEmpDeletedTemplate").html();

                            EmpHtml = EmpHtml.replace(/@EmpNo/g, SelectedHasot[j].EmpNo);
                            EmpHtml = EmpHtml.replace(/@EmpName/g, SelectedHasot[j].EmpName + (IsShowEmpNo ? (" " + SelectedHasot[j].EmpNo) : ""));
                            EmpHtml = EmpHtml.replace(/@EmpCity/g, SelectedHasot[j].City);
                            EmpHtml = EmpHtml.replace(/@CityCode/g, SelectedHasot[j].CityCode);



                            $("#" + TaxiId).append(EmpHtml);

                        }



                        if ((!SelectedHasot[j + 1] || SelectedHasot[j + 1].Seq != SelectedHasot[j].Seq || PrevHasotTime != SelectedHasot[j + 1].HasotTime)) {


                            $("#" + TaxiId).parent().find(".spCountPassenger").text("-- " + PassengerInTaxi + " --");

                            if (SelectedHasot[j].StatusDelete != 1) {

                                var EmptyHtml = $("#dvEmptyTemplate").html();

                                for (var m = 0; m < PassengerInCar - PassengerInTaxi; m++) {

                                    $("#" + TaxiId).append(EmptyHtml);

                                }

                            }

                        }
                    }
                }


            }


            var DeletedHasot = mydata.filter(x => x.Status == 2 && x.StatusDelete != 1);

            for (var j = 0; j < DeletedHasot.length; j++) {

                var Seq = DeletedHasot[j].Seq;
                var TaxiId = $("div[seq='" + Seq + "']").attr("id");

                var EmpHtml = $("#dvEmpDeletedTemplate").html();

                EmpHtml = EmpHtml.replace(/@EmpNo/g, DeletedHasot[j].EmpNo);
                EmpHtml = EmpHtml.replace(/@EmpName/g, DeletedHasot[j].EmpName + (IsShowEmpNo ? (" " + DeletedHasot[j].EmpNo) : ""));
                EmpHtml = EmpHtml.replace(/@EmpCity/g, DeletedHasot[j].City);
                EmpHtml = EmpHtml.replace(/@CityCode/g, DeletedHasot[j].CityCode);



                $("#" + TaxiId).append(EmpHtml);
            }









            InitTypeHead();
            InitTypeHeadOthers();
            DefineDragAndDropEvents();

        }

        function SetStatus(HasotId) {
            var data = Ajax("Hasot_SetHasot", "EmpId=" + HasotId + "&Mode=11");

            FillData();

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

                MaslulIdSelected = false;
                $('.txtM').hide();
                $("#ddlMaslulim").val("");
                $("#ddlCarType").val(1);
                $('#txtComment').val("");
                $('#txtMdest,#txtMprice').val("");
                var SearchDate = $('#txtSearchDate').val();


                var DayName = getDayfromDate(SearchDate);

                var ShiftId = $('#ddlShift').val();
                var Dir = $('#ddlDirection').val();

                var DirectionText = $("#ddlDirection option:selected").text().replace(/--/g, "");
                var ShiftText = $("#ddlShift option:selected").text().replace(/--/g, "");

                $("#spDirectionForTaxi").text(SearchDate + " ( " + DayName + ") - " + DirectionText + " - " + ShiftText);



               
                // var data = Ajax("Hasot_GetHasotShiftTimes", "Date=" + SearchDate + "&ShiftId=" + ShiftId + "&Mode=1");
                if (Dir == 0)
                    $('#txtHourForTaxi').val(DayConfigureWithShift[0].StartTime);
                if (Dir == 1)
                    $('#txtHourForTaxi').val(DayConfigureWithShift[0].EndTime);





                $("#spStartTimeShift").text(DayConfigureWithShift[0].StartTime);
                $("#spEndTimeShift").text(DayConfigureWithShift[0].EndTime);
                $("#dvAddAlert").html("");


                SetRelvantMaslulimOptions();
                $("#ModalTaxi").modal();
                //  debugger


                //BuildCombo(MaslulimData, "#ddlMaslulim", "Id", "MaslulDesc");


            }

            if (Type == 3) {


                if (SelectAllCheckBox) {
                    $('input:checkbox').prop('checked', false);
                    SelectAllCheckBox = false;
                    $("#spCheckAll").text("סמן כל המוניות");
                } else {
                    $('input:checkbox').prop('checked', true);
                    SelectAllCheckBox = true;
                    $("#spCheckAll").text("בטל כל הסימוני המוניות");
                }


            }

            if (Type != 3) {
                $('input:checkbox').prop('checked', false);
                SelectAllCheckBox = false;
                $("#spCheckAll").text("סמן כל המוניות");
            }
        }



     
        function SetRelvantMaslulimOptions() {


           
            //var StartTimeShift = Number($("#spStartTimeShift").text().replace(":", ""));
            //var EndTimeShift = Number($("#spEndTimeShift").text().replace(":", ""));

            var HourForTaxi = Number($('#txtHourForTaxi').val().replace(":", ""));

            //   if (HourForTaxi >= 1500 && HourForTaxi <= 1800 && MaslulData.MaslulDesc.indexOf('אשקלון') > -1) ExtraSapId = 5;
            var Dir = $('#ddlDirection').val();

            var CurrentDay = DayConfigureWithShift[0].DayId;
            var ShiftId = DayConfigureWithShift[0].ShiftId;


            if (DayConfigureWithShift[0].DayType == 5 || DayConfigureWithShift[0].DayType == 9) CurrentDay = 7;
            if (DayConfigureWithShift[0].DayType == 8) CurrentDay = 6;
            if (HourForTaxi >= 2100 || HourForTaxi <= 530 || (CurrentDay == 7 && (ShiftId != 3 || (ShiftId == 3 && Dir==0)) )|| (CurrentDay == 6 && HourForTaxi >= 1700) || (CurrentDay == 6 && ShiftId==3)) {

                MaslulimChoose = MaslulimData.filter(x => x.Type == 1 || x.Sap_Id == 99);

            } else {

                MaslulimChoose = MaslulimData.filter(x => x.Type != 1 || x.Sap_Id == 99);
            }



            InitTypeHead();


        }

        var MaslulimChoose = [];
        function InitTypeHead() {
            $('.typeahead').typeahead({
                items: 15,
                source: function (query, process) {
                    states = [];
                    map = {};

                    $.each(MaslulimChoose, function (i, state) {

                        // map[state.EmpNo] = state;
                        map[state.Sap_Id + " - " + state.MaslulDesc] = state;
                        states.push(state.Sap_Id + " - " + state.MaslulDesc);
                    });

                    process(states);
                },

                updater: function (item) {


                    MaslulIdSelected = map[item].Id;
                    //CityValueDesc = map[item].ValueDesc;


                    return item;
                }
            });



        }


        var SelectAllCheckBox = false;

        function AddTaxi() {


            debugger

            var MaslulimId = MaslulIdSelected; //$("#ddlMaslulim").val();

            if (MaslulimId == 0) {
                $("#dvAddAlert").html("חובה לבחור מסלול להסעה.");
                return;
            }
            var MaslulData = GetMaslulDescByMaslulId(MaslulimId);
            var ExtraSapId = 0;
            var CarTypeId = $("#ddlCarType").val();
            if (CarTypeId == 0) {
                $("#dvAddAlert").html("חובה לבחור סוג הסעה.");
                return;
            }


            //************************************************************

            var HourForTaxiNumeric = Number($('#txtHourForTaxi').val().replace(":", ""));
            var CurrentDay = DayConfigureWithShift[0].DayId;
            var ShiftId = DayConfigureWithShift[0].ShiftId;


            if (DayConfigureWithShift[0].DayType == 5 || DayConfigureWithShift[0].DayType == 9) CurrentDay = 7;
            if (DayConfigureWithShift[0].DayType == 8) CurrentDay = 6;
            if (HourForTaxiNumeric >= 2100 || HourForTaxiNumeric <= 530 || (CurrentDay == 7 && (ShiftId != 3 || (ShiftId == 3 && Dir == 0))) || (CurrentDay == 6 && HourForTaxiNumeric >= 1700) || (CurrentDay == 6 && ShiftId == 3)) {

                if (MaslulData.Type != 1 && MaslulData.Sap_Id != 99) {

                    $("#dvAddAlert").html("יש לבחור מסלול של לילה עבור שעה זו.");
                    return;

                }
               // MaslulimChoose = MaslulimData.filter(x => x.Type == 1 || x.Sap_Id == 99);

            } else {
                if (MaslulData.Type == 1 && MaslulData.Sap_Id != 99) {
                    $("#dvAddAlert").html("יש לבחור מסלול של יום עבור שעה זו.");
                    return;

                }

                // MaslulimChoose = MaslulimData.filter(x => x.Type != 1 || x.Sap_Id == 99);
            }


              //************************************************************


            var Mdest = $('#txtMdest').val();
            var Mprice = $('#txtMprice').val();
            if (MaslulData.Sap_Id == 99 && !Mdest) {
                $("#dvAddAlert").html("בנסיעה מיוחדת חובה לשים יעד.");
                return;

            }




            // משמרת 3
            //if (EndTimeShift < StartTimeShift) {
            //    EndTimeShift = EndTimeShift + StartTimeShift;

            //    if (HourForTaxi < 1000) {
            //        HourForTaxi = HourForTaxi + StartTimeShift;

            //    }
            //}

            //if (HourForTaxi > EndTimeShift || HourForTaxi < StartTimeShift) {
            //    $("#dvAddAlert").html(" שעת נסיעה חייבת להיות בטווח שעות משמרת.");
            //    return;

            //}

            var Dir = $('#ddlDirection').val();
            var TaxiHtml = $("#dvTaxiTemplate0").html();

            var MaxSeq = Math.max(...mydata.map(o => o.Seq));

            var SearchDate = $('#txtSearchDate').val();
            var ShiftId = $('#ddlShift').val();
            var Comment = $('#txtComment').val();

            var HasotTime = $("#txtHourForTaxi").val();
            // אם זה איסוף תוריד את הזמן של האיסוף
            if (Dir == 0 && MaslulData.Sap_Id != 99) {

                var TimeBeforeTaxi = MaslulData.TimeBeforeTaxi;
                HasotTime = addMinutes(HasotTime, -1 * TimeBeforeTaxi);
            }


            var data = Ajax("Hasot_SetHasot", "EmpId=0&Date=" + SearchDate + "&HasotTime=" + HasotTime +
                "&ShiftId=" + ShiftId + "&Dir=" + Dir + "&City=&Mode=1&MaslulId=" + MaslulimId +
                "&Comment=" + Comment + "&CarTypeId=" + CarTypeId + "&CarSymbol=&Seq=" + (MaxSeq + 1) + "&ExtraSapId=" + ExtraSapId
                + "&Mdest=" + Mdest + "&Mprice=" + Mprice);
            FillData();





            $("#ModalTaxi").modal('hide');

            DefineDragAndDropEvents();
        }


        function addMinutes(time, minsToAdd) {
            function D(J) { return (J < 10 ? '0' : '') + J; };
            var piece = time.split(':');
            var mins = piece[0] * 60 + +piece[1] + +minsToAdd;

            return D(mins % (24 * 60) / 60 | 0) + ':' + D(mins % 60);
        }


        function GetMaslulDescByMaslulId(MaslulId) {

            var MaslulDesc;
            var Type;
            var Sap_Id;
            var City1;
            var City2;
            var City3;
            var City4;
            var TimeBeforeTaxi;

            var HasotDate;
            for (var i = 0; i < MaslulimData.length; i++) {

                if (MaslulimData[i].Id == MaslulId) {

                    MaslulDesc = (MaslulimData[i].Sap_Id == "99") ? "מיוחדת" : MaslulimData[i].MaslulDesc;
                    Type = MaslulimData[i].Type;
                    Sap_Id = MaslulimData[i].Sap_Id;
                    City1 = MaslulimData[i].City1;
                    City2 = MaslulimData[i].City2;
                    City3 = MaslulimData[i].City3;
                    City4 = MaslulimData[i].City4;
                    TimeBeforeTaxi = MaslulimData[i].TimeBeforeTaxi;
                    HasotDate = MaslulimData[i].HasotDate;

                    break;
                }

            }


            // return [MaslulDesc, Sap_Id, City1, City2];

            return {
                MaslulDesc: MaslulDesc,
                Type: Type,
                Sap_Id: Sap_Id,
                City1: City1,
                City2: City2,
                City3: City3,
                City4: City4,
                TimeBeforeTaxi: TimeBeforeTaxi
            };

        }

        function DeleteTaxi(TaxiId) {

            bootbox.confirm("האם אתה בטוח שברצונך למחוק את המונית?", function (result) {
                if (result) {


                    var EmpCount = $("#" + TaxiId + " .dvEmpInTaxi").length;
                    var Seq = $("#" + TaxiId).attr("seq");

                    if (EmpCount != 0) {
                        $("#" + TaxiId + " .dvEmpInTaxi").each(function () {




                            var EmpId = $(this).attr('id').replace("dv_", "");
                            var SearchDate = $('#txtSearchDate').val();
                            var ShiftId = $('#ddlShift').val();
                            var Dir = $('#ddlDirection').val();
                            var City = "";
                            var data = Ajax("Hasot_SetHasot", "EmpId=" + EmpId + "&Date=" + SearchDate + "&HasotTime=" + "&ShiftId=" + ShiftId + "&Dir=" + Dir
                                + "&City=" + City + "&Mode=0&MaslulId=0&Comment=");

                        });
                    }
                    else {

                        // var EmpId = $(this).attr('id').replace("dv_", "");
                        var SearchDate = $('#txtSearchDate').val();
                        var ShiftId = $('#ddlShift').val();
                        var Dir = $('#ddlDirection').val();
                        var City = "";
                        var data = Ajax("Hasot_SetHasot", "EmpId=0&Seq=" + Seq + "&Date=" + SearchDate + "&HasotTime=" + "&ShiftId=" + ShiftId + "&Dir=" + Dir + "&City=" + City + "&Mode=0&MaslulId=0&Comment=");


                    }



                    FillData();

                }

            });


        }

        function DeleteEmpFromTaxi(EmpNo, CarTypeId, Obj) {


            var TextConfirm = "האם אתה בטוח שברצונך להסיר את העובד\ת מ" + ((CarTypeId == 1) ? 'מונית' : 'מיניבוס') + " זו?";

            bootbox.confirm(TextConfirm, function (result) {
                if (result) {

                    var Seq = $(Obj).parent().attr("Seq");
                    var CarTypeId = $(Obj).parent().attr("CarTypeId");
                    var MaslulId = $(Obj).parent().attr("MaslulId");
                    var SearchDate = $('#txtSearchDate').val();
                    var ShiftId = $('#ddlShift').val();
                    var Dir = $('#ddlDirection').val();
                    var City = "";
                    var data = Ajax("Hasot_SetHasot", "EmpId=" + EmpNo + "&Date=" + SearchDate + "&HasotTime=" + "&ShiftId=" + ShiftId + "&Dir=" + Dir + "&City=" + City + "&Seq=" + Seq + "&CarTypeId=" + CarTypeId + "&MaslulId=" + MaslulId + "&Mode=0&Comment=");
                    FillData();


                }

            });


        }

        var ChangeCityEmpNo;
        var sourcecity = "";
        var sourceempcity = "";
        var sourcetempstreet = "";
        function ChangeCity(EmpNo, Obj) {



            CityValueCode = $(Obj).attr("city");
            CityValueDesc = $(Obj).attr("empcity");


            sourcecity = $(Obj).attr("sourcecity");
            sourceempcity = $(Obj).attr("sourceempcity");
            sourcetempstreet = $(Obj).attr("sourcetempstreet");


            var TempStreet = $(Obj).attr("TempStreet");

            $("#txtChangeCityAddress").val("");
            $("#txtCityTemp").val("");

            ChangeCityEmpNo = EmpNo;


            // alert($("#uNonMaslul_" + ChangeCityEmpNo).attr("City"));

            $("#ModalChangeCity").modal();
        }

        function ChangeCityAction() {

            //   var TempCityCode = $("#txtCityTemp").val();
            var CityCode = CityValueCode;//$("#txtCityTemp").val();
            var CityText = CityValueDesc;//$("#ddlCity :selected").text();
            var txtChangeCityAddress = $("#txtChangeCityAddress").val();
            //if (!CityCode && TempCityCode) {

            //    CityCode = TempCityCode;
            //    CityText = TempCityCode;
            //}

            if (!CityCode) {
                $("#uNonMaslul_" + ChangeCityEmpNo).attr("City", CityCode);
                $("#uNonMaslul_" + ChangeCityEmpNo).parent().attr("City", CityCode);
                $("#uNonMaslul_" + ChangeCityEmpNo).html(CityText);
                $("#uNonMaslul_" + ChangeCityEmpNo).parent().attr("TempStreet", txtChangeCityAddress);
                $("#uNonMaslul_" + ChangeCityEmpNo).parent().attr("TempCityText", CityText);
                $("#ModalChangeCity").modal('hide');

            }



            if (CityCode != 0) {
                $("#uNonMaslul_" + ChangeCityEmpNo).attr("City", CityCode);
                $("#uNonMaslul_" + ChangeCityEmpNo).parent().attr("City", CityCode);
                $("#uNonMaslul_" + ChangeCityEmpNo).html(CityText);
                $("#uNonMaslul_" + ChangeCityEmpNo).parent().attr("TempStreet", txtChangeCityAddress);
                $("#uNonMaslul_" + ChangeCityEmpNo).parent().attr("TempCityText", CityText);
                $("#ModalChangeCity").modal('hide');
            }


        }

        function DefineDragAndDropEvents() {
            $(".draggable").draggable({
                helper: "clone",
                cursor: "hand",


                // revert: true,
                start: function (event, ui) {
                    ui.helper.css("z-index", "2000");
                    ui.helper.width($(this).width());


                    const element = $(".maindivTaxi");
                    element.animate({
                        scrollTop: element.prop("scrollHeight")
                    }, 500);

                    $(".empdelete").hide();

                    // $(".maindivTaxi").addClass("overflow");//.scrollTo({ left: 0, top: $(".maindivTaxi").scrollHeight, behavior: "smooth" });
                },

                stop: function (event, ui) {



                    const element = $(".maindivTaxi");
                    element.animate({
                        scrollTop: 0
                    }, 500);

                    $(".empdelete").show();
                    // $(".maindivTaxi").addClass("overflow");//.scrollTo({ left: 0, top: $(".maindivTaxi").scrollHeight, behavior: "smooth" });
                }


            });


            $(".droppable").droppable({
                // activeClass: "ui-state-default",
                // hoverClass: "ui-state-hover",
                accept: ".draggable",
                drop: function (event, ui) {





                    var TargetCity1 = $(this).parent().attr("City1");
                    var TargetCity2 = $(this).parent().attr("City2");
                    var TargetCity3 = $(this).parent().attr("City3");
                    var TargetCity4 = $(this).parent().attr("City4");

                    //var CarTypeId =
                    //var CarSymbol =
                    var sapid = $(this).parent().attr("sapid");



                    var TargetCarTypeId = $(this).parent().attr("CarTypeId");
                    var TargetCarSymbol = $(this).parent().attr("CarSymbol");
                    var TargetSeq = $(this).parent().attr("Seq");
                    var TargetMaslulDesc = $(this).parent().attr("MaslulDesc");
                    var TargetExtraSapId = $(this).parent().attr("ExtraSapId");


                    var Targetmdest = (sapid == 99) ? $(this).parent().attr("mdest") : "";
                    var Targetmprice = (sapid == 99) ? $(this).parent().attr("mprice") : "";


                    var SourceEmpNo = ui.draggable.attr("EmpNo");
                    var SourceEmpCity = ui.draggable.attr("City");

                    var SourceSeq = ui.draggable.parent().attr("Seq");

                    var SourceMaslulId = ui.draggable.parent().attr("MaslulId");
                    var SourceCarTypeId = ui.draggable.parent().attr("CarTypeId");
                    var SourceHasotTime = ui.draggable.parent().attr("HasotTime");
                    var TempStreet = ui.draggable.attr("TempStreet");

                    var TempCityText = ui.draggable.attr("TempCityText");

                    var SourceEmpCityDesc = ui.draggable.attr("empcity");
                    if (TempCityText) SourceEmpCityDesc = TempCityText;



                    //if ((SourceEmpCity != TargetCity1 && SourceEmpCity != TargetCity2 && SourceEmpCity != TargetCity3 && SourceEmpCity != TargetCity4) && sapid != 99
                    //    && (
                    //        (SourceEmpCityDesc.indexOf('ראשל') == -1 && (SourceEmpCityDesc.indexOf('אשקלון') == -1 || TargetMaslulDesc.indexOf('אשקלון') == -1)) ||
                    //        (SourceEmpCityDesc.indexOf('אשקלון') == -1 && (SourceEmpCityDesc.indexOf('ראשל') == -1 || TargetMaslulDesc.indexOf('ראשל') == -1))
                    //    )) {


                    //    bootbox.alert("יעד נסיעת עובד אינו מתאים ליעד ההסעה");
                    //    return;
                    //}

                    var SearchDate = $('#txtSearchDate').val();
                    var HasotTime = $(this).parent().attr("HasotTime");
                    var Comment = $(this).parent().attr("Comment");
                    var ShiftId = $('#ddlShift').val();
                    var Dir = $('#ddlDirection').val();
                    var MaslulId = $(this).parent().attr("MaslulId");


                    if (HasotTime && SourceHasotTime && HasotTime != SourceHasotTime) {
                        bootbox.alert("לא ניתן להעביר עובדים בשעות שונות!");
                        return;

                    }


                    //debugger

                    //var res = MaslulimData.filter(x => x.Id == MaslulId);



                    var data = Ajax("Hasot_SetHasot", "EmpId=" + SourceEmpNo + "&Date=" + SearchDate + "&HasotTime=" + HasotTime +
                        "&ShiftId=" + ShiftId + "&Dir=" + Dir + "&City=" + SourceEmpCity + "&Mode=1&MaslulId=" + MaslulId +
                        "&Comment=" + Comment + "&CarTypeId=" + TargetCarTypeId + "&CarSymbol=" + TargetCarSymbol + "&Seq=" + TargetSeq + "&ExtraSapId=" + TargetExtraSapId +
                        "&TempStreet=" + TempStreet + "&Mdest=" + Targetmdest + "&Mprice=" + Targetmprice +
                        "&SourceSeq=" + SourceSeq + "&SourceMaslulId=" + SourceMaslulId + "&SourceCarTypeId=" + SourceCarTypeId);

                    if (data[0] && data[0]["Id"] == 0) {
                        bootbox.alert("לא נמצא מסלול מתאים המכיל את איחוד הערים הזה!");
                        return;

                    }


                    FillData();

                }
            });
        }


        function ClearData() {

            bootbox.confirm("שים לב, לחיצה על אישור תמחק את כל השינויים ותחזיר את המצב הראשוני", function (result) {
                if (result) {


                    FillData(1);


                }

            });

        }

        //function compare(a, b) {
        //    if (a.Seq < b.Seq) {
        //        return -1;
        //    }
        //    if (a.Seq > b.Seq) {
        //        return 1;
        //    }
        //    return 0;
        //}

        function pad(str, max) {

            try {

                str = str.toString();
                return str.length < max ? pad("0" + str, max) : str;
            } catch {

                return "";
            }
        }


        function GetDataForHazmana() {

            var SearchDate = $('#txtSearchDate').val();
            var DayName = getDayfromDate(SearchDate);
            var ShiftId = $('#ddlShift').val();
            var Dir = $('#ddlDirection').val();

            var DirectionText = $("#ddlDirection option:selected").text().replace(/--/g, "");
            var ShiftText = $("#ddlShift option:selected").text().replace(/--/g, "");
            var TitleModal = SearchDate + " ( " + DayName + ") - " + DirectionText + " - " + ShiftText;



            let res = { IsufDir: 0, IsufShift: 0, IsufDate: 0, IsufDesc: "", PizurDir: 1, PizurShift: 0, PizurDate: 0, PizurDesc: "" };
            if (Dir == 0) {


                res.IsufShift = ShiftId;
                res.IsufDate = SearchDate;
                res.IsufDesc = TitleModal;

                if (ShiftId == 1) {


                    res.PizurShift = 3;
                    res.PizurDate = ConvertHebrewDateToJSDATE(SearchDate, -1, "Heb");
                    var DayName = getDayfromDate(res.IsufDate);
                    var TitleModal = res.IsufDate + " ( " + DayName + ") - פיזור - לילה ";
                    res.PizurDesc = TitleModal

                }



                if (ShiftId == 2) {


                    res.PizurShift = 1;
                    res.PizurDate = SearchDate;
                    var TitleModal = res.PizurDate + " ( " + DayName + ") - פיזור - בוקר ";
                    res.PizurDesc = TitleModal

                }



                if (ShiftId == 3) {

                    res.PizurShift = 2;
                    res.PizurDate = SearchDate;
                    var TitleModal = res.PizurDate + " ( " + DayName + ") - פיזור - צהריים ";
                    res.PizurDesc = TitleModal

                }

            }
            else {

                res.PizurShift = ShiftId;
                res.PizurDate = SearchDate;
                res.PizurDesc = TitleModal;

                if (ShiftId == 1) {


                    res.IsufShift = 2;
                    res.IsufDate = SearchDate;
                    // res.IsufDate = ConvertHebrewDateToJSDATE(SearchDate, -1, "Heb");
                    // var DayName = getDayfromDate(res.IsufDate);
                    var TitleModal = res.PizurDate + " ( " + DayName + ") - איסוף - צהריים ";
                    res.IsufDesc = TitleModal

                }



                if (ShiftId == 2) {


                    res.IsufShift = 3;
                    res.IsufDate = SearchDate;

                    var TitleModal = res.PizurDate + " ( " + DayName + ") - איסוף - לילה ";
                    res.IsufDesc = TitleModal
                }



                if (ShiftId == 3) {

                    res.IsufShift = 1;

                    res.IsufDate = ConvertHebrewDateToJSDATE(SearchDate, 1, "Heb");
                    var DayName = getDayfromDate(res.IsufDate);
                    var TitleModal = res.IsufDate + " ( " + DayName + ") - איסוף - בוקר ";
                    res.IsufDesc = TitleModal;
                    // res.PizurDate = res.IsufDate;
                    res.PizurDesc = res.IsufDate + " ( " + DayName + ") - פיזור - לילה ";

                }

            }



            return res;






        }

        var CurrentResFromHazmana = "";

        var SelectedCarTypeId = 0;

        function PrintData(type) {

            //הדפסת שובר
            if (type == 1) {

                var Dir = $('#ddlDirection').val();

                var Selected = $('input:checked[style*="display: @displayChecbox"]');
                var ListIds = [];
                $(Selected).each(function () {
                    ListIds.push($(this).attr("id").replace("ch_", ""));
                });


                var data = SaveData(ListIds);

                if (data.length == 0) {

                    bootbox.alert("לא נבחרה מונית להדפסת שובר");
                    return;
                }

                data = data.sort((a, b) => (a.HasaNumber > b.HasaNumber) ? 1 : -1);





                var printtemplate = "";


                var TaxiVocherList = data.filter(x => x.CarTypeId == 1 && x.Sap_Id && ListIds.indexOf(x.Seq.toString()) > -1);





                var ArrayList = [];


                for (var i = 0; i < TaxiVocherList.length; i++) {


                    if (ArrayList.indexOf(TaxiVocherList[i].Seq) == -1) {
                        if (TaxiVocherList[i].Status == "2") continue;
                        ArrayList.push(TaxiVocherList[i].Seq);



                        var Template = $("#dvPrintTemplate").html();

                        Template = Template.replace(/@DateOrginal/g, (TaxiVocherList[i].ShiftId == 3 && Dir == 1) ? ("(משמרת - " + TaxiVocherList[i].HasotDateHeb + ")") : "");
                        Template = Template.replace(/@Date/g, (TaxiVocherList[i].ShiftId == 3 && Dir == 1) ? ConvertHebrewDateToJSDATE(TaxiVocherList[i].HasotDateHeb, 1, "Heb") : TaxiVocherList[i].HasotDateHeb);

                        Template = Template.replace(/@Hour/g, TaxiVocherList[i].HasotTime);
                        Template = Template.replace(/@MaslulDesc/g, TaxiVocherList[i].MaslulDesc);


                        Template = Template.replace(/@MaslulDir/g, ((Dir == 0) ? "איסוף מ " : "פיזור ל "));


                        Template = Template.replace(/@Numerator/g, pad(TaxiVocherList[i].HasaNumber, 4));
                        Template = Template.replace(/@Comment/g, TaxiVocherList[i].Comment);

                        var WorkerList = "";
                        var OnlyWorker = TaxiVocherList.filter(x => x.Seq == TaxiVocherList[i].Seq && x.Status != "2");
                        for (var j = 0; j < OnlyWorker.length; j++) {
                            var WorkerTemplate = $("#dvWorkerTemplate").html();

                            WorkerTemplate = WorkerTemplate.replace(/@WorkerName/g, ((OnlyWorker[j].EmpName) ? OnlyWorker[j].EmpName : "ללא עובדים"));
                            WorkerTemplate = WorkerTemplate.replace(/@WorkerNumber/g, j + 1);


                            WorkerList += WorkerTemplate;


                        }


                        Template = Template.replace(/@WorkerList/g, WorkerList);
                        Template = Template.replace(/@Sap_Id/g, TaxiVocherList[i].Sap_Id);
                        Template = Template.replace(/@Day/g, TaxiVocherList[i].DayOrNight);

                        //Template = Template.replace(/@TotalG1/g, TotalG1);
                        //Template = Template.replace(/@AshmashName/g, AshmashName);

                        if (!printtemplate)
                            printtemplate = Template;
                        else
                            printtemplate = printtemplate + "<div class='footer'>" + Template + "</div>";


                    }

                }


                PrintDivFood(printtemplate, "הדפסת הסעות");

                FillData();

            }

            // הזמנה יומית
            if (type == 2) {
                SelectedCarTypeId = 1;
                //var SearchDate = $('#txtSearchDate').val();
                //var DayName = getDayfromDate(SearchDate);
                //var ShiftId = $('#ddlShift').val();
                //var Dir = $('#ddlDirection').val();

                //var DirectionText = $("#ddlDirection option:selected").text().replace(/--/g, "");
                //var ShiftText = $("#ddlShift option:selected").text().replace(/--/g, "");

                var res = GetDataForHazmana();

                CurrentResFromHazmana = res;

                $("#spSendMailTitleIsuf").text(res.IsufDesc);
                $("#spSendMailTitlePizur").text(res.PizurDesc);
                $("#btnSendMail").show();



                $("#spCarTypeDesc").text("אל תחנת מוניות קניון אשדוד");

               
                var data = Ajax("Hasot_SetHasot", "EmpId=0&Date=" + res.PizurDate + "&HasotTime=&ShiftId=" + res.PizurShift + "&Dir=" + res.PizurDir + "&City=&Mode=4&MaslulId=0&Comment=");

                if (data.length < 1) return;


                var dvPizurRangeFilter = $("#dvPizurRangeFilter").html();
                var dvIsufRangeFilter = $("#dvIsufRangeFilter").html();
                dvPizurRangeFilter = dvPizurRangeFilter.replace("@ClassN", "dvRangeFilter");
                dvIsufRangeFilter = dvIsufRangeFilter.replace("@ClassN", "dvRangeFilter");
               // $(dvPizurRangeFilter).addClass("dvRangeFilter");
               // $(dvIsufRangeFilter).addClass("dvRangeFilter");
                
                $("#dvIsuf,#dvPizur").html("");


           
                $("#dvIsuf").append(dvIsufRangeFilter);
                $("#dvPizur").append(dvPizurRangeFilter);

                $('#txtHourForTaxiStartIsuf,#txtHourForTaxiEndIsuf,#txtHourForTaxiStartPizur,#txtHourForTaxiEndPizur').datetimepicker(
                    {

                        datepicker: false,
                        format: 'H:i',
                        mask: true,
                        step: 15,
                        onChangeDateTime: GetSelectedTaxi
                    });


                var DateTemplate = $("#dvDateTemplate").html();

                var Pizur = data.filter(x => x.Dir == 1);
                if (Pizur.length > 0) {
                    var DirectionAndShift = " פיזור " + Pizur[0].ShiftDesc + ((res.PizurShift == 3) ? ("( משמרת - " + res.PizurDate + ")") : "");



                    DateTemplate = DateTemplate.replace(/@HasotDateHeb/g, Pizur[0].HasotDateHeb);
                    DateTemplate = DateTemplate.replace(/@DirectionAndShift/g, DirectionAndShift);

                    $("#dvPizur").append(DateTemplate);

                }

                DateTemplate = $("#dvDateTemplate").html();
                var Isuf = data.filter(x => x.Dir == 0);
                if (Isuf.length > 0) {
                    var DirectionAndShift = " איסוף " + Isuf[0].ShiftDesc;
                    DateTemplate = DateTemplate.replace(/@HasotDateHeb/g, Isuf[0].HasotDateHeb);
                    DateTemplate = DateTemplate.replace(/@DirectionAndShift/g, DirectionAndShift);

                    $("#dvIsuf").append(DateTemplate);

                }




                var ArrayList = [];

                var Counter = 0;

                var PrevDiv = 0;

                var MaxPizur = 0;
                var MinPizur = 9999;
                var MaxIsuf = 0;
                var MinIsuf = 9999;

                for (var i = 0; i < data.length; i++) {

                    var Seq = data[i].Seq;
                    var Dir = data[i].Dir;
                    var ShiftId = data[i].ShiftId;
                    var MaslulDesc = data[i].MaslulDesc;

                    var DirDiv = "#dv" + ((Dir == 1) ? "Pizur" : "Isuf");

                    if (PrevDiv != Dir) {

                        Counter = 0;
                        PrevDiv = Dir;
                    }



                    if (ArrayList.filter(x => x.Dir == Dir && x.Seq == Seq && x.MaslulDesc == MaslulDesc).length == 0) {
                        var HasotTime = data[i].HasotTime.replace(":", "");

                        if (Dir == 1 && HasotTime < MinPizur) {

                            MinPizur = HasotTime;
                        }

                        if (Dir == 1 && HasotTime > MaxPizur) {

                            MaxPizur = HasotTime;
                        }


                        if (Dir == 0 && HasotTime < MinIsuf) {

                            MinIsuf = HasotTime;
                        }

                        if (Dir == 0 && HasotTime > MaxIsuf) {

                            MaxIsuf = HasotTime;
                        }


                        ArrayList.push({ Dir: Dir, Seq: Seq, MaslulDesc: MaslulDesc });
                        var MaslulTemplate = $("#dvMaslulTemplate").html();
                        MaslulTemplate = MaslulTemplate.replace(/@MaslulDesc/g, data[i].MaslulDesc);

                        var AllChild = data.filter(x => x.Dir == Dir && x.Seq == Seq);


                        Counter += AllChild.length;

                        if (Counter > 19) {

                            Counter = AllChild.length;
                            $(DirDiv).append('<div class="break"></div>');
                        }


                        if (AllChild.length > 0) {
                            var AllChildDelete = data.filter(x => x.Dir == Dir && x.Seq == Seq && x.Status == 2);
                            var AllChildNew = data.filter(x => x.Dir == Dir && x.Seq == Seq && x.Status > 2);

                            if (AllChild.length == AllChildNew.length) {
                                MaslulTemplate = MaslulTemplate.replace(/@ClassPass/g, "dvNewPass maslulTitle");

                                MaslulTemplate = MaslulTemplate.replace(/@Status/g, "- נסיעה חדשה");
                                MaslulTemplate = MaslulTemplate.replace(/@nolineTitle/g, "nolineNew maslulTitle");
                                MaslulTemplate = MaslulTemplate.replace(/@noline/g, "nolineNew");

                            }

                            if (AllChild.length == AllChildDelete.length) {
                                MaslulTemplate = MaslulTemplate.replace(/@ClassPass/g, "dvDeletedPass maslulTitle");
                                MaslulTemplate = MaslulTemplate.replace(/@Status/g, "- מונית מבוטלת");
                                MaslulTemplate = MaslulTemplate.replace(/@nolineTitle/g, "nolineDeleted maslulTitle");
                                MaslulTemplate = MaslulTemplate.replace(/@noline/g, "nolineDeleted");

                            }

                            //   MaslulTemplate = MaslulTemplate.replace(/@nolineTitle/g, "maslulTitle");
                        }

                        MaslulTemplate = MaslulTemplate.replace(/@ClassPass/g, "maslulTitle");
                        MaslulTemplate = MaslulTemplate.replace(/@Status/g, "");

                        // new
                        MaslulTemplate = MaslulTemplate.replace(/@HasotTime/g, data[i].HasotTime.replace(":",""));
                        MaslulTemplate = MaslulTemplate.replace(/@ShiftId/g, data[i].ShiftId);
                        MaslulTemplate = MaslulTemplate.replace(/@Dir/g, data[i].Dir);

                        $(DirDiv).append(MaslulTemplate);

                        if (Dir == 1) {
                            $('#txtHourForTaxiStartPizur').attr("shiftid", data[i].ShiftId);
                            $('#txtHourForTaxiStartPizur').attr("dir", data[i].Dir);
                        } else {
                            $('#txtHourForTaxiStartIsuf').attr("shiftid", data[i].ShiftId);
                            $('#txtHourForTaxiStartIsuf').attr("dir", data[i].Dir);

                        }
                    }

                    var PassTemplate = $("#dvPassTemplate").html();
                    PassTemplate = PassTemplate.replace(/@HasotTimeFilter/g, data[i].HasotTime.replace(":", ""));
                    PassTemplate = PassTemplate.replace(/@HasotTime/g, data[i].HasotTime);

                   
                    PassTemplate = PassTemplate.replace(/@ShiftId/g, data[i].ShiftId);
                    PassTemplate = PassTemplate.replace(/@Dir/g, data[i].Dir);

                    PassTemplate = PassTemplate.replace(/@EmpName/g, (data[i].EmpName) ? data[i].EmpName : "ללא נוסעים");
                    PassTemplate = PassTemplate.replace(/@PhoneNum/g, getPsikIfExists(data[i].PhoneNum));
                    PassTemplate = PassTemplate.replace(/@Street/g, getPsikIfExists(data[i].Street));
                    PassTemplate = PassTemplate.replace(/@City/g, getPsikIfExists(data[i].City));

                    if (data[i].Status == 2) {

                        PassTemplate = PassTemplate.replace(/@ClassPass/g, "dvDeletedPass");
                        PassTemplate = PassTemplate.replace(/@Status/g, "- בוטל");
                        PassTemplate = PassTemplate.replace(/@noline/g, "nolineDeleted");
                    }

                    if (data[i].Status > 2) {

                        PassTemplate = PassTemplate.replace(/@ClassPass/g, "dvNewPass");
                        PassTemplate = PassTemplate.replace(/@Status/g, "- חדש");
                        PassTemplate = PassTemplate.replace(/@noline/g, "nolineNew");
                    }
                    PassTemplate = PassTemplate.replace(/@Status/g, "");
                    $(DirDiv).append(PassTemplate);





                }

                $("#ModalSendMail").modal();

              

                if (MinPizur != 9999) {
                    $('#txtHourForTaxiStartPizur').val(ConvertIntToTime(MinPizur));
                    $('#txtHourForTaxiEndPizur').val(ConvertIntToTime(MaxPizur));
                }
                if (MinIsuf != 9999) {

                    $('#txtHourForTaxiStartIsuf').val(ConvertIntToTime(MinIsuf));
                    $('#txtHourForTaxiEndIsuf').val(ConvertIntToTime(MaxIsuf));
                }



            }

            // הדפסה של יומית
            if (type == 3) {


                // $("#dvIsuf,#dvPizur").css("float","none");
                $('.dvRangeFilter').remove();
                var printtemplate = $('#dvSendMail').html();
                printtemplate = printtemplate.replace(/g;float/g, "");

                PrintDivFood(printtemplate, "הדפסה סידור תחנת מוניות");
            }

            // הזמנה יומית אופטובוסים
            if (type == 4) {
                SelectedCarTypeId = 2;
                //var SearchDate = $('#txtSearchDate').val();
                //var DayName = getDayfromDate(SearchDate);
                //var ShiftId = $('#ddlShift').val();
                //var Dir = $('#ddlDirection').val();

                //var DirectionText = $("#ddlDirection option:selected").text().replace(/--/g, "");
                //var ShiftText = $("#ddlShift option:selected").text().replace(/--/g, "");

                var res = GetDataForHazmana();

                CurrentResFromHazmana = res;

                $("#spSendMailTitleIsuf").text(res.IsufDesc);
                $("#spSendMailTitlePizur").text(res.PizurDesc);
                // $("#btnSendMail").hide();
                $("#spCarTypeDesc").text("אל חברת אוטובוסים");
                var data = Ajax("Hasot_SetHasot", "EmpId=0&Date=" + res.PizurDate + "&HasotTime=&ShiftId=" + res.PizurShift + "&Dir=" + res.PizurDir + "&City=&Mode=44&MaslulId=0&Comment=");

                if (data.length < 1) return;

                $("#dvIsuf,#dvPizur").html("");


                var DateTemplate = $("#dvDateTemplate").html();

                var Pizur = data.filter(x => x.Dir == 1);
                if (Pizur.length > 0) {

                    var DirectionAndShift = " פיזור " + Pizur[0].ShiftDesc + ((res.PizurShift == 3) ? ("( משמרת - " + res.PizurDate + ")") : "");


                    DateTemplate = DateTemplate.replace(/@HasotDateHeb/g, Pizur[0].HasotDateHeb);

                    DateTemplate = DateTemplate.replace(/@DirectionAndShift/g, DirectionAndShift);

                    $("#dvPizur").append(DateTemplate);

                }

                DateTemplate = $("#dvDateTemplate").html();
                var Isuf = data.filter(x => x.Dir == 0);
                if (Isuf.length > 0) {
                    var DirectionAndShift = " איסוף " + Isuf[0].ShiftDesc;
                    DateTemplate = DateTemplate.replace(/@HasotDateHeb/g, Isuf[0].HasotDateHeb);
                    DateTemplate = DateTemplate.replace(/@DirectionAndShift/g, DirectionAndShift);

                    $("#dvIsuf").append(DateTemplate);

                }




                var ArrayList = [];



                var Counter = 0;
                // var PrevDiv = 0;
                for (var i = 0; i < data.length; i++) {

                    var Seq = data[i].Seq;
                    var Dir = data[i].Dir;
                    var DirDiv = "#dv" + ((Dir == 1) ? "Pizur" : "Isuf");



                    //if (PrevDiv != Dir) {
                    //    Counter = 0;
                    //    PrevDiv = Dir;
                    //}

                    if (ArrayList.filter(x => x.Dir == Dir && x.Seq == Seq).length == 0) {

                        if (Counter > 0 && (Counter % 22) == 0) {

                            $(DirDiv).append('<div class="break"></div>');
                        }
                        ArrayList.push({ Dir: Dir, Seq: Seq });
                        var MaslulTemplate = $("#dvMaslulTemplate").html();
                        MaslulTemplate = MaslulTemplate.replace(/@MaslulDesc/g, data[i].MaslulDesc);

                        var AllChild = data.filter(x => x.Dir == Dir && x.Seq == Seq);
                        Counter += AllChild.length + 1;
                        if (AllChild.length > 0) {
                            var AllChildDelete = data.filter(x => x.Dir == Dir && x.Seq == Seq && x.Status == 2);
                            var AllChildNew = data.filter(x => x.Dir == Dir && x.Seq == Seq && x.Status > 2);

                            if (AllChild.length == AllChildNew.length) {
                                MaslulTemplate = MaslulTemplate.replace(/@ClassPass/g, "dvNewPass maslulTitle");

                                MaslulTemplate = MaslulTemplate.replace(/@Status/g, "- נסיעה חדשה");
                                MaslulTemplate = MaslulTemplate.replace(/@nolineTitle/g, "nolineNew maslulTitle");
                                MaslulTemplate = MaslulTemplate.replace(/@noline/g, "nolineNew");

                            }

                            if (AllChild.length == AllChildDelete.length) {
                                MaslulTemplate = MaslulTemplate.replace(/@ClassPass/g, "dvDeletedPass maslulTitle");
                                MaslulTemplate = MaslulTemplate.replace(/@Status/g, "- מונית מבוטלת");
                                MaslulTemplate = MaslulTemplate.replace(/@nolineTitle/g, "nolineDeleted maslulTitle");
                                MaslulTemplate = MaslulTemplate.replace(/@noline/g, "nolineDeleted");

                            }

                            //   MaslulTemplate = MaslulTemplate.replace(/@nolineTitle/g, "maslulTitle");
                        }

                        MaslulTemplate = MaslulTemplate.replace(/@ClassPass/g, "maslulTitle");
                        MaslulTemplate = MaslulTemplate.replace(/@Status/g, "");


                        $(DirDiv).append(MaslulTemplate);


                    }


                    // @ShiftId_ @Dir_ @HasotTime


                    var PassTemplate = $("#dvPassTemplate").html();
                    PassTemplate = PassTemplate.replace(/@HasotTime/g, data[i].HasotTime);


                    PassTemplate = PassTemplate.replace(/@EmpName/g, data[i].EmpName);
                    PassTemplate = PassTemplate.replace(/@PhoneNum/g, getPsikIfExists(data[i].PhoneNum));
                    PassTemplate = PassTemplate.replace(/@Street/g, getPsikIfExists(data[i].Street));
                    PassTemplate = PassTemplate.replace(/@City/g, getPsikIfExists(data[i].City));

                    if (data[i].Status == 2) {

                        PassTemplate = PassTemplate.replace(/@ClassPass/g, "dvDeletedPass");
                        PassTemplate = PassTemplate.replace(/@Status/g, "- בוטל");
                        PassTemplate = PassTemplate.replace(/@noline/g, "nolineDeleted");
                    }

                    if (data[i].Status > 2) {

                        PassTemplate = PassTemplate.replace(/@ClassPass/g, "dvNewPass");
                        PassTemplate = PassTemplate.replace(/@Status/g, "- חדש");
                        PassTemplate = PassTemplate.replace(/@noline/g, "nolineNew");
                    }



                    PassTemplate = PassTemplate.replace(/@Status/g, "");
                    $(DirDiv).append(PassTemplate);


                }

                $("#ModalSendMail").modal();


            }
        }


        function GetSelectedTaxi(type) {


            debugger
            var ShiftIdPizur = $('#txtHourForTaxiStartPizur').attr("shiftid");
            var MinPizur = $('#txtHourForTaxiStartPizur').val();
            var MaxPizur = $('#txtHourForTaxiEndPizur').val();



            var StartClassNamePizur = ShiftIdPizur + "_1_";
          

            $("div[class^='" + StartClassNamePizur + "'],div[class*=' " + StartClassNamePizur + "']").hide();
            $("br[class^='" + StartClassNamePizur + "'],br[class*=' " + StartClassNamePizur + "']").hide();
            MinPizur = MinPizur.replace(":", "");
            MaxPizur = MaxPizur.replace(":", "");


            for (var i = MinPizur; i <= MaxPizur; i++) {
               
                $("div[class*='" + StartClassNamePizur + i + "']").show();
                $("br[class*='" + StartClassNamePizur + i + "']").show();
            }




          

            var ShiftIdIsuf = $('#txtHourForTaxiStartIsuf').attr("shiftid");
            var MinIsuf = $('#txtHourForTaxiStartIsuf').val();
            var MaxIsuf = $('#txtHourForTaxiEndIsuf').val();


            var StartClassNameIsuf = ShiftIdIsuf + "_0_";
            

            $("div[class^='" + StartClassNameIsuf + "'],div[class*=' " + StartClassNameIsuf + "']").hide();
            $("br[class^='" + StartClassNameIsuf + "'],br[class*=' " + StartClassNameIsuf + "']").hide();

            MinIsuf = MinIsuf.replace(":", "");
            MaxIsuf = MaxIsuf.replace(":", "");


            for (var i = MinIsuf; i <= MaxIsuf; i++) {

                $("div[class*='" + StartClassNameIsuf + i + "']").show();
                $("br[class*='" + StartClassNameIsuf + i + "']").show();
            }









        }

        function getPsikIfExists(val) {
            if ($.trim(val)) return ", " + val;
            else
                return "";


        }

        function SendAction() {

            if (SelectedCarTypeId == 1) {


                $("#spcarTypeId").text("מוניות");
            } else
                $("#spcarTypeId").text("אוטובוסים");

            $("#ModalWaitAjax").modal();


            var SearchDate = $('#txtSearchDate').val();

            var ShiftId = CurrentResFromHazmana.PizurShift;// $('#ddlShift').val();
            var Dir = 1;// $('#ddlDirection').val();



            var MinIsuf = $('#txtHourForTaxiStartIsuf').val();
            var MaxIsuf = $('#txtHourForTaxiEndIsuf').val();
            var MinPizur = $('#txtHourForTaxiStartPizur').val();
            var MaxPizur = $('#txtHourForTaxiEndPizur').val();

            
            if (MinIsuf == "__:__") { MinIsuf = ""; MaxIsuf = ""; }
            if (MinPizur == "__:__") { MinPizur = ""; MaxPizur = ""; }

            $('.dvRangeFilter').remove();
            $('#dvSendMail').parent().find(":hidden").remove();

            var Html = $('#dvSendMail').parent().html();
            var TitleIsuf = $("#spSendMailTitleIsuf").text();
            var TitlePizur = $("#spSendMailTitlePizur").text();
            
            Html = Html.replace(/g;float/g, "");

            


            var data = AjaxAsync("Hasot_SetHasot", "EmpId=0&Date=" + SearchDate + "&HasotTime=&ShiftId=" + ShiftId + "&Dir=" + Dir + "&CarTypeId=" + SelectedCarTypeId
                + "&City=&Mode=5&MaslulId=0&Comment=&Html=" + Html + "&TitleIsuf=" + TitleIsuf + "&TitlePizur=" + TitlePizur
                + "&StartDate=" + MinIsuf + "&EndDate=" + MaxIsuf + "&TempStreet=" + MinPizur + "&Mdest=" + MaxPizur
                , FinishAjax);





        }

        function FinishAjax() {
            $("#ModalSendMail").modal("hide");
            $("#ModalWaitAjax").modal("hide");


        }

        function SaveData(ListIds) {

            var data = "";
            for (var i = 0; i < ListIds.length; i++) {
                var Seq = ListIds[i];
                if (Seq == "@Seq") continue;
                var SearchDate = $('#txtSearchDate').val();
                var ShiftId = $('#ddlShift').val();
                var Dir = $('#ddlDirection').val();
                var City = "";
                data = Ajax("Hasot_SetHasot", "EmpId=0&Date=" + SearchDate + "&HasotTime=&ShiftId=" + ShiftId + "&Dir=" + Dir + "&City=" + City + "&Seq=" + Seq + "&Mode=3&MaslulId=0&Comment=");
            }


            return data;

        }

        function RefreshData() {

            //var SearchDate = $('#txtSearchDate').val();
            //var ShiftId = $('#ddlShift').val();
            //var Dir = $('#ddlDirection').val();
            //var City = "";
            //var data = Ajax("Hasot_SetHasot", "EmpId=0&Date=" + SearchDate + "&HasotTime=&ShiftId=" + ShiftId + "&Dir=" + Dir + "&City=" + City + "&Mode=4&MaslulId=0&Comment=");
          
            FillData(2);

            bootbox.alert("כל הנתונים התרעננו");

            //return data;

        }

        function Search() {


            $('div[emp]').removeClass("searchClass");
            var Search = $('#txtSearch').val();
            if ($.trim(Search)) {
                $('div[emp]:contains("' + Search + '")').addClass("searchClass");//.css('background-color', 'green');

                var container = $('div[emp]:contains("' + Search + '")').parent();
                var scrollTo = $('div[emp]:contains("' + Search + '")');

                // Calculating new position of scrollbar
                var position = scrollTo.offset().top
                    - container.offset().top
                    + container.scrollTop();

                // Setting the value of scrollbar
                container.scrollTop(position);

            }

        }

        function ShowHideMeyuhedet() {


            if (!MaslulIdSelected) return;
            var SelectedObj = MaslulimData.filter(x => x.Id == MaslulIdSelected);

            if (SelectedObj[0].Sap_Id != 99) {

                $('#txtMdest,#txtMprice').val("");
                $('.txtM').hide();
            } else {

                $('.txtM').show();

            }

        }

        var TempSelectedTaxiId;

        function AddComment(TaxiId) {
            if (TaxiId) {
                TempSelectedTaxiId = TaxiId;

                var Comment = $("#" + TaxiId).attr("comment");
                $("#txtCommentAdd").val(Comment);
                $("#ModalComments").modal();
            } else {
                // save


                var Seq = $("#" + TempSelectedTaxiId).attr("seq");// .replace("dvTaxi_", "");
                var SearchDate = $('#txtSearchDate').val();
                var ShiftId = $('#ddlShift').val();
                var Dir = $('#ddlDirection').val();
                var Comment = $("#txtCommentAdd").val();
                var data = Ajax("Hasot_SetHasot", "Seq=" + Seq + "&Date=" + SearchDate + "&ShiftId=" + ShiftId + "&Dir=" + Dir + "&Mode=9&Comment=" + Comment);

                FillData();
                $("#ModalComments").modal('hide');

            }


            // alert(TaxiId);
        }

        function RestoreDelete(TaxiId) {


            if (TaxiId) {

                var SearchDate = $('#txtSearchDate').val();
                var ShiftId = $('#ddlShift').val();
                var Dir = $('#ddlDirection').val();
                var Seq = $("#" + TaxiId).attr("Seq");
                var data = Ajax("Hasot_SetHasot", "Seq=" + Seq + "&Date=" + SearchDate + "&ShiftId=" + ShiftId + "&Dir=" + Dir + "&Mode=13");

                FillData();


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
                            <option value="0">-- איסוף --</option>
                            <option value="1">-- פיזור --</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <select id="ddlShift" class="form-control">
                            <option value="1">-- בוקר --</option>
                            <option value="2">-- צהריים --</option>
                            <option value="3">-- לילה --</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <div class="input-group ls-group-input" id="parentdiv">
                            <input type="text" class="form-control" id="txtSearchDate">
                            <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>
                    <%-- <div class="col-md-1">
                        <button type="button" class="btn btn-info btn-round" onclick="FillData()">
                            <i class="glyphicon glyphicon-search"></i>&nbsp; <span class="btnAssign">חפש </span>
                        </button>
                    </div>--%>




                    <div class="col-md-6" style="text-align: left;">
                        <div class="btn btn-success btn-round" onclick="ClearData()" id="dvBtnLoadNew">
                            <i class="fa fa-recycle"></i>&nbsp; <span class="btnAssign">טען מחדש
                            </span>
                        </div>
                        <div class="btn btn-warning btn-round" onclick="RefreshData()">
                            <i class="fa fa-refresh"></i>&nbsp; <span class="btnAssign">רענן נתונים
                            </span>
                        </div>

                        <div class="btn btn-primary btn-round" id="dvHazmana" onclick="PrintData(2)">
                            <i class="fa fa-paper-plane"></i>&nbsp; <span class="btnAssign">הזמנה יומית
                            </span>
                        </div>
                        <div class="btn btn-default btn-round" id="dvHazmanaMinibusim" onclick="PrintData(4)">
                            <i class="fa fa-paper-plane"></i>&nbsp; <span class="btnAssign">הזמנה יומית מיניבוסים
                            </span>
                        </div>
                        <div class="btn btn-primary btn-round" onclick="PrintData(1)">
                            <i class="fa fa-print"></i>&nbsp; <span class="btnAssign">שוברים
                            </span>
                        </div>

                    </div>
                    <%--  <div class="col-md-1" style="margin-right:10px;">
                        <div class="btn btn-primary btn-round" onclick="SaveData()">
                            <i class="glyphicon glyphicon-floppy-save"></i>&nbsp; <span class="btnAssign">שמור סידור
                            </span>
                        </div>
                    </div>


                    <div class="col-md-1" style="margin-right:10px">
                        <div class="btn btn-info btn-round" onclick="PrintData()">
                            <i class="fa fa-print"></i>&nbsp; <span class="btnAssign">הדפסה
                            </span>
                        </div>
                    </div>--%>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-12">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading" style="text-align: center;">

                    <div style="float: right; position: absolute; right: 25px;" class="btn btn-info btn-xs btn-round" onclick='PageAction(3)'>
                        <span id="spCheckAll">סמן כל המוניות</span>  <i class="fa fa-check"></i>
                    </div>

                    <div style="float: left" class="btn btn-info btn-xs btn-round" onclick='PageAction(1)'>
                        נסיעה הבאה <i class="fa fa-arrow-circle-left"></i>
                    </div>
                    <div style="float: LEFT" class="btn btn-info btn-xs btn-round" onclick='PageAction(0)'>
                        <i class="fa fa-arrow-circle-right"></i>&nbsp;נסיעה לפני&nbsp;
                    </div>
                    <div style="float: left" class="btn btn-success btn-xs btn-round" onclick='PageAction(2)'>
                        הוסף הסעה <i class="fa fa-taxi"></i>
                    </div>

                    <div style="float: left; margin-left: 20px;">
                        <input type="text" id="txtSearch" style="height: 25px; background: white;" onkeyup="Search()" placeholder="חיפוש עובד\ת" class="form-control" />
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
        <div class="modal-dialog" style="width: 500px;">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">הוספת הסעה ל <span id="spDirectionForTaxi"></span>
                    </h4>
                </div>
                <div class="modal-body" id="Div4">
                    <div class="col-md-12" style="padding: 5px">
                        סוג הסעה (מונית או מיניבוס)
                        <br />

                        <select id="ddlCarType" class="form-control">
                            <option value="0">-- בחר סוג הסעה --</option>
                            <option value="1">-- מונית --</option>
                            <option value="2">-- מיניבוס --</option>
                        </select>
                    </div>

                    <div class="col-md-12" style="padding: 5px">
                        שעה
                        <br />
                        <div class="input-group ls-group-input col-md-12">
                            <input type="text" id="txtHourForTaxi" placeholder="שעה" style="font-weight: bold" class="form-control" />
                        </div>


                    </div>


                    <div class="col-md-12" style="padding: 5px">
                        בחירת מסלול <span style="color: red; font-weight: bold; font-size: smaller">(יש לשים לב לבחירת מסלול בהתאם לשעה שנבחרה מעלה!)</span>
                        <br />
                        <input type="text" id="ddlMaslulim" class="form-control typeahead" onchange="ShowHideMeyuhedet();" style="background: white" spellcheck="false" autocomplete="off"
                            placeholder=" מספר מסלול או שם מסלול" />
                        <%--  <select id="ddlMaslulim" class="form-control" onchange="ShowHideMeyuhedet()">
                            <option value="0">-- בחר מסלול --</option>
                        </select>--%>
                    </div>
                    <div class="col-md-12" style="padding: 5px">
                        <%-- <div class="btn ls-red-btn btn-round">
                            שים לב! השעות הם בין&nbsp; <b><u><span id="spStartTimeShift"></span></u></b>&nbsp;לבין
                            &nbsp;<b><u><span id="spEndTimeShift"></span></u> </b>
                        </div>--%>
                    </div>

                    <div class="col-md-12 txtM" style="padding: 5px; background-color: wheat; border: solid 1px red; border-radius: 10px;">
                        יעד לנסיעה מיוחדת
                        <br />
                        <div class="input-group ls-group-input col-md-12">
                            <input type="text" id="txtMdest" style="background: white" placeholder="יעד" class="form-control" />
                        </div>

                        מחיר
                        <br />
                        <div class="input-group ls-group-input col-md-12">
                            <input type="number" id="txtMprice" style="background: white" placeholder="מחיר" class="form-control" />
                        </div>
                    </div>



                    <div class="col-md-12" style="padding: 5px;">
                        הערות
                        <br />
                        <div class="input-group ls-group-input col-md-12">
                            <input type="text" id="txtComment" placeholder="הערות" class="form-control" />
                        </div>
                    </div>
                    <div class="col-md-12" style="text-align: left">
                        <button type="button" class="btn btn-info btn-round" onclick="AddTaxi()">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>הוסף הסעה</span>
                        </button>
                    </div>
                    <div class="col-md-12 dvMessageRed" id="dvAddAlert">
                        &nbsp;
                    </div>
                    <div class="clear">
                        &nbsp;
                    </div>
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
                    <h4 class="modal-title">עדכון עיר <span id="Span1"></span>
                    </h4>
                </div>
                <div class="modal-body" id="Div2">
                    <div class="col-md-12" style="padding: 5px">
                        <%--<select id="ddlCity" class="form-control">
                            <option value="0">-- בחר עיר --</option>
                        </select>--%>
                        <input type="text" id="txtCityTemp" class="form-control rounded" placeholder="בחר עיר ליעד החדש" style="background: white;" />
                    </div>
                    <div class="col-md-12" style="padding: 5px">
                        <input type="text" class="form-control" id="txtChangeCityAddress" placeholder="כתובת ליעד החדש" />
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
                        &nbsp;
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-info btn-xs" data-dismiss="modal">
                        סגור</button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="ModalComments" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">עדכון הערה להסעה</span>
                    </h4>
                </div>
                <div class="modal-body">
                    <div class="col-md-12" style="padding: 5px">

                        <label>הערה להסעה</label>
                    </div>
                    <div class="col-md-12" style="padding: 5px">

                        <input type="text" id="txtCommentAdd" class="form-control rounded" placeholder="" style="background: white;" />
                    </div>



                    <div class="col-md-12" style="text-align: left">
                        <button type="button" class="btn btn-info btn-round" onclick="AddComment(false)">
                            <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>עדכן הערה</span>
                        </button>
                    </div>

                    <div class="clear">
                        &nbsp;
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-info btn-xs" data-dismiss="modal">
                        סגור</button>
                </div>
            </div>
        </div>
    </div>



    <%-- טמפלט של מונית --%>
    <div id="dvTaxiTemplate0" style="display: none">
        <div class="col-md-3" style="margin: 5px;">
            <div class="row">
                <div class="panel panel-primary" style="margin: 2px">
                    <div class="panel-heading" style="background: @back">
                        <h3 class="panel-title">


                            <div style="float: right;">
                                <input type="checkbox" id="ch_@Seq" style="display: @displayChecbox" />&nbsp;&nbsp;
                            </div>


                            <div style="float: left; margin-right: 2px; font-weight: bold; border: solid 1px white;" class="btn btn-danger btn-xs btn-round" onclick='AddComment("@TaxiId")'>
                                ...
                            </div>
                            <div style="float: left; margin-right: 2px; font-weight: bold; border: solid 1px white; display: @displayDeleted" class="btn btn-default btn-xs btn-round" onclick='RestoreDelete("@TaxiId")'>
                                <i class="fa-lg fa fa-refresh"></i>
                            </div>

                            <div style="float: left; font-weight: bold; border: solid 1px white; display: @displayChecboxRemove" class="btn btn-danger btn-xs btn-round" onclick='DeleteTaxi("@TaxiId")'>
                                הסר @CarTypeHebrew
                            </div>
                            <i class="fa-lg fa fa-@CarType"></i>&nbsp; שעה: <b>@HasotTime</b>
                        </h3>
                    </div>
                    <div class="panel-body" style="padding: 2px;">

                        <div class="alert alert-danger" style="padding: 3px; margin: 0px;" title="@Comment">

                            <div>
                                <b>@Sap_Id</b> - @MaslulDesc  <span class="spCountPassenger badge"></span><span class="@badge" style="float: left; font-weight: bold; margin-top: 2px">@CarSymbol</span>
                                <span style="float: left; color: black; font-weight: bold; margin-top: 2px">@HasaNumber</span>
                            </div>


                        </div>



                        <div id="@TaxiId" class="maindivTaxi" city1="@City1" city2="@City2" city3="@City3" city4="@City4" sapid="@Sap_Id" cartypeid="@CarTypeId" seq="@Seq" carsymbol="@CarSymbol" hasottime="@HasotTime" masluldesc="@MaslulDesc" mdest="@mdest" mprice="@mprice" style="padding: 2px; height: 120px; overflow: auto"
                            hasotdate="@HasotDate" dirtaxi="@Dir" maslulid="@MaslulId" comment="@Comment" extrasapid="@ExtraSapId">
                        </div>


                    </div>
                </div>
            </div>
        </div>

    </div>
    <%-- טמפלט של עובד  btn-primary--%>
    <div id="dvEmpTemplate" style="display: none">


        <div title="@TextChange" class="col-md-6 btn @btnStyle btn-xs btn-round dvBtnWorker dvEmpInTaxi draggable" emp="" empcity="@EmpCity" tempcitytext="" tempstreet="@TempStreet" citycode="@CityCode" empno="@EmpNo" city="@CityCode"
            id="dv_@EmpNo" onclick="DeleteEmpFromTaxi(@EmpNo,@CarTypeId,this)">
            @EmpName <span class="badge @blink_me" style="float: left; margin-top: 1px">x</span>
        </div>
        <div class="col-md-5" style="padding-left: 0px; margin: 0px">
            <span class="spCity">@EmpCity </span>
            <span style="float: left; display: @displayNew" onclick="SetStatus(@HasotId)"><i class="fa fa-refresh" style="color: green"></i></span>
        </div>
        <div class="clear">
        </div>
    </div>

    <%-- טמפלט של עובד מחוק  btn-primary--%>
    <div id="dvEmpDeletedTemplate" style="display: none">

        <div class="col-md-10 empdelete" emp="">
            <span class="" style="text-decoration: line-through; text-decoration-thickness: 1px;">@EmpName - @EmpCity </span>
        </div>
        <div class="clear">
        </div>
    </div>


    <%-- טמפלט של ריק --%>
    <div id="dvEmptyTemplate" style="display: none">
        <div class="col-md-6 btn btn-default btn-xs btn-round dvBtnWorker droppable" style="background: white; border: solid 1px black;">
            &nbsp;
        </div>
        <div class="clear">
        </div>
    </div>

    <div id="dvNoMaslulTemplate" style="display: none">
        <div class="col-md-2 dvNoMaslulTemplate" style="float: left; position: absolute; left: 20px; margin-top: 5px;">
            <div class="row">
                <div class="panel panel-primary" style="margin: 2px">
                    <div class="panel-heading">
                        <h3 class="panel-title">
                            <i class="fa fa-taxi"></i>&nbsp; עובדים ללא הסעה
                        </h3>
                    </div>
                    <div class="panel-body" style="padding: 2px;">
                        <div class="col-md-12" style="margin-bottom: 10px; margin-top: 10px;">
                            <input type="text" class="form-control" id="txtNewOved" spellcheck="false" autocomplete="off"
                                placeholder=" מספר עובד או שם">
                        </div>
                        <div id="dvNonMaslulEmp">
                            &nbsp;
                        </div>
                        <div id="dvNonMaslulEmpFromDB" style="border: solid 1px gray; padding-top: 10px; height: 300px; overflow-y: auto; overflow-x: hidden">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <%-- טמפלט של עובד  --%>
    <div id="dvNonMaslulEmpTemplate" style="display: none">
        <div title="@TextChange" class="col-md-12 btn @btnStyle btn-xs btn-round dvBtnWorker draggable" emp="" onclick="ChangeCity(@EmpNo,this)"
            empno="@EmpNo" sourcecity="@City" sourcetempstreet="@TempStreet" sourceempcity="@EmpCity" city="@City" tempstreet="@TempStreet" empcity="@EmpCity">
            @EmpName - <u id="uNonMaslul_@EmpNo" empno="@EmpNo" city="@City">@EmpCity</u>
        </div>

        <div class="clear">
        </div>
    </div>


    <%-- טמפלט של הדפסה --%>
    <div id="dvPrintTemplate" style="display: none">
        <style>
            @media print {
                .break {
                    page-break-before: always;
                }

                .dvComments {
                    font-family: Arial, Helvetica, sans-serif !important;
                }

                .footer {
                    page-break-before: always;
                }

                .divPazText {
                    text-align: left;
                    text-decoration: underline;
                }

                .divTextNumber {
                    text-align: left;
                    font-weight: bold;
                    font-size: 18px;
                }

                .dvSomeText {
                    font-weight: bold;
                    font-size: 15px;
                }

                .spMaslulDesc {
                    font-size: 20px;
                }

                .tdUnderline {
                    border-bottom: solid 2px black;
                }

                .tdPaddingTop {
                    padding-top: 30px;
                }

                .spWrite {
                    text-decoration: underline;
                    font-weight: bold;
                }

                .tdPaddingRight {
                    padding-right: 20px;
                }

                .tdCube {
                    border: solid 1px gray;
                    vertical-align: top;
                    padding: 5px;
                    padding-bottom: 30px;
                }

                .spWriteDayOr {
                    border: solid 1px black;
                    border-radius: 20px;
                    padding: 10px;
                }

                .spPay {
                    margin-right: 37px;
                    padding-right: 37px;
                }

                .td50 {
                    width: 50%;
                }
            }
        </style>


        <table width="100%" style="padding: 0px; margin: 0px">
            <tr>
                <td>
            <%--        <img src="../assets/images/ZikukH.gif" width="250px" />--%>
                      <img src="../assets/images/Baza.png" width="250px" />

                    <%-- <div class="divPrintText" style="">חלוקת מנות אוכל יום:&nbsp;<span class="spPrintText"> @Day</span>  &nbsp;&nbsp; משמרת:&nbsp;<span class="spPrintText"> @ShiftText</span> </div>--%>

                </td>

                <td class="tdPaddingTop">
                 <%--    <div class="divPazText">פז בית זיקוק לנפט אשדוד בע"מ</div>--%>
                    <div class="divPazText"> בית זיקוק אשדוד בע"מ</div>
                    <br />
                    <div class="divTextNumber">@Numerator</div>
                </td>


            </tr>

            <tr>
                <td colspan="3" class="tdUnderline tdPaddingTop">

                    <div class="dvSomeText">לכבוד חברת מוניות</div>

                </td>


            </tr>

            <tr>
                <td>
                    <br />
                    <br />
                    <div class="dvSomeText">תאריך: <span class="spWrite">@Date</span> <span class="spWrite">@DateOrginal</span></div>
                    <br />
                    <div class="dvSomeText">שעה: <span class="spWrite">@Hour</span>  </div>
                    <br />
                    <div class="dvSomeText">נא לבצע עבורנו נסיעה במסלול: @MaslulDir <span class="spWrite spMaslulDesc">@MaslulDesc</span> </div>
                    <br />
                    <div class="dvSomeText"><span class="spWrite spMaslulDesc">עובדים</span>   </div>


                </td>
                <td></td>

            </tr>


            <tr>
                <td class="tdPaddingRight ">@WorkerList
                    <%--  <div class="dvSomeText"><span class="spWorkerNumber">2.</span><span class="spWorkerWrite">דוד עובדיה</span></div>
<div class="dvSomeText"><span class="spWorkerNumber">3.</span><span class="spWorkerWrite">דוד עובדיה</span></div>--%>
                </td>

            </tr>

            <tr>

                <td colspan="3" class="tdPaddingTop">
                    <table width="100%">
                        <tr>

                            <td class="tdCube td50" valign="top">
                                <div class="dvSomeText">שם מזמין:<span class="spWorkerWrite"></span></div>

                            </td>


                            <td class="tdCube td50" valign="top">
                                <div class="dvSomeText">חתימה:<span class="spWorkerWrite"></span></div>

                            </td>

                        </tr>
                    </table>

                </td>



            </tr>


            <tr>


                <td colspan="3" class="tdCube">

                    <div class="dvSomeText">הנסיעה בוצעה במונית: <span class="">__________</span>  </div>
                    <br />
                    <div class="dvSomeText">הנסיעה בוצעה: <span class="spWriteDayOr">@Day</span>  </div>
                    <br />
                    <div class="dvSomeText">מסלול מספר: <span class="spWrite">@Sap_Id </span><span class="spPay">הסכום:__________₪ </span></div>
                    <br />
                    <div class="dvSomeText">נסיעה מיוחדת מחיר יתואם מראש:<span class="">__________₪ </span></div>
                    <br />
                    <div class="dvSomeText dvComments" style="text-decoration: underline">הערות</div>

                    <br />
                    <div class="dvSomeText dvComments">@Comment</div>
                </td>

            </tr>



        </table>

    </div>


    <div id="dvWorkerTemplate" style="display: none">

        <div class="dvSomeText spMaslulDesc"><span class="spWorkerNumber">@WorkerNumber.&nbsp;</span><span class="spWorkerWrite">@WorkerName</span></div>

    </div>

    <div class="modal fade" id="ModalSendMail" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">

        <div class="vertical-alignment-helper">

            <div class="modal-lg vertical-align-center">
                <div class="modal-content taximodal-content">
                    <div class="modal-header label-info">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                            &times;</button>
                        <h4 class="modal-title">
                            <span style="float: right" id="spSendMailTitleIsuf"></span>
                            <span style="float: left; margin-left: 200px;" id="spSendMailTitlePizur"></span>
                            &nbsp;
                        </h4>
                    </div>
                    <div class="modal-body taximodal-body">
                        <div class="col-md-12" id="dvSendMail">

                            <style>
                                @media print {
                                    .break {
                                        page-break-before: always;
                                    }

                                    #dvPizur {
                                        float: right !important;
                                    }

                                    .imageDiv {
                                        /*content: url('../assets/images/ZikukH.gif');*/
                                        content: url('../assets/images/Baza.png');
                                        float: left;
                                        width: 150px;
                                    }


                                    .maslulTitle {
                                        text-decoration: underline;
                                        font-size: 18px;
                                    }

                                    .searchClass {
                                        background: green;
                                        color: white;
                                        font-weight: bold;
                                        border: solid 1px white;
                                        border-radius: 10px;
                                    }

                                    .nolineDeleted {
                                        font-weight: bold;
                                        color: darkred;
                                    }

                                    .nolineNew {
                                        font-weight: bold;
                                        color: green;
                                    }

                                    .dvPassTemplate {
                                        margin: 10px;
                                        font-size: 15px;
                                    }

                                    .dvDeletedPass {
                                        text-decoration: line-through;
                                        font-weight: bold;
                                        color: darkred;
                                    }

                                    .dvNewPass {
                                        font-weight: bold;
                                        color: green;
                                    }
                                }
                            </style>


                            <div style="font-size: 16px; font-weight: bold; direction: rtl" id="spCarTypeDesc"></div>
                              <%--<div style="font-size: 16px; font-weight: bold">מאת פז בית זיקוק אשדוד</div>--%>
                            <div style="font-size: 16px; font-weight: bold">מאת בית זיקוק אשדוד</div>
                            <br />

                            <div class="imageDiv"></div>

                            <div style="float: right" id="dvIsuf">
                            </div>

                            <div class="break @clearfix"></div>
                            <div class="imageDiv"></div>

                            <div style="float: left" id="dvPizur">
                            </div>





                        </div>



                        <div class="col-md-12" style="text-align: left">
                        </div>
                        <div class="col-md-12 dvMessageRed" id="dvErrorSendMail">
                        </div>
                        <div class="clear">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-info btn-round" id="btnSendMail" onclick="SendAction(1)">
                            <i class="fa fa-paper-plane"></i>&nbsp; <span>שלח מייל</span>
                        </button>



                        <div class="btn btn-primary btn-round" onclick="PrintData(3)">
                            <i class="fa fa-print"></i>&nbsp; <span class="btnAssign">הדפסה
                            </span>
                        </div>

                        <button type="button" class="btn btn-danger btn-round" data-dismiss="modal">
                            <i class="fa fa-close"></i>&nbsp;
    סגור</button>
                    </div>
                </div>
            </div>

        </div>
    </div>




    <div id="dvIsufRangeFilter" style="display: none">
        <div class="col-md-12 @ClassN" style="padding: 5px">

            <div class="col-md-1">משעה</div>
            <div class="col-md-3">
                <div class="input-group ls-group-input col-md-12">
                    <input type="text" id="txtHourForTaxiStartIsuf" placeholder="שעה" style="font-weight: bold" class="form-control" />
                </div>
            </div>

            <div class="col-md-1">עד </div>
            <div class="col-md-3">
                <div class="input-group ls-group-input col-md-12">
                    <input type="text" id="txtHourForTaxiEndIsuf" placeholder="שעה" style="font-weight: bold" class="form-control" />
                </div>
            </div>

        </div>
    </div>


    <div id="dvPizurRangeFilter" style="display: none">
        <div class="col-md-12 @ClassN" style="padding: 5px">

            <div class="col-md-1">משעה</div>
            <div class="col-md-3">
                <div class="input-group ls-group-input col-md-12">
                    <input type="text" id="txtHourForTaxiStartPizur" placeholder="שעה" style="font-weight: bold" class="form-control" />
                </div>
            </div>

            <div class="col-md-1">עד </div>
            <div class="col-md-3">
                <div class="input-group ls-group-input col-md-12">
                    <input type="text" id="txtHourForTaxiEndPizur" placeholder="שעה" style="font-weight: bold" class="form-control" />
                </div>
            </div>

        </div>
    </div>

    <div id="dvDateTemplate" style="display: none">
        <div style="font-size: 20px; font-weight: bold; text-decoration: underline">תאריך @HasotDateHeb <span style="font-weight: bold">@DirectionAndShift</span> </div>

    </div>
    <div id="dvMaslulTemplate" style="display: none">
        <br class="@ShiftId_@Dir_@HasotTime"/>
        <div style="font-weight: bold;" class="@ShiftId_@Dir_@HasotTime"><span class="@ClassPass">@MaslulDesc </span><span class="@nolineTitle">@Status</span> </div>
    </div>
    <div id="dvPassTemplate" style="display: none">
        <div class="dvPassTemplate @ShiftId_@Dir_@HasotTimeFilter">

            <span style="font-weight: bold; direction: rtl" class="@ClassPass">@HasotTime - </span>
            <span class="@ClassPass">@EmpName</span>
            <span style="font-weight: bold" class="@ClassPass">@PhoneNum</span>
            <span class="@ClassPass">@Street</span>
            <span style="font-weight: bold" class="@ClassPass">@City</span>
            <span class="@noline">@Status</span>
        </div>
    </div>


    <style>
        .blink_me {
            animation: blinker 1s linear infinite;
        }

        @keyframes blinker {
            50% {
                opacity: 0;
            }
        }

        .overflow {
            overflow: hidden !important;
        }

        /* #dvPizur{

             background-image:url('../assets/images/ZikukH.gif');
        }*/
        .maslulTitle {
            text-decoration: underline;
            font-size: 18px;
        }

        .searchClass {
            background: green;
            color: white;
            font-weight: bold;
            border: solid 1px white;
            border-radius: 10px;
        }

        .nolineDeleted {
            font-weight: bold;
            color: darkred;
        }

        .nolineNew {
            font-weight: bold;
            color: green;
        }

        .dvPassTemplate {
            margin: 10px;
            font-size: 15px;
        }

        .dvDeletedPass {
            text-decoration: line-through;
            font-weight: bold;
            color: darkred;
        }

        .dvNewPass {
            font-weight: bold;
            color: green;
        }

        .vertical-alignment-helper {
            display: table;
            height: 50%;
            width: 100%;
            pointer-events: none;
        }

        .vertical-align-center {
            /* To center vertically */
            display: table-cell;
            vertical-align: middle;
            pointer-events: none;
        }

        .taximodal-content {
            /* Bootstrap sets the size of the modal in the modal-dialog class, we need to inherit it */
            width: 90%;
            max-width: inherit; /* For Bootstrap 4 - to avoid the modal window stretching 
full width */
            height: inherit;
            /* To center horizontally */
            margin: 0 auto;
            pointer-events: all;
        }

        .taximodal-body {
            height: 550px;
            overflow: auto;
        }
    </style>


    <div class="modal fade" id="ModalWaitAjax" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-primary">

                    <h4 class="modal-title bg-primary">הודעת מערכת
                    </h4>
                </div>
                <div class="modal-body">
                    <div class="col-md-12" style="padding: 5px; text-align: center; font-size: 25px">
                        המערכת שולחת מייל לתחנת  <span id="spcarTypeId"></span>
                        <br />
                        <br />
                        <img src="../assets/images/ajax-loader.gif" width="100px" />
                        <br />
                        <br />
                        אנא המתן...
                    </div>

                    <div class="clear">
                        &nbsp;
                    </div>
                </div>

            </div>
        </div>
    </div>
</asp:Content>
