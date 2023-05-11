/// <summary>
/// Page Cash Annual Budget Analysis (ID 50018).
/// </summary>
page 50018 "Cash Annual Budget Analysis"
{
    // version MAG

    Caption = 'Annual Budget Analysis';
    PageType = CardPart;
    SourceTable = "Payment Voucher Line";

    layout
    {
        area(content)
        {
            field("Fiscal Year Start Date"; Rec."Fiscal Year Start Date")
            {
                ApplicationArea = All;
            }
            field("Fiscal Year End Date"; Rec."Fiscal Year End Date")
            {
                ApplicationArea = All;
            }
            field("Budget Amount for the Year"; Rec."Budget Amount for the Year")
            {
                ApplicationArea = All;
            }
            field("Actual Amount for the Year"; Rec."Actual Amount for the Year")
            {
                ApplicationArea = All;
            }
            field("Commitment Amount for the Year"; Rec."Commitment Amount for the Year")
            {
                ApplicationArea = All;
            }
            field("Balance on Budget for the Year"; Rec."Balance on Budget for the Year")
            {
                ApplicationArea = All;
            }
            field("Budget Comment for the Year"; Rec."Budget Comment for the Year")
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
        Rec.SETFILTER("Fiscal Year Date Filter", '%1..%2', Rec."Fiscal Year Start Date", Rec."Fiscal Year End Date");
        StyleText1 := '';
        IF Rec."Budget Comment for the Year" = 'Within Budget' THEN
            StyleText1 := 'Favorable'
        ELSE
            IF Rec."Budget Comment for the Year" = 'Out of Budget' THEN
                StyleText1 := 'Unfavorable';
    end;

    trigger OnOpenPage();
    begin
        Rec.SETFILTER("Fiscal Year Date Filter", '%1..%2', Rec."Fiscal Year Start Date", Rec."Fiscal Year End Date");
    end;

    var
        StyleText1: Text[20];
        StyleText2: Text[20];
}

