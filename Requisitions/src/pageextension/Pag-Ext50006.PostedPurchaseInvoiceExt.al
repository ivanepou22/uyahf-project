/// <summary>
/// PageExtension Posted Purchase InvoiceExt (ID 50106) extends Record Posted Purchase Invoice.
/// </summary>
pageextension 50006 "Posted Purchase InvoiceExt" extends "Posted Purchase Invoice"
{
    layout
    {
        // Add changes to page layout here
        addafter("Vendor Invoice No.")
        {
            field("Purchase Requisition No."; Rec."Purchase Requisition No.")
            {
                ApplicationArea = All;
                Editable = false;
            }

        }
    }

    actions
    {
        // Add changes to page actions here
    }
}