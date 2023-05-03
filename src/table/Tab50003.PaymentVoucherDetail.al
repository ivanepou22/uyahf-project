/// <summary>
/// Table Payment Voucher Detail (ID 50077).
/// </summary>
table 50003 "Payment Voucher Detail"
{
    // version

    Caption = 'Payment Voucher Detail';

    fields
    {
        field(1; "Document No."; Code[20])
        {
        }
        field(2; "Line No."; Integer)
        {
            Editable = false;
        }
        field(3; Details; Text[150])
        {
            Caption = 'Details';

            trigger OnValidate();
            begin
                TestStatusOpen;
            end;
        }
        field(4; Amount; Decimal)
        {
            Caption = 'Amount';
            DecimalPlaces = 0 : 2;

            trigger OnValidate();
            begin
                TestStatusOpen;
            end;
        }
        field(5; "Commitment Entry No."; Integer)
        {
        }
        field(6; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Store Requisition,Purchase Requisition,Store Return,Cash Voucher,HR Cash Voucher,Imprest Cash Voucher,IT Cash Voucher,Engineering Cash Voucher,Cheque Payment Voucher,Procurement Payment Voucher';
            OptionMembers = "Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher","Procurement Payment Voucher";
        }
    }

    keys
    {
        key(Key1; "Document No.", "Document Type", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        TestStatusOpen;
        PaymentVoucherLine.SETRANGE("Document Type", "Document Type");
        PaymentVoucherLine.SETRANGE("Document No.", "Document No.");
        IF PaymentVoucherLine.COUNT > 0 THEN
            ERROR('You can not delete the Payment Voucher Details because it already has related Payment Voucher Lines');
    end;

    trigger OnModify();
    begin
        TestStatusOpen;
    end;

    var
        PaymentVoucherHeader: Record "Payment Voucher Header";
        PaymentVoucherLine: Record "Payment Voucher Line";
        TotalDetailsAmount: Decimal;

    /// <summary>
    /// Description for GetPaymentVoucherHeader.
    /// </summary>
    local procedure GetPaymentVoucherHeader();
    begin
        TESTFIELD("Document No.");
        TESTFIELD("Document Type");
        //IF "Document No." <> PaymentVoucherHeader."No." THEN
        PaymentVoucherHeader.GET("Document No.", "Document Type");
    end;

    /// <summary>
    /// Description for TestStatusOpen.
    /// </summary>
    local procedure TestStatusOpen();
    begin
        GetPaymentVoucherHeader;
        PaymentVoucherHeader.TESTFIELD(Status, PaymentVoucherHeader.Status::Open);
    end;
}

