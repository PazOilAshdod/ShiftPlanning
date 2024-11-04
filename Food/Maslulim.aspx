﻿<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage/MasterPage.master" AutoEventWireup="true"
    CodeFile="Maslulim.aspx.cs" Inherits="Hasot_Maslulim" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../assets/css/rtl-css/typeahead.js-bootstrap.css" rel="stylesheet" type="text/css" />
    <script src="../assets/js/bootstrap3-typeahead.min.js" type="text/javascript"></script>
    <script type="text/javascript">

        var mydata;


        var OrgUnitCode = "";

        $(document).ready(function () {


            //$('input.typeahead').typeahead({
            //    items: 15,
            //    source: function (query, process) {
            //        states = [];
            //        map = {};

            //        var data = Ajax("Employees_GetEmployeesList", "Type=0&EmpNo=");



            //        $.each(data, function (i, state) {
            //            map[state.FullText] = state;
            //            states.push(state.FullText);
            //        });

            //        process(states);
            //    },

            //    updater: function (item) {

            //        EmpNo = map[item].EmpNo;
            //        SearchEmp(EmpNo);
            //        return item;
            //    }


            //});


            FillData();
        });

        //function SearchEmp(EmpNo) {
        //    var data = Ajax("Employees_GetEmployeesList", "Type=1&EmpNo=" + EmpNo);

        //    if (data[0]) {
        //        selectedEmp = EmpNo;




        //        //$("#txtEmpNo").val(data[0].EmpNo);
        //        //$("#txtFirstName").val(data[0].FirstName);
        //        //$("#txtLastName").val(data[0].LastName);
        //        $("#txtArea").val(data[0].OrgUnitCode);
        //        //$("#txtStartDate").val(data[0].StartDate);
        //        //$("#txtEndDate").val(data[0].EndDate);
        //        //$("#txtPhone").val(data[0].PhoneNum);
        //        $("#txtCity").val(data[0].City);
        //        //$("#txtAddress").val(data[0].Address);
        //        $("#txtLooz").val(data[0].GroupCode);
        //        //$("#txtTaz").val(data[0].EmpId);
        //        //if (data[0].IsHasa == "1") {

        //        //    $('#chIsHasa').prop('checked', true);
        //        //} else {

        //        //    $('#chIsHasa').prop('checked', false);
        //        //}




        //    }



        //    //$("#dvQualContainer").html("");
        //    //var mydata = Ajax("Employees_GetEmployeesList", "Type=2&EmpNo=" + EmpNo);

        //    //for (var i = 0; i < mydata.length; i++) {
        //    //    QualHtml = $("#dvQualTemplate").html();
        //    //    QualHtml = QualHtml.replace("@Text", mydata[i].Text);
        //    //    $("#dvQualContainer").append(QualHtml);

        //    //}


        //    // SetAbsence(EmpNo);


        //}

        function DeleteMaslul(Id) {

            bootbox.confirm("האם אתה בטוח שברצונך למחוק את המסלול?", function (result) {
                if (result) {
                    Ajax("Hasot_GetSetMaslulim", "Type=3&Id=" + Id);
                    FillData();
                }

            });


        }
        
        function FillData() {

            $("#dvReqContainer").html("");

            var ReqHtml = `
                     <tr>
                                    <td>@Sap_Id</td>
                                    <td>@MaslulDesc</td>
                                    <td>@City1</td>
                                     <td>@City2</td>
                                     <td>@City3</td>
                                     <td>@City4</td>
                                     <td>@TimeBeforeTaxi</td>
                                     <td style='text-align:center'><i class='fa fa-edit' style='color:#428bca;font-size:25px' onclick='EditMaslul(@Id)'></i></td>
                                     <td style='text-align:center'><i class='fa fa-trash-o' style='color:red;font-size:25px' onclick='DeleteMaslul(@Id)'></i></td>
                                </tr>`;


            mydata = Ajax("Hasot_GetSetMaslulim", "Type=1");

            for (var i = 0; i < mydata.length; i++) {
                var QualHtml = ReqHtml;
                QualHtml = QualHtml.replace(/@Id/g, mydata[i].Id);
                QualHtml = QualHtml.replace("@Sap_Id", mydata[i].Sap_Id);
                QualHtml = QualHtml.replace("@MaslulDesc", mydata[i].MaslulDesc);
                QualHtml = QualHtml.replace("@City1", mydata[i].City1);
                QualHtml = QualHtml.replace("@City2", mydata[i].City2);
                QualHtml = QualHtml.replace("@City3", mydata[i].City3);
                QualHtml = QualHtml.replace("@City4", mydata[i].City4);
                alert(mydata[i].TimeBeforeTaxi);

                QualHtml = QualHtml.replace("@TimeBeforeTaxi", mydata[i].TimeBeforeTaxi);
                QualHtml = QualHtml.replace(/null/g, "");

                $("#dvReqContainer").append(QualHtml);

            }




        }

        var SelectedId = "";

        function EditMaslul(Id) {

            SelectedId = Id;

            if (Id==0) {


                $("#spReqDesc").text("מסלול חדש");
                $("#txtSap_Id").val("");
                $("#txtMaslulDesc").val("");
                $("#txtCity1").val("");
                $("#txtCity2").val("");
                $("#txtCity3").val("");
                $("#txtCity4").val("");
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
            }

            $("#ModalEdit").modal();
        }

     

        function SaveDataTODB() {
           
            //var form = $("#fmrReqDetails");
            //var IsValid = form.validationEngine('validate');


            //if (IsValid) {

                var Sap_Id =  $("#txtSap_Id").val();
                var MaslulDesc =  $("#txtMaslulDesc").val();
                var City1 =   $("#txtCity1").val();
                var City2 =   $("#txtCity2").val();
                var City3 =  $("#txtCity3").val();
                var City4 =  $("#txtCity4").val();

               
               
                //var strPost = form.serialize();

                Ajax("Hasot_GetSetMaslulim", "Type=2&Id=" + SelectedId  +"&Sap_Id=" + Sap_Id + "&MaslulDesc=" + MaslulDesc +
                    "&City1=" + City1 + "&City2=" + City2 + "&City3=" + City3 + "&City4=" + City4);

                $("#ModalEdit").modal('hide');

                FillData();

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
                        <i class="glyphicon glyphicon-th-list"></i>&nbsp;<span class="spAreaName">רשימת מסלולים</span>

                       
                    </h3>


                </div>
                <div class="panel-body">
                     <div style="text-align:left;margin-bottom:10px">
                            <div class="btn btn-success  btn-round" onclick="EditMaslul(0)">
                                <span>הוספת מסלול חדש</span>
                            </div>
                        </div>
                    <style>
                        .tableFixHead {
                            overflow: auto;
                            height: 550px;
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
                    <div class="tableFixHead">
                        <table class="table table-bordered table-hover">
                            <thead>
                                <tr>
                                    <th style="font-weight: bold">מס' סאפ</th>
                                    <th style="font-weight: bold">תאור מסלול</th>
                                    <th style="font-weight: bold">עיר 1</th>
                                    <th style="font-weight: bold">עיר 2</th>
                                    <th style="font-weight: bold">עיר 3</th>
                                    <th style="font-weight: bold">עיר 4</th>
                                    <th style="font-weight: bold">הקדמה באיסוף</th>
                                    <th style="font-weight: bold"></th>
                                    <th style="font-weight: bold"></th>
                                </tr>
                            </thead>
                            <tbody id="dvReqContainer">
                            </tbody>
                        </table>
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
    <%-- <script src="../assets/js/pages/formValidation.js"></script>--%>
</asp:Content>