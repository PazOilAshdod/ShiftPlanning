using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for HasotObjects
/// </summary>


// עובדי משמרת המועומדים להסעות
 
public class MishmarotWorkers
{
    public MishmarotWorkers(DataRow row)
    {


        this.HasotId = Helper.ConvertToNullInt(row["HasotId"].ToString());
        this.OrgUnitCode = row["OrgUnitCode"].ToString();
        this.EmpNo = row["EmpNo"].ToString();



        this.CityCode = row["CityCode"].ToString();
        this.ShiftDate = Helper.ConvertToDateTime(row["ShiftDate"].ToString());
        this.ShiftCode = Helper.ConvertToInt(row["ShiftCode"].ToString());
        this.AddedHours = Helper.ConvertToInt(row["AddedHours"].ToString());
        this.SourceAssignmentId = Helper.ConvertToNullInt(row["SourceAssignmentId"].ToString());

        this.SourceShiftDate = Helper.ConvertToDateTime(row["SourceShiftDate"].ToString());
        this.SourceShiftCode = Helper.ConvertToNullInt(row["SourceShiftCode"].ToString());

        this.SourceShiftDatePrevNext = Helper.ConvertToDateTime(row["SourceShiftDatePrevNext"].ToString());
        this.SourceShiftCodePrevNext = Helper.ConvertToNullInt(row["SourceShiftCodePrevNext"].ToString());

        this.RequirementId = Helper.ConvertToInt(row["RequirementId"].ToString());
        this.RequirementLine = Helper.ConvertToInt(row["RequirementLine"].ToString());
        this.RequirementAbb = row["RequirementAbb"].ToString();
        this.SwapEmpNo = row["SwapEmpNo"].ToString();
        this.FullName = row["FullName"].ToString();
        this.IsAsterisk = Helper.ConvertToBoolString(row["IsAsterisk"].ToString());

        this.RealShiftCode = this.ShiftCode;
        if (this.RequirementAbb.Contains("^^")) this.RealShiftCode = 5;
        if (this.RequirementAbb.Contains("++")) this.RealShiftCode = 6;
    }

    public int? HasotId;
    public int TypeId = 1;
    public string OrgUnitCode;
    public string EmpNo;
    public string FullName;
    public string CityCode;

    public DateTime? ShiftDate;
    public int? ShiftCode;
    public int? RealShiftCode;
    public int? AddedHours;

    public int? SourceAssignmentId;
    public DateTime? SourceShiftDate;
    public int? SourceShiftCode;

    public DateTime? SourceShiftDatePrevNext;
    public int? SourceShiftCodePrevNext;

    public int? RequirementId;
    public int? RequirementLine;
    public string RequirementAbb;
    public string SwapEmpNo;
    public int? IsAsterisk;

}

// עובדי יום המועומדים להסעות
public class OvdeYomWorkers
{
    public OvdeYomWorkers(DataRow row)
    {

        this.EmpNo = row["EmpNo"].ToString();
        this.CityCode = row["CityCode"].ToString();
        this.IsImahot = Helper.ConvertToInt(row["IsImahot"].ToString());

        if (this.IsImahot > 2)
        {
            this.TypeId = (int)this.IsImahot;

        }

    }


    public int TypeId = 2;
    public string EmpNo;
    public string CityCode;
    public int? IsImahot;


}

//אובייקט המחזיק את הרשומות של מיפוי מיניבוסים
public class Maps
{
    public Maps()
    {

    }
    public Maps(DataRow row, Configure Configure)
    {
        this.Id = Helper.ConvertToInt(row["Id"].ToString());
        this.Type = Helper.ConvertToInt(row["Type"].ToString());
        this.ShiftId = Helper.ConvertToInt(row["ShiftId"].ToString());
        this.DayInWeek = Helper.ConvertToInt(row["DayInWeek"].ToString());
        this.Hour = Helper.ConvertToTime(row["Hour"].ToString());

        this.OnlyDays = row["OnlyDays"].ToString();
        this.IsOvdeYom = Helper.ConvertToNullInt(row["IsOvdeYom"].ToString());
        this.IsImahot = Helper.ConvertToNullInt(row["IsImahot"].ToString());
        this.City = row["City"].ToString();
        this.CarType = row["CarType"].ToString();
        this.CarSymbol = row["CarSymbol"].ToString();
        this.CarTypeId = (this.CarType == "מיניבוס") ? 2 : 1;

        this.Count = (this.CarTypeId == 2) ? Configure.MinibusNumber : Configure.TaxiNumber;
        this.CurrentCount = 0;

    }
    public int Id;
    public int Type;
    public int ShiftId;
    public int DayInWeek;

