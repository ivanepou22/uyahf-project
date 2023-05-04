/// <summary>
/// Table Document Dimension (ID 50100).
/// </summary>
table 50008 "Document Dimension"
{
    // version NAVW16.00

    Caption = 'Document Dimension';

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(2; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Store Requisition,Purchase Requisition,Store Return,Cash Voucher,HR Cash Voucher,Imprest Cash Voucher,IT Cash Voucher,Engineering Cash Voucher,Cheque Payment Voucher';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Store Requisition","Purchase Requisition","Store Return","Cash Voucher","HR Cash Voucher","Imprest Cash Voucher","IT Cash Voucher","Engineering Cash Voucher","Cheque Payment Voucher";
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            NotBlank = true;
            TableRelation = Dimension;

            trigger OnValidate();
            begin
                IF NOT DimMgt.CheckDim("Dimension Code") THEN
                    ERROR(DimMgt.GetDimErr);
            end;
        }
        field(6; "Dimension Value Code"; Code[20])
        {
            Caption = 'Dimension Value Code';
            NotBlank = true;
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FIELD("Dimension Code"));

            trigger OnValidate();
            begin
                IF NOT DimMgt.CheckDimValue("Dimension Code", "Dimension Value Code") THEN
                    ERROR(DimMgt.GetDimErr);
            end;
        }
    }

    keys
    {
        key(Key1; "Table ID", "Document Type", "Document No.", "Line No.", "Dimension Code")
        {
        }
        key(Key2; "Dimension Code", "Dimension Value Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        GLSetup.GET;
        UpdateLineDim(Rec, TRUE);
        IF "Dimension Code" = GLSetup."Global Dimension 1 Code" THEN
            UpdateGlobalDimCode(
              1, "Table ID", "Document Type", "Document No.", "Line No.", '');
        IF "Dimension Code" = GLSetup."Global Dimension 2 Code" THEN
            UpdateGlobalDimCode(
              2, "Table ID", "Document Type", "Document No.", "Line No.", '');
    end;

    trigger OnInsert();
    begin
        TESTFIELD("Dimension Value Code");
        GLSetup.GET;
        UpdateLineDim(Rec, FALSE);
        IF "Dimension Code" = GLSetup."Global Dimension 1 Code" THEN
            UpdateGlobalDimCode(
              1, "Table ID", "Document Type", "Document No.", "Line No.", "Dimension Value Code");
        IF "Dimension Code" = GLSetup."Global Dimension 2 Code" THEN
            UpdateGlobalDimCode(
              2, "Table ID", "Document Type", "Document No.", "Line No.", "Dimension Value Code");
    end;

    trigger OnModify();
    begin
        GLSetup.GET;
        UpdateLineDim(Rec, FALSE);
        IF "Dimension Code" = GLSetup."Global Dimension 1 Code" THEN
            UpdateGlobalDimCode(
              1, "Table ID", "Document Type", "Document No.", "Line No.", "Dimension Value Code");
        IF "Dimension Code" = GLSetup."Global Dimension 2 Code" THEN
            UpdateGlobalDimCode(
              2, "Table ID", "Document Type", "Document No.", "Line No.", "Dimension Value Code");
    end;

    trigger OnRename();
    begin
        ERROR(Text000, TABLECAPTION);
    end;

    var
        Text000: Label 'You can not rename a %1.';
        Text001: Label 'You have changed a dimension.\\';
        Text002: Label 'Do you want to update the lines?';
        Text003: Label 'You may have changed a dimension.\\Do you want to update the lines?';
        GLSetup: Record "General Ledger Setup";
        DimMgt: Codeunit "DimensionManagement";
        UpdateLine: Option NotSet,Update,DoNotUpdate;

    /// <summary>
    /// Description for UpdateGlobalDimCode.
    /// </summary>
    /// <param name="GlobalDimCodeNo">Parameter of type Integer.</param>
    /// <param name="Table ID">Parameter of type Integer.</param>
    /// <param name="Document Type">Parameter of type Option.</param>
    /// <param name="Document No.">Parameter of type Code[20].</param>
    /// <param name="Line No.">Parameter of type Integer.</param>
    /// <param name="NewDimValue">Parameter of type Code[20].</param>
    procedure UpdateGlobalDimCode(GlobalDimCodeNo: Integer; "Table ID": Integer; "Document Type": Option; "Document No.": Code[20]; "Line No.": Integer; NewDimValue: Code[20]);
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        ReminderHeader: Record "Reminder Header";
        FinChrgMemoHeader: Record "Finance Charge Memo Header";
        TransHeader: Record "Transfer Header";
        TransLine: Record "Transfer Line";
        ServHeader: Record "Service Header";
        ServLine: Record "Service Line";
        ServItemLine: Record "Service Item Line";
        StdSalesLine: Record "Standard Sales Line";
        StdPurchLine: Record "Standard Purchase Line";
        StdServLine: Record "Standard Service Line";
    begin
        CASE "Table ID" OF
            DATABASE::"Sales Header":
                BEGIN
                    IF SalesHeader.GET("Document Type", "Document No.") THEN BEGIN
                        CASE GlobalDimCodeNo OF
                            1:
                                SalesHeader."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                SalesHeader."Shortcut Dimension 2 Code" := NewDimValue;
                        END;
                        SalesHeader.MODIFY(TRUE);
                    END;
                END;
            DATABASE::"Sales Line":
                BEGIN
                    IF SalesLine.GET("Document Type", "Document No.", "Line No.") THEN BEGIN
                        CASE GlobalDimCodeNo OF
                            1:
                                SalesLine."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                SalesLine."Shortcut Dimension 2 Code" := NewDimValue;
                        END;
                        SalesLine.MODIFY(TRUE);
                    END;
                END;
            DATABASE::"Purchase Header":
                BEGIN
                    IF PurchHeader.GET("Document Type", "Document No.") THEN BEGIN
                        CASE GlobalDimCodeNo OF
                            1:
                                PurchHeader."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                PurchHeader."Shortcut Dimension 2 Code" := NewDimValue;
                        END;
                        PurchHeader.MODIFY(TRUE);
                    END;
                END;
            DATABASE::"Purchase Line":
                BEGIN
                    IF PurchLine.GET("Document Type", "Document No.", "Line No.") THEN BEGIN
                        CASE GlobalDimCodeNo OF
                            1:
                                PurchLine."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                PurchLine."Shortcut Dimension 2 Code" := NewDimValue;
                        END;
                        PurchLine.MODIFY(TRUE);
                    END;
                END;
            DATABASE::"Reminder Header":
                BEGIN
                    IF ReminderHeader.GET("Document No.") THEN BEGIN
                        CASE GlobalDimCodeNo OF
                            1:
                                ReminderHeader."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                ReminderHeader."Shortcut Dimension 2 Code" := NewDimValue;
                        END;
                        ReminderHeader.MODIFY(TRUE);
                    END;
                END;
            DATABASE::"Finance Charge Memo Header":
                BEGIN
                    IF FinChrgMemoHeader.GET("Document No.") THEN BEGIN
                        CASE GlobalDimCodeNo OF
                            1:
                                FinChrgMemoHeader."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                FinChrgMemoHeader."Shortcut Dimension 2 Code" := NewDimValue;
                        END;
                        FinChrgMemoHeader.MODIFY(TRUE);
                    END;
                END;
            DATABASE::"Transfer Header":
                BEGIN
                    IF TransHeader.GET("Document No.") THEN BEGIN
                        CASE GlobalDimCodeNo OF
                            1:
                                TransHeader."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                TransHeader."Shortcut Dimension 2 Code" := NewDimValue;
                        END;
                        TransHeader.MODIFY(TRUE);
                    END;
                END;
            DATABASE::"Transfer Line":
                BEGIN
                    IF TransLine.GET("Document No.", "Line No.") THEN BEGIN
                        CASE GlobalDimCodeNo OF
                            1:
                                TransLine."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                TransLine."Shortcut Dimension 2 Code" := NewDimValue;
                        END;
                        TransLine.MODIFY(TRUE);
                    END;
                END;
            DATABASE::"Service Header":
                BEGIN
                    IF ServHeader.GET("Document Type", "Document No.") THEN BEGIN
                        CASE GlobalDimCodeNo OF
                            1:
                                ServHeader."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                ServHeader."Shortcut Dimension 2 Code" := NewDimValue;
                        END;
                        ServHeader.MODIFY(TRUE);
                    END;
                END;
            DATABASE::"Service Line":
                BEGIN
                    IF ServLine.GET("Document Type", "Document No.", "Line No.") THEN BEGIN
                        CASE GlobalDimCodeNo OF
                            1:
                                ServLine."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                ServLine."Shortcut Dimension 2 Code" := NewDimValue;
                        END;
                        ServLine.MODIFY(TRUE);
                    END;
                END;
            DATABASE::"Service Item Line":
                BEGIN
                    IF ServItemLine.GET("Document Type", "Document No.", "Line No.") THEN BEGIN
                        CASE GlobalDimCodeNo OF
                            1:
                                ServItemLine."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                ServItemLine."Shortcut Dimension 2 Code" := NewDimValue;
                        END;
                        ServItemLine.MODIFY(TRUE);
                    END;
                END;
            DATABASE::"Standard Sales Line":
                BEGIN
                    IF StdSalesLine.GET("Document No.", "Line No.") THEN BEGIN
                        CASE GlobalDimCodeNo OF
                            1:
                                StdSalesLine."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                StdSalesLine."Shortcut Dimension 2 Code" := NewDimValue;
                        END;
                        StdSalesLine.MODIFY(TRUE);
                    END;
                END;
            DATABASE::"Standard Purchase Line":
                BEGIN
                    IF StdPurchLine.GET("Document No.", "Line No.") THEN BEGIN
                        CASE GlobalDimCodeNo OF
                            1:
                                StdPurchLine."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                StdPurchLine."Shortcut Dimension 2 Code" := NewDimValue;
                        END;
                        StdPurchLine.MODIFY(TRUE);
                    END;
                END;
            DATABASE::"Standard Service Line":
                BEGIN
                    IF StdServLine.GET("Document No.", "Line No.") THEN BEGIN
                        CASE GlobalDimCodeNo OF
                            1:
                                StdServLine."Shortcut Dimension 1 Code" := NewDimValue;
                            2:
                                StdServLine."Shortcut Dimension 2 Code" := NewDimValue;
                        END;
                        StdServLine.MODIFY(TRUE);
                    END;
                END;
        END;
    end;

    /// <summary>
    /// Description for UpdateLineDim.
    /// </summary>
    /// <param name="DocDim">Parameter of type Record "Document Dimension".</param>
    /// <param name="FromOnDelete">Parameter of type Boolean.</param>
    procedure UpdateLineDim(var DocDim: Record "Document Dimension"; FromOnDelete: Boolean);
    var
        NewDocDim: Record "Document Dimension";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        ServItemLine: Record "Service Item Line";
        ServLine: Record "Service Line";
        Question: Text[250];
        UpdateDim: Boolean;
    begin
        WITH DocDim DO BEGIN
            IF ("Table ID" = DATABASE::"Sales Header") OR
               ("Table ID" = DATABASE::"Purchase Header") OR
               ("Table ID" = DATABASE::"Transfer Header") OR
               ("Table ID" = DATABASE::"Service Header") OR
               ("Table ID" = DATABASE::"Service Item Line")
            THEN BEGIN
                Question := STRSUBSTNO(Text001 + Text002);
                CASE "Table ID" OF
                    DATABASE::"Sales Header":
                        NewDocDim.SETRANGE("Table ID", DATABASE::"Sales Line");
                    DATABASE::"Purchase Header":
                        NewDocDim.SETRANGE("Table ID", DATABASE::"Purchase Line");
                    DATABASE::"Transfer Header":
                        NewDocDim.SETRANGE("Table ID", DATABASE::"Transfer Line");
                    DATABASE::"Service Header":
                        BEGIN
                            IF ("Document Type" = ServItemLine."Document Type"::Order) OR
                               ("Document Type" = ServItemLine."Document Type"::Quote)
                            THEN
                                NewDocDim.SETRANGE("Table ID", DATABASE::"Service Item Line")
                            ELSE
                                NewDocDim.SETRANGE("Table ID", DATABASE::"Service Line");
                        END;
                    DATABASE::"Service Item Line":
                        NewDocDim.SETRANGE("Table ID", DATABASE::"Service Line");
                END;
                NewDocDim.SETRANGE("Document Type", "Document Type");
                NewDocDim.SETRANGE("Document No.", "Document No.");
                NewDocDim.SETRANGE("Dimension Code", "Dimension Code");
                IF FromOnDelete THEN
                    IF NOT NewDocDim.FINDFIRST THEN
                        EXIT;
                CASE "Table ID" OF
                    DATABASE::"Sales Header":
                        BEGIN
                            SalesLine.SETRANGE("Document Type", "Document Type");
                            SalesLine.SETRANGE("Document No.", "Document No.");
                            SalesLine.SETFILTER("No.", '<>%1', '');
                            IF SalesLine.FINDSET THEN BEGIN
                                IF GUIALLOWED THEN BEGIN
                                    IF DIALOG.CONFIRM(Question, TRUE) THEN BEGIN
                                        NewDocDim.DELETEALL(TRUE);
                                        IF NOT FromOnDelete THEN
                                            REPEAT
                                                InsertNew(DocDim, DATABASE::"Sales Line", SalesLine."Line No.");
                                            UNTIL SalesLine.NEXT = 0;
                                    END
                                END ELSE BEGIN
                                    NewDocDim.DELETEALL(TRUE);
                                    IF NOT FromOnDelete THEN
                                        REPEAT
                                            InsertNew(DocDim, DATABASE::"Sales Line", SalesLine."Line No.");
                                        UNTIL SalesLine.NEXT = 0;
                                END;
                            END;
                        END;
                    DATABASE::"Purchase Header":
                        BEGIN
                            PurchaseLine.SETRANGE("Document Type", "Document Type");
                            PurchaseLine.SETRANGE("Document No.", "Document No.");
                            PurchaseLine.SETFILTER("No.", '<>%1', '');
                            IF PurchaseLine.FINDSET THEN BEGIN
                                IF GUIALLOWED THEN BEGIN
                                    IF DIALOG.CONFIRM(Question, TRUE) THEN BEGIN
                                        NewDocDim.DELETEALL(TRUE);
                                        IF NOT FromOnDelete THEN
                                            REPEAT
                                                InsertNew(DocDim, DATABASE::"Purchase Line", PurchaseLine."Line No.");
                                            UNTIL PurchaseLine.NEXT = 0;
                                    END;
                                END ELSE BEGIN
                                    NewDocDim.DELETEALL(TRUE);
                                    IF NOT FromOnDelete THEN
                                        REPEAT
                                            InsertNew(DocDim, DATABASE::"Purchase Line", PurchaseLine."Line No.");
                                        UNTIL PurchaseLine.NEXT = 0;
                                END;
                            END;
                        END;
                    DATABASE::"Transfer Header":
                        BEGIN
                            TransLine.SETRANGE("Document No.", "Document No.");
                            TransLine.SETRANGE("Derived From Line No.", 0);
                            IF TransLine.FINDSET THEN BEGIN
                                IF GUIALLOWED THEN BEGIN
                                    IF DIALOG.CONFIRM(Question, TRUE) THEN BEGIN
                                        NewDocDim.DELETEALL(TRUE);
                                        IF NOT FromOnDelete THEN
                                            REPEAT
                                                InsertNew(DocDim, DATABASE::"Transfer Line", TransLine."Line No.");
                                            UNTIL TransLine.NEXT = 0;
                                    END;
                                END ELSE BEGIN
                                    NewDocDim.DELETEALL(TRUE);
                                    IF NOT FromOnDelete THEN
                                        REPEAT
                                            InsertNew(DocDim, DATABASE::"Transfer Line", TransLine."Line No.");
                                        UNTIL TransLine.NEXT = 0;
                                END;
                            END;
                        END;

                    DATABASE::"Service Header":
                        BEGIN
                            IF ("Document Type" = "Document Type"::Order) OR
                               ("Document Type" = "Document Type"::Quote)
                            THEN BEGIN
                                ServItemLine.SETRANGE("Document Type", "Document Type");
                                ServItemLine.SETRANGE("Document No.", "Document No.");

                                IF ServItemLine.FIND('-') THEN
                                    IF GUIALLOWED = FALSE OR (UpdateLine = UpdateLine::Update) THEN
                                        UpdateDim := TRUE
                                    ELSE
                                        IF DIALOG.CONFIRM(Question, TRUE) THEN
                                            UpdateDim := TRUE
                                        ELSE
                                            UpdateDim := FALSE
                                ELSE
                                    UpdateDim := FALSE;

                                IF UpdateDim THEN BEGIN
                                    GLSetup.GET;
                                    REPEAT
                                        NewDocDim.SETRANGE("Line No.", ServItemLine."Line No.");
                                        IF NewDocDim.FIND('-') THEN BEGIN
                                            NewDocDim.SetRecursiveValue(TRUE);
                                            NewDocDim.DELETE(TRUE);
                                        END;
                                    UNTIL ServItemLine.NEXT = 0;

                                    IF NOT FromOnDelete THEN BEGIN
                                        ServItemLine.FIND('-');
                                        REPEAT
                                            SetRecursiveValue(TRUE);
                                            InsertNew(DocDim, DATABASE::"Service Item Line", ServItemLine."Line No.");
                                        UNTIL ServItemLine.NEXT = 0;
                                    END;
                                END;

                                ServLine.SETRANGE("Document Type", "Document Type");
                                ServLine.SETRANGE("Document No.", "Document No.");
                                ServLine.SETRANGE("Service Item Line No.", 0);
                                IF ServLine.FIND('-') THEN BEGIN
                                    IF UpdateDim THEN BEGIN
                                        NewDocDim.SETRANGE("Table ID", DATABASE::"Service Line");
                                        REPEAT
                                            NewDocDim.SETRANGE("Line No.", ServLine."Line No.");
                                            IF NewDocDim.FIND('-') THEN BEGIN
                                                NewDocDim.SetRecursiveValue(TRUE);
                                                NewDocDim.DELETE(TRUE);
                                            END;
                                        UNTIL ServItemLine.NEXT = 0;
                                        IF NOT FromOnDelete THEN BEGIN
                                            ServLine.FINDFIRST;
                                            REPEAT
                                                SetRecursiveValue(TRUE);
                                                InsertNew(DocDim, DATABASE::"Service Line", ServLine."Line No.");
                                            UNTIL ServLine.NEXT = 0;
                                        END;
                                    END;
                                END;

                            END ELSE BEGIN
                                ServLine.SETRANGE("Document Type", "Document Type");
                                ServLine.SETRANGE("Document No.", "Document No.");
                                ServItemLine.SETRANGE("Document Type", "Document Type");
                                ServItemLine.SETRANGE("Document No.", "Document No.");

                                IF ServLine.FIND('-') OR ServItemLine.FIND('-') THEN
                                    IF DIALOG.CONFIRM(Question, TRUE) THEN
                                        UpdateDim := TRUE;

                                IF ServLine.FIND('-') THEN BEGIN
                                    NewDocDim.SETRANGE("Table ID", DATABASE::"Service Line");
                                    IF GUIALLOWED THEN BEGIN
                                        IF UpdateDim THEN BEGIN
                                            NewDocDim.DELETEALL(TRUE);
                                            IF NOT FromOnDelete THEN
                                                REPEAT
                                                    InsertNew(DocDim, DATABASE::"Service Line", ServLine."Line No.");
                                                UNTIL ServLine.NEXT = 0;
                                        END;
                                    END ELSE BEGIN
                                        NewDocDim.DELETEALL(TRUE);
                                        IF NOT FromOnDelete THEN
                                            REPEAT
                                                InsertNew(DocDim, DATABASE::"Service Line", ServLine."Line No.");
                                            UNTIL ServLine.NEXT = 0;
                                    END;
                                END;

                                IF ServItemLine.FIND('-') THEN BEGIN
                                    NewDocDim.SETRANGE("Table ID", DATABASE::"Service Item Line");
                                    IF GUIALLOWED THEN BEGIN
                                        IF UpdateDim THEN BEGIN
                                            NewDocDim.DELETEALL(TRUE);
                                            IF NOT FromOnDelete THEN
                                                REPEAT
                                                    InsertNew(DocDim, DATABASE::"Service Item Line", ServItemLine."Line No.");
                                                UNTIL ServItemLine.NEXT = 0;
                                        END;
                                    END ELSE BEGIN
                                        NewDocDim.DELETEALL(TRUE);
                                        IF NOT FromOnDelete THEN
                                            REPEAT
                                                InsertNew(DocDim, DATABASE::"Service Item Line", ServItemLine."Line No.");
                                            UNTIL ServItemLine.NEXT = 0;
                                    END;
                                END;
                            END;
                        END;
                    DATABASE::"Service Item Line":
                        BEGIN
                            IF UpdateLine = UpdateLine::Update THEN
                                SetRecursiveValue(TRUE);
                            UpdateServLineDim(DocDim, FromOnDelete);
                        END
                END;
            END;
        END;
    end;

    /// <summary>
    /// Description for GetDimensions.
    /// </summary>
    /// <param name="TableNo">Parameter of type Integer.</param>
    /// <param name="DocType">Parameter of type Option.</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="DocLineNo">Parameter of type Integer.</param>
    /// <param name="TempDocDim">Parameter of type Record "357".</param>
    procedure GetDimensions(TableNo: Integer; DocType: Option; DocNo: Code[20]; DocLineNo: Integer; var TempDocDim: Record "Document Dimension");
    var
        DocDim: Record "Document Dimension";
    begin
        TempDocDim.DELETEALL;

        WITH DocDim DO BEGIN
            RESET;
            SETRANGE("Table ID", TableNo);
            SETRANGE("Document Type", DocType);
            SETRANGE("Document No.", DocNo);
            SETRANGE("Line No.", DocLineNo);
            IF FINDSET THEN
                REPEAT
                    TempDocDim := DocDim;
                    TempDocDim.INSERT;
                UNTIL NEXT = 0;
        END;
    end;

    /// <summary>
    /// Description for UpdateAllLineDim.
    /// </summary>
    /// <param name="TableNo">Parameter of type Integer.</param>
    /// <param name="DocType">Parameter of type Option.</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="OldDocDimHeader">Parameter of type Record "Document Dimension".</param>
    procedure UpdateAllLineDim(TableNo: Integer; DocType: Option; DocNo: Code[20]; var OldDocDimHeader: Record "Document Dimension");
    var
        DocDimHeader: Record "Document Dimension";
        DocDimLine: Record "Document Dimension";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        LineTableNo: Integer;
    begin
        CASE TableNo OF
            DATABASE::"Sales Header":
                BEGIN
                    LineTableNo := DATABASE::"Sales Line";
                    SalesLine.SETRANGE("Document Type", DocType);
                    SalesLine.SETRANGE("Document No.", DocNo);
                    IF NOT SalesLine.FINDFIRST THEN
                        EXIT;
                END;
            DATABASE::"Purchase Header":
                BEGIN
                    LineTableNo := DATABASE::"Purchase Line";
                    PurchaseLine.SETRANGE("Document Type", DocType);
                    PurchaseLine.SETRANGE("Document No.", DocNo);
                    IF NOT PurchaseLine.FINDFIRST THEN
                        EXIT;
                END;
            DATABASE::"Service Header":
                BEGIN
                    UpdateAllServLineDim(TableNo, DocType, DocNo, OldDocDimHeader, 0);
                    EXIT;
                END;
        END;

        DocDimHeader.SETRANGE("Table ID", TableNo);
        DocDimHeader.SETRANGE("Document Type", DocType);
        DocDimHeader.SETRANGE("Document No.", DocNo);
        DocDimHeader.SETRANGE("Line No.", 0);

        DocDimLine.SETRANGE("Document Type", DocType);
        DocDimLine.SETRANGE("Document No.", DocNo);
        DocDimLine.SETFILTER("Line No.", '<>0');

        IF NOT (DocDimHeader.FINDFIRST OR OldDocDimHeader.FINDFIRST) THEN
            EXIT;

        IF UpdateLine <> UpdateLine::Update THEN
            IF GUIALLOWED THEN
                IF NOT CONFIRM(Text003, TRUE) THEN
                    EXIT;

        // Going through all the dimensions on the Header AFTER they have been updated
        WITH DocDimHeader DO
            IF FINDSET THEN
                REPEAT
                    IF NOT OldDocDimHeader.GET("Table ID", "Document Type", "Document No.", "Line No.", "Dimension Code") OR
                       (OldDocDimHeader."Dimension Value Code" <> "Dimension Value Code")
                    THEN BEGIN
                        DocDimLine.SETRANGE("Dimension Code", "Dimension Code");
                        CASE TableNo OF
                            DATABASE::"Sales Header":
                                BEGIN
                                    DocDimLine.SETRANGE("Table ID", LineTableNo);
                                    DocDimLine.DELETEALL(TRUE);

                                    SalesLine.SETRANGE("Document Type", DocType);
                                    SalesLine.SETRANGE("Document No.", DocNo);
                                    IF SalesLine.FINDSET THEN
                                        REPEAT
                                            InsertNew(DocDimHeader, LineTableNo, SalesLine."Line No.");
                                        UNTIL SalesLine.NEXT = 0;
                                END;
                            DATABASE::"Purchase Header":
                                BEGIN
                                    DocDimLine.SETRANGE("Table ID", LineTableNo);
                                    DocDimLine.DELETEALL(TRUE);

                                    PurchaseLine.SETRANGE("Document Type", DocType);
                                    PurchaseLine.SETRANGE("Document No.", DocNo);
                                    IF PurchaseLine.FIND('-') THEN
                                        REPEAT
                                            InsertNew(DocDimHeader, LineTableNo, PurchaseLine."Line No.");
                                        UNTIL PurchaseLine.NEXT = 0;
                                END;
                        END;
                    END;
                UNTIL NEXT = 0;

        // Going through all the dimensions on the Header BEFORE they have been updated
        // If the DimCode were there before but not anymore, all DimLines with the DimCode are deleted
        WITH OldDocDimHeader DO
            IF FIND('-') THEN
                REPEAT
                    IF NOT DocDimHeader.GET("Table ID", "Document Type", "Document No.", "Line No.", "Dimension Code") THEN BEGIN
                        DocDimLine.SETRANGE("Dimension Code", "Dimension Code");
                        DocDimLine.DELETEALL(TRUE);
                    END;
                UNTIL NEXT = 0;
    end;

    /// <summary>
    /// Description for InsertNew.
    /// </summary>
    /// <param name="DocDim">Parameter of type Record "357".</param>
    /// <param name="TableNo">Parameter of type Integer.</param>
    /// <param name="LineNo">Parameter of type Integer.</param>
    local procedure InsertNew(var DocDim: Record "Document Dimension"; TableNo: Integer; LineNo: Integer);
    var
        NewDocDim: Record "Document Dimension";
    begin
        WITH DocDim DO BEGIN
            NewDocDim."Table ID" := TableNo;
            NewDocDim."Document Type" := "Document Type";
            NewDocDim."Document No." := "Document No.";
            NewDocDim."Line No." := LineNo;
            NewDocDim."Dimension Code" := "Dimension Code";
            NewDocDim."Dimension Value Code" := "Dimension Value Code";
            IF UpdateLine = UpdateLine::Update THEN
                NewDocDim.SetRecursiveValue(TRUE)
            ELSE
                IF UpdateLine = UpdateLine::DoNotUpdate THEN
                    NewDocDim.SetRecursiveValue(FALSE);
            NewDocDim.INSERT(TRUE);
        END;
    end;

    /// <summary>
    /// Description for OnDeleteServRec.
    /// </summary>
    procedure OnDeleteServRec();
    begin
        GLSetup.GET;
        UpdateLineDim(Rec, TRUE);
        IF "Dimension Code" = GLSetup."Global Dimension 1 Code" THEN
            UpdateGlobalDimCode(
              1, "Table ID", "Document Type", "Document No.", "Line No.", '');
        IF "Dimension Code" = GLSetup."Global Dimension 2 Code" THEN
            UpdateGlobalDimCode(
              2, "Table ID", "Document Type", "Document No.", "Line No.", '');
    end;

    /// <summary>
    /// Description for UpdateServLineDim.
    /// </summary>
    /// <param name="DocDim">Parameter of type Record "357".</param>
    /// <param name="FromOnDelete">Parameter of type Boolean.</param>
    procedure UpdateServLineDim(var DocDim: Record "Document Dimension"; FromOnDelete: Boolean);
    var
        NewDocDim: Record "Document Dimension";
        ServLine: Record "Service Line";
        ServItemLine: Record "Service Item Line";
        Question: Text[250];
        UpdateDim: Boolean;
    begin
        WITH DocDim DO BEGIN
            IF "Table ID" = DATABASE::"Service Item Line" THEN BEGIN
                Question := STRSUBSTNO(Text001 + Text002);
                NewDocDim.SETRANGE("Table ID", DATABASE::"Service Line");
                NewDocDim.SETRANGE("Document Type", "Document Type");
                NewDocDim.SETRANGE("Document No.", "Document No.");
                NewDocDim.SETRANGE("Dimension Code", "Dimension Code");

                IF FromOnDelete THEN
                    IF NOT NewDocDim.FIND('-') THEN
                        EXIT;

                ServItemLine.SETRANGE("Document Type", "Document Type");
                ServItemLine.SETRANGE("Document No.", "Document No.");
                ServItemLine.SETRANGE("Line No.", "Line No.");

                IF ServItemLine.FIND('-') THEN BEGIN

                    ServLine.SETRANGE("Document Type", "Document Type");
                    ServLine.SETRANGE("Document No.", "Document No.");
                    ServLine.SETRANGE("Service Item Line No.", ServItemLine."Line No.");
                    IF ServLine.FIND('-') THEN BEGIN
                        IF GUIALLOWED = FALSE OR (UpdateLine = UpdateLine::Update) THEN
                            UpdateDim := TRUE;

                        IF UpdateDim = FALSE THEN
                            IF DIALOG.CONFIRM(Question, TRUE) THEN BEGIN
                                SetRecursiveValue(TRUE);
                                UpdateDim := TRUE;
                            END ELSE
                                SetRecursiveValue(FALSE);

                        IF UpdateDim THEN BEGIN
                            ServLine.FIND('-');
                            REPEAT
                                NewDocDim.SETRANGE("Line No.", ServLine."Line No.");
                                IF NewDocDim.FIND('-') THEN BEGIN
                                    NewDocDim.SetRecursiveValue(TRUE);
                                    NewDocDim.DELETEALL(TRUE);
                                END;
                            UNTIL ServLine.NEXT = 0;
                            IF NOT FromOnDelete THEN BEGIN
                                ServLine.FIND('-');
                                REPEAT
                                    SetRecursiveValue(TRUE);
                                    InsertNew(DocDim, DATABASE::"Service Line", ServLine."Line No.");
                                UNTIL ServLine.NEXT = 0;
                            END;
                        END;
                    END;
                END;
            END;
        END;
    end;

    /// <summary>
    /// Description for SetRecursiveValue.
    /// </summary>
    /// <param name="Recursive">Parameter of type Boolean.</param>
    procedure SetRecursiveValue(Recursive: Boolean);
    begin
        IF Recursive THEN
            UpdateLine := UpdateLine::Update
        ELSE
            UpdateLine := UpdateLine::DoNotUpdate;
    end;

    /// <summary>
    /// Description for UpdateAllServLineDim.
    /// </summary>
    /// <param name="TableNo">Parameter of type Integer.</param>
    /// <param name="DocType">Parameter of type Option.</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="OldDocDimHeader">Parameter of type Record "357".</param>
    /// <param name="DocLineNo">Parameter of type Integer.</param>
    procedure UpdateAllServLineDim(TableNo: Integer; DocType: Option; DocNo: Code[20]; var OldDocDimHeader: Record "Document Dimension"; DocLineNo: Integer);
    var
        DocDimHeader: Record "Document Dimension";
        DocDimLine: Record "Document Dimension";
        ServLine: Record "Service Line";
        ServItemLine: Record "Service Item Line";
    begin
        CASE TableNo OF
            DATABASE::"Service Header":
                BEGIN
                    ServLine.SETRANGE("Document Type", DocType);
                    ServLine.SETRANGE("Document No.", DocNo);
                    ServItemLine.SETRANGE("Document Type", DocType);
                    ServItemLine.SETRANGE("Document No.", DocNo);
                    IF NOT ServLine.FIND('-') AND NOT ServItemLine.FIND('-') THEN
                        EXIT;
                END;
            DATABASE::"Service Item Line":
                BEGIN
                    ServItemLine.SETRANGE("Document Type", DocType);
                    ServItemLine.SETRANGE("Document No.", DocNo);
                    ServItemLine.SETRANGE("Line No.", DocLineNo);
                    IF ServItemLine.FINDFIRST THEN;

                    ServLine.SETRANGE("Document Type", DocType);
                    ServLine.SETRANGE("Document No.", DocNo);
                    ServLine.SETRANGE("Service Item Line No.", ServItemLine."Line No.");
                    IF NOT ServLine.FIND('-') THEN
                        EXIT;

                    DocDimLine.SETRANGE("Table ID", DATABASE::"Service Line");
                END;
            ELSE
                EXIT;
        END;

        DocDimHeader.SETRANGE("Table ID", TableNo);
        DocDimHeader.SETRANGE("Document Type", DocType);
        DocDimHeader.SETRANGE("Document No.", DocNo);
        DocDimHeader.SETRANGE("Line No.", DocLineNo);

        DocDimLine.SETRANGE("Document Type", DocType);
        DocDimLine.SETRANGE("Document No.", DocNo);


        IF NOT (DocDimHeader.FIND('-') OR OldDocDimHeader.FIND('-')) THEN
            EXIT;

        IF UpdateLine <> UpdateLine::Update THEN
            IF GUIALLOWED THEN
                IF NOT CONFIRM(Text003, TRUE) THEN
                    EXIT;

        // Going through all the dimensions on the Header AFTER they have been updated
        WITH DocDimHeader DO
            IF FIND('-') THEN
                REPEAT
                    IF NOT OldDocDimHeader.GET("Table ID", "Document Type", "Document No.", "Line No.", "Dimension Code") OR
                       (OldDocDimHeader."Dimension Value Code" <> "Dimension Value Code")
                    THEN BEGIN
                        DocDimLine.SETRANGE("Dimension Code", "Dimension Code");
                        CASE TableNo OF
                            DATABASE::"Service Header":
                                BEGIN
                                    DocDimLine.SETFILTER("Line No.", '<>0');
                                    DocDimLine.SETRANGE("Table ID", DATABASE::"Service Item Line");
                                    IF DocDimLine.FINDSET THEN
                                        REPEAT
                                            DocDimLine.SetRecursiveValue(TRUE);
                                            DocDimLine.DELETE(TRUE);
                                        UNTIL DocDimLine.NEXT = 0;

                                    DocDimLine.SETRANGE("Table ID", DATABASE::"Service Line");
                                    IF DocDimLine.FIND('-') THEN
                                        REPEAT
                                            DocDimLine.SetRecursiveValue(TRUE);
                                            DocDimLine.DELETE(TRUE);
                                        UNTIL DocDimLine.NEXT = 0;

                                    IF (DocType = ServLine."Document Type"::Order) OR
                                       (DocType = ServLine."Document Type"::Quote)
                                    THEN BEGIN
                                        IF ServItemLine.FIND('-') THEN
                                            REPEAT
                                                Rec.SetRecursiveValue(TRUE);
                                                InsertNew(DocDimHeader, DATABASE::"Service Item Line", ServItemLine."Line No.");
                                            UNTIL ServItemLine.NEXT = 0;
                                        ServLine.SETRANGE("Service Item Line No.", 0);
                                        IF ServLine.FIND('-') THEN
                                            REPEAT
                                                Rec.SetRecursiveValue(TRUE);
                                                InsertNew(DocDimHeader, DATABASE::"Service Line", ServLine."Line No.");
                                            UNTIL ServLine.NEXT = 0;
                                    END ELSE
                                        IF ServLine.FIND('-') THEN
                                            REPEAT
                                                Rec.SetRecursiveValue(TRUE);
                                                InsertNew(DocDimHeader, DATABASE::"Service Line", ServLine."Line No.");
                                            UNTIL ServLine.NEXT = 0;
                                END;
                            DATABASE::"Service Item Line":
                                BEGIN
                                    IF ServItemLine.FINDFIRST THEN
                                        REPEAT
                                            ServLine.SETRANGE("Service Item Line No.", ServItemLine."Line No.");
                                            IF ServLine.FIND('-') THEN BEGIN
                                                REPEAT
                                                    DocDimLine.SETRANGE("Line No.", ServLine."Line No.");
                                                    IF DocDimLine.FIND('-') THEN
                                                        REPEAT
                                                            Rec.SetRecursiveValue(TRUE);
                                                            DocDimLine.DELETE(TRUE);
                                                        UNTIL DocDimLine.NEXT = 0;
                                                UNTIL ServLine.NEXT = 0;

                                                ServLine.FIND('-');
                                                REPEAT
                                                    Rec.SetRecursiveValue(TRUE);
                                                    InsertNew(DocDimHeader, DATABASE::"Service Line", ServLine."Line No.");
                                                UNTIL ServLine.NEXT = 0;
                                            END;
                                        UNTIL ServItemLine.NEXT = 0;
                                END;
                        END;
                    END;
                UNTIL NEXT = 0;

        // Going through all the dimensions on the Header BEFORE they have been updated
        // If the DimCode were there before but not anymore, all DimLines with the DimCode are deleted
        WITH OldDocDimHeader DO
            IF FINDSET THEN
                REPEAT
                    IF NOT DocDimHeader.GET("Table ID", "Document Type", "Document No.", "Line No.", "Dimension Code") THEN BEGIN
                        DocDimLine.SETRANGE("Dimension Code", "Dimension Code");
                        DocDimLine.SetRecursiveValue(TRUE);
                        DocDimLine.DELETEALL(TRUE);
                    END;
                UNTIL NEXT = 0;
    end;
}

