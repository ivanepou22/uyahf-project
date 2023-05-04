/// <summary>
/// TableExtension Approval Entry Ext (ID 50141) extends Record Approval Entry.
/// </summary>
tableextension 50041 "Approval Entry Ext" extends "Approval Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50010; "Escalated On"; Date)
        {
            Caption = 'Date Escalated';
            Editable = false;
        }
        field(50011; "Payee Name"; Text[150])
        {
            Editable = false;
        }
        field(50012; "Payee No."; Code[50])
        {
            Editable = false;
        }
        field(50013; Description; Text[245])
        {
            Editable = false;
        }
        field(50014; "Prepared By"; Code[50])
        {
            Editable = false;
        }
        field(50015; "Posting Date"; Date)
        {
            Editable = false;
        }
    }

    var
        myInt: Integer;
}