    public TimeSpan? Hour;
    public string OnlyDays;
    public int? IsOvdeYom;
    public int? IsImahot;

    public string City;


    public string CarType;
    public int? CarTypeId;
    public string CarSymbol;

    public int Count;
    public int CurrentCount;
    public int Seq = 0;

}

public class Area
{
    public Area(DataRow row)
    {

        this.Code = row["Code"].ToString();
        this.Name = row["Name"].ToString();


    }


    public string Code;
    public string Name;



}

//אובייקט המחזיק את המסלולים שבהם משתמשים לצורך ההסעות
public class Maslulim
{
    public Maslulim()
    {

    }
    public Maslulim(DataRow row)
    {
        this.Id = Helper.ConvertToInt(row["Id"].ToString());
        this.Sap_Id = Helper.ConvertToInt(row["Sap_Id"].ToString());
        this.Tarif = Helper.ConvertToFloat(row["Tarif"].ToString());
        this.Type = Helper.ConvertToNullInt(row["Type"].ToString());
        this.City1 = row["City1"].ToString();
        this.City2 = row["City2"].ToString();
        this.City3 = row["City3"].ToString();
        this.City4 = row["City4"].ToString();
        this.MaslulDesc = row["MaslulDesc"].ToString();
        if (!string.IsNullOrEmpty(this.City1)) this.AllCity.Add(this.City1);
        if (!string.IsNullOrEmpty(this.City2)) this.AllCity.Add(this.City2);
        if (!string.IsNullOrEmpty(this.City3)) this.AllCity.Add(this.City3);
        if (!string.IsNullOrEmpty(this.City4)) this.AllCity.Add(this.City4);
        this.TimeBeforeTaxi = Helper.ConvertToNullInt(row["TimeBeforeTaxi"].ToString());
        this.IsOnlyMinibus = Helper.ConvertToBool(row["IsOnlyMinibus"].ToString());
    }
    public int Id;
    public int Sap_Id;
    public int? Type;

    public string City1;
    public string City2;
    public string City3;
    public string City4;
    public string MaslulDesc;
    public List<string> AllCity = new List<string>();
    public int? TimeBeforeTaxi;
    public float Tarif;

    public bool IsOnlyMinibus = false;

}

// אובייקט של משמרות
public class Shift
{
    public Shift(DataRow row)
    {
        this.TypeId = Helper.ConvertToInt(row["TypeId"].ToString());
        this.ShiftId = Helper.ConvertToInt(row["ShiftId"].ToString());
        this.StartTime = Helper.ConvertToTime(row["StartTime"].ToString());
        this.EndTime = Helper.ConvertToTime(row["EndTime"].ToString());

    }

    public int TypeId;
    public int ShiftId;
    public TimeSpan? StartTime;
    public TimeSpan? EndTime;

}

// זמני משמרות
public class ShiftTimes
{

    public ShiftTimes(DataRow row)
    {
        this.DayId = Helper.ConvertToInt(row["DayId"].ToString());
        this.ShiftId = Helper.ConvertToInt(row["ShiftId"].ToString());
        this.HolidayCode = row["HolidayCode"].ToString();
        this.DayType = Helper.ConvertToInt(row["DayType"].ToString());
        this.TomorrowDayType = Helper.ConvertToInt(row["TomorrowDayType"].ToString());


    }

    public int DayId;
    public int ShiftId;
    public string HolidayCode;
    public string ValueDesc;
    public int? DayType;
    public int? TomorrowDayType;

}

