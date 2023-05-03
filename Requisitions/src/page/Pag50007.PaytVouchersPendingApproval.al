/// <summary>
/// Page Payt Vouchers Pending Approval (ID 50106).
/// </summary>
page 50007 "Payt Vouchers Pending Approval"
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
                }
                field("Posting Date"; Rec."Posting Date")
                {
                }
                field("Budget Code"; Rec."Budget Code")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Document Type"; Rec."Document Type")
                {
                }
                field("Payment Type"; Rec."Payment Type")
                {
                }
                field(Payee; Rec.Payee)
                {
                }
                field(Comment; Rec.Comment)
                {
                }
                field("Prepared by"; Rec."Prepared by")
                {
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                }
                field("WHT Local"; Rec."WHT Local")
                {
                }
                field("WHT Foreign"; Rec."WHT Foreign")
                {
                }
                field("Currency Code"; Rec."Currency Code")
                {
                }
                field("Payment Voucher Details Total"; Rec."Payment Voucher Details Total")
                {
                }
                field("Payment Voucher Lines Total"; Rec."Payment Voucher Lines Total")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage();
    begin
        CurrPage.UPDATE;
    end;
}

