/// <summary>
/// Table Delegate Escalate Management (ID 50220).
/// </summary>
table 50017 "Delegate Escalate Management"
{
    Caption = 'Delegate Escalate Management';

    fields
    {
        field(1; "Document Type"; Option)
        {
            OptionCaption = 'Store Requisition,Purchase Requisition,Store Return,Cash Voucher,HR Cash Voucher,Imprest Cash Voucher,IT Cash Voucher,Engineering Cash Voucher,Cheque Payment Voucher,Procurement Payment Voucher';
            OptionMembers = "Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher","Procurement Payment Voucher";
        }
        field(2; "User ID"; code[50])
        {
            TableRelation = "User Setup"."User ID";
            Caption = 'User ID';
        }
        field(3; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(4; "Delegate ID"; code[50])
        {
            TableRelation = "User Setup"."User ID";
            Caption = 'Delegate ID';
        }
        field(5; "Escalate ID"; code[50])
        {
            TableRelation = "User Setup"."User ID";
            Caption = 'Escalate ID';
        }
        field(6; "Created By"; Code[50])
        {
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(7; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            Editable = false;
        }
        field(8; "Last Modified By"; code[100])
        {
            Caption = 'Last Modified By';
            Editable = false;
        }
        field(9; "Last Modified Date"; Date)
        {
            Caption = 'Last Modified Date';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Document Type", "User ID", "Shortcut Dimension 1 Code")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin
        "Created By" := UserId;
        "Creation Date" := Today();
    end;

    trigger OnModify()
    begin
        "Last Modified By" := UserId;
        "Last Modified Date" := Today();
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}