// הגדרות מערכת
public class Configure
{
    public Configure(DataRow row)
    {

        this.MinibusNumber = Helper.ConvertToInt(row["MinibusNumber"].ToString());
        this.TaxiNumber = Helper.ConvertToInt(row["TaxiNumber"].ToString());


    }


    public int MinibusNumber;
    public int TaxiNumber;



}


public class SeqObject
{
    public SeqObject()
    {



    }


    public int? MaslulId;
    public TimeSpan? HasotTime;
    public int? CarTypeId = 1;


}

// אובייקט מרכזי המכיל את ההשמה של ההסעות לעובדים
public class HasotTemplate
{
    public HasotTemplate(DataRow row)
    {
        this.HasotId = Helper.ConvertToInt(row["HasotId"].ToString());
        this.MaslulId = Helper.ConvertToNullInt(row["MaslulId"].ToString());
        this.Dir = Helper.ConvertToInt(row["Dir"].ToString());
        this.ShiftId = Helper.ConvertToInt(row["ShiftId"].ToString());
        this.EmpNo = row["EmpNo"].ToString();
        this.Comment = row["Comment"].ToString();
        this.IsYom = Helper.ConvertToBool(row["IsYom"].ToString());
        this.CityCode = row["CityCode"].ToString();
        this.HasotDate = Helper.ConvertToDateTime(row["HasotDate"].ToString());
        this.HasotTime = Helper.ConvertToTime(row["HasotTime"].ToString());

        this.CarTypeId = Helper.ConvertToNullInt(row["CarTypeId"].ToString());
        this.Seq = Helper.ConvertToInt(row["Seq"].ToString());

        this.Status = Helper.ConvertToInt(row["Status"].ToString());
        this.StatusDelete = Helper.ConvertToNullInt(row["StatusDelete"].ToString());


        this.IsSource = Helper.ConvertToBool(row["IsSource"].ToString());
        this.CarSymbol = row["CarSymbol"].ToString();
        this.TempStreet = row["TempStreet"].ToString();
        this.Mdest = row["Mdest"].ToString();
        this.Mprice = Helper.ConvertToFloat(row["Mprice"].ToString());
        this.TextChange = row["TextChange"].ToString();
        
    }


    public HasotTemplate()
    {


    }

    public object Clone()
    {
        return this.MemberwiseClone();
    }

    public int? HasotId;
    public int? MaslulId;
    public int Dir;
    public int ShiftId;
    public string EmpNo;
    public string FullName;
    public bool IsYom;
    public string CityCode;
    public string CityDesc;
    public DateTime? HasotDate;
    public TimeSpan? HasotTime;
    public Maps Map;
    public int? CarTypeId = 1;
    public int Seq = 0;
    public int StatusAction = 0;
    public int Status = 1;
    public int? StatusDelete = 0;

    public bool IsSource = true;
    public string Comment;
    public string CarSymbol;
    public string TempStreet;
    public string Mdest;
    public float Mprice;
    public string TextChange;
    public int? AddedHours;


    //  public bool IsFromRefresh = false;

}


// ההסעות שכבר קיימות לצורך שינוי או עדכון
public class CurrentHasot
{
    public CurrentHasot(DataRow row)
    {
        this.HasotId = Helper.ConvertToInt(row["HasotId"].ToString());
        this.MaslulId = Helper.ConvertToNullInt(row["MaslulId"].ToString());
        this.Dir = Helper.ConvertToInt(row["Dir"].ToString());
        this.ShiftId = Helper.ConvertToInt(row["ShiftId"].ToString());
        this.EmpNo = row["EmpNo"].ToString();
        this.Comment = row["Comment"].ToString();
        this.IsYom = Helper.ConvertToBool(row["IsYom"].ToString());
        this.CityCode = row["CityCode"].ToString();
        this.HasotDate = Helper.ConvertToDateTime(row["HasotDate"].ToString());
        this.HasotTime = Helper.ConvertToTime(row["HasotTime"].ToString());

        this.CarTypeId = Helper.ConvertToNullInt(row["CarTypeId"].ToString());
        this.Seq = Helper.ConvertToInt(row["Seq"].ToString());

        this.Status = Helper.ConvertToInt(row["Status"].ToString());
        this.StatusDelete = Helper.ConvertToNullInt(row["StatusDelete"].ToString());


        this.IsSource = Helper.ConvertToBool(row["IsSource"].ToString());

        this.TempStreet = row["TempStreet"].ToString();
        this.CarSymbol = row["CarSymbol"].ToString();
        this.Mdest = row["Mdest"].ToString();
        this.Mprice = Helper.ConvertToFloat(row["Mprice"].ToString());

    }

