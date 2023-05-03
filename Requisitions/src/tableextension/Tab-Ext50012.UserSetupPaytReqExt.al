/// <summary>
/// TableExtension User Setup Ext (ID 50052) extends Record User Setup.
/// </summary>

tableextension 50012 "User Setup Payt Req Ext" extends "User Setup"
{
    fields
    {
        // Add changes to table fields here


        field(50003; "SBU Head"; Boolean)
        {
        }
        field(50004; "Archive Document"; Boolean)
        {
        }
        field(50005; "EDIT PVL"; Boolean)
        {
        }
        field(50006; "Voucher Admin"; Boolean)
        {
        }
        field(50007; "Delegate Approval Requests1"; Boolean)
        {
            Description = 'Rights to delegate Medical Claims Requests and Leave requests Approvals.';
        }
        field(50008; "E-mail Address1"; Text[100])
        {
        }
        field(50032; "Change Amount on Approved Req."; Boolean)
        {
        }
        field(50033; Signature; BLOB)
        {
            SubType = Bitmap;
        }
        field(50036; "Export Payment File"; Boolean)
        {
            Description = 'Specifies whether a user has permissions to export payments to a file';
        }
        field(50037; "Edit Advance Status"; Boolean)
        {

        }
        field(50038; "Escalate to"; Code[50])
        {
            Caption = 'Escalate to';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(50039; "Budget Controller"; Boolean)
        {
            Description = 'Specifices users who can enter purchase requisition/payment requisition lines so as to perform budget checks';
        }
    }

    var
        myInt: Integer;
}