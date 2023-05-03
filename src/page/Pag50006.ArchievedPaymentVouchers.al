/// <summary>
/// Page Archieved Payment Vouchers (ID 50105).
/// </summary>
page 50006 "Archieved Payment Vouchers"
{
    // version MAG

    Caption = 'Archieved Payment Vouchers';
    CardPageID = "Payt Voucher Archieve";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Payt Voucher Header Archieve";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                }
                field("Voucher No."; Rec."Voucher No.")
                {
                }
                field(Payee; Rec.Payee)
                {
                }
                field("Posting Date"; Rec."Posting Date")
                {
                }
                field("Document Type"; Rec."Document Type")
                {
                }
                field("Payment Type"; Rec."Payment Type")
                {
                }
                field("Budget Code"; Rec."Budget Code")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field(Comment; Rec.Comment)
                {
                }
                field("Prepared by"; Rec."Prepared by")
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

    var
        PaymentVoucherDetail: Record "Payment Voucher Detail";
        // NFLApprovalsManagement: Codeunit "NFL Approvals Management";
        SelectTemplateBatch: Report "Select Template & Batch";
        PaymentVoucherHeader: Record "Payment Voucher Header";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        gvJournalTemplateName: Code[20];
        gvJournalBatchName: Code[20];
    //  PaymentVoucher: Page "Cash Voucher";  LF
}

