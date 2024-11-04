//using DocumentFormat.OpenXml.Packaging;
//using DocumentFormat.OpenXml;
//using DocumentFormat.OpenXml.Spreadsheet;
//using X15 = DocumentFormat.OpenXml.Office2013.Excel;
//using X14 = DocumentFormat.OpenXml.Office2010.Excel;

//using System.Data;


////Keep this namespace


//public class GeneratedClass
//{
//    public void CreatePackage(string filePath)
//    {
//        using (SpreadsheetDocument package = SpreadsheetDocument.Create(filePath, SpreadsheetDocumentType.Workbook))
//        {
//            WriteExcelFile(GenerateDataSet(), package);
//        }
//    }

//    private DataSet GenerateDataSet()
//    {
//        DataTable table1 = new DataTable("patients");
//        table1.Columns.Add("name");
//        table1.Columns.Add("id");
//        table1.Rows.Add("sam", 1);
//        table1.Rows.Add("mark", 2);

//        DataTable table2 = new DataTable("medications");
//        table2.Columns.Add("id");
//        table2.Columns.Add("medication");
//        table2.Rows.Add(1, "atenolol");
//        table2.Rows.Add(2, "amoxicillin");

//        // Create a DataSet and put both tables in it.
//        DataSet set = new DataSet("office");
//        set.Tables.Add(table1);
//        set.Tables.Add(table2);

//        return set;

//    }

//    private static void WriteExcelFile(DataSet ds, SpreadsheetDocument spreadsheet)
//    {

//        spreadsheet.AddWorkbookPart();
//        spreadsheet.WorkbookPart.Workbook = new DocumentFormat.OpenXml.Spreadsheet.Workbook();

//        spreadsheet.WorkbookPart.Workbook.Append(new BookViews(new WorkbookView()));

//        WorkbookStylesPart workbookStylesPart = spreadsheet.WorkbookPart.AddNewPart<WorkbookStylesPart>();
//        GenerateWorkbookStylesPartContent(workbookStylesPart);

//        uint worksheetNumber = 1;
//        Sheets sheets = spreadsheet.WorkbookPart.Workbook.AppendChild<Sheets>(new Sheets());
//        foreach (DataTable dt in ds.Tables)
//        {
//            string worksheetName = dt.TableName;
//            WorksheetPart newWorksheetPart = spreadsheet.WorkbookPart.AddNewPart<WorksheetPart>();
//            Sheet sheet = new Sheet() { Id = spreadsheet.WorkbookPart.GetIdOfPart(newWorksheetPart), SheetId = worksheetNumber, Name = worksheetName };
//            newWorksheetPart.Worksheet = new Worksheet(new SheetViews(new SheetView() { WorkbookViewId = 0, RightToLeft = true }), new SheetData());
//            newWorksheetPart.Worksheet.Save();

//            sheets.Append(sheet);



//            WriteDataTableToExcelWorksheet(dt, newWorksheetPart);

//            worksheetNumber++;
//        }
//        spreadsheet.WorkbookPart.Workbook.Save();
//    }

//    private static void WriteDataTableToExcelWorksheet(DataTable dt, WorksheetPart worksheetPart)
//    {
//        var worksheet = worksheetPart.Worksheet;




//        var sheetData = worksheet.GetFirstChild<SheetData>();

//        string cellValue = "";

//        int numberOfColumns = dt.Columns.Count;
//        bool[] IsNumericColumn = new bool[numberOfColumns];

//        string[] excelColumnNames = new string[numberOfColumns];
//        for (int n = 0; n < numberOfColumns; n++)
//            excelColumnNames[n] = GetExcelColumnName(n);

//        //
//        //  Create the Header row in our Excel Worksheet
//        //
//        uint rowIndex = 2;

//        var headerRow = new Row { RowIndex = rowIndex };  // add a row at the top of spreadsheet
//        sheetData.Append(headerRow);

//        for (int colInx = 0; colInx < numberOfColumns; colInx++)
//        {
//            DataColumn col = dt.Columns[colInx];
//            AppendTextCell(excelColumnNames[colInx] + "2", col.ColumnName, headerRow);
//            IsNumericColumn[colInx] = (col.DataType.FullName == "System.Decimal") || (col.DataType.FullName == "System.Int32");
//        }


//        // טבלה עם כתרת
//        rowIndex = 4;

//        headerRow = new Row { RowIndex = rowIndex };  // add a row at the top of spreadsheet
//        sheetData.Append(headerRow);

