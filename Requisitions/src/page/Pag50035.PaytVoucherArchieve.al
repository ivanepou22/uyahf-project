/// <summary>
/// Page Payt Voucher Archieve (ID 50227).
/// </summary>
page 50035 "Payt Voucher Archieve"
{
    // version MAG

    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    SourceTable = "Payt Voucher Header Archieve";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                }
                field("Voucher No."; "Voucher No.")
                {
                }
                field("Posting Date"; "Posting Date")
                {
                }
                field("Budget Code"; "Budget Code")
                {
                }
                field(Status; Status)
                {
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                }
                field("Document Type"; "Document Type")
                {
                }
                field(Comment; Comment)
                {
                }
                field("Prepared by"; "Prepared by")
                {
                }
                field(Payee; Payee)
                {
                }
                field("Payment Type"; "Payment Type")
                {
                }
                field("Balancing Entry"; "Balancing Entry")
                {
                }
                field("Currency Code"; "Currency Code")
                {
                }
                field("Accounting Period Start Date"; "Accounting Period Start Date")
                {
                }
                field("Accounting Period End Date"; "Accounting Period End Date")
                {
                }
                field("Fiscal Year Start Date"; "Fiscal Year Start Date")
                {
                }
                field("Fiscal Year End Date"; "Fiscal Year End Date")
                {
                }
                field("Filter to Date Start Date"; "Filter to Date Start Date")
                {
                }
                field("Filter to Date End Date"; "Filter to Date End Date")
                {
                }
                field("Quarter Start Date"; "Quarter Start Date")
                {
                }
                field("Quarter End Date"; "Quarter End Date")
                {
                }
                field(Archieved; Archieved)
                {
                }
                field(Commited; Commited)
                {
                }
                field("Transferred to Journals"; "Transferred to Journals")
                {
                }
                field("Bank File Generated"; "Bank File Generated")
                {
                }
                field("Received by"; "Received by")
                {
                }
                field("Payment Voucher Details Total"; "Payment Voucher Details Total")
                {
                }
                field("Payment Voucher Lines Total"; "Payment Voucher Lines Total")
                {
                }
                field("Payee No."; "Payee No.")
                {
                }
                field("Accountability Comment"; "Accountability Comment")
                {
                }
            }
            part(Details; "Payt Voucher Detail Subform")
            {
                SubPageLink = "Document No." = FIELD("No."),
                              "Document Type" = FIELD("Document Type");
            }
            part(Lines; "Payt Voucher Line Subform")
            {
                SubPageLink = "Document No." = FIELD("No."),
                              "Document Type" = FIELD("Document Type");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Navigate)
            {
                action("Print Payment Requisition")
                {
                    Image = PrintDocument;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction();
                    var
                        PaymentVoucherHeader: Record "Payment Voucher Header";
                        ChequePaymentVoucher: Report "Cheque Payment Voucher";
                    begin
                        PaytVoucherHeaderArchieve.RESET;
                        PaytVoucherHeaderArchieve.SETRANGE("No.", "No.");
                        ArchivedChequePaytVoucher.SETTABLEVIEW(PaytVoucherHeaderArchieve);
                        ArchivedChequePaytVoucher.RUN();
                    end;
                }
            }
        }
    }

    var
        PaytVoucherHeaderArchieve: Record "Payt Voucher Header Archieve";
        ArchivedChequePaytVoucher: Report "Archived Cheque Payt Voucher";
}

