/// <summary>
/// Page List of All Payment Vouchers (ID 50004).
/// </summary>
page 50004 "List of All Payment Vouchers"
{
    // version MAG

    Caption = 'List of All Payment Vouchers';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Payment Voucher Header";

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
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = All;
                }
                field("Payee No."; Rec."Payee No.")
                {
                    ApplicationArea = All;
                }
                field(Payee; Rec.Payee)
                {
                    ApplicationArea = All;
                }
                field("Budget Code"; Rec."Budget Code")
                {
                    ApplicationArea = All;
                }
                field("Prepared by"; Rec."Prepared by")
                {
                    ApplicationArea = All;
                }
                field(PaymentVoucherLinesExist; Rec.PaymentVoucherLinesExist)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(Comment; Rec.Comment)
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
        area(navigation)
        {
            action(Document)
            {
                Caption = 'Document';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+O';

                trigger OnAction();
                begin
                    Rec.ShowPaymentVoucherDocument(Rec."No.", Rec."Document Type");
                end;
            }
        }
    }

    var
        PaymentVoucherDetail: Record "Payment Voucher Detail";
        // NFLApprovalsManagement: Codeunit "NFL Approvals Management";
        SelectTemplateBatch: Report "Select Template & Batch";
        PaymentVoucherHeader: Record "Payment Voucher Header";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        gvJournalTemplateName: Code[20];
        gvJournalBatchName: Code[20];
    // PaymentVoucher: Page "Cash Voucher";  LF
}

