/// <summary>
/// Page Released Payment Vouchers (ID 50005).
/// </summary>
page 50005 "Open Payment Vouchers"
{
    // version MAG

    Caption = 'Released Payment Vouchers';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Payment Voucher Header";
    SourceTableView = WHERE(Status = FILTER(Open));

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
                field("Document Type"; Rec."Document Type")
                {
                }
                field("Payment Type"; Rec."Payment Type")
                {
                }
                field(Payee; Rec.Payee)
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
                field("WHT Local"; Rec."WHT Local")
                {
                }
                field("WHT Foreign"; Rec."WHT Foreign")
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
        area(navigation)
        {
            action(Document)
            {
                Caption = 'Document';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

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
}

