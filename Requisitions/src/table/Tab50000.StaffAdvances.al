/// <summary>
/// Table Staff Advances (ID 50039).
/// </summary>
table 50000 "Staff Advances"
{

    fields
    {
        field(1; "Code"; Code[20])
        {
        }
        field(2; Name; Text[50])
        {
        }
        field(3; Blocked; Boolean)
        {
        }
        field(4; "Bank Code"; Code[10])
        {
        }
        field(5; "Bank Name"; Text[30])
        {
        }
        field(6; "Branch Code"; Code[10])
        {

        }
        field(7; "Bank Account No."; Text[30])
        {
        }
        field(8; "payment Type"; Option)
        {
            OptionMembers = PAY;
        }
        field(9; "Bank No."; Code[10])
        {
            // TableRelation = "Employee Bank Account"."No.";
            // trigger OnValidate();
            // begin
            //     recBank.RESET;
            //     recBank.SETRANGE(recBank."No.", "Bank No.");
            //     IF recBank.FINDFIRST THEN BEGIN
            //         VALIDATE("Bank Name", recBank.Name);
            //         Validate("Bank Code", recBank."KBA Code");
            //         Validate("Branch Code", recBank."Bank Branch Code");
            //         MODIFY;
            //     END else begin
            //         VALIDATE("Bank Name", '');
            //         Validate("Bank Code", '');
            //         Validate("Branch Code", '');
            //         MODIFY;
            //     end;
            // end;
        }
        field(10; TIN; Code[10])
        {
        }
        field(12; "Staff Control Account"; Code[20])
        {
        }
        field(13; Department; text[130])
        {
        }
        field(14; section; Text[50])
        {
        }
        field(15; "Work ID No."; text[20])
        {
        }
        field(16; Position; Text[100])
        {
            Caption = 'Position';
        }
        field(17; "Date of Birth"; Date)
        {
            Caption = 'DOB';
        }
        field(18; Nationality; Text[50])
        {
            Caption = 'Nationality';
        }
        field(19; "Passport Number"; Text[50])
        {
            Caption = 'Passport Number';
        }
        field(20; "Phone Number"; Text[50])
        {
            Caption = 'Phone Number';
            ExtendedDatatype = PhoneNo;
        }
        field(21; "Physical Address"; Text[200])
        {
            Caption = 'Physical Address';
        }
        field(22; "Postal Address"; text[200])
        {
            Caption = 'Postal Address';
        }
        field(23; "Home District"; Text[100])
        {
            Caption = 'Home District';
        }
        field(24; "Marital Status"; Option)
        {
            OptionMembers = " ",Single,Married,Divorced;
        }
        field(25; Village; Text[100])
        {
            Caption = 'Village';
        }
        field(26; Email; Text[50])
        {
            ExtendedDatatype = EMail;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
    // recBank: Record "Employee Bank Account";
}

