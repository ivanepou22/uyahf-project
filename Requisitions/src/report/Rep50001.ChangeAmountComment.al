/// <summary>
/// Report Change Amount Comment (ID 50050).
/// </summary>
report 50001 "Change Amount Comment"
{
    // version MAG

    Caption = 'Change Amount Comment';
    Description = 'Change Amount Comment';
    PreviewMode = PrintLayout;
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Comment)
                {
                    field("Change Amount Comment"; ChangeAmountComment)
                    {
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport();
    begin
        CLEAR(ChangeAmountComment);
    end;

    trigger OnPostReport();
    begin
        IF DocumentType = DocumentType::"Purchase Requisition" THEN
            NFLRequisitionCommentLine.SETRANGE("Document Type", DocumentType::"Purchase Requisition");

        IF DocumentType = DocumentType::"Store Requisition" THEN
            NFLRequisitionCommentLine.SETRANGE("Document Type", DocumentType::"Store Requisition");

        NFLRequisitionCommentLine.SETRANGE("Document Type", DocumentType);
        NFLRequisitionCommentLine.SETRANGE("No.", DocumentNo);
        NFLRequisitionCommentLine.SETRANGE("Document Line No.", LineNumber);
        IF NFLRequisitionCommentLine.FINDLAST THEN
            LNo := NFLRequisitionCommentLine."Line No." + 10000
        ELSE
            LNo := 10000;

        NFLRequisitionCommentLine."Document Type" := DocumentType;
        NFLRequisitionCommentLine."No." := DocumentNo;
        NFLRequisitionCommentLine."Line No." := LNo;
        NFLRequisitionCommentLine."Document Line No." := LineNumber;
        NFLRequisitionCommentLine.Date := WORKDATE;
        NFLRequisitionCommentLine.Username := USERID;
        NFLRequisitionCommentLine."System Created" := TRUE;
        NFLRequisitionCommentLine.Comment := ChangeAmountComment;
        NFLRequisitionCommentLine."Old Value" := OldValue;
        NFLRequisitionCommentLine."New Value" := NewValue;
        NFLRequisitionCommentLine.INSERT;
    end;

    trigger OnPreReport();
    begin
        IF ChangeAmountComment = '' THEN
            ERROR('Please specify a comment');
    end;

    var
        NFLRequisitionHeader: Record "NFL Requisition Header";
        NFLRequisitionCommentLine: Record "NFL Requisition Comment Line";
        NFLRequisitionLine: Record "NFL Requisition Line";
        CommitmentEntry: Record "Commitment Entry";
        gvCommitmentEntry: Record "Commitment Entry";
        lastCommitmentEntry: Record "Commitment Entry";
        reversedCommitmentEntry: Record "Commitment Entry";
        GLAccount: Record "G/L Account";
        Item: Record Item;
        FixedAsset: Record "Fixed Asset";
        GeneralPostingSetup: Record "General Posting Setup";
        FADepreciationBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        ChangeAmountComment: Text[50];
        DocumentNo: Code[20];
        DocumentType: Option "Store Requisition","Purchase Requisition","Store Return";
        LineNumber: Integer;
        LNo: Integer;
        OldValue: Decimal;
        NewValue: Decimal;
        CurrencyFactor: Decimal;

    /// <summary>
    /// Description for SetCompositeKey.
    /// </summary>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="DocType">Parameter of type Option "Store Requisition","Purchase Requisition","Store Return".</param>
    /// <param name="LineNo">Parameter of type Integer.</param>
    /// <param name="OldAmount">Parameter of type Decimal.</param>
    /// <param name="NewAmount">Parameter of type Decimal.</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure SetCompositeKey(var DocNo: Code[20]; var DocType: Option "Store Requisition","Purchase Requisition","Store Return"; var LineNo: Integer; var OldAmount: Decimal; var NewAmount: Decimal): Boolean;
    begin
        DocumentNo := DocNo;
        DocumentType := DocType;
        LineNumber := LineNo;
        OldValue := OldAmount;
        NewValue := NewAmount;
        EXIT(TRUE);
    end;

    /// <summary>
    /// Description for ReverseCommitment.
    /// </summary>
    /// <param name="CommitmentEntryNo">Parameter of type Integer.</param>
    procedure ReverseCommitment(var CommitmentEntryNo: Integer);
    begin
        //MAG 13TH SEPT 2018, Reverse commitment on posting the invoice.
        gvCommitmentEntry.SETRANGE("Entry No.", CommitmentEntryNo);
        IF gvCommitmentEntry.FIND('-') THEN BEGIN
            IF NOT lastCommitmentEntry.FINDLAST THEN
                lastCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No." + 1
            ELSE
                lastCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No." + 1;

            reversedCommitmentEntry.INIT;
            reversedCommitmentEntry := lastCommitmentEntry;
            reversedCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No.";
            reversedCommitmentEntry."Document Type" := gvCommitmentEntry."Document Type"::"Engineering Cash Voucher";
            reversedCommitmentEntry."G/L Account No." := gvCommitmentEntry."G/L Account No.";
            reversedCommitmentEntry."Posting Date" := gvCommitmentEntry."Posting Date";
            reversedCommitmentEntry."Document No." := gvCommitmentEntry."Document No.";
            reversedCommitmentEntry.Description := gvCommitmentEntry.Description;
            reversedCommitmentEntry."External Document No." := gvCommitmentEntry."External Document No.";
            reversedCommitmentEntry."Global Dimension 1 Code" := gvCommitmentEntry."Global Dimension 1 Code";
            reversedCommitmentEntry."Global Dimension 2 Code" := gvCommitmentEntry."Global Dimension 2 Code";
            reversedCommitmentEntry."Dimension Set ID" := gvCommitmentEntry."Dimension Set ID";
            reversedCommitmentEntry.Quantity := -1 * gvCommitmentEntry.Quantity;
            //reversedCommitmentEntry."Unit Cost" := -1 * gvCommitmentEntry."Unit Cost";
            //reversedCommitmentEntry."Unit Cost (LCY)" := -1 * gvCommitmentEntry."Unit Cost (LCY)";
            reversedCommitmentEntry.Amount := -1 * gvCommitmentEntry.Amount;
            reversedCommitmentEntry."Debit Amount" := -1 * gvCommitmentEntry."Debit Amount";
            reversedCommitmentEntry."Credit Amount" := -1 * gvCommitmentEntry."Credit Amount";
            reversedCommitmentEntry."Additional-Currency Amount" := -1 * gvCommitmentEntry."Additional-Currency Amount";
            reversedCommitmentEntry."Add.-Currency Debit Amount" := -1 * gvCommitmentEntry."Add.-Currency Debit Amount";
            reversedCommitmentEntry."Add.-Currency Credit Amount" := -1 * gvCommitmentEntry."Add.-Currency Credit Amount";
            reversedCommitmentEntry.Reversed := TRUE;
            reversedCommitmentEntry."Reversed Entry No." := gvCommitmentEntry."Entry No.";
            reversedCommitmentEntry."User ID" := USERID;
            reversedCommitmentEntry."Source Code" := 'REQ-REQ';
            reversedCommitmentEntry.INSERT;
            gvCommitmentEntry.Reversed := TRUE;
            gvCommitmentEntry."Reversed by Entry No." := reversedCommitmentEntry."Entry No.";
            gvCommitmentEntry.MODIFY;
        END;
        //MAG-END
    end;

    /// <summary>
    /// Description for CreateCommitment.
    /// </summary>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="DocType">Parameter of type Option "Store Requisition","Purchase Requisition","Store Return".</param>
    /// <param name="LineNo">Parameter of type Integer.</param>
    /// <param name="Amount">Parameter of type Decimal.</param>
    /// <param name="Quantity">Parameter of type Decimal.</param>
    /// <returns>Return variable "Integer".</returns>
    procedure CreateCommitment(var DocNo: Code[20]; var DocType: Option "Store Requisition","Purchase Requisition","Store Return"; var LineNo: Integer; var Amount: Decimal; Quantity: Decimal): Integer;
    begin
        //MAG 13TH SEPT. 2018, Create Commitment entry when Purchase requisition status has been released
        NFLRequisitionHeader.GET(DocType, DocNo);
        NFLRequisitionLine.SETRANGE("Document Type", DocumentType);
        NFLRequisitionLine.SETRANGE("Document No.", DocNo);
        NFLRequisitionLine.SETRANGE("Line No.", LineNo);
        //NFLRequisitionLine.SETFILTER("Commitment Entry No.", '%1', 0);
        IF NFLRequisitionLine.FINDFIRST THEN BEGIN
            IF NOT CommitmentEntry.FINDLAST THEN
                CommitmentEntry."Entry No." := CommitmentEntry."Entry No." + 1
            ELSE
                CommitmentEntry."Entry No." := CommitmentEntry."Entry No." + 1;

            CommitmentEntry.INIT;
            IF NFLRequisitionLine.Type = NFLRequisitionLine.Type::"G/L Account" THEN BEGIN
                GLAccount.SETRANGE("No.", NFLRequisitionLine."No.");
                GLAccount.SETRANGE("Prepayment Account", TRUE);
                IF GLAccount.FIND('-') THEN BEGIN
                    CommitmentEntry."G/L Account No." := NFLRequisitionLine."Control Account"; // Commit on the Actual Expense that was budgeted for.
                    CommitmentEntry."Prepayment Commitment" := TRUE;
                END ELSE
                    CommitmentEntry."G/L Account No." := NFLRequisitionLine."No.";
            END ELSE
                IF NFLRequisitionLine.Type = NFLRequisitionLine.Type::Item THEN BEGIN
                    Item.SETRANGE("No.", NFLRequisitionLine."No.");
                    IF Item.FINDFIRST THEN
                        GeneralPostingSetup.SETRANGE("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
                    IF GeneralPostingSetup.FINDFIRST THEN
                        CommitmentEntry."G/L Account No." := GeneralPostingSetup."Purch. Account"
                END ELSE
                    IF NFLRequisitionLine.Type = NFLRequisitionLine.Type::"Fixed Asset" THEN BEGIN
                        FADepreciationBook.SETRANGE("FA No.", NFLRequisitionLine."No.");
                        IF FADepreciationBook.FINDFIRST THEN
                            FAPostingGroup.SETRANGE(Code, FADepreciationBook."FA Posting Group");
                        IF FAPostingGroup.FINDFIRST THEN
                            CommitmentEntry."G/L Account No." := FAPostingGroup."Acquisition Cost Account";
                    END;

            CommitmentEntry.Description := NFLRequisitionLine.Description;
            CommitmentEntry.VALIDATE("Document Type", CommitmentEntry."Document Type"::"Engineering Cash Voucher");
            CommitmentEntry."Document No." := NFLRequisitionLine."Document No.";
            CommitmentEntry."Posting Date" := NFLRequisitionHeader."Posting Date";
            CommitmentEntry."Dimension Set ID" := NFLRequisitionLine."Dimension Set ID";
            CommitmentEntry."Global Dimension 1 Code" := NFLRequisitionLine."Shortcut Dimension 1 Code";
            CommitmentEntry."Global Dimension 2 Code" := NFLRequisitionLine."Shortcut Dimension 2 Code";
            CommitmentEntry.Amount := Quantity * Amount;
            CommitmentEntry."Source Code" := 'PUR-REQ';
            CommitmentEntry."User ID" := USERID;

            IF CommitmentEntry.Amount > 0 THEN
                CommitmentEntry."Debit Amount" := CommitmentEntry.Amount
            ELSE
                CommitmentEntry."Credit Amount" := CommitmentEntry.Amount;

            GeneralLedgerSetup.GET;
            CurrencyFactor := CurrencyExchangeRate.ExchangeRate(NFLRequisitionHeader."Posting Date", GeneralLedgerSetup."Additional Reporting Currency");
            CommitmentEntry."Additional-Currency Amount" := ROUND(CommitmentEntry.Amount * CurrencyFactor, Currency."Amount Rounding Precision");
            IF CommitmentEntry."Additional-Currency Amount" > 0 THEN
                CommitmentEntry."Add.-Currency Debit Amount" := CommitmentEntry."Additional-Currency Amount"
            ELSE
                CommitmentEntry."Add.-Currency Credit Amount" := CommitmentEntry."Additional-Currency Amount";
            CommitmentEntry.INSERT;
            EXIT(CommitmentEntry."Entry No."); // This will be used to update the NFL purchase line, It will be transfered to the Order lines and used to reverse out the commitment on posting the invoice.
        END;

        //MAG - END
    end;
}

