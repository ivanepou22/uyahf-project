/// <summary>
/// Page Cash Budget Analysis Fact Box (ID 50020).
/// </summary>
page 50020 "Cash Budget Analysis Fact Box"
{
    // version MAG

    Caption = 'Budget Analysis Fact Box';
    PageType = CardPart;
    SourceTable = "Payment Voucher Line";

    layout
    {
        area(content)
        {
            group("Analysis Details")
            {
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                }
                field("Budget Code"; Rec."Budget Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Budget Comment"; Rec."Budget Comment")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleText1;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord();
    begin
        Rec.SETFILTER("Fiscal Year Date Filter", '%1..%2', Rec."Fiscal Year Start Date", Rec."Fiscal Year End Date");
        Rec.SETFILTER("Filter to Date Filter", '%1..%2', Rec."Filter to Date Start Date", Rec."Filter to Date End Date");
        StyleText1 := '';
        StyleText2 := '';
        IF Rec."Budget Comment as at Date" = 'Within Budget' THEN
            StyleText1 := 'Favorable';
        IF Rec."Budget Comment for the Year" = 'Within Budget' THEN
            StyleText2 := 'Favorable';
        IF Rec."Budget Comment as at Date" = 'Out of Budget' THEN
            StyleText1 := 'Unfavorable';
        IF Rec."Budget Comment for the Year" = 'Out of Budget' THEN
            StyleText2 := 'Unfavorable';

        IF Rec."Budget Comment" = 'Within Budget' THEN
            StyleText1 := 'Favorable';
        IF Rec."Budget Comment" = 'Out of Budget' THEN
            StyleText1 := 'Unfavorable';
    end;

    trigger OnOpenPage();
    begin
        Rec.SETFILTER("Fiscal Year Date Filter", '%1..%2', Rec."Fiscal Year Start Date", Rec."Fiscal Year End Date");
        Rec.SETFILTER("Filter to Date Filter", '%1..%2', Rec."Filter to Date Start Date", Rec."Filter to Date End Date");
    end;

    var
        StyleText1: Text[20];
        StyleText2: Text[20];
}

