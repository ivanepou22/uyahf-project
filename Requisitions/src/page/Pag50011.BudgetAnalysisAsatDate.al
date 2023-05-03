/// <summary>
/// Page Budget Analysis As at Date (ID 50202).
/// </summary>
page 50011 "Budget Analysis As at Date"
{
    // version MAG

    Caption = 'Budget Analysis As at Date';
    PageType = CardPart;
    SourceTable = "NFL Requisition Line";

    layout
    {
        area(content)
        {
            field("Fiscal Year Start Date"; "Fiscal Year Start Date")
            {
            }
            field("Fiscal Year End Date"; "Fiscal Year End Date")
            {
            }
            field("Budget Amount as at Date"; "Budget Amount as at Date")
            {
            }
            field("Actual Amount as at Date"; "Actual Amount as at Date")
            {
            }
            field("Commitment Amount as at Date"; "Commitment Amount as at Date")
            {
            }
            field("Balance on Budget as at Date"; "Balance on Budget as at Date")
            {
            }
            field("Budget Comment as at Date"; "Budget Comment as at Date")
            {
                StyleExpr = StyleText1;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord();
    begin
        SETFILTER("Filter to Date Filter", '%1..%2', "Filter to Date Start Date", "Filter to Date End Date");
        StyleText1 := '';
        IF "Budget Comment as at Date" = 'Within Budget' THEN
            StyleText1 := 'Favorable';
        IF "Budget Comment as at Date" = 'Out of Budget' THEN
            StyleText1 := 'Unfavorable';
    end;

    trigger OnOpenPage();
    begin
        SETFILTER("Filter to Date Filter", '%1..%2', "Filter to Date Start Date", "Filter to Date End Date");
    end;

    var
        StyleText1: Text[20];
        StyleText2: Text[20];
}