//        for (int colInx = 0; colInx < numberOfColumns; colInx++)
//        {
//            DataColumn col = dt.Columns[colInx];
//            AppendTextCell(excelColumnNames[colInx] + "4", col.ColumnName, headerRow);
//            IsNumericColumn[colInx] = (col.DataType.FullName == "System.Decimal") || (col.DataType.FullName == "System.Int32");
//        }


//        //
//        //  Now, step through each row of data in our DataTable...
//        //
//        double cellNumericValue = 0;
//        foreach (DataRow dr in dt.Rows)
//        {
//            // ...create a new row, and append a set of this row's data to it.
//            ++rowIndex;
//            var newExcelRow = new Row { RowIndex = rowIndex };  // add a row at the top of spreadsheet
//            sheetData.Append(newExcelRow);

//            for (int colInx = 0; colInx < numberOfColumns; colInx++)
//            {
//                cellValue = dr.ItemArray[colInx].ToString();

//                // Create cell with data
//                if (IsNumericColumn[colInx])
//                {
//                    //  For numeric cells, make sure our input data IS a number, then write it out to the Excel file.
//                    //  If this numeric value is NULL, then don't write anything to the Excel file.
//                    cellNumericValue = 0;
//                    if (double.TryParse(cellValue, out cellNumericValue))
//                    {
//                        cellValue = cellNumericValue.ToString();
//                        AppendNumericCell(excelColumnNames[colInx] + rowIndex.ToString(), cellValue, newExcelRow);
//                    }
//                }
//                else
//                {
//                    //  For text cells, just write the input data straight out to the Excel file.
//                    AppendTextCell(excelColumnNames[colInx] + rowIndex.ToString(), cellValue, newExcelRow);
//                }
//            }
//        }
//    }

//    private static void AppendTextCell(string cellReference, string cellStringValue, Row excelRow)
//    {
//        //  Add a new Excel Cell to our Row
//        Cell cell = new Cell() { CellReference = cellReference, DataType = CellValues.String };
//        CellValue cellValue = new CellValue();
//        cellValue.Text = cellStringValue;
//        cell.StyleIndex = 1U;
//        cell.Append(cellValue);
//        excelRow.Append(cell);

       
//    }

//    private static void AppendNumericCell(string cellReference, string cellStringValue, Row excelRow)
//    {
//        //  Add a new Excel Cell to our Row
//        Cell cell = new Cell() { CellReference = cellReference };
//        CellValue cellValue = new CellValue();
//        cellValue.Text = cellStringValue;
//       // cell.StyleIndex = 2U;
//        cell.Append(cellValue);
//        excelRow.Append(cell);
//    }

//    private static string GetExcelColumnName(int columnIndex)
//    {
//        if (columnIndex < 26)
//            return ((char)('A' + columnIndex)).ToString();

//        char firstChar = (char)('A' + (columnIndex / 26) - 1);
//        char secondChar = (char)('A' + (columnIndex % 26));

//        return string.Format("{0}{1}", firstChar, secondChar);
//    }

  
//    private static void GenerateWorkbookStylesPartContent(WorkbookStylesPart workbookStylesPart1)
//    {
//        Stylesheet stylesheet1 = new Stylesheet() { MCAttributes = new MarkupCompatibilityAttributes() { Ignorable = "x14ac" } };
//        stylesheet1.AddNamespaceDeclaration("mc", "http://schemas.openxmlformats.org/markup-compatibility/2006");
//        stylesheet1.AddNamespaceDeclaration("x14ac", "http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac");

//        Fonts fonts1 = new Fonts() { Count = (UInt32Value)2U, KnownFonts = false };

//        Font font1 = new Font();
//        FontSize fontSize1 = new FontSize() { Val = 13D };
//        //Color color1 = new Color() { Theme = (UInt32Value)1U };
//        FontName fontName1 = new FontName() { Val = "Arial" };
//        //FontFamilyNumbering fontFamilyNumbering1 = new FontFamilyNumbering() { Val = 2 };
//        //FontScheme fontScheme1 = new FontScheme() { Val = FontSchemeValues.Minor };
//      //  ForegroundColor foregroundColor = new ForegroundColor() { Rgb = new HexBinaryValue() { Value = "#EE2828" }};
//       // BackgroundColor backgroundColor = new BackgroundColor() { Rgb = new HexBinaryValue() { Value = "#EE2828" } };

