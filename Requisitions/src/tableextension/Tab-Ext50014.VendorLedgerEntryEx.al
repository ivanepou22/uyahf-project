/// <summary>
/// TableExtension Vendor Ledger Entry Ex (ID 50107) extends Record Vendor Ledger Entry.
/// </summary>
tableextension 50014 "Vendor Ledger Entry Ex" extends "Vendor Ledger Entry"
{
    fields
    {
        field(50003; "Payment Type"; Option)
        {
            OptionMembers = " ",Cash,Cheque,Voucher;
        }
        field(50004; "Entry Date"; Date)
        {
        }
        field(50005; "Bank Batch No."; Code[30])
        {
        }
        field(50042; "Payment Voucher"; Boolean)
        {
            Description = 'Indentifies whether an entry originates from a payment voucher document';
            Editable = false;
        }
        field(50043; "Payment Voucher No."; Code[20])
        {
            Description = 'Indentifies the payment voucher no.';
            Editable = false;
        }
        field(50046; "Document Ref. No."; Code[20])
        {
            Description = 'Identifies individual transaction';
            Editable = false;
        }
        field(50047; "Cashier ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}