    public CurrentHasot()
    {

    }

    public int HasotId;
    public int? MaslulId;
    public int Dir;
    public int ShiftId;
    public string EmpNo;

    public bool IsYom;
    public string CityCode;
    public string Comment;
    public DateTime? HasotDate;
    public TimeSpan? HasotTime;

    public int? CarTypeId;
    public int Seq;
    public int Status;
    public int? StatusDelete;
    public bool IsSource;

    public string TempStreet;
    public string CarSymbol;
    public string Mdest;
    public float Mprice;


}

public class CarsBindToEmpNo
{
    public CarsBindToEmpNo()
    {

    }
    public int Type;
    public int MaslulId;
    public string CityCode;
    public string CarType;
    public string CarSymbol;
    public string EmpNo;
    public int Dir;
    public DateTime? HasotDate;
    public TimeSpan? HasotTime;
    public int ShiftId;
    public bool IsYom;
    public int Count;

}

// כל עיר באיזה אובייקט של מסלולים היא נמצאית
public class CityMaslulim
{
    public CityMaslulim(int ListCount)
    {
        this.MaslulId = new List<int>();
        this.Count = new List<int>();

        for (int i = 0; i < ListCount; i++)
        {
            this.MaslulId.Add(0);
            this.Count.Add(0);
        }


    }
    public List<string> EmpNo;
    public List<string> CityCodes;
    public List<int> MaslulId;

    public List<int> Count;

}

// ההסעות שכבר קיימות לצורך שינוי או עדכון
public class CurrentHasotTemp
{
    public CurrentHasotTemp(DataRow row)
    {

        this.EmpName = row["EmpName"].ToString();
        this.HasotId = Helper.ConvertToInt(row["HasotId"].ToString());
        this.EmpNo = row["EmpNo"].ToString();
        this.MaslulId = Helper.ConvertToNullInt(row["MaslulId"].ToString());
        this.CarTypeId = Helper.ConvertToNullInt(row["CarTypeId"].ToString());
        this.Seq = Helper.ConvertToInt(row["Seq"].ToString());
        this.Status = Helper.ConvertToInt(row["Status"].ToString());
        this.IsSource = Helper.ConvertToBool(row["IsSource"].ToString());
        this.HasotDate = Helper.ConvertToDateTime(row["HasotDate"].ToString());
        this.HasotTime = Helper.ConvertToTime(row["HasotTime"].ToString());



        this.HasotIdTemp = Helper.ConvertToInt(row["HasotIdTemp"].ToString());
        this.EmpNoTemp = row["EmpNoTemp"].ToString();
        this.MaslulIdTemp = Helper.ConvertToNullInt(row["MaslulIdTemp"].ToString());
        this.CarTypeIdTemp = Helper.ConvertToNullInt(row["CarTypeIdTemp"].ToString());
        this.SeqTemp = Helper.ConvertToInt(row["SeqTemp"].ToString());
        this.StatusTemp = Helper.ConvertToInt(row["StatusTemp"].ToString());
        // this.IsSourceTemp = Helper.ConvertToBool(row["IsSourceTemp"].ToString());
        this.HasotDateTemp = Helper.ConvertToDateTime(row["HasotDateTemp"].ToString());
        this.HasotTimeTemp = Helper.ConvertToTime(row["HasotTimeTemp"].ToString());

        //this.Dir = Helper.ConvertToInt(row["Dir"].ToString());
        //this.ShiftId = Helper.ConvertToInt(row["ShiftId"].ToString());

        //this.Comment = row["Comment"].ToString();
        //this.IsYom = Helper.ConvertToBool(row["IsYom"].ToString());
        //this.CityCode = row["CityCode"].ToString();



        //this.Seq = Helper.ConvertToInt(row["Seq"].ToString());


        //this.StatusDelete = Helper.ConvertToNullInt(row["StatusDelete"].ToString());






    }