//        font1.Append(fontSize1);
//       // font1.Append(color1);
//        font1.Append(fontName1);
//        // font1.Append(fontFamilyNumbering1);
//        // font1.Append(fontScheme1);
//        //font1.Append(foregroundColor);
//        //font1.Append(backgroundColor);
//        font1.Append(new Bold());
//        font1.Append(new Color() { Rgb = "ff0000" });

//        Font font2 = new Font();
//        Bold bold1 = new Bold();
//        FontSize fontSize2 = new FontSize() { Val = 11D };
//        Color color2 = new Color() { Theme = (UInt32Value)1U };
//        FontName fontName2 = new FontName() { Val = "Arial" };
//        FontFamilyNumbering fontFamilyNumbering2 = new FontFamilyNumbering() { Val = 2 };
//        FontScheme fontScheme2 = new FontScheme() { Val = FontSchemeValues.Minor };
        
//        font2.Append(bold1);
//        font2.Append(fontSize2);
//        font2.Append(color2);
//        font2.Append(fontName2);
//        font2.Append(fontFamilyNumbering2);
//        font2.Append(fontScheme2);

//        fonts1.Append(font1);
//        fonts1.Append(font2);

//        Fills fills1 = new Fills() { Count = (UInt32Value)2U };


     
        


//        Fill fill1 = new Fill();
//        PatternFill patternFill1 = new PatternFill() { PatternType = PatternValues.Solid };
//        //ForegroundColor foregroundColor1 = new ForegroundColor() { Rgb = "Red" };
//        //patternFill1.Append(foregroundColor1);
//        BackgroundColor backgroundColor1 = new BackgroundColor() { Rgb = new HexBinaryValue() { Value = "8EA9DB" } };
//        patternFill1.Append(backgroundColor1);

//        fill1.Append(patternFill1);


//        //new DocumentFormat.OpenXml.Spreadsheet.Fill( // Index 3 - The Blue fill.
//        //   new DocumentFormat.OpenXml.Spreadsheet.PatternFill(
//        //   new DocumentFormat.OpenXml.Spreadsheet.ForegroundColor() { Rgb = new HexBinaryValue() { Value = "8EA9DB" } }
//        //   )
//        //   { PatternType = PatternValues.Solid })
//        //    )







//        Fill fill2 = new Fill();
//        PatternFill patternFill2 = new PatternFill() { PatternType = PatternValues.DarkGray };
//        //ForegroundColor foregroundColor1 = new ForegroundColor() { Rgb = "FFFF0000" };
//        //patternFill2.Append(foregroundColor1);
//        //BackgroundColor backgroundColor1 = new BackgroundColor() { Rgb = "FFFF0000" };
//        //patternFill2.Append(backgroundColor1);


//        fill2.Append(patternFill2);
//        fills1.Append(fill1);
//        fills1.Append(fill2);

//        Borders borders1 = new Borders() { Count = (UInt32Value)2U };

//        Border border1 = new Border();
//        LeftBorder leftBorder1 = new LeftBorder();
//        RightBorder rightBorder1 = new RightBorder();
//        TopBorder topBorder1 = new TopBorder();
//        BottomBorder bottomBorder1 = new BottomBorder();
//        DiagonalBorder diagonalBorder1 = new DiagonalBorder();

//        border1.Append(leftBorder1);
//        border1.Append(rightBorder1);
//        border1.Append(topBorder1);
//        border1.Append(bottomBorder1);
//        border1.Append(diagonalBorder1);

//        Border border2 = new Border();

//        LeftBorder leftBorder2 = new LeftBorder() { Style = BorderStyleValues.Thin };
//        Color color3 = new Color() { Indexed = (UInt32Value)64U };

//        leftBorder2.Append(color3);

//        RightBorder rightBorder2 = new RightBorder() { Style = BorderStyleValues.Thin };
//        Color color4 = new Color() { Indexed = (UInt32Value)64U };

//        rightBorder2.Append(color4);

//        TopBorder topBorder2 = new TopBorder() { Style = BorderStyleValues.Thin };
//        Color color5 = new Color() { Indexed = (UInt32Value)64U };

//        topBorder2.Append(color5);

//        BottomBorder bottomBorder2 = new BottomBorder() { Style = BorderStyleValues.Thin };
//        Color color6 = new Color() { Indexed = (UInt32Value)64U };

//        bottomBorder2.Append(color6);
//        DiagonalBorder diagonalBorder2 = new DiagonalBorder();

//        border2.Append(leftBorder2);
//        border2.Append(rightBorder2);
//        border2.Append(topBorder2);
//        border2.Append(bottomBorder2);
//        border2.Append(diagonalBorder2);

