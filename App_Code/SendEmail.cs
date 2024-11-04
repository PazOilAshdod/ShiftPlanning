using System;
using System.Configuration;
using System.IO;
using System.Net.Mail;
using System.Web;

/// <summary>
/// Summary description for SendEmail
/// </summary>
public static class SendEmail
{
    //public SendEmail()
    //{
    //    //
    //    // TODO: Add constructor logic here
    //    //
    //}


    public static void SendEmailExecute(string Area, string WorkerName, string ShiftCode, string Date,
        string Creator, string Reason, string Comment, string AddEmail1, string AddEmail2, string OrgUnitCode)
    {
       // SmtpClient SmtpServer = new SmtpClient();
       // MailMessage actMSG = new MailMessage();
       // SmtpServer.Host = ConfigurationManager.AppSettings["mail_smtp"].ToString();
       // SmtpServer.Port = 25;
       // SmtpServer.UseDefaultCredentials = false;

       // string mail_user = "wrk_mirkam";
       // string mail_pass = "mp123$";
       // string ManagerName = "";

       // string From = ConfigurationManager.AppSettings["From"].ToString();
       // string To = ConfigurationManager.AppSettings["To"].ToString();

       // //  SmtpServer.Credentials = new System.Net.NetworkCredential(mail_user, mail_pass);


       // actMSG.IsBodyHtml = true;



       // actMSG.Subject = "קריאה מיוחדת - " + Area + " - " + WorkerName;
       // actMSG.Body = String.Format("{0}", "<div  style='direction:rtl; font-family: Arial, Helvetica, sans-serif;'>"
       //                                     + " שלום רב, " + ManagerName + "<br>"
       //                                     // + "היום הגיע תאריך סיום משוער למעקף שהגדרת בתאריך - <b>" + WriteDate + "</b><br><br>"
       //                                     + "<b><u> להלן פרטי קריאה מיוחדת: </u></b><br><br>"

       //                                     + "<b>תאריך: </b>" + Date + "<br>"
       //                                     + "<b>אזור: </b>" + Area + "<br>"
       //                                     + "<b>משמרת: </b>" + ShiftCode + "<br>"
       //                                     + "<b>שם עובד: </b>" + WorkerName + "<br>"
       //                                     + "<b>יוזם: </b>" + Creator + "<br>"
       //                                     + "<b>סיבה: </b>" + Reason + "<br>"

       //                                     + "<b>הערות: </b>" + Comment + "<br><br>"
       //                                     + "<font style='color:red;'>מייל זה הינו אוטמטי ולא ניתן להשבה!</font>"
       //                                     + "</div><br>");



       //// actMSG.To.Add("hzachiel@pazar.co.il");

       // //    actMSG.To.Add("eavivit@pazar.co.il");



       // // *********************** פרודקשן *****************

       // //actMSG.To.Add("Mavner@pazar.co.il");

       // //// אזורים ללא תומר
       // //if (OrgUnitCode != "20000011" && OrgUnitCode !="20000016" && OrgUnitCode !="20000017")  
       // //{
       // //    actMSG.To.Add("Ibardugo@pazar.co.il");

       // //}


       // //if (!string.IsNullOrEmpty(AddEmail1))
       // //{
       // //    actMSG.To.Add(AddEmail1);
       // //}


       // //if (!string.IsNullOrEmpty(AddEmail2))
       // //{
       // //    actMSG.To.Add(AddEmail2);
       // //}

       // // *********************** פרודקשן *****************


       // actMSG.From = new MailAddress(From);

       // SmtpServer.Send(actMSG);
       // actMSG.Dispose();
    }

    public static void SendEmailExecuteTaxi(string Date, string Body, string TaxiMail)
    {

        SmtpClient SmtpServer = new SmtpClient();
        SmtpServer.Host = ConfigurationManager.AppSettings["mail_smtp"].ToString();
        SmtpServer.Port = 25;
        SmtpServer.UseDefaultCredentials = false;

        string mail_user = ConfigurationManager.AppSettings["mail_user"].ToString();
        string mail_pass = ConfigurationManager.AppSettings["mail_pass"].ToString();



        MailMessage actMSG = new MailMessage();


        //SmtpServer.Credentials = new System.Net.NetworkCredential(mail_user, mail_pass);


        actMSG.IsBodyHtml = true;



        actMSG.Subject = "תכנון הסעות - " + Date;

        string BodyHtml = @"
                            <html>
                              <head>
  <style>
       .nolineDeleted {
            font-weight: bold;
            color: darkred;
        }

        .nolineNew {
            font-weight: bold;
            color: green;
        }
       
        .dvPassTemplate{
            direction:rtl;
           
            margin: 10px;
            font-size:15px;
        

        }



        .dvDeletedPass{
          
            text-decoration: line-through;
            font-weight:bold;
            color:darkred;

        }

         .dvNewPass{

           
            font-weight:bold;
            color:green;

        }

 
      
    </style>


                             </head> 
                             <body style='font-family:sans-serif;'><div style='float:right;direction:rtl'>
                           " + Body + @"
                            <br><br><font style='color:red;'>מייל זה הינו אוטמטי ולא ניתן להשבה!</font></div>
 </body>
                            <br></html>
                        ";

        actMSG.Body = BodyHtml;



        actMSG.To.Add(TaxiMail);
        actMSG.From = new MailAddress(ConfigurationManager.AppSettings["mail_sender"].ToString());



        SmtpServer.Send(actMSG);
        actMSG.Dispose();
    }

    public static void SendEmailExecuteTaxiWithAttach(string Date,string FilePath, string TaxiMail,string BodyTitle, string Title)
    {

        // מצורף קובץ של סידור מוניות:
      
        try
        {
         


            SmtpClient SmtpServer = new SmtpClient();
            SmtpServer.Host = ConfigurationManager.AppSettings["mail_smtp"].ToString();
            SmtpServer.Port = 25;
            SmtpServer.UseDefaultCredentials = false;

            string mail_user = ConfigurationManager.AppSettings["mail_user"].ToString();
            string mail_pass = ConfigurationManager.AppSettings["mail_pass"].ToString();



            MailMessage actMSG = new MailMessage();


         //   SmtpServer.Credentials = new System.Net.NetworkCredential(mail_user, mail_pass);


            actMSG.IsBodyHtml = true;



            actMSG.Subject = "תכנון הסעות - " + Date;

            string BodyHtml = @"
                            <html>
                              <head>
                             </head> 
                             <body style='font-family:sans-serif;'><div style='float:right;direction:rtl'>
                             "+Title+@" <br> " + BodyTitle + @"
                            <br><br><font style='color:red;'>מייל זה הינו אוטמטי ולא ניתן להשבה!</font></div>
                             </body>
                            <br></html>
                        ";

            actMSG.Body = BodyHtml;



            actMSG.To.Add(TaxiMail);
            actMSG.From = new MailAddress(ConfigurationManager.AppSettings["mail_sender"].ToString());


            System.Net.Mime.ContentType ct = new System.Net.Mime.ContentType(System.Net.Mime.MediaTypeNames.Application.Pdf);
            System.Net.Mail.Attachment attach = new System.Net.Mail.Attachment(FilePath);
       
            actMSG.Attachments.Add(attach);
           
            SmtpServer.Send(actMSG);
            actMSG.Dispose();
        }
        catch (Exception ex)
        {

        }
        finally
        {
            //writer.Close();
            //writer.Dispose();
            //ms.Close();
            //ms.Dispose();
        }
    }
}