/// <summary>
/// Page Cash Monthly Budget Analysis (ID 50021).
/// </summary>
page 50021 "Cash Monthly Budget Analysis"
{
    // version MAG

    Caption = 'Monthly Budget Analysis';
    PageType = CardPart;
    SourceTable = "Payment Voucher Line";

    layout
    {
        area(content)
        {
            field("Accounting Period Start Date"; Rec."Accounting Period Start Date")
            {
                ApplicationArea = All;
            }
            field("Accounting Period End Date"; Rec."Accounting Period End Date")
            {
                ApplicationArea = All;
            }
            field("Budget Amount for the Month"; Rec."Budget Amount for the Month")
            {
                ApplicationArea = All;
            }
            field("Actual Amount for the Month"; Rec."Actual Amount for the Month")
            {
                ApplicationArea = All;
            }
            field("Commitment Amt for the Month"; Rec."Commitment Amt for the Month")
            {
                ApplicationArea = All;
            }
            field("Bal. on Budget for the Month"; Rec."Bal. on Budget for the Month")
            {
                ApplicationArea = All;
            }
            field("Budget Comment for the Month"; Rec."Budget Comment for the Month")
            {
                ApplicationArea = All;
                StyleExpr = StyleText1;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord();
    begin
        Rec.SETFILTER("Month Date Filter", '%1..%2', Rec."Accounting Period Start Date", Rec."Accounting Period End Date");
        StyleText1 := '';
        IF Rec."Budget Comment for the Month" = 'Within Budget' THEN
            StyleText1 := 'Favorable';
        IF Rec."Budget Comment for the Month" = 'Out of Budget' THEN
            StyleText1 := 'Unfavorable';

        Rec.CalcFields("Budget Amount for the Month", "Actual Amount for the Month", "Commitment Amt for the Month");
    end;

    trigger OnOpenPage();
    begin
        Rec.SETFILTER("Month Date Filter", '%1..%2', Rec."Accounting Period Start Date", Rec."Accounting Period End Date");
    end;

    var
        StyleText1: Text[20];
        StyleText2: Text[20];
}