//        borders1.Append(border1);
//        borders1.Append(border2);

//        CellStyleFormats cellStyleFormats1 = new CellStyleFormats() { Count = (UInt32Value)1U };
//        CellFormat cellFormat1 = new CellFormat() { NumberFormatId = (UInt32Value)0U, FontId = (UInt32Value)0U, FillId = (UInt32Value)0U, BorderId = (UInt32Value)0U };

//        cellStyleFormats1.Append(cellFormat1);

//        CellFormats cellFormats1 = new CellFormats() { Count = (UInt32Value)3U };
//        CellFormat cellFormat2 = new CellFormat() { NumberFormatId = (UInt32Value)0U, FontId = (UInt32Value)0U, FillId = (UInt32Value)0U, BorderId = (UInt32Value)0U, FormatId = (UInt32Value)0U };
//        CellFormat cellFormat3 = new CellFormat() { NumberFormatId = (UInt32Value)0U, FontId = (UInt32Value)0U, FillId = (UInt32Value)0U, BorderId = (UInt32Value)1U, FormatId = (UInt32Value)0U };
//        CellFormat cellFormat4 = new CellFormat() { NumberFormatId = (UInt32Value)0U, FontId = (UInt32Value)1U, FillId = (UInt32Value)0U, BorderId = (UInt32Value)1U, FormatId = (UInt32Value)0U, ApplyFont = true, ApplyBorder = true };

//        cellFormats1.Append(cellFormat2);
//        cellFormats1.Append(cellFormat3);
//        cellFormats1.Append(cellFormat4);

//        CellStyles cellStyles1 = new CellStyles() { Count = (UInt32Value)1U };
//        CellStyle cellStyle1 = new CellStyle() { Name = "Normal", FormatId = (UInt32Value)0U, BuiltinId = (UInt32Value)0U };

//        cellStyles1.Append(cellStyle1);
//        DifferentialFormats differentialFormats1 = new DifferentialFormats() { Count = (UInt32Value)0U };
//        TableStyles tableStyles1 = new TableStyles() { Count = (UInt32Value)0U, DefaultTableStyle = "TableStyleMedium2", DefaultPivotStyle = "PivotStyleLight16" };

//        StylesheetExtensionList stylesheetExtensionList1 = new StylesheetExtensionList();

//        StylesheetExtension stylesheetExtension1 = new StylesheetExtension() { Uri = "{EB79DEF2-80B8-43e5-95BD-54CBDDF9020C}" };
//        stylesheetExtension1.AddNamespaceDeclaration("x14", "http://schemas.microsoft.com/office/spreadsheetml/2009/9/main");
//        X14.SlicerStyles slicerStyles1 = new X14.SlicerStyles() { DefaultSlicerStyle = "SlicerStyleLight1" };

//        stylesheetExtension1.Append(slicerStyles1);

//        StylesheetExtension stylesheetExtension2 = new StylesheetExtension() { Uri = "{9260A510-F301-46a8-8635-F512D64BE5F5}" };
//        stylesheetExtension2.AddNamespaceDeclaration("x15", "http://schemas.microsoft.com/office/spreadsheetml/2010/11/main");
//        X15.TimelineStyles timelineStyles1 = new X15.TimelineStyles() { DefaultTimelineStyle = "TimeSlicerStyleLight1" };

//        stylesheetExtension2.Append(timelineStyles1);

//        stylesheetExtensionList1.Append(stylesheetExtension1);
//        stylesheetExtensionList1.Append(stylesheetExtension2);

//        stylesheet1.Append(fonts1);
//        stylesheet1.Append(fills1);
//        stylesheet1.Append(borders1);
//        stylesheet1.Append(cellStyleFormats1);
//        stylesheet1.Append(cellFormats1);
//        stylesheet1.Append(cellStyles1);
//        stylesheet1.Append(differentialFormats1);
//        stylesheet1.Append(tableStyles1);
//        stylesheet1.Append(stylesheetExtensionList1);

//        workbookStylesPart1.Stylesheet = stylesheet1;
//    }


//    // Generates content of workbookStylesPart1.
//    private static void GenerateWorkbookStylesPart1Content(WorkbookStylesPart workbookStylesPart1)
//    {
//        Stylesheet stylesheet1 = new Stylesheet() { MCAttributes = new MarkupCompatibilityAttributes() { Ignorable = "x14ac x16r2" } };
//        stylesheet1.AddNamespaceDeclaration("mc", "http://schemas.openxmlformats.org/markup-compatibility/2006");
//        stylesheet1.AddNamespaceDeclaration("x14ac", "http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac");
//        stylesheet1.AddNamespaceDeclaration("x16r2", "http://schemas.microsoft.com/office/spreadsheetml/2015/02/main");

