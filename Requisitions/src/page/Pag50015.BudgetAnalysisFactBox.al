/// <summary>
/// Page Budget Analysis Fact Box (ID 50015).
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
                field("Control Account"; Rec."Control Account")
                {
                }
                field("Budget Code"; Rec."Budget Code")
                {
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                }
                field("Amount Requested"; Rec."Line Amount")
                {
                    Caption = 'Amount Requested';
                }
                field("Budget Comment"; Rec."Budget Comment")
                {
                    StyleExpr = StyleText3;
                }
            }
            group("Related Documents")
            {
                field("Purchase Orders"; Rec."Purchase Orders")
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
        Rec.SETFILTER("Fiscal Year Date Filter", '%1..%2', Rec."Fiscal Year Start Date", Rec."Fiscal Year End Date");
        Rec.SETFILTER("Filter to Date Filter", '%1..%2', Rec."Filter to Date Start Date", Rec."Fiscal Year End Date");
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

        IF Rec."Budget Comment" = 'Out of Budget' THEN
            StyleText3 := 'Unfavorable';
        IF Rec."Budget Comment" = 'Out of Budget' THEN
            StyleText3 := 'Unfavorable';
    end;

    trigger OnOpenPage();
    begin
        Rec.SETFILTER("Fiscal Year Date Filter", '%1..%2', Rec."Fiscal Year Start Date", Rec."Fiscal Year End Date");
        Rec.SETFILTER("Filter to Date Filter", '%1..%2', Rec."Filter to Date Start Date", Rec."Filter to Date End Date");
    end;

    var
        StyleText1: Text[20];
        StyleText2: Text[20];
        StyleText3: Text[20];
}

