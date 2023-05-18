/// <summary>
/// Page Payt Vouchers Pending Approval (ID 50006).
/// </summary>
page 50006 "Payt Vouchers Pending Approval"
{
    // version MAG

    Caption = 'Payment Vouchers Pending Approval';
    CardPageID = "Cash Voucher";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Payment Voucher Header";
    SourceTableView = WHERE(Status = FILTER("Pending Approval"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Budget Code"; Rec."Budget Code")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = All;
                }
                field(Payee; Rec.Payee)
                {
                    ApplicationArea = All;
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                }
                field("Prepared by"; Rec."Prepared by")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("WHT Local"; Rec."WHT Local")
                {
                    ApplicationArea = All;
                }
                field("WHT Foreign"; Rec."WHT Foreign")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Payment Voucher Details Total"; Rec."Payment Voucher Details Total")
                {
                    ApplicationArea = All;
                }
                field("Payment Voucher Lines Total"; Rec."Payment Voucher Lines Total")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Co&mments")
            {
                ApplicationArea = Comments;
                Caption = 'Co&mments';
                Image = ViewComments;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Purch. Comment Sheet";
                RunPageLink = "Document Type" = CONST("Cash Voucher"),
                                  "No." = FIELD("No."),
                                  "Document Line No." = CONST(0);
                ToolTip = 'View or add comments for the record.';
            }
        }
    }

    trigger OnOpenPage();
    begin
        CurrPage.UPDATE;
    end;
}

