/// <summary>
/// TableExtension Source Code Setup Ext (ID 50059) extends Record Source Code Setup.
/// </summary>
tableextension 50000 "Source Code Setup Ext" extends "Source Code Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Budget Assumptions"; Code[10])
        {
            TableRelation = "Source Code";
        }
        field(50001; "NFL Requisition Header"; Code[10]) { }
        field(50002; "Outlet/SubAgent"; Code[10])
        {
            TableRelation = "Source Code";
        }
        field(50003; "Newspaper Print Order"; Code[10])
        {
            TableRelation = "Source Code";
        }
        field(50004; "Newspaper Returns"; Code[10])
        {
            TableRelation = "Source Code";
        }
    }

    var
        myInt: Integer;
}