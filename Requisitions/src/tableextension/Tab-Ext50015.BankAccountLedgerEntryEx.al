/// <summary>
/// TableExtension Bank Account Ledger Entry Ex (ID 50108) extends Record Bank Account Ledger Entry.
/// </summary>
/// <summary>
/// TableExtension Bank Account Ledger Entry Ex (ID 50108) extends Record Bank Account Ledger Entry.
/// </summary>
tableextension 50015 "Bank Account Ledger Entry Ex" extends "Bank Account Ledger Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50001; "Advance Code"; Code[20])
        {
            Description = 'Staff Members'' Codes for tracking advances and loans';
            TableRelation = "Staff Advances";
        }
        field(50003; "Payment Type"; Option)
        {
            OptionMembers = " ",Cash,Cheque,Voucher;
        }
        field(50005; "Credit Memo Type"; Option)
        {
            OptionMembers = " ",Transport,"Bank/TT","Security Deposit",Swap,Commission;
        }
        field(50006; "Entry Date"; Date)
        {
        }
        field(50007; "Bank Batch No."; Code[30])
        {
        }
        field(50008; "Mapped to"; Boolean)
        {
        }
        field(50009; "No of entries applied"; Integer)
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