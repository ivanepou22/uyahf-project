/// <summary>
/// TableExtension Approval Entry Exts extends Record Approval Entry.
/// </summary>
tableextension 50015 "Approval Entry Exts" extends "Approval Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Escalated By"; Code[40])
        {
            Caption = 'Escalated By';
            TableRelation = "User Setup"."User ID";
            Editable = false;
        }
        field(50111; "Document Type1"; Option)
        {
            Caption = 'Document Type';
            Editable = false;
            OptionCaption = 'Store Requisition,Purchase Requisition,Store Return,Cash Voucher,HR Cash Voucher,Imprest Cash Voucher,IT Cash Voucher,Engineering Cash Voucher,Cheque Payment Voucher,Procurement Payment Voucher';
            OptionMembers = "Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher","Procurement Payment Voucher";
        }
    }

    var
        myInt: Integer;
}