    public string EmpName;
    public int HasotId;
    public string EmpNo;
    public int? MaslulId;
    public int? CarTypeId;
    public int Seq;
    public int Status;
    public bool IsSource;
    public DateTime? HasotDate;
    public TimeSpan? HasotTime;


    public int HasotIdTemp;
    public string EmpNoTemp;
    public int? MaslulIdTemp;
    public int? CarTypeIdTemp;
    public int SeqTemp;
    public int StatusTemp;
    //public bool IsSourceTemp;
    public DateTime? HasotDateTemp;
    public TimeSpan? HasotTimeTemp;


    


}

public class NewMaslulim
{
    public NewMaslulim()
    {
       

    }
   
    public int MaslulId;
    public int BothMaslulCount;
    public int MaslulCityCount;

}

//כלסס של פונקציות עזר 
public static class Helper
{
    public static TimeSpan AddHours(TimeSpan timeSpan, int hoursToAdd)
    {
        TimeSpan newSpan = new TimeSpan(0, hoursToAdd, 0, 0);
        TimeSpan res = timeSpan.Add(newSpan);
        return new TimeSpan(res.Hours, res.Minutes, res.Seconds);
    }
    public static TimeSpan AddMinutes(TimeSpan timeSpan, int MinutesToAdd)
    {
        TimeSpan newSpan = new TimeSpan(0, 0, MinutesToAdd, 0);
        TimeSpan res = timeSpan.Add(newSpan);
        return new TimeSpan(res.Hours, res.Minutes, res.Seconds);
    }


    public static bool In<TItem>(this TItem source, Func<TItem, TItem, bool> comparer, IEnumerable<TItem> items)
    {
        return items.Any(item => comparer(source, item));
    }

    public static bool In<TItem, T>(this TItem source, Func<TItem, T> selector, IEnumerable<TItem> items)
    {
        return items.Select(selector).Contains(selector(source));
    }

    public static bool In<T>(this T source, IEnumerable<T> items)
    {
        return items.Contains(source);
    }

    public static bool In<TItem>(this TItem source, Func<TItem, TItem, bool> comparer, params TItem[] items)
    {
        return source.In(comparer, (IEnumerable<TItem>)items);
    }

    public static bool In<TItem, T>(this TItem source, Func<TItem, T> selector, params TItem[] items)
    {
        return source.In(selector, (IEnumerable<TItem>)items);
    }

    public static bool In<T>(this T source, params T[] items)
    {
        return source.In((IEnumerable<T>)items);
    }
    public static int ConvertToInt(string val)
    {

        int res;
        bool isOk = Int32.TryParse(val, out res);

        if (isOk)
            return res;

        return 0;


    }


    public static float ConvertToFloat(string val)
    {

        float res;
        bool isOk = float.TryParse(val, out res);

        if (isOk)
            return res;

        return 0;


    }

    public static int ConvertToBoolString(string val)
    {



        if (val == "True")
            return 1;

        return 0;


    }


    public static bool ConvertToBool(string val)
    {

        bool res;
        bool isOk = bool.TryParse(val, out res);

        if (isOk)
            return res;

        return false;


    }


    public static int? ConvertToNullInt(string val)
    {

        int res;
        bool isOk = Int32.TryParse(val, out res);

        if (isOk)
            return res;

        return null;


    }


    public static DateTime? ConvertToDateTime(string val)
    {

        DateTime res;
        bool isOk = DateTime.TryParse(val, out res);

        if (isOk)
            return res;

        return null;


    }


    public static TimeSpan? ConvertToTime(string val)
    {

        TimeSpan res;
        bool isOk = TimeSpan.TryParse(val, out res);

        if (isOk)
            return res;

        return null;


    }

    public static string ConvertToNullIfEmpty(string v)
    {
        if (string.IsNullOrEmpty(v)) return null;
        else
            return v;
    }
}
