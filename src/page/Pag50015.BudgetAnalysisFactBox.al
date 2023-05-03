/// <summary>
/// Page Budget Analysis Fact Box (ID 50206).
/// </summary>
page 50015 "Budget Analysis Fact Box"
{
    // version MAG

    Caption = 'Budget Analysis Fact Box';
    PageType = CardPart;
    SourceTable = "NFL Requisition Line";

    layout
    {
        area(content)
        {
            group("Analysis Details")
            {
                field("Control Account"; "Control Account")
                {
                }
                field("Budget Code"; "Budget Code")
                {
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                }
                field("Amount Requested"; "Line Amount")
                {
                    Caption = 'Amount Requested';
                }
                field("Budget Comment"; "Budget Comment")
                {
                    StyleExpr = StyleText3;
                }
            }
            group("Related Documents")
            {
                field("Purchase Orders"; "Purchase Orders")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord();
    begin
        SETFILTER("Fiscal Year Date Filter", '%1..%2', "Fiscal Year Start Date", "Fiscal Year End Date");
        SETFILTER("Filter to Date Filter", '%1..%2', "Filter to Date Start Date", "Fiscal Year End Date");
        StyleText1 := '';
        StyleText2 := '';
        IF "Budget Comment as at Date" = 'Within Budget' THEN
            StyleText1 := 'Favorable';
        IF "Budget Comment for the Year" = 'Within Budget' THEN
            StyleText2 := 'Favorable';
        IF "Budget Comment as at Date" = 'Out of Budget' THEN
            StyleText1 := 'Unfavorable';
        IF "Budget Comment for the Year" = 'Out of Budget' THEN
            StyleText2 := 'Unfavorable';

        IF "Budget Comment" = 'Out of Budget' THEN
            StyleText3 := 'Unfavorable';
        IF "Budget Comment" = 'Out of Budget' THEN
            StyleText3 := 'Unfavorable';
    end;

    trigger OnOpenPage();
    begin
        SETFILTER("Fiscal Year Date Filter", '%1..%2', "Fiscal Year Start Date", "Fiscal Year End Date");
        SETFILTER("Filter to Date Filter", '%1..%2', "Filter to Date Start Date", "Filter to Date End Date");
    end;

    var
        StyleText1: Text[20];
        StyleText2: Text[20];
        StyleText3: Text[20];
}