//        Fonts fonts1 = new Fonts() { Count = (UInt32Value)1U, KnownFonts = true };

//        Font font1 = new Font();
//        FontSize fontSize1 = new FontSize() { Val = 11D };
//        Color color1 = new Color() { Theme = (UInt32Value)1U };
//        FontName fontName1 = new FontName() { Val = "Calibri" };
//        FontFamilyNumbering fontFamilyNumbering1 = new FontFamilyNumbering() { Val = 2 };
//        FontScheme fontScheme1 = new FontScheme() { Val = FontSchemeValues.Minor };

//        font1.Append(fontSize1);
//        font1.Append(color1);
//        font1.Append(fontName1);
//        font1.Append(fontFamilyNumbering1);
//        font1.Append(fontScheme1);

//        fonts1.Append(font1);

//        Fills fills1 = new Fills() { Count = (UInt32Value)2U };

//        Fill fill1 = new Fill();
//        PatternFill patternFill1 = new PatternFill() { PatternType = PatternValues.None };

//        fill1.Append(patternFill1);

//        Fill fill2 = new Fill();
//        PatternFill patternFill2 = new PatternFill() { PatternType = PatternValues.Gray125 };

//        fill2.Append(patternFill2);

//        fills1.Append(fill1);
//        fills1.Append(fill2);

//        Borders borders1 = new Borders() { Count = (UInt32Value)1U };

//        Border border1 = new Border();
//        LeftBorder leftBorder1 = new LeftBorder();
//        RightBorder rightBorder1 = new RightBorder();
//        TopBorder topBorder1 = new TopBorder();
//        BottomBorder bottomBorder1 = new BottomBorder();
//        DiagonalBorder diagonalBorder1 = new DiagonalBorder();

//        border1.Append(leftBorder1);
//        border1.Append(rightBorder1);
//        border1.Append(topBorder1);
//        border1.Append(bottomBorder1);
//        border1.Append(diagonalBorder1);

//        borders1.Append(border1);

//        CellStyleFormats cellStyleFormats1 = new CellStyleFormats() { Count = (UInt32Value)1U };
//        CellFormat cellFormat1 = new CellFormat() { NumberFormatId = (UInt32Value)0U, FontId = (UInt32Value)0U, FillId = (UInt32Value)0U, BorderId = (UInt32Value)0U };

//        cellStyleFormats1.Append(cellFormat1);

//        CellFormats cellFormats1 = new CellFormats() { Count = (UInt32Value)1U };
//        CellFormat cellFormat2 = new CellFormat() { NumberFormatId = (UInt32Value)0U, FontId = (UInt32Value)0U, FillId = (UInt32Value)0U, BorderId = (UInt32Value)0U, FormatId = (UInt32Value)0U };

//        cellFormats1.Append(cellFormat2);

//        CellStyles cellStyles1 = new CellStyles() { Count = (UInt32Value)1U };
//        CellStyle cellStyle1 = new CellStyle() { Name = "Normal", FormatId = (UInt32Value)0U, BuiltinId = (UInt32Value)0U };

//        cellStyles1.Append(cellStyle1);
//        DifferentialFormats differentialFormats1 = new DifferentialFormats() { Count = (UInt32Value)0U };
//        TableStyles tableStyles1 = new TableStyles() { Count = (UInt32Value)0U, DefaultTableStyle = "TableStyleMedium2", DefaultPivotStyle = "PivotStyleLight16" };

//        StylesheetExtensionList stylesheetExtensionList1 = new StylesheetExtensionList();

//        StylesheetExtension stylesheetExtension1 = new StylesheetExtension() { Uri = "{EB79DEF2-80B8-43e5-95BD-54CBDDF9020C}" };
//        stylesheetExtension1.AddNamespaceDeclaration("x14", "http://schemas.microsoft.com/office/spreadsheetml/2009/9/main");
//        X14.SlicerStyles slicerStyles1 = new X14.SlicerStyles() { DefaultSlicerStyle = "SlicerStyleLight1" };

//        stylesheetExtension1.Append(slicerStyles1);

