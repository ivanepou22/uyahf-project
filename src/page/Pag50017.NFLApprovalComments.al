/// <summary>
/// Page NFL Approval Comments (ID 50209).
/// </summary>
page 50017 "NFL Approval Comments"
{
    // version NFL02.000

    Caption = 'NFL Approval Comments';
    DataCaptionFields = "Document Type", "Document No.";
    DelayedInsert = true;
    DeleteAllowed = true;
    LinksAllowed = false;
    ModifyAllowed = true;
    MultipleNewLines = true;
    PageType = Card;
    SourceTable = "NFL Approval Comment Line";

    layout
    {
        area(content)
        {
            field(DocNo; DocNo)
            {
                CaptionClass = FORMAT(DocType);
                Editable = false;
                Visible = false;
            }
            repeater(Group)
            {
                field(Comment; Comment)
                {
                    Editable = UserApprover;
                }
                field("User ID"; "User ID")
                {
                }
                field("Date and Time"; "Date and Time")
                {
                }
                field("Entry No."; "Entry No.")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
    trigger OnOpenPage()
    var
        approvalEntry: Record "Approval Entry";
    begin
        UserApprover := false;
        approvalEntry.Reset();
        approvalEntry.SetRange(approvalEntry."Approver ID", UserId);
        approvalEntry.SetRange(approvalEntry.Status, approvalEntry.Status::Open);
        if approvalEntry.FindFirst() then
            UserApprover := true;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean;
    begin
        // "Table ID" := NewTableId;
        // "Document Type" := NewDocumentType;
        // "Document No." := NewDocumentNo;
        "Comment Entry No." := NewSequenceNumber;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    begin
        /*IF CloseAction = ACTION::OK THEN BEGIN
          IF CONFIRM(Text00,TRUE) THEN BEGIN
            RejectValue := TRUE;
          END ELSE BEGIN
            RejectValue := FALSE;
            EXIT;
          END;
        END;
        */

    end;

    var
        NewTableId: Integer;
        NewDocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        NewDocumentNo: Code[20];
        DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        DocNo: Code[20];
        RejectValue: Boolean;
        Text00: Label 'Are you really sure you want to reject this document?';
        NewSequenceNumber: Integer;
        LineNo2: Integer;
        UserApprover: Boolean;

    /// <summary>
    /// Description for SetUpLine.
    /// </summary>
    /// <param name="TableId">Parameter of type Integer.</param>
    /// <param name="DocumentType">Parameter of type Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order".</param>
    /// <param name="DocumentNo">Parameter of type Code[20].</param>
    /// <param name="EntryNo">Parameter of type Integer.</param>
    procedure SetUpLine(TableId: Integer; DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"; DocumentNo: Code[20]; EntryNo: Integer);
    begin
        NewTableId := TableId;
        NewDocumentType := DocumentType;
        NewDocumentNo := DocumentNo;
        NewSequenceNumber := EntryNo;
    end;

    /// <summary>
    /// Description for Setfilters.
    /// </summary>
    /// <param name="TableId">Parameter of type Integer.</param>
    /// <param name="DocumentType">Parameter of type Option "Store Requisition","Purchase Requisition",Payment,"Bank Reconciliation".</param>
    /// <param name="DocumentNo">Parameter of type Code[20].</param>
    /// <param name="EntryNo">Parameter of type Integer.</param>
    procedure Setfilters(TableId: Integer; DocumentType: Option "Store Requisition","Purchase Requisition",Payment,"Bank Reconciliation"; DocumentNo: Code[20]; EntryNo: Integer);
    begin
        IF TableId <> 0 THEN BEGIN
            FILTERGROUP(2);
            SETCURRENTKEY("Table ID", "Document Type", "Document No.");
            SETRANGE("Table ID", TableId);
            SETRANGE("Document Type", DocumentType);
            IF DocumentNo <> '' THEN
                SETRANGE("Document No.", DocumentNo);
            FILTERGROUP(0);
        END;

        DocType := DocumentType;
        DocNo := DocumentNo;
        NewSequenceNumber := EntryNo;
    end;

    /// <summary>
    /// Reject.
    /// </summary>
    /// <returns>Return value of type Boolean.</returns>
    procedure Reject(): Boolean;
    begin
        EXIT(RejectValue);
    end;

    /// <summary>
    /// Setfilters3.
    /// </summary>
    /// <param name="TableId">Integer.</param>
    /// <param name="DocumentType">Option "Store Requisition","Purchase Requisition",Payment,"Bank Reconciliation".</param>
    /// <param name="DocumentNo">Code[20].</param>
    /// <param name="LineNo">Integer.</param>
    procedure Setfilters3(TableId: Integer; DocumentType: Option "Store Requisition","Purchase Requisition",Payment,"Bank Reconciliation"; DocumentNo: Code[20]; LineNo: Integer);
    begin
        //To help View comments after rejection
        IF TableId <> 0 THEN BEGIN
            FILTERGROUP(2);
            SETCURRENTKEY("Table ID", "Document Type", "Document No.", "Entry No.");
            SETRANGE("Table ID", TableId);
            SETRANGE("Document Type", DocumentType);
            IF DocumentNo <> '' THEN
                SETRANGE("Document No.", DocumentNo);
            IF LineNo > 0 THEN
                SETRANGE("Entry No.", LineNo);

            FILTERGROUP(0);
        END;
        DocType := DocumentType;
        DocNo := DocumentNo;
        LineNo2 := LineNo;
        //END
    end;
}

