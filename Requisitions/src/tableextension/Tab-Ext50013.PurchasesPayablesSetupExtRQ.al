/// <summary>
/// TableExtension Purchases & Payables Setup Ext (ID 50053) extends Record Purchases & Payables Setup.
/// </summary>
tableextension 50013 "Purchases Payables Setup ExtRQ" extends "Purchases & Payables Setup"
{
    fields
    {
        field(50001; "TIN No. Min Order Amount(LCY)"; Decimal)
        {
        }
        field(50003; "Payment Voucher Jnl. Template"; Code[10])
        {
            Caption = 'Payment Voucher Jnl. Template';
            TableRelation = "Gen. Journal Template";

            trigger OnValidate();
            begin
                CLEAR("Payment Voucher Jnl. Batch");
            end;
        }
        field(50004; "Payment Voucher Jnl. Batch"; Code[10])
        {
            Caption = 'Payment Voucher Jnl. Batch';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Payment Voucher Jnl. Template"));
        }
        field(50005; "WHT Local %"; Decimal)
        {
        }
        field(50006; "WHT Local Account"; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(50007; "WHT Foreign %"; Decimal)
        {
        }
        field(50008; "WHT Foreign Account"; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(50009; "WHT Minimum Amount"; Decimal)
        {
        }

        field(50011; "HR Cash Voucher Nos."; Code[10])
        {
            Caption = 'HR Cash Voucher Nos.';
            TableRelation = "No. Series";
        }
        field(50012; "Imprest Cash Voucher Nos."; Code[10])
        {
            Caption = 'Imprest Cash Voucher Nos.';
            TableRelation = "No. Series";
        }
        field(50013; "IT Cash Voucher Nos."; Code[10])
        {
            Caption = 'IT Cash Voucher Nos.';
            TableRelation = "No. Series";
        }
        field(50014; "Eng. Cash Voucher Nos."; Code[10])
        {
            Caption = 'Eng. Cash Voucher Nos.';
            TableRelation = "No. Series";
        }
        field(50115; "Cheque Payment Voucher Nos."; Code[10])
        {
            Caption = 'Cheque Payment Voucher Nos.';
            TableRelation = "No. Series";
        }
        field(50116; "Payment Voucher Archieve Nos."; Code[10])
        {
            Caption = 'Payment Voucher Archieve Nos.';
            TableRelation = "No. Series";
        }
        field(50117; "Cash Voucher Nos."; Code[10])
        {
            Caption = 'Cash Voucher Nos.';
            TableRelation = "No. Series";
        }
        field(50118; "Create Purch. comm. on Approv."; Boolean)
        {
            Caption = 'Create Purch. Commitment On Approval';
        }
        field(50119; "Create Vouch. comm. on Approv."; Boolean)
        {
            Caption = 'Create Voucher Commitment On Approval';
        }
    }

    var
        myInt: Integer;
}