/// <summary>
/// PageExtension PurchasesAndpayables (ID 50101) extends Record Purchases & Payables Setup //OriginalId.
/// </summary>
pageextension 50001 "PurchasesAndpayables" extends "Purchases & Payables Setup" //OriginalId
{
    layout
    {
        addafter("Price List Nos.")
        {
            field("Imprest Cash Voucher Nos."; Rec."Imprest Cash Voucher Nos.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Imprest Cash Voucher Nos. field.';
            }
            field("IT Cash Voucher Nos."; Rec."IT Cash Voucher Nos.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the IT Cash Voucher Nos. field.';
            }
            field("Payment Voucher Archieve Nos."; Rec."Payment Voucher Archieve Nos.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Payment Voucher Archieve Nos. field.';
            }
            field("Cash Voucher Nos."; Rec."Cash Voucher Nos.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Cash Voucher Nos. field.';
            }
            field("Cheque Payment Voucher Nos."; Rec."Cheque Payment Voucher Nos.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Cheque Payment Voucher Nos. field.';
            }
            field("HR Cash Voucher Nos."; Rec."HR Cash Voucher Nos.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the HR Cash Voucher Nos. field.';
            }
            field("Eng. Cash Voucher Nos."; Rec."Eng. Cash Voucher Nos.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Eng. Cash Voucher Nos. field.';
            }
        }
    }

    actions
    {
    }
}