//        StylesheetExtension stylesheetExtension2 = new StylesheetExtension() { Uri = "{9260A510-F301-46a8-8635-F512D64BE5F5}" };
//        stylesheetExtension2.AddNamespaceDeclaration("x15", "http://schemas.microsoft.com/office/spreadsheetml/2010/11/main");
//        X15.TimelineStyles timelineStyles1 = new X15.TimelineStyles() { DefaultTimelineStyle = "TimeSlicerStyleLight1" };

//        stylesheetExtension2.Append(timelineStyles1);

//        stylesheetExtensionList1.Append(stylesheetExtension1);
//        stylesheetExtensionList1.Append(stylesheetExtension2);

//        stylesheet1.Append(fonts1);
//        stylesheet1.Append(fills1);
//        stylesheet1.Append(borders1);
//        stylesheet1.Append(cellStyleFormats1);
//        stylesheet1.Append(cellFormats1);
//        stylesheet1.Append(cellStyles1);
//        stylesheet1.Append(differentialFormats1);
//        stylesheet1.Append(tableStyles1);
//        stylesheet1.Append(stylesheetExtensionList1);

//        workbookStylesPart1.Stylesheet = stylesheet1;
//    }
//    //private static void WriteDataTableToExcelWorksheet(DataTable dt, WorksheetPart worksheetPart)
//    //{
//    //    OpenXmlWriter writer = OpenXmlWriter.Create(worksheetPart, Encoding.ASCII);
//    //    writer.WriteStartElement(new Worksheet());
//    //    writer.WriteStartElement(new SheetData());

//    //    string cellValue = "";

//    //    int numberOfColumns = dt.Columns.Count;
//    //    bool[] IsNumericColumn = new bool[numberOfColumns];
//    //    bool[] IsDateColumn = new bool[numberOfColumns];

//    //    string[] excelColumnNames = new string[numberOfColumns];
//    //    for (int n = 0; n < numberOfColumns; n++)
//    //        excelColumnNames[n] = GetExcelColumnName(n);

//    //    //
//    //    //  Create the Header row in our Excel Worksheet
//    //    //
//    //    uint rowIndex = 1;

//    //    writer.WriteStartElement(new Row { RowIndex = rowIndex });
//    //    for (int colInx = 0; colInx < numberOfColumns; colInx++)
//    //    {
//    //        DataColumn col = dt.Columns[colInx];
//    //        AppendTextCell(excelColumnNames[colInx] + "1", col.ColumnName, ref writer);
//    //        IsNumericColumn[colInx] = (col.DataType.FullName == "System.Decimal") || (col.DataType.FullName == "System.Int32") || (col.DataType.FullName == "System.Double") || (col.DataType.FullName == "System.Single");
//    //        IsDateColumn[colInx] = (col.DataType.FullName == "System.DateTime");
//    //    }
//    //    writer.WriteEndElement();   //  End of header "Row"

//    //    double cellNumericValue = 0;
//    //    foreach (DataRow dr in dt.Rows)
//    //    {

//    //        ++rowIndex;

//    //        writer.WriteStartElement(new Row { RowIndex = rowIndex });

//    //        for (int colInx = 0; colInx < numberOfColumns; colInx++)
//    //        {
//    //            cellValue = dr.ItemArray[colInx].ToString();
//    //            cellValue = ReplaceHexadecimalSymbols(cellValue);
//    //            if (IsNumericColumn[colInx])
//    //            {
//    //                cellNumericValue = 0;
//    //                if (double.TryParse(cellValue, out cellNumericValue))
//    //                {
//    //                    cellValue = cellNumericValue.ToString();
//    //                    AppendNumericCell(excelColumnNames[colInx] + rowIndex.ToString(), cellValue, ref writer);
//    //                }
//    //            }
//    //            else if (IsDateColumn[colInx])
//    //            {
//    //                //  This is a date value.
//    //                DateTime dtValue;
//    //                string strValue = "";
//    //                if (DateTime.TryParse(cellValue, out dtValue))
//    //                    strValue = dtValue.ToShortDateString();
//    //                AppendTextCell(excelColumnNames[colInx] + rowIndex.ToString(), strValue, ref writer);
//    //            }
//    //            else
//    //            {
//    //                AppendTextCell(excelColumnNames[colInx] + rowIndex.ToString(), cellValue, ref writer);
//    //            }
//    //        }
//    //        writer.WriteEndElement(); //  End of Row
//    //    }
//    //    writer.WriteEndElement(); //  End of SheetData
//    //    writer.WriteEndElement(); //  End of worksheet

//    //    writer.Close();
//    //}



//}

