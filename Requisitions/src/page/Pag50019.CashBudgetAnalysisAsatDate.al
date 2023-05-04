/// <summary>
/// Page CashBudget Analysis As at Date (ID 50213).
/// </summary>
page 50019 "CashBudget Analysis As at Date"
{
    // version MAG

    Caption = 'Budget Analysis As at Date';
    PageType = CardPart;
    SourceTable = "Payment Voucher Line";

    layout
    {
        area(content)
        {
            field("Filter to Date Start Date"; Rec."Filter to Date Start Date")
            {
            }
            field("Filter to Date End Date"; Rec."Filter to Date End Date")
            {
            }
            field("Budget Amount as at Date"; Rec."Budget Amount as at Date")
            {
            }
            field("Actual Amount as at Date"; Rec."Actual Amount as at Date")
            {
            }
            field("Commitment Amount as at Date"; Rec."Commitment Amount as at Date")
            {
            }
            field("Balance on Budget as at Date"; Rec."Balance on Budget as at Date")
            {
            }
            field("Budget Comment as at Date"; Rec."Budget Comment as at Date")
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
        Rec.SETFILTER("Filter to Date Filter", '%1..%2', Rec."Filter to Date Start Date", Rec."Filter to Date End Date");
        StyleText1 := '';
        IF Rec."Budget Comment as at Date" = 'Within Budget' THEN
            StyleText1 := 'Favorable';
        IF Rec."Budget Comment as at Date" = 'Out of Budget' THEN
            StyleText1 := 'Unfavorable';
    end;

    trigger OnOpenPage();
    begin
        Rec.SETFILTER("Filter to Date Filter", '%1..%2', Rec."Filter to Date Start Date", Rec."Filter to Date End Date");
    end;

    var
        StyleText1: Text[20];
        StyleText2: Text[20];
}

