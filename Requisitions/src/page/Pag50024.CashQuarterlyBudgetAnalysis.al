/// <summary>
/// Page Cash Quarterly Budget Analysis (ID 50216).
/// </summary>
page 50024 "Cash Quarterly Budget Analysis"
{
    // version MAG

    Caption = 'Quarterly Budget Analysis';
    PageType = CardPart;
    SourceTable = "Payment Voucher Line";

    layout
    {
        area(content)
        {
            field("Quarter Start Date"; "Quarter Start Date")
            {
            }
            field("Quarter End Date"; "Quarter End Date")
            {
            }
            field("Budget Amount for the Quarter"; "Budget Amount for the Quarter")
            {
            }
            field("Actual Amount for the Quarter"; "Actual Amount for the Quarter")
            {
            }
            field("Commitment Amt for the Quarter"; "Commitment Amt for the Quarter")
            {
            }
            field("Bal. on Budget for the Quarter"; "Bal. on Budget for the Quarter")
            {
            }
            field("Budget Comment for the Quarter"; "Budget Comment for the Quarter")
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
        SETFILTER("Quarter Date Filter", '%1..%2', "Quarter Start Date", "Quarter End Date");
        StyleText1 := '';
        IF "Budget Comment for the Quarter" = 'Within Budget' THEN
            StyleText1 := 'Favorable';
        IF "Budget Comment for the Quarter" = 'Out of Budget' THEN
            StyleText1 := 'Unfavorable';
    end;

    trigger OnOpenPage();
    begin
        SETFILTER("Quarter Date Filter", '%1..%2', "Quarter Start Date", "Quarter End Date");
        CurrPage.UPDATE;
    end;

    var
        StyleText1: Text[20];
        StyleText2: Text[20];
}

