/// <summary>
/// Page Cash Monthly Budget Analysis (ID 50215).
/// </summary>
page 50023 "Cash Monthly Budget Analysis"
{
    // version MAG

    Caption = 'Monthly Budget Analysis';
    PageType = CardPart;
    SourceTable = "Payment Voucher Line";

    layout
    {
        area(content)
        {
            field("Accounting Period Start Date"; "Accounting Period Start Date")
            {
            }
            field("Accounting Period End Date"; "Accounting Period End Date")
            {
            }
            field("Budget Amount for the Month"; "Budget Amount for the Month")
            {
            }
            field("Actual Amount for the Month"; "Actual Amount for the Month")
            {
            }
            field("Commitment Amt for the Month"; "Commitment Amt for the Month")
            {
            }
            field("Bal. on Budget for the Month"; "Bal. on Budget for the Month")
            {
            }
            field("Budget Comment for the Month"; "Budget Comment for the Month")
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
        SETFILTER("Month Date Filter", '%1..%2', "Accounting Period Start Date", "Accounting Period End Date");
        StyleText1 := '';
        IF "Budget Comment for the Month" = 'Within Budget' THEN
            StyleText1 := 'Favorable';
        IF "Budget Comment for the Month" = 'Out of Budget' THEN
            StyleText1 := 'Unfavorable';
    end;

    trigger OnOpenPage();
    begin
        SETFILTER("Month Date Filter", '%1..%2', "Accounting Period Start Date", "Accounting Period End Date");
        CurrPage.UPDATE;
    end;

    var
        StyleText1: Text[20];
        StyleText2: Text[20];
}

