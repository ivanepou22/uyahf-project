/// <summary>
/// TableExtension G/L Entry Ext (ID 50072) extends Record G/L Entry.
/// </summary>
tableextension 50010 "G/L Entry Payt Req Ext" extends "G/L Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50002; "Staff Code"; Code[20])
        {
        }
        field(50003; "Payment Type"; Option)
        {
            OptionMembers = " ",Cash,Cheque,Voucher;
        }
        field(50004; "Revenue Stream"; Code[20])
        {
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = FILTER(3));
        }
        field(50005; "Credit Memo Type"; Option)
        {
            OptionMembers = Transport,"Bank/TT","Security Deposit",Swap,Commission,Fax,Promotion;
        }
        field(50007; "Transaction Type"; Option)
        {
            OptionMembers = " ","Agent Commission";
        }
        field(50009; Region; Code[20])
        {

        }
        field(50014; "SalesPerson Code"; Code[100])
        {
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(50015; "Entry Date"; Date)
        {
        }
        field(50016; "Bank Batch No."; Code[30])
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
        field(50044; "Appl.-to Commitment Entry"; Integer)
        {
            Description = 'Indentifies a commitment to be reversed when an expense is registered from a commitment';
            Editable = false;
        }
        field(50045; "Reference No."; Code[20])
        {
        }
        field(50046; "Document Ref. No."; Code[20])
        {
            Description = 'Identifies individual transaction';
            Editable = false;
        }
        field(50048; "Banking Date"; Date)
        {
        }
        field(50049; "Banking Ref. No."; Code[20])
        {
            Editable = false;
        }
        field(50072; "Deferral Code"; Code[10])
        {
            Caption = 'Deferral Code';
            TableRelation = "Deferral Template"."Deferral Code";
        }
        field(50073; "Advance Code"; Code[20])
        {
            Description = 'Staff Members'' Codes for tracking advances and loans';
            TableRelation = "Staff Advances";
        }
        field(50074; Transferred; Boolean)
        {
            Caption = 'Transferred';
        }
        field(50075; "Comm. Category"; Code[10])
        {
        }
        field(50076; "Comm. Class"; Code[10])
        {
        }
    }

    var
        myInt: Integer;
}