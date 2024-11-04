<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage/MasterPage.master" AutoEventWireup="true"
    CodeFile="MonthlyReport.aspx.cs" Inherits="Hasot_MonthlyReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../assets/css/rtl-css/typeahead.js-bootstrap.css" rel="stylesheet" type="text/css" />



    <script src="../assets/js/bootstrap3-typeahead.min.js" type="text/javascript"></script>
    <script type="text/javascript">

        var mydata;

        var dataforPrint = "";
        var dataforPrintOne = "";

        var OrgUnitCode = "";
        var SelectedTab = "home-tab";
        $(document).ready(function () {

            InitDateTimePickerPlugin('#txtStartDate', getFirstDayOfMonth(0), false, false);
            InitDateTimePickerPlugin('#txtEndDate', getLastDayOfMonth(1), false, false);
            // $("#home-tab").addClass("active");
            // $('.nav-tabs a[href="home"]').tab('show');

            FillData();

            $('.nav-tabs a').on('shown.bs.tab', function (e) {
                SelectedTab = $(e.target).attr('id');

            });

        });



        function DeleteMaslul(Id) {

            bootbox.confirm("האם אתה בטוח שברצונך למחוק את המסלול?", function (result) {
                if (result) {
                    Ajax("Hasot_GetSetMaslulim", "Type=3&Id=" + Id);
                    FillData();
                }

            });


        }

        function SaveNewPrice(Seq, HasotDate, HasotTime) {
         
            var Tarif = $("#txt_Price" + Seq).val();
            Ajax("Hasot_SetHasot", "Mode=8&Seq=" + Seq + "&Mprice=" + Tarif + "&Date=" + HasotDate + "&HasotTime=" + HasotTime  );

            FillData();

        }   

        function FillData() {

            SelectedSap_Id = "";
            PupulateMonthlyReport();
            PupulateMonthlyReportDetails();



        }

        function PupulateMonthlyReport() {

            $("#dvReqContainerOne").html("");


            var StartDate = $("#txtStartDate").val();
            var EndDate = $("#txtEndDate").val();

            var ReqHtml = `
                     <tr>
                                     
                                    <td>@Sap_Id</td>
                                    <td>@MaslulDesc</td>
                                    <td >@TaxiCount</td>
                                    <td>@Tarif</td>
                                    <td style="font-weight: bold;background:LightGoldenrodYellow">@Total</td>
                                    <td>@TaxiCount200</td>
                                    <td>@Tarif200</td>
                                    <td style="font-weight: bold;background:LightGoldenrodYellow">@Total200</td>
                                    <td style="font-weight: bold;background:LightGoldenrodYellow">@TotalAll</td>
                                </tr>`;




            var mydata = Ajax("Hasot_SetHasot", "Mode=66&StartDate=" + StartDate + "&EndDate=" + EndDate);

            let sum = 0;
            mydata.forEach(obj => {
                for (let property in obj) {
                    if (property == "TaxiCount" || property == "TaxiCount200" )
                        sum += obj[property];
                }
            })

            $("#spTotalOne").text(sum);

            for (var i = 0; i < mydata.length; i++) {

                if (i == 0) {

                    $("#TotalAllForReport").html(mydata[0].TotalAllForReport);
                    $("#MamAllForReport").html(mydata[0].MamAllForReport);
                    $("#TashlumForReport").html(mydata[0].TashlumForReport);

                }


                var QualHtml = ReqHtml;
                QualHtml = QualHtml.replace(/@Sap_Id/g, mydata[i].Sap_Id);
                QualHtml = QualHtml.replace("@MaslulDesc", mydata[i].MaslulDesc);

                QualHtml = QualHtml.replace("@Tarif200", mydata[i].Tarif200);
                QualHtml = QualHtml.replace(/@TotalAll/g, mydata[i].TotalAll);
                QualHtml = QualHtml.replace("@TaxiCount200", mydata[i].TaxiCount200);
                QualHtml = QualHtml.replace(/@Total200/g, mydata[i].Total200);
                QualHtml = QualHtml.replace("@Tarif", mydata[i].Tarif);
                QualHtml = QualHtml.replace(/@Total/g, mydata[i].Total);
                QualHtml = QualHtml.replace("@TaxiCount", mydata[i].TaxiCount);

                QualHtml = QualHtml.replace(/null/g, "");



                if (i != 0 && (i % 20 == 0 || i == mydata.length - 1)) {

                    $("#dvPrintTemplateContainerOne").append("<div class='break'></div>");
                    var Template = $("#dvPrintTemplateOne").html();


                    Template = Template.replace(/@count/g, i);
                    $("#dvPrintTemplateContainerOne").append(Template);


                    var StartDate = $("#txtStartDate").val();
                    var EndDate = $("#txtEndDate").val();

                    $("#spDatesOne_" + i).text(StartDate + "-" + EndDate);
                    $("#spTaxiCountOne_" + i).text(sum);

                    if (i == mydata.length - 1) {
                        dataforPrintOne += "<tr><td>" + mydata[i].Sap_Id + "</td><td>" + mydata[i].MaslulDesc + "</td><td>" + mydata[i].TaxiCount
                            + "</td><td>" + mydata[i].Tarif + "</td><td>" + mydata[i].Total + "</td><td>" + mydata[i].TaxiCount200 + "</td>"
                            + "</td><td>" + mydata[i].Tarif200 + "</td><td>" + mydata[i].Total200 + "</td><td>" + mydata[i].TotalAll + "</td></tr>"

                    }


                    $("#tbodyTempOne_" + i).append(dataforPrintOne);

                    dataforPrintOne = "";
                }


           

                dataforPrintOne += "<tr><td>" + mydata[i].Sap_Id + "</td><td>" + mydata[i].MaslulDesc.replace("<a", "<span").replace("</a", "</span") + "</td><td>" + mydata[i].TaxiCount
                    + "</td><td>" + mydata[i].Tarif + "</td><td>" + mydata[i].Total + "</td><td>" + mydata[i].TaxiCount200 + "</td>"
                    + "</td><td>" + mydata[i].Tarif200 + "</td><td>" + mydata[i].Total200 + "</td><td>" + mydata[i].TotalAll + "</td></tr>"

                $("#dvReqContainerOne").append(QualHtml);

            }




          

        }

        var SelectedSap_Id;

        function RedirectToDetails(Sap_Id) {
            SelectedSap_Id = Sap_Id;
            PupulateMonthlyReportDetails(Sap_Id);
            activeTab('profile');
        }

        function activeTab(tab) {
            $('.nav-tabs a[href="#' + tab + '"]').tab('show');
        };

        function PupulateMonthlyReportDetails(Sap_Id) {
            $("#TotalAllForReportD").html("0.0");
            $("#MamAllForReportD").html("0.0");
            $("#TashlumForReportD").html("0.0");
            if (!Sap_Id) Sap_Id = "";

            $("#dvReqContainer").html("");


            var StartDate = $("#txtStartDate").val();
            var EndDate = $("#txtEndDate").val();

            var ReqHtml = `
                     <tr>
                                     
                                    <td>@Dir</td>
                                    <td>@Day</td>
                                    <td>@HasotDateHeb</td>
                                    <td>@HasotTime</td>
                                    <td>@HasaNumber</td>
                                    <td>@Sap_Id</td>
                                    <td>@MaslulDesc</td>
                                    <td title="@Comment">@Comment</td>
                                    <td style="@StylePadd">@Tarif</td>
                                </tr>`;


            mydata = Ajax("Hasot_SetHasot", "Mode=6&StartDate=" + StartDate + "&EndDate=" + EndDate + "&Sap_Id=" + Sap_Id);

            $("#spTotal").text(mydata.length);

            for (var i = 0; i < mydata.length; i++) {

               

                if (i == 0) {

                    $("#TotalAllForReportD").html(mydata[0].TotalAllForReport);
                    $("#MamAllForReportD").html(mydata[0].MamAllForReport);
                    $("#TashlumForReportD").html(mydata[0].TashlumForReport);

                }


                var QualHtml = ReqHtml;
                QualHtml = QualHtml.replace(/@Dir/g, mydata[i].Dir);
                QualHtml = QualHtml.replace("@Day", getDayfromDate(mydata[i].HasotDateHeb));
                QualHtml = QualHtml.replace("@HasotDateHeb", mydata[i].HasotDateHeb);


                QualHtml = QualHtml.replace("@HasotTime", mydata[i].HasotTime);
                QualHtml = QualHtml.replace("@HasaNumber", pad(mydata[i].HasaNumber, 4));
                QualHtml = QualHtml.replace(/@Comment/g, mydata[i].Comment);
                QualHtml = QualHtml.replace("@Sap_Id", mydata[i].Sap_Id);
                QualHtml = QualHtml.replace("@MaslulDesc", mydata[i].MaslulDesc);
                if (mydata[i].Sap_Id == 99) {
                   
                    var inputtext = `<div class="" style="float:right">
                              <input type="number"  style="background:white;width:100px;" id="txt_Price`+ mydata[i].Seq + `"  value="` + mydata[i].Tarif + `"></div>
                      <div onclick="SaveNewPrice(` + mydata[i].Seq + `,'` + mydata[i].HasotDateHeb + `','` + mydata[i].HasotTime + `')"
                    class="btn btn-primary btn-xs" style="float:left"> שמור</div ><div class="clear:both"></div >
                      `;



                    QualHtml = QualHtml.replace("@Tarif", inputtext);
                    QualHtml = QualHtml.replace("@StylePadd", "padding:2px;padding-top:4px;");

                } else {
                    QualHtml = QualHtml.replace("@Tarif", mydata[i].Tarif);
                }

                QualHtml = QualHtml.replace(/null/g, "");



                if (i != 0 && (i % 20 == 0 || i == mydata.length - 1)) {

                   
                    $("#dvPrintTemplateContainer").append("<div class='break'></div>");
                    var Template = $("#dvPrintTemplate").html();


                    Template = Template.replace(/@count/g, i);
                    $("#dvPrintTemplateContainer").append(Template);


                    var StartDate = $("#txtStartDate").val();
                    var EndDate = $("#txtEndDate").val();

                    $("#spDates_" + i).text(StartDate + "-" + EndDate);
                    $("#spTaxiCount_" + i).text(mydata.length);

                    if (i == mydata.length - 1) {
                        dataforPrint += "<tr><td>" + pad(mydata[i].HasaNumber, 4) + "</td><td>" + mydata[i].HasotDateHeb + "</td><td>" + mydata[i].HasotTime
                            + "</td><td>" + mydata[i].Sap_Id + "</td><td>" + mydata[i].MaslulDesc + "</td><td>" + mydata[i].Tarif + "</td></tr>"


                    }


                    $("#tbodyTemp_" + i).append(dataforPrint);

                    dataforPrint = "";
                }


                dataforPrint += "<tr><td>" + pad(mydata[i].HasaNumber, 4) + "</td><td>" + mydata[i].HasotDateHeb + "</td><td>" + mydata[i].HasotTime
                    + "</td><td>" + mydata[i].Sap_Id + "</td><td>" + mydata[i].MaslulDesc + "</td><td>" + mydata[i].Tarif + "</td></tr>"


                $("#dvReqContainer").append(QualHtml);

            }



        }

        function pad(str, max) {

            if (!str) return "";

            str = str.toString();
            return str.length < max ? pad("0" + str, max) : str;
        }

        var SelectedId = "";

        function EditMaslul(Id) {

            SelectedId = Id;

            if (Id == 0) {


                $("#spReqDesc").text("מסלול חדש");
                $("#txtSap_Id").val("");
                $("#txtMaslulDesc").val("");
                $("#txtCity1").val("");
                $("#txtCity2").val("");
                $("#txtCity3").val("");
                $("#txtCity4").val("");
                $("#txtTimeBeforeTaxi").val("");

            }

            else {
                var Obj = mydata.filter(x => x.Id == Id)[0];

                $("#spReqDesc").text(Obj.MaslulDesc);
                $("#txtSap_Id").val(Obj.Sap_Id);
                $("#txtMaslulDesc").val(Obj.MaslulDesc);
                $("#txtCity1").val(Obj.City1);
                $("#txtCity2").val(Obj.City2);
                $("#txtCity3").val(Obj.City3);
                $("#txtCity4").val(Obj.City4);
                $("#txtTimeBeforeTaxi").val(Obj.TimeBeforeTaxi);
            }

            $("#ModalEdit").modal();
        }

        function SaveDataTODB() {

            //var form = $("#fmrReqDetails");
            //var IsValid = form.validationEngine('validate');


            //if (IsValid) {

            var Sap_Id = $("#txtSap_Id").val();
            var MaslulDesc = $("#txtMaslulDesc").val();
            var City1 = $("#txtCity1").val();
            var City2 = $("#txtCity2").val();
            var City3 = $("#txtCity3").val();
            var City4 = $("#txtCity4").val();

            var TimeBeforeTaxi = $("#txtTimeBeforeTaxi").val();

            //var strPost = form.serialize();

            Ajax("Hasot_GetSetMaslulim", "Type=2&Id=" + SelectedId + "&Sap_Id=" + Sap_Id + "&MaslulDesc=" + MaslulDesc +
                "&City1=" + City1 + "&City2=" + City2 + "&City3=" + City3 + "&City4=" + City4 + "&TimeBeforeTaxi=" + TimeBeforeTaxi);

            $("#ModalEdit").modal('hide');

            FillData();

            //}

        }

        function PrintData(type) {

            if (SelectedTab == "home-tab") {

                if (type == 1) {



                    var printtemplate = $("#dvPrintTemplateContainerOne").html();
                    PrintDivFood(printtemplate, "הדפסת מוניות");

                }


                if (type == 2) {
                    var StartDate = $("#txtStartDate").val();
                    var EndDate = $("#txtEndDate").val();
                    var printtemplate = $("#dvPrintTemplateContainer").html();

                    var res = Ajax("Hasot_SetHasot", "Mode=77&StartDate=" + StartDate + "&EndDate=" + EndDate + "&Sap_Id=" + SelectedSap_Id);


                    if (res[0]) {

                      
                       
                        var file_path = res[0].MaslulDescClear;
                        var a = document.createElement('A');
                        a.href = file_path;
                        a.download = file_path.substr(file_path.lastIndexOf('/') + 1);
                        document.body.appendChild(a);
                        a.click();
                        document.body.removeChild(a);

                    }
                }

            



            }

            else {
                if (type == 1) {



                    var printtemplate = $("#dvPrintTemplateContainer").html();
                    PrintDivFood(printtemplate, "הדפסת מוניות");

                }

                if (type == 2) {
                    var StartDate = $("#txtStartDate").val();
                    var EndDate = $("#txtEndDate").val();
                    var printtemplate = $("#dvPrintTemplateContainer").html();

                    var res = Ajax("Hasot_SetHasot", "Mode=7&StartDate=" + StartDate + "&EndDate=" + EndDate + "&Sap_Id=" + SelectedSap_Id);


                    if (res[0]) {

                        //window.open(res[0].HasaNumber);
                       
                        var file_path = res[0].HasaNumber;
                        var a = document.createElement('A');
                        a.href = file_path;
                        a.download = file_path.substr(file_path.lastIndexOf('/') + 1);
                        document.body.appendChild(a);
                        a.click();
                        document.body.removeChild(a);

                    }
                }

            }

            //if (type == 3) {



            //}

        }



    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <div class="col-md-12">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-th-list"></i>&nbsp;<span class="spAreaName">סיכום חודשי - מוניות</span>
                    </h3>


                </div>
                <div class="panel-body">

                    <div class="col-md-3">
                        <label style="float: right; font-weight: bold; padding: 5px;">תאריך התחלה:</label>
                        <div class="input-group ls-group-input">

                            <input type="text" class="form-control txtDate" id="txtStartDate" />
                            <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <label style="float: right; font-weight: bold; padding: 5px;">תאריך סיום:</label>
                        <div class="input-group ls-group-input">
                            <input type="text" class="form-control txtDate" id="txtEndDate" />
                            <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
                        </div>
                    </div>

                    <div class="col-md-2 ">
                        <div type="button" class="btn btn-primary btn-round" style="" onclick="FillData()">
                            <i class="glyphicon glyphicon-search"></i>&nbsp;<span>חפש</span>
                        </div>
                    </div>

                    <div class="col-md-4" style="text-align: left;">
                        <div class="btn btn-success btn-round" onclick="PrintData(2)">
                            <i class="fa fa-file-excel-o"></i>&nbsp; <span class="btnAssign">Excel
                            </span>
                        </div>


                        <div class="btn btn-primary btn-round" onclick="PrintData(1)">
                            <i class="fa fa-print"></i>&nbsp; <span class="btnAssign">הדפסה
                            </span>
                        </div>

                    </div>

                    <div class="col-md-12" style="text-align: right">
                        <hr />

                        <ul class="nav nav-tabs" id="myTab" role="tablist">
                            <li class="nav-item active">
                                <a class="nav-link active in" id="home-tab" data-toggle="tab" href="#home" role="tab"
                                    aria-controls="home" aria-selected="true">דו"ח סיכום מוניות חודשי</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" id="profile-tab" data-toggle="tab" href="#profile" role="tab"
                                    aria-controls="profile" aria-selected="false">דו"ח סיכום מוניות חודשי מפורט</a>
                            </li>

                        </ul>
                        <div class="tab-content" id="myTabContent">
                            <div class="tab-pane fade active in" style="border: solid 1px #ddd; border-top: none; padding: 0px !important; padding-right: 10px !important" id="home" role="tabpanel" aria-labelledby="home-tab">
                                <style>
                                    tfoot {
                                        position: absolute;
                                        float: left;
                                        background: Goldenrod
                                    }

                                    tfoot {
                                        top: 470px;
                                        left: 34px
                                    }

                                    #footertable td {
                                        padding: 0px;
                                        border-bottom: solid 1px white
                                    }

                                    #footertableD td {
                                        padding: 0px;
                                        border-bottom: solid 1px white
                                    }
                                </style>
                                <label style="font-weight: bold; padding-top: 10px">כמות נסיעות:</label>
                                <span style="font-weight: bold; text-decoration: underline" id="spTotalOne">0</span>
                                <div class="tableFixHead">
                                    <table class="table table-bordered table-hover">
                                        <thead>

                                            <tr>
                                                <th style="font-weight: bold">מס' מסלול</th>
                                                <th style="font-weight: bold">שם מסלול</th>
                                                <th style="font-weight: bold">כמות נסיעות</th>
                                                <th style="font-weight: bold">תעריף </th>
                                                <th style="font-weight: bold">סה"כ </th>
                                                <th style="font-weight: bold">כמות ללילה\שבת\חג</th>
                                                <th style="font-weight: bold">תעריף לילה\שבת\חג</th>
                                                <th style="font-weight: bold">סה"כ </th>
                                                <th style="font-weight: bold">סה"כ לתשלום</th>


                                            </tr>
                                        </thead>
                                        <tbody id="dvReqContainerOne">
                                        </tbody>
                                        <tfoot>
                                            <tr>

                                                <td style="font-weight: bold; font-size: 18px; color: white; text-align: left; direction: rtl; border: solid 1px gray">

                                                    <table id="footertable">
                                                        <tr>
                                                            <td>סה"כ :</td>
                                                            <td style="text-align: right" id="TotalAllForReport">0</td>
                                                        </tr>
                                                        <tr>
                                                            <td>מע"מ :</td>
                                                            <td style="text-align: right" id="MamAllForReport">0</td>
                                                        </tr>
                                                        <tr>
                                                            <td>סה"כ לתשלום :</td>
                                                            <td style="text-align: right" id="TashlumForReport">0</td>
                                                        </tr>

                                                    </table>




                                                </td>


                                            </tr>


                                        </tfoot>

                                    </table>



                                </div>

                                <%--<div class="alert alert-danger">
                                    <span class="spSummery" style=""><u>סיכום-</u> </span>
                                    <span class="spSummery">סה"כ כמות מנות שחולקה:</span><span id="spTotalFood" class="badge spTotal"></span>,
                                    <span class="spSummery">כמות מנות לעובדי אבטחה G1: </span>



                                </div>--%>
                            </div>
                            <div class="tab-pane fade" id="profile" style="border: solid 1px #ddd; border-top: none; padding: 0px !important; padding-right: 10px !important" role="tabpanel" aria-labelledby="profile-tab">



                                <style>
                                    .tableFixHead {
                                        overflow: auto;
                                        height: 380px;
                                    }

                                        .tableFixHead thead th {
                                            position: sticky;
                                            top: 0;
                                            z-index: 1;
                                        }


                                    table {
                                        border-collapse: collapse;
                                        width: 100%;
                                    }

                                    th, td {
                                        padding: 8px 16px;
                                    }

                                    th {
                                        color: #31708f;
                                        background-color: #d9edf7;
                                        border-color: #bce8f1;
                                    }
                                </style>
                                <label style="font-weight: bold; padding-top: 10px">כמות מוניות:</label>
                                <span style="font-weight: bold; text-decoration: underline" id="spTotal">0</span>
                                <div class="tableFixHead">
                                    <table class="table table-bordered table-hover">
                                        <thead>

                                            <tr>
                                                <th style="font-weight: bold">כיוון</th>
                                                <th style="font-weight: bold">יום בשבוע</th>
                                                <th style="font-weight: bold">תאריך</th>
                                                <th style="font-weight: bold">שעה</th>
                                                <th style="font-weight: bold">מס' נסיעה</th>
                                                <th style="font-weight: bold">מס' מסלול</th>
                                                <th style="font-weight: bold">מסלול</th>
                                                <th style="font-weight: bold">הערות</th>
                                                <th style="font-weight: bold; width: 15%">תעריף</th>

                                            </tr>
                                        </thead>
                                        <tbody id="dvReqContainer">
                                        </tbody>

                                        <tfoot>
                                            <tr>

                                                <td style="font-weight: bold; font-size: 18px; color: white; text-align: left; direction: rtl; border: solid 1px gray">

                                                    <table id="footertableD">
                                                        <tr>
                                                            <td>סה"כ :</td>
                                                            <td style="text-align: right" id="TotalAllForReportD">0</td>
                                                        </tr>
                                                        <tr>
                                                            <td>מע"מ :</td>
                                                            <td style="text-align: right" id="MamAllForReportD">0</td>
                                                        </tr>
                                                        <tr>
                                                            <td>סה"כ לתשלום :</td>
                                                            <td style="text-align: right" id="TashlumForReportD">0</td>
                                                        </tr>

                                                    </table>




                                                </td>


                                            </tr>


                                        </tfoot>

                                    </table>
                                </div>




                            </div>

                        </div>
                    </div>

                </div>



            </div>
        </div>
    </div>

    <%-- חלון מודלי של הגדרת דרישה--%>
    <div class="modal fade" id="ModalEdit" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        <span id="spReqDesc"></span>
                    </h4>



                </div>
                <div class="modal-body" id="Div8">
                    <form id="fmrReqDetails" method="post" action="">
                        <div class="col-md-3">
                            <span class="help-block m-b-none">מס' סאפ:</span>
                        </div>
                        <div class="col-md-9">
                            <input type="text" id="txtSap_Id" name="txtSap_Id" class="form-control validate[required] text-input" />
                        </div>
                        <div class="clear">
                            &nbsp;
                        </div>

                        <div class="col-md-3">
                            <span class="help-block m-b-none">תיאור מסלול:</span>
                        </div>
                        <div class="col-md-9">
                            <input type="text" id="txtMaslulDesc" name="txtMaslulDesc" class="form-control validate[required] text-input" />
                        </div>
                        <div class="clear">
                            &nbsp;
                        </div>


                        <div class="col-md-3">
                            <span class="help-block m-b-none">הקדמה לאיסוף:</span>
                        </div>
                        <div class="col-md-9">
                            <input type="text" id="txtTimeBeforeTaxi" name="txtTimeBeforeTaxi" class="form-control text-input" />
                        </div>
                        <div class="clear">
                            &nbsp;
                        </div>

                        <div class="col-md-3">
                            <span class="help-block m-b-none">עיר 1:</span>
                        </div>
                        <div class="col-md-9">
                            <input type="text" id="txtCity1" name="txtCity1" class="form-control validate[required] text-input" />
                        </div>
                        <div class="clear">
                            &nbsp;
                        </div>
                        <div class="col-md-3">
                            <span class="help-block m-b-none">עיר 2:</span>
                        </div>
                        <div class="col-md-9">
                            <input type="text" id="txtCity2" name="txtCity2" class="form-control validate[required] text-input" />
                        </div>
                        <div class="clear">
                            &nbsp;
                        </div>
                        <div class="col-md-3">
                            <span class="help-block m-b-none">עיר 3:</span>
                        </div>
                        <div class="col-md-9">
                            <input type="text" id="txtCity3" name="txtCity3" class="form-control validate[required] text-input" />
                        </div>
                        <div class="clear">
                            &nbsp;
                        </div>


                        <div class="col-md-3">
                            <span class="help-block m-b-none">עיר 4:</span>
                        </div>
                        <div class="col-md-9">
                            <input type="text" id="txtCity4" name="txtCity4" class="form-control validate[required] text-input" />
                        </div>
                        <div class="clear">
                            &nbsp;
                        </div>
                        <div class="col-md-6" style="text-align: left">
                        </div>
                    </form>
                    <div class="clear">
                        &nbsp;
                    </div>
                </div>
                <div class="modal-footer">
                    <div class="btn btn-primary btn-round" onclick="SaveDataTODB()">
                        <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>עדכן</span>
                    </div>

                    <div class="btn btn-danger btn-round" data-dismiss="modal">
                        <i class="glyphicon glyphicon-eject"></i>&nbsp; <span>סגור</span>
                    </div>


                </div>
            </div>
        </div>
    </div>
    <%-- טמפלט של עובד --%>
    <div id="dvReqTemplate" style="display: none">
        <div class="col-md-3 dvRequireDetails">
            @RequirementDescTable
        </div>
        <div class="col-md-1 dvRequireDetails">
            @DayDesc
        </div>
        <div class="col-md-1 dvRequireDetails">
            @ShiftDesc
        </div>
        <div class="col-md-2 dvRequireDetailsOver" title="@QualificationDesc">
            @QualificationDesc
        </div>
        <%-- <div class="col-md-1 dvRequireDetails">
            @EmpQuantity
        </div>--%>
        <div class="col-md-1 dvRequireDetails">
            @ObligatoryAssignmentTable
        </div>
        <div class="col-md-1 dvRequireDetails">
            @ObligatoryCheckTable
        </div>

        <div class="col-md-2 dvRequireDetails">
            @Dates
        </div>
        <div class="col-md-1 dvRequireDetails">

            <div class="btn btn-primary btn-xs" style="width: 45%" onclick='EditRequirement("@RequirementId", "@DateTypeCode","@ShiftCode", "@QualificationCode", "@EmpQuantity","@Seq", "@RequirementDesc", "@RequirementAbb","@ObligatoryAssignment", "@ObligatoryCheck","@BeginDate", "@EndDate","@RequirementType","@IsAssignAuto")'>
                ערוך
            </div>

            <div class="btn btn-danger btn-xs" style="width: 45%" onclick='DeleteRequirement("@RequirementId")'>
                מחק
            </div>
        </div>




        <%--<div class="btn btn-primary btn-xs" onclick="EditRequirement('@RequirementId, '@DateTypeCode','@ShiftCode', '@QualificationCode', '@EmpQuantity', '@RequirementDesc', '@RequirementAbb','@ObligatoryAssignment', '@ObligatoryCheck','@BeginDate', '@EndDate')">
                <i class="fa fa-edit"></i>&nbsp;ערוך</div>
        --%>
    </div>

    <%-- טמפלט של הדפסה --%>
    <div id="dvPrintTemplate" style="display: none">
        <style>
            @media print {
                .break {
                    page-break-before: always;
                }

                .footer {
                    page-break-before: always;
                }

                .divPazText {
                   font-weight: bold;
                    font-size: 24px;
                }

                .divTextNumber {
                    text-align: left;
                    font-weight: bold;
                    font-size: 20px;
                }

                .dvSomeText {
                    font-weight: bold;
                    font-size: 24px;
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

        <table width="100%" style="padding: 0px; margin: 0px;">
            <tr>
                <td>
                    <img src="../assets/images/Baza.png" width="250px" />


                </td>

                <td class="tdPaddingTop" colspan="2" style="text-align:left">

                    <div class="divPazText"><u>בית זיקוק אשדוד בע"מ</u></div>

                </td>


            </tr>

            <tr>
                <td colspan="2" class="tdUnderline tdPaddingTop">

                    <div class="dvSomeText">דוח מוניות מפורט לתאריכים -   <span id="spDates_@count" class="spDates">20.12.22 - 05.09.23 </span></div>


                </td>
                <td class="tdUnderline tdPaddingTop" style="text-align:left">
                    <div class="dvSomeText" style="">כמות: <span id="spTaxiCount_@count"></span></div>

                </td>

            </tr>



        </table>

        <table width="100%" border="1" style="padding: 0px; margin: 0px; border-collapse: collapse; margin-top: 20px;">
            <tr>
                <th>מס' נסיעה
                </th>
                <th>תאריך נסיעה
                </th>
                <th>שעת נסיעה
                </th>
                <th>מס' מסלול
                </th>
                <th>מסלול
                </th>
                <th>תעריף
                </th>
            </tr>
            <tbody id="tbodyTemp_@count">
            </tbody>


        </table>

    </div>
    <div id="dvPrintTemplateContainer" style="display: none">
    </div>


     <%-- טמפלט של הדפסה --%>
    <div id="dvPrintTemplateOne" style="display: none">
        <style>
            @media print {
                .break {
                    page-break-before: always;
                }

                .footer {
                    page-break-before: always;
                }

                .divPazText {
                     font-weight: bold;
                    font-size: 24px;
                  
                    
                }

                .divTextNumber {
                    text-align: left;
                    font-weight: bold;
                    font-size: 24px;
                }

                .dvSomeText {
                    font-weight: bold;
                    font-size: 24px;
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

        <table width="100%"  style="padding: 0px; margin: 0px;">
            <tr>
                <td>
                    <img src="../assets/images/Baza.png" width="250px" />


                </td>

                <td class="tdPaddingTop" colspan="2" style="text-align:left">

                    <div class="dvSomeText"><u>בית זיקוק אשדוד בע"מ</u></div>

                </td>


            </tr>

            <tr>
                <td colspan="2" class="tdUnderline tdPaddingTop">

                    <div class="dvSomeText">דוח מוניות  לתאריכים -   <span id="spDatesOne_@count" class="spDates">20.12.22 - 05.09.23 </span></div>


                </td>
                <td class="tdUnderline tdPaddingTop" style="text-align:left">
                    <div class="dvSomeText" style="">כמות: <span id="spTaxiCountOne_@count"></span></div>

                </td>

            </tr>



        </table>

        <table width="100%" border="1" style="padding: 0px; margin: 0px; border-collapse: collapse; margin-top: 20px;">
            <tr>
                <th>מס' מסלול
                </th>
                <th>שם מסלול
                </th>
                <th>כמות נסיעות
                </th>
                <th>תעריף
                </th>
                <th>סה"כ
                </th>
                <th>כמות לילה\שבת\חג
                </th>
                 <th>תעריף לילה\שבת\חג
                </th>
                 <th>סה"כ
                </th>
                 <th>סה"כ לתשלום
                </th>
            </tr>
            <tbody id="tbodyTempOne_@count">
            </tbody>


        </table>

    </div>
    <div id="dvPrintTemplateContainerOne" style="display: none">
    </div>

</asp:Content>
