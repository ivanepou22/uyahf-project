/// <summary>
/// TableExtension Bank Acc. Reconciliation Ext (ID 50060) extends Record Bank Acc. Reconciliation.
/// </summary>
tableextension 50005 "Bank Acc. Reconciliation Ext" extends "Bank Acc. Reconciliation"
{
    fields
    {
        field(50500; Status1; Option)
        {
            Editable = false;
            OptionCaption = 'Open,Released,Pending Approval,Pending Prepayment';
            OptionMembers = Open,Released,"Pending Approval","Pending Prepayment";
        }
        field(50501; "Document No.1"; Code[20])
        {
        }
        field(50502; "Approved By1"; Text[30])
        {
            Editable = false;
        }
        field(50503; "Prepared By1"; Text[30])
        {
            Editable = false;
        }
    }

    var
        myInt: Integer;
}