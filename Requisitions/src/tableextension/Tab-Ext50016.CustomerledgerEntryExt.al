tableextension 50016 "Customer ledger Entry Ext" extends "Cust. Ledger Entry"
{
    fields
    {
        field(50000; "Cashier ID"; Code[100])
        {
        }
        field(50001; "Advance Code"; Code[20])
        {
        }
        field(50003; "Payment Type"; Option)
        {
            OptionMembers = " ",Cash,Cheque,Voucher;
        }
        field(50004; "Revenue Stream"; Code[20])
        {
        }
        field(50005; "Credit Memo Type"; Option)
        {
            OptionMembers = " ",Transport,"Bank/TT","Security Deposit",Swap,Commission;
        }
        field(50006; "Inv Comm. Amount"; Decimal)
        {
        }
        field(50007; "Transaction Type"; Option)
        {
            OptionMembers = " ","Agent Commission";
        }
        field(50008; "Commission Posted"; Boolean)
        {
        }
        field(50009; "Cr.Memo Comm. Amount"; Decimal)
        {
        }
        field(50010; "Entry Date"; Date)
        {
        }
        field(50011; "Advertising Doc No."; Code[20])
        {
        }
        field(50012; "Inv Comm. %"; Decimal)
        {
        }
        field(50013; "Cr. Memo Comm %"; Decimal)
        {
        }
        field(50014; "Sales Type"; Option)
        {
            OptionMembers = " ",Direct,Indirect;
        }
        field(50015; "Transfered to Payroll"; Boolean)
        {
        }
        field(50016; "Commissioned Sales Invoices"; Text[200])
        {
        }
        field(50042; "Payment Voucher"; Boolean)
        {
        }
        field(50043; "Payment Voucher No."; Code[20])
        {
        }
        field(50045; "Reference No."; Code[20])
        {
        }
        field(50046; "Document Ref. No."; Code[20])
        {
        }
        field(50048; "Banking Date"; Date)
        {
        }
        field(50049; "Banking Ref. No."; Code[20])
        {
        }
    }
}