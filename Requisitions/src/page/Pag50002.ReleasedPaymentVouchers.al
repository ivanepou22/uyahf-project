/// <summary>
/// Page Released Payment Vouchers (ID 50002).
/// </summary>
page 50002 "Released Payment Vouchers"
{
    Caption = 'Released Payment Vouchers';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Payment Voucher Header";
    SourceTableView = WHERE(Status = FILTER(Released));

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
                field("Budget Code"; Rec."Budget Code")
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
                field("Prepared by"; Rec."Prepared by")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
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
                ApplicationArea = Basic, Suite;
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

