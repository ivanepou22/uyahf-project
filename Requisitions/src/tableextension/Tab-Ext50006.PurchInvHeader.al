/// <summary>
/// TableExtension Purchase Header Ext (ID 50050) extends Record Purchase Header.
/// </summary>
tableextension 50006 "Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {

        field(50003; Particulars; Text[80]) { }
        field(50004; "Valid To Date"; Date) { }
        field(50006; "Created Quotes"; Integer) { }
        field(50007; "Store Requisition No."; Code[20])
        {
        }
        field(50008; "External Doc No."; Code[20])
        {
        }
        field(50009; OutstandingQtyExist; Boolean)
        {
        }
        field(50010; "Invoiced Amount"; Decimal)
        {
        }
        field(50011; "Requester ID"; Code[10])
        {
        }
        field(50012; "Requisition No."; Code[10])
        {
        }
        field(50020; "Delivery Note No"; Code[25])
        {
        }
        field(50021; "Purchase Requisition No."; Code[20])
        {
        }
        field(50100; "Doc. Created By:"; Code[50])
        {
        }
        field(50101; "Doc. Creation Date:"; Date)
        {
        }
        field(50310; "Commitment Budget"; Code[10])
        {
        }
        field(50311; "Installment No."; Integer)
        {
        }
        field(50312; "Non-Contract Transaction"; Boolean)
        {
        }
        field(50313; "Training Schedule No."; Code[10])
        {
        }
        field(50314; "Training Plan No."; Code[10])
        {
        }
        field(50315; "Training LPO No. Series"; Code[10])
        {
        }
        field(50316; "Training Schedule No.1"; Code[10])
        {
        }
        field(50317; "Training Plan No.1"; Code[10])
        {
        }
        field(50318; "Training LPO No. Series1"; Code[10])
        {
        }
        field(50319; "Payment Terms2 Text"; Text[100])
        {
        }
        field(50320; "Procurement Reference No."; Code[30])
        {
        }
        field(50321; "Delivery Notifications"; Text[70])
        {
        }
    }

    var
        myInt: Integer;
}