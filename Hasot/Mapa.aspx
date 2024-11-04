<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage/MasterPage.master" AutoEventWireup="true"
    CodeFile="Mapa.aspx.cs" Inherits="Hasot_Mapa" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
    <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
    <link href="../assets/css/rtl-css/typeahead.js-bootstrap.css" rel="stylesheet" type="text/css" />
    <script src="../assets/js/bootstrap3-typeahead.min.js" type="text/javascript"></script>
    <script type="text/javascript">

        var mydata;
        var DayInWeek;
        var CityList;
        var CityValueCode;
        var CityValueDesc;
        var comboDates;

        var addDatesShow = false;

        var FirstStartDate = "";
        var FirstEndDate = "";
        $(document).ready(function () {


            InitDatesCombo();

            $(".dvAddedDates").hide();
            


            InitData();
            CityList = Ajax("Gen_GetTable", "TableName=Codes&Condition=TableId=17");

            ChangeDate();
            InitTypeHead();

            $(window).scroll(function () {
                $("#dvArgaz").css({
                    "top": ($(window).scrollTop()) + "px",
                    "left": ($(window).scrollLeft()) + "px"
                });
            });

        });


        function AddDates() {
            if (addDatesShow) {
                $(".dvAddedDates").hide();
                addDatesShow = false;
            } else {
                $(".dvAddedDates").show();
                addDatesShow = true;

            }


        }

        function InitDatesCombo() {
            comboDates = Ajax("Hasot_SetGetMaps", "TypeAction=0");
            $("#ddlDates").html("");

            for (var i = 0; i < comboDates.length; i++) {
                var Items = "";



                var FullDateRange = comboDates[i].FullDateRange;
                var IsSelect = comboDates[i].IsSelect;
                var selected = "";
                if (IsSelect == 1) {
                    selected = "selected";
                    FirstStartDate = comboDates[i].StartDate;
                    FirstEndDate = comboDates[i].EndDate;
                    InitDateTimePickerPlugin('#txtStartDate', FirstStartDate, false, false);
                    InitDateTimePickerPlugin('#txtEndDate', FirstEndDate, false, false);
                }
               
                   
                Items += '<option value="' + FullDateRange + '" ' + selected+' >' + FullDateRange + '</option>';

                $("#ddlDates").append(Items);

            }

        }

        function ChangeDate() {
            var CurrentSelectedDates = $("#ddlDates").val();

            var ObgFullDates = comboDates.filter(x => x.FullDateRange == CurrentSelectedDates);

            if (ObgFullDates.length > 0) {
                FirstStartDate = ObgFullDates[0].StartDate;
                FirstEndDate = ObgFullDates[0].EndDate;
                //$("#txtStartDate").val(ObgFullDates[0].StartDate);
                //$("#txtEndDate").val(ObgFullDates[0].EndDate);

                FillData();
            }



        }

        function RemoveDates() {

            var CurrentSelectedDates = $("#ddlDates").val();

            var ObgFullDates = comboDates.filter(x => x.FullDateRange == CurrentSelectedDates);

            if (ObgFullDates.length > 0) {
                var IsSelect = ObgFullDates[0].IsSelect;

                if (IsSelect == 1) {
                    bootbox.alert("לא ניתן להסיר את טווח התאריכים המעודכן להיום");
                    return;
                }

                bootbox.confirm("שים לב, המערכת מוחקת את כל הנתונים לטווח תאריכים זה, האם אתה בטוח?", function (result) {
                    if (result) {
                        var StartDate = $("#txtStartDate").val();
                        var EndDate = $("#txtEndDate").val();

                        mydata = Ajax("Hasot_SetGetMaps", "TypeAction=42&StartDate=" + FirstStartDate + "&EndDate=" + FirstEndDate);

                        InitDatesCombo();
                        FillData();
                    }
                });

            }


        }

        function SaveNewDates() {


           
            var CurrentSelectedDates = $("#ddlDates").val();
            var ObgFullDates = comboDates.filter(x => x.FullDateRange == CurrentSelectedDates);

            if (ObgFullDates.length > 0) {
                var StartDate = $("#txtStartDate").val();
                var EndDate = $("#txtEndDate").val();

             

                if (!IsDateValid(StartDate) || !IsDateValid(EndDate)) {

                    bootbox.alert("חובה לבחור תאריכים תיקניים!");
                    return;
                }


                mydata = Ajax("Hasot_SetGetMaps", "TypeAction=22&StartDate=" + StartDate + "&EndDate=" + EndDate + "&CopyStartDate=" + ObgFullDates[0].StartDate + "&CopyEndDate=" + ObgFullDates[0].EndDate);

                if (mydata[0].res == 1) {

                    InitDatesCombo();
                    FillData();
                    AddDates();
                    $("#txtStartDate,#txtEndDate").val("");
                } else {

                    bootbox.alert("עליך לבחור טווח תאריכים נכון");
                }
                
            }
        }

        function InitTypeHead() {
            $('.typeahead').typeahead({
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

        function FillData() {
            var StartDate = $("#txtStartDate").val();
            var EndDate = $("#txtEndDate").val();
            mydata = Ajax("Hasot_SetGetMaps", "TypeAction=1&StartDate=" + FirstStartDate + "&EndDate=" + FirstEndDate);
            var PrevId = "";
            var TargetId = "";

            $('div[id^="dvMainBody"]').html("");


            for (var i = 0; i < mydata.length; i++) {



                if (PrevId != mydata[i].Id) {
                    var PizurIsufTemplate = $('#dvPizurIsufTemplate').html();

                    var Type = mydata[i].Type;
                    var Name = "איסוף";
                    var BtnClass = "success";
                    if (Type == 1) {
                        Name = "פיזור";
                        BtnClass = "warning";

                    }

                    var Hour = (mydata[i].Hour) ? (getHourFromObj(mydata[i].Hour)) : "";
                    var IsOvdeYom = (mydata[i].IsOvdeYom == 1) ? "ע.יום" : "";
                    var IsImahot = (mydata[i].IsImahot == 1) ? "אמהות" : "";
                    var OnlyDays = mydata[i].OnlyDays;


                    PizurIsufTemplate = PizurIsufTemplate.replace(/@Id/g, mydata[i].Id);
                    PizurIsufTemplate = PizurIsufTemplate.replace(/@Name/g, Name);
                    PizurIsufTemplate = PizurIsufTemplate.replace(/@classbtn/g, BtnClass);
                    PizurIsufTemplate = PizurIsufTemplate.replace(/@Hour/g, Hour);
                    PizurIsufTemplate = PizurIsufTemplate.replace(/@ImahotOvdot/g, IsImahot);
                    PizurIsufTemplate = PizurIsufTemplate.replace(/@OvdeYom/g, IsOvdeYom);
                    PizurIsufTemplate = PizurIsufTemplate.replace(/@Day/g, OnlyDays);

                    var DayInWeek = mydata[i].DayInWeek;
                    var ShiftId = mydata[i].ShiftId;

                    TargetId = '#dvMainBody' + DayInWeek + '_' + ShiftId;



                    $(TargetId).append(PizurIsufTemplate);

                    if (mydata[i].Hour) $(TargetId).find("#dvMaindir_" + mydata[i].Id).find(".spHour").show();
                    if (mydata[i].IsOvdeYom) $(TargetId).find("#dvMaindir_" + mydata[i].Id).find(".spOvdeYom").show();
                    if (mydata[i].IsImahot) $(TargetId).find("#dvMaindir_" + mydata[i].Id).find(".spImahotOvdot").show();
                    if (mydata[i].OnlyDays) $(TargetId).find("#dvMaindir_" + mydata[i].Id).find(".spDay").show();

                    PrevId = mydata[i].Id;
                }


                if (mydata[i].DetailsId) {


                    var CarAndDestTemplate = $('#dvRowTemplate').html();

                    CarAndDestTemplate = CarAndDestTemplate.replace(/@Id/g, mydata[i].DetailsId);

                    CarAndDestTemplate = CarAndDestTemplate.replace(/@City/g, getCityNameByValue(mydata[i].City));



                    //  spCarCount


                    $(TargetId).find("#dvMaindir_" + mydata[i].Id).find(".dvList").append(CarAndDestTemplate);


                    if (mydata[i].CarType) $(TargetId).find("#dvMaindir_" + mydata[i].Id).find("#dvRow_" + mydata[i].DetailsId).find(".spCarName").text(mydata[i].CarType);
                    if (mydata[i].CarSymbol) $(TargetId).find("#dvMaindir_" + mydata[i].Id).find("#dvRow_" + mydata[i].DetailsId).find(".spCarCount").text(mydata[i].CarSymbol);


                }



            }

            DefineDragAndDropEvents();


        }

        function getCityNameByValue(CityValue) {

            var CityName = CityList.filter(x => x.ValueCode == CityValue);

            if (CityName.length == 1) {

                return CityName[0].ValueDesc;
            }

            return "";
        }

        function getHourFromObj(Obj) {


            return ((Obj.Hours.toString().length == 1 || Obj.Hours == 0) ? ("0" + Obj.Hours) : Obj.Hours) + ":" + ((Obj.Minutes.toString().length == 1 || Obj.Minutes == 0) ? ("0" + Obj.Minutes) : Obj.Minutes);

        }

        //function FillAjax() {
        //    mydata = Ajax("Hasot_SetGetMaps", "TypeAction=1" + SearchDate + "&Type=2&EmpNo="
        //        + EmpNo + "&AreaId=" + AreaId + "&FoodHeadersId=" + FoodHeadersId);


        //}



        function InitData() {
            $('#txtHourForTaxi').datetimepicker(
                {

                    datepicker: false,
                    format: 'H:i',
                    mask: true,
                    step: 15
                });




            expand(null, 15);
            DefineDragAndDropEvents();
            GetComboItemsSync("Codes", "TableId=1", "#ddlDays", "ValueCode", "ValueDesc");
            $("#ddlDays option[value=0],#ddlDays option[value=25],#ddlDays option[value=6],#ddlDays option[value=7]").remove();

            //CityList = Ajax("Gen_GetTable", "TableName=Codes&Condition=TableId=17");
            //BuildCombo(CityList, "#ddlCity", "ValueCode", "ValueDesc");



        }

        function DefineDragAndDropEvents() {
            $(".draggable").draggable({
                helper: "clone",
                cursor: "hand",
                // revert: true,
                start: function (event, ui) {


                    if (ui.helper.context.id == "dvCity") {

                        var SelectedCity = $("#ddlCity").val();
                        $(ui.helper[0]).find("#ddlCity").val(SelectedCity);
                    }


                    if (ui.helper.context.id == "dvDay") {

                        var SelectedDays = $("#ddlDays").val();
                        $(ui.helper[0]).find("#ddlDays").val(SelectedDays);
                    }


                    ui.helper.css("z-index", "2000");
                    ui.helper.width($(this).width());

                }


            });




            $(".droppable").droppable({
                // activeClass: "ui-state-default",
                // hoverClass: "ui-state-hover",
                accept: ".draggable",
                drop: function (event, ui) {

                    debugger

                    var TargetId = $(this).attr("id");

                    var SourceId = ui.draggable.attr("id");


                    var ShiftId = TargetId.substring(TargetId.indexOf("_") + 1);



                    // הסרת איסוף פיזור
                    if (SourceId.indexOf("dvMaindir_") != -1 && TargetId == "dvArgaz") {

                        $("#" + SourceId).remove();


                        Ajax("Hasot_SetGetMaps", "TypeAction=4&Id=" + SourceId.replace("dvMaindir_", ""));

                    }

                    //העתקה אחד לשני
                    if (SourceId.indexOf("dvMaindir_") != -1 && TargetId.indexOf("dvMainBody") != -1) {

                        //var Template = $("#" + SourceId).parent().html();
                        //$('#' + TargetId).append(Template);
                        var res = Ajax("Hasot_SetGetMaps", "TypeAction=6&Id=" + SourceId.replace("dvMaindir_", "") + "&Type=0&ShiftId=" + ShiftId + "&DayInWeek=" + DayInWeek);
                        //   Ajax("Hasot_SetGetMaps", "TypeAction=4&Id=" + SourceId.replace("dvMaindir_", ""));
                        FillData();
                    }

                    // הוספת איסוף פיזור חדש
                    if ((SourceId == "dvIsuf" || SourceId == "dvPizur") && TargetId.indexOf("dvMainBody") != -1) {

                        var StartDate = $("#txtStartDate").val();
                        var EndDate = $("#txtEndDate").val();

                        var Type = (SourceId == "dvIsuf") ? 0 : 1;
                        var res = Ajax("Hasot_SetGetMaps", "TypeAction=2&Id=0&Type=" + Type + "&ShiftId=" + ShiftId + "&DayInWeek=" + DayInWeek + "&StartDate=" + StartDate + "&EndDate=" + EndDate);

                        var NewId = res[0].Id;

                        var PizurIsufTemplate = $('#dvPizurIsufTemplate').html();
                        if (SourceId == "dvIsuf") {

                            PizurIsufTemplate = PizurIsufTemplate.replace(/@Id/g, NewId);
                            PizurIsufTemplate = PizurIsufTemplate.replace(/@Name/g, "איסוף");
                            PizurIsufTemplate = PizurIsufTemplate.replace(/@classbtn/g, "success");
                            PizurIsufTemplate = PizurIsufTemplate.replace(/@Hour/g, "");
                            PizurIsufTemplate = PizurIsufTemplate.replace(/@ImahotOvdot/g, "");
                            PizurIsufTemplate = PizurIsufTemplate.replace(/@OvdeYom/g, "");
                            PizurIsufTemplate = PizurIsufTemplate.replace(/@Day/g, "");
                        }

                        if (SourceId == "dvPizur") {
                            PizurIsufTemplate = PizurIsufTemplate.replace(/@Id/g, NewId);
                            PizurIsufTemplate = PizurIsufTemplate.replace(/@Name/g, "פיזור");
                            PizurIsufTemplate = PizurIsufTemplate.replace(/@classbtn/g, "warning");
                            PizurIsufTemplate = PizurIsufTemplate.replace(/@Hour/g, "");
                            PizurIsufTemplate = PizurIsufTemplate.replace(/@ImahotOvdot/g, "");
                            PizurIsufTemplate = PizurIsufTemplate.replace(/@OvdeYom/g, "");
                            PizurIsufTemplate = PizurIsufTemplate.replace(/@Day/g, "");
                        }

                        $('#' + TargetId).append(PizurIsufTemplate);
                        DefineDragAndDropEvents();
                        // alert(TargetId);

                    }

                    // העתקה מאחד לשני בימים אחרים לשישי ושבת
                    if (SourceId.indexOf("dvMaindir_") != -1 && TargetId.startsWith("a") && TargetId.endsWith("Link")) {


                        var ParentSourceContainer = $('#' + SourceId).parent().attr("id");
                        var ShiftIdNew = ParentSourceContainer.substr(ParentSourceContainer.length - 1);
                        var DayInWeekNew = TargetId.replace("a", "").replace("Link", "");

                        var res = Ajax("Hasot_SetGetMaps", "TypeAction=6&Id=" + SourceId.replace("dvMaindir_", "") + "&Type=0&ShiftId=" + ShiftIdNew + "&DayInWeek=" + DayInWeekNew);
                        FillData();


                        $("#" + TargetId).click();

                    }



                }
            });

            $(".droppableArea").droppable({
                // activeClass: "ui-state-default",
                // hoverClass: "ui-state-hover",
                accept: ".draggable",
                drop: function (event, ui) {
                    
                    var TargetId = $(this).attr("id");

                    var SourceId = ui.draggable.attr("id");

                    if (SourceId == "dvIsuf" || SourceId == "dvPizur") {
                        // 
                        return;
                    }

                    var dvMaindirId = TargetId.replace("dvMaindir_", "");

                    if (SourceId == "dvHours" && TargetId.indexOf("dvMaindir_") != -1) {




                        var Hour = $('#txtHourForTaxi').val();

                        if (Hour == "__:__") {
                            bootbox.alert("חובה לשים שעה תקינה!");
                            return;

                        }

                        $('#' + TargetId).find(".spHour").text(Hour);
                        $('#' + TargetId).find(".spHour").show();


                        Ajax("Hasot_SetGetMaps", "TypeAction=2&Id=" + dvMaindirId + "&Hour=" + Hour);






                    }

                    if (SourceId == "dvOvdeYom" && TargetId.indexOf("dvMaindir_") != -1) {




                        $('#' + TargetId).find(".spOvdeYom").text("ע.יום");
                        $('#' + TargetId).find(".spOvdeYom").show();


                        Ajax("Hasot_SetGetMaps", "TypeAction=2&Id=" + dvMaindirId + "&IsOvdeYom=1");


                    }

                    if (SourceId == "dvImahot" && TargetId.indexOf("dvMaindir_") != -1) {




                        $('#' + TargetId).find(".spImahotOvdot").text("אמהות");
                        $('#' + TargetId).find(".spImahotOvdot").show();

                        Ajax("Hasot_SetGetMaps", "TypeAction=2&Id=" + dvMaindirId + "&IsImahot=1");

                    }

                    if (SourceId == "dvDay" && TargetId.indexOf("dvMaindir_") != -1) {

                        var DayValue = $("#ddlDays option:selected").val();

                        if (!DayValue) {
                            bootbox.alert("חובה לבחור יום בכדי להוסיפו!");
                            return;
                        }
                        var Day = $("#ddlDays option:selected").text();// $('#ddlDays').val();
                        Day = $.trim(Day.replace("יום", ""));

                        // if (Day == "שבת") Day = "ז";




                        var ExistDay = $('#' + TargetId).find(".spDay").text();

                        if (ExistDay == "null") ExistDay = null;

                        if (ExistDay && ExistDay.indexOf(Day) > -1) {
                            bootbox.alert("יום זה קיים !");
                            return;

                        }

                        if (ExistDay) {
                            Day = ExistDay + "-" + Day;

                        }



                        Day = Day + "'";
                        $('#' + TargetId).find(".spDay").text(Day);
                        $('#' + TargetId).find(".spDay").show();



                        Ajax("Hasot_SetGetMaps", "TypeAction=2&Id=" + dvMaindirId + "&OnlyDays=" + Day);

                    }

                    if (SourceId == "dvCity" && TargetId.indexOf("dvMaindir_") != -1) {

                        

                        var CarAndDestTemplate = $('#dvRowTemplate').html();

                        //var CurrentListCity = $('#' + TargetId).find(".dvList").text();
                        //if (CurrentListCity.indexOf(CityValueDesc) > -1) {


                        //    return;
                        //}

                        var res = Ajax("Hasot_SetGetMaps", "TypeAction=3&Id=0&MapsId=" + dvMaindirId + "&City=" + CityValueCode);

                        var NewId = res[0].Id;

                        CarAndDestTemplate = CarAndDestTemplate.replace(/@Id/g, NewId);

                        CarAndDestTemplate = CarAndDestTemplate.replace(/@City/g, CityValueDesc);


                        $('#' + TargetId).find(".dvList").append(CarAndDestTemplate);

                        DefineDragAndDropEvents();

                    }

                    if (SourceId == "dvSwitch" && TargetId.indexOf("dvMaindir_") != -1) {



                        Ajax("Hasot_SetGetMaps", "TypeAction=7&Id=" + dvMaindirId);
                        FillData();

                    }



                }
            });

            $(".droppableCity").droppable({
                // activeClass: "ui-state-default",
                // hoverClass: "ui-state-hover",
                accept: ".draggable",
                drop: function (event, ui) {





                    var TargetId = $(this).attr("id");
                    var SourceId = ui.draggable.attr("id");
                    if (SourceId == "dvIsuf" || SourceId == "dvPizur") {
                        // 
                        return;
                    }



                    if ((SourceId == "dvMinibus" || SourceId == "dvTaxi") && TargetId.indexOf("dvRow_") != -1) {





                        var Count = "";
                        var CarType = "";
                        if (SourceId == "dvMinibus") {

                            Count = $('#txtMinibusCount').val();
                            CarType = "מיניבוס";
                            $('#' + TargetId).find(".spCarCount").text(Count);
                            $('#' + TargetId).find(".spCarName").text(CarType);


                        }

                        if (SourceId == "dvTaxi") {
                            Count = $('#txtTaxiCount').val();
                            CarType = "מונית";
                            $('#' + TargetId).find(".spCarCount").text(Count);
                            $('#' + TargetId).find(".spCarName").text(CarType);

                        }



                        //$('#' + TargetId).find(".dvList").append(CarAndDestTemplate);
                        Ajax("Hasot_SetGetMaps", "TypeAction=3&Id=" + TargetId.replace("dvRow_", "") + "&CarType=" + CarType + "&CarSymbol=" + Count);
                        $('#' + TargetId).find(".dvCarContainer").show();
                        DefineDragAndDropEvents();

                    }



                }
            });
        }



        function deleteFromTitle(Id, sp) {

            $("#dvMaindir_" + Id).find("." + sp).remove();

            //<span><span onclick="deleteFromTitle('@Id','spDay')" class="badge spDay">@Day</span></span>
            //      <span><span onclick="deleteFromTitle('@Id','spHour')" class="badge spHour">@Hour</span></span>
            //      <span><span onclick="deleteFromTitle('@Id','spImahotOvdot')" class="badge spImahotOvdot">@ImahotOvdot</span></span>
            //      <span><span onclick="deleteFromTitle('@Id','spOvdeYom')" class="badge spOvdeYom">@OvdeYom</span></span>
            //if(sp=="")
            Ajax("Hasot_SetGetMaps", "TypeAction=41&Id=" + Id + "&City=" + sp);

        }

        function deleteFromCarRow(Id, sp) {
            $("#dvRow_" + Id).remove();
            Ajax("Hasot_SetGetMaps", "TypeAction=5&Id=" + Id);
        }

        function expand(Obj, id) {


            DayInWeek = id;




            if (id == "6" || id == "7") {
                $('#dvDay').hide();
            } else {
                $('#dvDay').show();

            }

            $("a").css("font-size", "");

            $('.collapse').collapse('hide');


            $('#dvDays' + id).collapse('show');


            if (Obj)
                $(Obj).css("font-size", "20px");
            else
                $('#a15Link').css("font-size", "20px");


        }


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="col-md-12">
        <div class="row">

            <style>
                .linkDays {
                    width: 130px;
                    text-align: center;
                    border: solid 4px lightGray;
                }

                .datesection {
                    padding-top: 7px;
                }

                .content {
                    min-height: 10px;
                    height: auto;
                    overflow: auto;
                    border-radius: 10px;
                }

                .dvDirectionTitle {
                    border-bottom: dashed 2px white;
                    padding-bottom: 5px;
                }

                .dvList {
                    padding: 0px;
                    padding-top: 5px;
                }

                .spImahotOvdot, .spHour, .spOvdeYom, .spDay {
                    display: none;
                    cursor: pointer;
                }

                .dvCarCity {
                    cursor: pointer;
                    font-weight: bold;
                }

                .droppableCity {
                    padding-bottom: 5px;
                }

                .spCarName {
                    font-weight: bold;
                }

                .spCarCount {
                    font-weight: bold;
                    float: left;
                    margin-top: 1px;
                }
            </style>


            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-th-list"></i>&nbsp; <b>מפת הסעות שבועי</b>
                    </h3>
                </div>
                <div class="panel-body">
                    <div class="col-md-4">
                        <a class="btn btn-primary btn-round linkDays droppable" id="a15Link" onclick="expand(this,15);" aria-expanded="false" aria-controls="dvDays15"><i class="glyphicon glyphicon-bell pull-left"></i>ימים א-ה </a>
                        <a class="btn btn-primary btn-round linkDays droppable" id="a6Link" onclick="expand(this,6);" aria-expanded="false" aria-controls="dvDays6"><i class="glyphicon glyphicon-bell pull-left"></i>יום שישי </a>
                        <a class="btn btn-primary btn-round linkDays droppable" id="a7Link" onclick="expand(this,7);" aria-expanded="false" aria-controls="dvDays6"><i class="glyphicon glyphicon-bell pull-left"></i>יום שבת </a>

                    </div>


                    <div class="col-md-3 datesection">
                        <select id="ddlDates" class="form-control" style="background: white;font-weight:bold" onchange="ChangeDate()">
                            <option value="">-- בחר תאריכים --</option>
                        </select>
                    </div>
                    <div class="col-md-1 datesection">
                        <div type="button" class="btn btn-danger btn-round" style="" onclick="RemoveDates()">
                            <i class="fa fa-remove"></i>&nbsp; <span>מחק </span>
                        </div>
                    </div>
                    <div class="col-md-3 datesection" style="text-align:center">
                         <div type="button" class="btn btn-success btn-round" style="" onclick="AddDates()">
                            <i class="fa fa-calendar"></i>&nbsp; <span>  צור טווח תאריכים חדש  </span>
                        </div>
                      
                    </div>

                    <div class="clear"></div>
                     <div class="col-md-7">
                     </div>
                    <div class="col-md-2 dvAddedDates">
                        <div class="input-group ls-group-input">
                            <input type="text" class="form-control txtDate" id="txtStartDate" />
                            <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>
                   
                    <div class="col-md-2 dvAddedDates">
                        <div class="input-group ls-group-input">
                            <input type="text" class="form-control txtDate" id="txtEndDate" />
                            <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>

                    <div class="col-md-1 dvAddedDates">
                        <div type="button" class="btn btn-primary btn-round" style="width: 100%" onclick="SaveNewDates()">
                            <i class="glyphicon glyphicon-save"></i>&nbsp;<span>הוסף</span>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <hr />

                    </div>

                    <div class="col-md-9" style="padding: 0px">
                        <div class="col-md-12">
                            <div id="dvDays15" class="collapse multi-collapse">
                                <div class="col-md-4" style="padding-right: 0px">

                                    <div class="panel panel-info">
                                        <div class="panel-heading">
                                            <h3 class="panel-title">
                                                <i class="fa fa-taxi"></i>&nbsp; משמרת בוקר
                                            </h3>
                                        </div>
                                        <div class="panel-body droppable" id="dvMainBody15_1" style="padding-bottom: 200px;">
                                        </div>
                                    </div>

                                </div>
                                <div class="col-md-4" style="padding-right: 0px">

                                    <div class="panel panel-info">
                                        <div class="panel-heading">
                                            <h3 class="panel-title">
                                                <i class="fa fa-taxi"></i>&nbsp; משמרת צהריים
                                            </h3>
                                        </div>
                                        <div class="panel-body droppable" id="dvMainBody15_2" style="padding-bottom: 200px;">
                                        </div>
                                    </div>

                                </div>
                                <div class="col-md-4" style="padding-right: 0px">

                                    <div class="panel panel-info">
                                        <div class="panel-heading">
                                            <h3 class="panel-title">
                                                <i class="fa fa-taxi"></i>&nbsp; משמרת לילה
                                            </h3>
                                        </div>
                                        <div class="panel-body droppable" id="dvMainBody15_3" style="padding-bottom: 200px;">
                                        </div>
                                    </div>

                                </div>
                            </div>





                        </div>
                        <div class="col-md-12">
                            <div id="dvDays6" class="collapse multi-collapse">
                                <div class="col-md-4" style="padding-right: 0px">

                                    <div class="panel panel-info">
                                        <div class="panel-heading">
                                            <h3 class="panel-title">
                                                <i class="fa fa-taxi"></i>&nbsp; משמרת בוקר
                                            </h3>
                                        </div>
                                        <div class="panel-body droppable" id="dvMainBody6_1" style="padding-bottom: 200px;">
                                        </div>
                                    </div>

                                </div>
                                <div class="col-md-4" style="padding-right: 0px">

                                    <div class="panel panel-info">
                                        <div class="panel-heading">
                                            <h3 class="panel-title">
                                                <i class="fa fa-taxi"></i>&nbsp; משמרת צהריים
                                            </h3>
                                        </div>
                                        <div class="panel-body droppable" id="dvMainBody6_2" style="padding-bottom: 200px;">
                                        </div>
                                    </div>

                                </div>
                                <div class="col-md-4" style="padding-right: 0px">

                                    <div class="panel panel-info">
                                        <div class="panel-heading">
                                            <h3 class="panel-title">
                                                <i class="fa fa-taxi"></i>&nbsp; משמרת לילה
                                            </h3>
                                        </div>
                                        <div class="panel-body droppable" id="dvMainBody6_3" style="padding-bottom: 200px;">
                                        </div>
                                    </div>

                                </div>
                            </div>
                        </div>
                        <div class="col-md-12">
                            <div id="dvDays7" class="collapse multi-collapse">
                                <div class="col-md-4" style="padding-right: 0px">

                                    <div class="panel panel-info">
                                        <div class="panel-heading">
                                            <h3 class="panel-title">
                                                <i class="fa fa-taxi"></i>&nbsp; משמרת בוקר
                                            </h3>
                                        </div>
                                        <div class="panel-body droppable" id="dvMainBody7_1" style="padding-bottom: 200px;">
                                        </div>
                                    </div>

                                </div>
                                <div class="col-md-4" style="padding-right: 0px">

                                    <div class="panel panel-info">
                                        <div class="panel-heading">
                                            <h3 class="panel-title">
                                                <i class="fa fa-taxi"></i>&nbsp; משמרת צהריים
                                            </h3>
                                        </div>
                                        <div class="panel-body droppable" id="dvMainBody7_2" style="padding-bottom: 200px;">
                                        </div>
                                    </div>

                                </div>
                                <div class="col-md-4" style="padding-right: 0px">

                                    <div class="panel panel-info">
                                        <div class="panel-heading">
                                            <h3 class="panel-title">
                                                <i class="fa fa-taxi"></i>&nbsp; משמרת לילה
                                            </h3>
                                        </div>
                                        <div class="panel-body droppable" id="dvMainBody7_3" style="padding-bottom: 200px;">
                                        </div>
                                    </div>

                                </div>
                            </div>
                        </div>


                    </div>
                    <div class="col-md-3  droppable" id="dvArgaz">

                        <div class="col-md-12">

                            <div class="panel panel-primary">
                                <div class="panel-heading">
                                    <h3 class="panel-title">
                                        <i class="glyphicon glyphicon-th-list"></i>&nbsp; ארגז כלים
                                    </h3>
                                </div>
                                <div class="panel-body">

                                    <div class="col-md-4" style="padding: 1px;">
                                        <div type="button" class="btn btn-success btn-round draggable" id="dvIsuf" style="width: 100%">
                                            <i class="glyphicon glyphicon-align-left pull-left"></i>&nbsp; <span>איסוף</span>
                                        </div>



                                    </div>
                                    <div class="col-md-4" style="padding: 1px;">
                                        <div type="button" class="btn btn-default btn-round draggable" id="dvSwitch" style="width: 100%">
                                            <i class="fa fa-refresh"></i>&nbsp; <span>החלפה</span>
                                        </div>



                                    </div>
                                    <div class="col-md-4" style="padding: 1px;">
                                        <div type="button" class="btn btn-warning btn-round draggable" id="dvPizur" style="width: 100%">
                                            <i class="glyphicon glyphicon-align-right pull-left"></i>&nbsp; <span>פיזור</span>
                                        </div>



                                    </div>

                                    <div class="col-md-12">
                                        <br />
                                    </div>

                                    <div class="col-md-12 btn btn-info btn-round draggable" id="dvDay">
                                        <select id="ddlDays" class="form-control" style="background: white">
                                            <option value="">-- בחר יום --</option>
                                        </select>
                                    </div>

                                    <div class="col-md-12">
                                        <br />
                                    </div>

                                    <div class="col-md-12 btn btn-info btn-round draggable" id="dvHours" style="height: 48px;">
                                        <div class="col-md-3">
                                            <label style="margin-top: 4px">שעה:</label>
                                        </div>
                                        <div class="col-md-9">
                                            <div class="input-group ls-group-input">
                                                <input type="text" id="txtHourForTaxi" class="form-control" style="background: white" />
                                                <span class="input-group-addon spDateIcon"><i class="fa fa-clock-o"></i></span>
                                            </div>


                                            <%--<div class="input-group ls-group-input">
                                            <input type="text" id="txtHourForTaxi" placeholder="שעה" class="form-control" />
                                        </div>--%>
                                        </div>
                                    </div>


                                    <div class="col-md-12">
                                        <br />
                                    </div>


                                    <div class="col-md-6" style="padding: 0px;">
                                        <div type="button" class="btn btn-outline-primary btn-round draggable" id="dvOvdeYom" style="width: 99%">
                                            <i class="glyphicon glyphicon-user pull-left"></i>&nbsp; <span>עובדי יום</span>
                                        </div>
                                    </div>


                                    <div class="col-md-6" style="padding: 0px;">
                                        <div type="button" class="btn btn-outline-info btn-round draggable" id="dvImahot" style="width: 99%">
                                            <i class="fa fa-female pull-left"></i>&nbsp; <span>אמהות עובדות</span>
                                        </div>
                                    </div>

                                    <div class="col-md-12">
                                        <br />
                                    </div>
                                    <div class="col-md-12 btn btn-info btn-round draggable" id="dvCity">

                                        <input type="text" id="ddlCity" class="form-control typeahead" style="background: white" spellcheck="false" autocomplete="off"
                                            placeholder=" קוד עיר או שם" />
                                        <%-- <select id="ddlCity" class="form-control" style="background: white">
                                            <option value="0">-- בחר יעד --</option>
                                           
                                        </select>--%>
                                    </div>

                                    <div class="col-md-12">
                                        <br />
                                    </div>

                                    <div class="col-md-5" style="padding: 0px;">
                                        <div type="button" class="btn btn-outline-success btn-round draggable" id="dvMinibus" style="width: 100%">
                                            <i class="fa fa-taxi pull-left"></i>&nbsp; 
                                               <span>מיניבוס</span>
                                            <input type="text" id="txtMinibusCount" style="width: 50px;" placeholder="" value="" />

                                        </div>



                                    </div>
                                    <div class="col-md-2"></div>
                                    <div class="col-md-5" style="padding: 0px;">
                                        <div type="button" class="btn btn-outline-secondary btn-round draggable" id="dvTaxi" style="width: 100%">
                                            <i class="fa fa-taxi pull-left"></i>&nbsp; <span>מונית</span>
                                            <input type="text" id="txtTaxiCount" style="width: 50px;" placeholder="" value="" />
                                        </div>



                                    </div>





                                    <div class="col-md-12">
                                        <br />
                                    </div>



                                </div>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%--  טמפלט של איסוף או פיזור--%>
    <div id="dvPizurIsufTemplate" style="display: none">

        <div class="alert btn-@classbtn btn-round droppableArea content draggable" id="dvMaindir_@Id">
            <%-- כותרת של האיסוף או פיזור--%>
            <div class="dvDirectionTitle col-md-12">
                <div class="row">
                    <span class="spDirection">@Name</span>&nbsp;-
                    <span><span onclick="deleteFromTitle('@Id','spDay')" class="badge spDay">@Day</span></span>
                    <span><span onclick="deleteFromTitle('@Id','spHour')" class="badge spHour">@Hour</span></span>
                    <span><span onclick="deleteFromTitle('@Id','spImahotOvdot')" class="badge spImahotOvdot">@ImahotOvdot</span></span>
                    <span><span onclick="deleteFromTitle('@Id','spOvdeYom')" class="badge spOvdeYom">@OvdeYom</span></span>

                </div>

            </div>
            <%--  רשימה של כל הערים עם הסוג מונית או מיניבוס--%>
            <div class="dvList col-md-12">
            </div>

        </div>


    </div>

    <div id="dvRowTemplate" style="display: none">
        <div class="row droppableCity" id="dvRow_@Id">
            <div class="col-md-6 dvCarCity" onclick="deleteFromCarRow('@Id','dvCarCity')">
                <span class="lblCity">@City</span>
            </div>

            <div class="col-md-6 btn btn-default btn-xs btn-round dvCarContainer">
                <span class="spCarName">סוג הסעה</span>  <span class="badge spCarCount"></span>
            </div>

        </div>
    </div>




</asp:Content>
