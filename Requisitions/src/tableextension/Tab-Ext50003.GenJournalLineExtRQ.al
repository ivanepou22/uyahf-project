/// <summary>
/// TableExtension Gen. Journal Line Ext (ID 50056) extends Record Gen. Journal Line.
/// </summary>
tableextension 50003 "Gen. Journal Line ExtRQ" extends "Gen. Journal Line"
{
    fields
    {
        field(50005; "Credit Memo Type"; Option)
        {
            OptionMembers = " ",Transport,"Bank/TT","Security Deposit",Swap,Commission,Fax,Promotion;
        }
        field(50009; "Transaction Type"; Option)
        {
            OptionMembers = " ","Agent Commission";
        }
        field(50021; "Bank File Generated"; Boolean) { }
        field(50022; "Bank File Generated On"; Date) { }
        field(50026; "Bank File Gen. by"; Code[20]) { }
        field(50031; "Cashier ID"; Code[50])
        {
            Description = 'To Capture Cashier Data entry Code';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate();
            var
                LUserSetupREC: Record "User Setup";
                UserMgt: Codeunit "User Management";
                GenJnlBatch: Record "Gen. Journal Batch";
                UserSelection: Codeunit "User Selection";
            begin
                //UserMgt.ValidateUserID("Cashier ID"); IE previous implementation
                UserSelection.ValidateUserName("Cashier ID"); //IE new implementation

                GenJnlBatch.RESET;
                GenJnlBatch.SETRANGE("Journal Template Name", "Journal Template Name");
                GenJnlBatch.SETRANGE(Name, "Journal Batch Name");
                IF GenJnlBatch.FIND('-') THEN BEGIN
                    IF GenJnlBatch."Cashier ID" <> '' THEN BEGIN
                        IF GenJnlBatch."Cashier ID" <> USERID THEN BEGIN
                            IF LUserSetupREC.GET(USERID) THEN
                                IF LUserSetupREC."Glue to Batch" = TRUE THEN
                                    ERROR('You must be logged in as %1', GenJnlBatch."Cashier ID")
                        END
                        ELSE
                            "Cashier ID" := GenJnlBatch."Cashier ID";
                        //END;
                    END
                    ELSE BEGIN
                        IF LUserSetupREC.GET(USERID) THEN
                            IF LUserSetupREC."Glue to Batch" = TRUE THEN
                                ERROR('You must use only your assigned Journal batch!\' +
                                      'Close the Journal and open again.');
                    END;
                END;
            end;
        }
        field(50032; "Payment Type"; Option)
        {
            OptionCaption = '" ,Cheque,EFT,Credit Card,Banking Slip,Cash,Other,Voucher"';
            OptionMembers = " ",Cheque,EFT,"Credit Card","Banking Slip",Cash,Other,Voucher;

            trigger OnValidate();
            begin
                IF "Document Type" = "Document Type"::"Credit Memo" THEN
                    TESTFIELD("Payment Type", "Payment Type"::Voucher);
            end;
        }
        field(50033; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Open,Approved,Pending Approval,Pending Prepayment';
            OptionMembers = Open,Approved,"Pending Approval","Pending Prepayment";
        }
        field(50034; "Payment Voucher"; Boolean)
        {
            Description = 'Indentifies whether an entry originates from a payment voucher document';
            Editable = true;
        }
        field(50035; "Payment Voucher No."; Code[20])
        {
            Description = 'Indentifies the payment voucher no.';
            Editable = false;
        }
        field(50036; "Appl.-to Commitment Entry"; Integer)
        {
            Description = 'Indentifies a commitment to be reversed when an expense is registered from a commitment';
            Editable = false;

            trigger OnLookup();
            var
                CommitmentEntry: Record "Commitment Entry";
            begin
                CommitmentEntry.SETRANGE(Reversed, FALSE);
                IF PAGE.RUNMODAL(PAGE::"Apply Commitment  Entry", CommitmentEntry) = ACTION::LookupOK THEN BEGIN
                    VALIDATE("Appl.-to Commitment Entry", CommitmentEntry."Entry No.");
                END;
            end;

            trigger OnValidate();
            var
                CommitmentEntry: Record "Commitment Entry";
                GLAccount: Record "G/L Account";
            begin
                IF NOT "Payment Voucher" THEN BEGIN
                    TESTFIELD("Account Type", "Account Type"::"G/L Account");
                    TESTFIELD("Account No.");
                    TESTFIELD("Bal. Account Type", "Bal. Account Type"::"G/L Account");
                    TESTFIELD("Bal. Account No.");
                    TESTFIELD(Amount);

                    IF "Appl.-to Commitment Entry" <> xRec."Appl.-to Commitment Entry" THEN BEGIN
                        IF "Appl.-to Commitment Entry" <> 0 THEN BEGIN
                            CommitmentEntry.GET("Appl.-to Commitment Entry");
                            IF Amount > 0 THEN BEGIN
                                IF CommitmentEntry."G/L Account No." <> "Account No." THEN
                                    ERROR('Account No. ' + "Account No." + ' in the Journal lines must be the same as the G/L Account No. ' + CommitmentEntry."G/L Account No." + ' in the Commitment Entry');
                                GLAccount.GET("Bal. Account No.");
                                IF GLAccount."Prepayment Account" = FALSE THEN
                                    ERROR("Bal. Account No." + ' must be a prepayment account');
                            END;

                            IF Amount < 0 THEN BEGIN
                                IF CommitmentEntry."G/L Account No." <> "Bal. Account No." THEN
                                    ERROR('Bal. Account No. ' + "Bal. Account No." + ' in the Journal lines must be the same as the G/L Account No. ' + CommitmentEntry."G/L Account No." + ' in the Commitment Entry');
                                GLAccount.GET("Account No.");
                                IF GLAccount."Prepayment Account" = FALSE THEN
                                    ERROR("Account No." + ' must be a prepayment account');
                            END;
                        END;
                    END;
                END;
            end;
        }
        field(50537; "Loan Type"; Code[150])
        {
            Caption = 'Loan Type';
            // TableRelation = "Loan Types";
        }
        field(50538; "Voucher Acc. Account"; Option)
        {
            OptionCaption = ' ,G/L Account,Vendor,Advance,Bank Account,Customer';
            OptionMembers = " ","G/L Account",Vendor,Advance,"Bank Account",Customer;
        }
        field(50539; "Advance Code"; Code[20])
        {
            TableRelation = "Staff Advances";
        }
    }


}