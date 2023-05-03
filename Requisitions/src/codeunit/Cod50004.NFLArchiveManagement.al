/// <summary>
/// Codeunit NFL ArchiveManagement (ID 50055).
/// </summary>
codeunit 50004 "NFL ArchiveManagement"
{
    // version NFL02.000


    trigger OnRun();
    begin
    end;

    var
        Text001: Label 'Document %1 has been archived.';
        Text002: Label 'Do you want to Restore %1 %2 Version %3?';
        Text003: Label '%1 %2 has been restored.';
        Text004: Label 'Document restored from Version %1.';
        Text005: Label '%1 %2 has been partly posted.\Restore not possible.';
        Text006: Label 'Entries exist for on or more of the following:\  - %1\  - %2\  - %3.\Restoration of document will delete these entries.\Continue with restore?';
        Text007: Label 'Archive %1 no.: %2?';
        Text008: Label 'Item Tracking Line';
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        Text009: Label 'Unposted %1 %2 does not exist anymore.\It is not possible to restore the %1.';
        StoreReqArchiveType: Option " ","Item Journal","Purchase Requisition";
        NFLRequisitionHeader: Record "NFL Requisition Header";

    /// <summary>
    /// Description for ArchiveSalesDocument.
    /// </summary>
    /// <param name="SalesHeader">Parameter of type Record "36".</param>
    procedure ArchiveSalesDocument(var SalesHeader: Record "Sales Header");
    begin
        IF CONFIRM(
          Text007, TRUE, SalesHeader."Document Type",
          SalesHeader."No.")
        THEN BEGIN
            StoreSalesDocument(SalesHeader, FALSE);
            MESSAGE(Text001, SalesHeader."No.");
        END;
    end;

    /// <summary>
    /// Description for ArchivePurchDocument.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "NFL Requisition Header".</param>
    procedure ArchivePurchDocument(var PurchHeader: Record "NFL Requisition Header");
    begin
        IF CONFIRM(
          Text007, TRUE, PurchHeader."Document Type",
          PurchHeader."No.")
        THEN BEGIN
            StorePurchDocument(PurchHeader, FALSE);
            MESSAGE(Text001, PurchHeader."No.");
        END;
    end;

    /// <summary>
    /// Description for StoreSalesDocument.
    /// </summary>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="InteractionExist">Parameter of type Boolean.</param>
    procedure StoreSalesDocument(var SalesHeader: Record "Sales Header"; InteractionExist: Boolean);
    var
        SalesLine: Record "Sales Line";
        SalesHeaderArchive: Record "Sales Header Archive";
        SalesLineArchive: Record "Sales Line Archive";
    begin
        SalesHeaderArchive.INIT;
        SalesHeaderArchive.TRANSFERFIELDS(SalesHeader);
        SalesHeaderArchive."Archived By" := USERID;
        SalesHeaderArchive."Date Archived" := WORKDATE;
        SalesHeaderArchive."Time Archived" := TIME;
        SalesHeaderArchive."Version No." := GetNextVersionNo(
          DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", SalesHeader."Doc. No. Occurrence");
        SalesHeaderArchive."Interaction Exist" := InteractionExist;
        SalesHeaderArchive.INSERT;
        StoreDocDim(
          DATABASE::"Sales Header", SalesHeader."Document Type",
          SalesHeader."No.", 0, SalesHeader."Doc. No. Occurrence", SalesHeaderArchive."Version No.",
           DATABASE::"Sales Header Archive");

        StoreSalesDocumentComments(
          SalesHeader."Document Type", SalesHeader."No.",
          SalesHeader."Doc. No. Occurrence", SalesHeaderArchive."Version No.");

        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        IF SalesLine.FINDSET THEN
            REPEAT
                WITH SalesLineArchive DO BEGIN
                    INIT;
                    TRANSFERFIELDS(SalesLine);
                    "Doc. No. Occurrence" := SalesHeader."Doc. No. Occurrence";
                    "Version No." := SalesHeaderArchive."Version No.";
                    INSERT;
                    StoreDocDim(
                      DATABASE::"Sales Line", SalesLine."Document Type", SalesLine."Document No.",
                      SalesLine."Line No.", SalesHeader."Doc. No. Occurrence", "Version No.",
                       DATABASE::"Sales Line Archive");
                END
            UNTIL SalesLine.NEXT = 0;
    end;

    /// <summary>
    /// Description for StorePurchDocument.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "NFL Requisition Header".</param>
    /// <param name="InteractionExist">Parameter of type Boolean.</param>
    procedure StorePurchDocument(var PurchHeader: Record "NFL Requisition Header"; InteractionExist: Boolean);
    var
        PurchLine: Record "NFL Requisition Line";
        PurchHeaderArchive: Record "NFL Requisition Header Archive";
        PurchLineArchive: Record "NFL Requisition Line Archive";
        NFLSetup: Record "NFL Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        PurchHeaderArchive.INIT;
        PurchHeaderArchive.TRANSFERFIELDS(PurchHeader);
        PurchHeaderArchive."Purchase Requisition No." := PurchHeader."No.";
        PurchHeaderArchive."Archived By" := USERID;
        PurchHeaderArchive."Date Archived" := WORKDATE;
        PurchHeaderArchive."Time Archived" := TIME;
        PurchHeaderArchive."Version No." := GetNextVersionNo(
          DATABASE::"NFL Requisition Header", PurchHeader."Document Type", PurchHeader."No.", PurchHeader."Doc. No. Occurrence");
        PurchHeaderArchive."Interaction Exist" := InteractionExist;
        IF PurchHeader."Document Type" = PurchHeader."Document Type"::"Store Requisition" THEN BEGIN
            NFLSetup.GET;
            NFLSetup.TESTFIELD("Store Req. Archive No. Series");
            PurchHeaderArchive."Archive No." := NoSeriesMgt.GetNextNo(NFLSetup."Store Req. Archive No. Series", TODAY, TRUE);
            PurchHeaderArchive."Created from" := StoreReqArchiveType;
        END;
        IF PurchHeader."Document Type" = PurchHeader."Document Type"::"Store Return" THEN BEGIN
            NFLSetup.GET;
            NFLSetup.TESTFIELD(NFLSetup."Store Return Archive No series");
            PurchHeaderArchive."Archive No." := NoSeriesMgt.GetNextNo(NFLSetup."Store Return Archive No series", TODAY, TRUE);
            PurchHeaderArchive."Created from" := StoreReqArchiveType;
        END;

        PurchHeaderArchive.INSERT;

        StorePurchDocumentComments(
          PurchHeader."Document Type", PurchHeader."No.",
          PurchHeader."Doc. No. Occurrence", PurchHeaderArchive."Version No.");

        PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
        PurchLine.SETRANGE("Document No.", PurchHeader."No.");
        IF PurchLine.FINDSET THEN
            REPEAT
                WITH PurchLineArchive DO BEGIN
                    INIT;
                    TRANSFERFIELDS(PurchLine);
                    "Doc. No. Occurrence" := PurchHeader."Doc. No. Occurrence";
                    "Version No." := PurchHeaderArchive."Version No.";
                    PurchLineArchive."Archive No." := PurchHeaderArchive."Archive No.";
                    // mark the lines which are being made to req./item jnl
                    IF PurchLineArchive."Archive No." <> '' THEN BEGIN
                        IF (StoreReqArchiveType = StoreReqArchiveType::"Item Journal") THEN BEGIN
                            //update store requisition
                            PurchLineArchive."Make Purchase Req." := FALSE;
                            IF PurchLine."Transfer to Item Jnl" THEN BEGIN
                                PurchLine."Transferred To Item Jnl" := TRUE;
                                PurchLine."Qty To Transfer to Item Jnl" := 0;
                            END;
                            PurchLine."Transfer to Item Jnl" := FALSE;
                            PurchLine.MODIFY;
                        END
                        ELSE
                            IF (StoreReqArchiveType = StoreReqArchiveType::"Purchase Requisition") THEN BEGIN
                                //update store requisition
                                PurchLineArchive."Transfer to Item Jnl" := FALSE;
                                IF PurchLine."Make Purchase Req." THEN BEGIN
                                    PurchLine."Transferred To Purch. Req." := TRUE;
                                    PurchLine."Qty To Make Purch. Req." := 0;
                                END;
                                PurchLine."Make Purchase Req." := FALSE;
                                PurchLine.MODIFY;

                            END;
                    END;
                    INSERT;
                END
            UNTIL PurchLine.NEXT = 0;
    end;

    /// <summary>
    /// Description for RestoreSalesDocument.
    /// </summary>
    /// <param name="SalesHeaderArchive">Parameter of type Record "5107".</param>
    procedure RestoreSalesDocument(var SalesHeaderArchive: Record "Sales Header Archive");
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLineArchive: Record "Sales Line Archive";
        //DocDimArchv: Record "5106";
        DocDim: Record "Document Dimension";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesInvHeader: Record "Sales Invoice Header";
        ReservEntry: Record "Reservation Entry";
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        SalesCommentLine: Record "Sales Comment Line";
        SalesCommentLineArchive: Record "Sales Comment Line Archive";
        SalesPost: Codeunit "Sales-Post";
        DimMgt: Codeunit "DimensionManagement";
        NextLine: Integer;
        ConfirmRequired: Boolean;
        RestoreDocument: Boolean;
    begin
        IF NOT (SalesHeader.GET(SalesHeaderArchive."Document Type", SalesHeaderArchive."No.")) THEN
            ERROR(Text009, SalesHeaderArchive."Document Type", SalesHeaderArchive."No.");
        SalesHeader.TESTFIELD(Status, SalesHeader.Status::Open);
        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN BEGIN
            SalesShptHeader.RESET;
            SalesShptHeader.SETCURRENTKEY("Order No.");
            SalesShptHeader.SETRANGE("Order No.", SalesHeader."No.");
            IF NOT SalesShptHeader.ISEMPTY THEN
                ERROR(Text005, SalesHeader."Document Type", SalesHeader."No.");
            SalesInvHeader.RESET;
            SalesInvHeader.SETCURRENTKEY("Order No.");
            SalesInvHeader.SETRANGE("Order No.", SalesHeader."No.");
            IF NOT SalesInvHeader.ISEMPTY THEN
                ERROR(Text005, SalesHeader."Document Type", SalesHeader."No.");
        END;

        ConfirmRequired := FALSE;
        ReservEntry.RESET;
        ReservEntry.SETCURRENTKEY(
          "Source ID",
          "Source Ref. No.",
          "Source Type",
          "Source Subtype");

        ReservEntry.SETRANGE("Source ID", SalesHeader."No.");
        ReservEntry.SETRANGE("Source Type", DATABASE::"Sales Line");
        ReservEntry.SETRANGE("Source Subtype", SalesHeader."Document Type");
        IF ReservEntry.FINDFIRST THEN
            ConfirmRequired := TRUE;

        ItemChargeAssgntSales.RESET;
        ItemChargeAssgntSales.SETRANGE("Document Type", SalesHeader."Document Type");
        ItemChargeAssgntSales.SETRANGE("Document No.", SalesHeader."No.");
        IF ItemChargeAssgntSales.FINDFIRST THEN
            ConfirmRequired := TRUE;

        RestoreDocument := FALSE;
        IF ConfirmRequired THEN BEGIN
            IF CONFIRM(
              Text006, FALSE, ReservEntry.TABLECAPTION, ItemChargeAssgntSales.TABLECAPTION, Text008)
            THEN
                RestoreDocument := TRUE;
        END ELSE
            IF CONFIRM(
              Text002, TRUE, SalesHeaderArchive."Document Type",
              SalesHeaderArchive."No.", SalesHeaderArchive."Version No.")
            THEN
                RestoreDocument := TRUE;
        IF RestoreDocument THEN BEGIN
            SalesHeader.TESTFIELD("Doc. No. Occurrence", SalesHeaderArchive."Doc. No. Occurrence");
            SalesHeader.DELETE(TRUE);
            SalesHeader.INIT;

            SalesHeader.SetHideValidationDialog(TRUE);
            SalesHeader."Document Type" := SalesHeaderArchive."Document Type";
            SalesHeader."No." := SalesHeaderArchive."No.";
            SalesHeader.INSERT(TRUE);
            SalesHeader.TRANSFERFIELDS(SalesHeaderArchive);
            SalesHeader.Status := SalesHeader.Status::Open;


            IF SalesHeaderArchive."Sell-to Contact No." <> '' THEN
                SalesHeader.VALIDATE("Sell-to Contact No.", SalesHeaderArchive."Sell-to Contact No.")
            ELSE
                SalesHeader.VALIDATE("Sell-to Customer No.", SalesHeaderArchive."Sell-to Customer No.");
            IF SalesHeaderArchive."Bill-to Contact No." <> '' THEN
                SalesHeader.VALIDATE("Bill-to Contact No.", SalesHeaderArchive."Bill-to Contact No.")
            ELSE
                SalesHeader.VALIDATE("Bill-to Customer No.", SalesHeaderArchive."Bill-to Customer No.");
            SalesHeader.VALIDATE("Salesperson Code", SalesHeaderArchive."Salesperson Code");
            SalesHeader.VALIDATE("Payment Terms Code", SalesHeaderArchive."Payment Terms Code");
            SalesHeader.VALIDATE("Payment Discount %", SalesHeaderArchive."Payment Discount %");
            SalesHeader."Shortcut Dimension 1 Code" := SalesHeaderArchive."Shortcut Dimension 1 Code";
            SalesHeader."Shortcut Dimension 2 Code" := SalesHeaderArchive."Shortcut Dimension 2 Code";
            SalesHeader."Dimension Set ID" := SalesHeaderArchive."Dimension Set ID";
            SalesHeader.COPYLINKS(SalesHeaderArchive);

            SalesHeader.MODIFY(TRUE);

            // SalesHeader.MODIFY(TRUE); IEpou

            SalesCommentLineArchive.SETRANGE("Document Type", SalesHeaderArchive."Document Type");
            SalesCommentLineArchive.SETRANGE("No.", SalesHeaderArchive."No.");
            SalesCommentLineArchive.SETRANGE("Doc. No. Occurrence", SalesHeaderArchive."Doc. No. Occurrence");
            SalesCommentLineArchive.SETRANGE("Version No.", SalesHeaderArchive."Version No.");
            IF SalesCommentLineArchive.FINDSET THEN
                REPEAT
                    SalesCommentLine.INIT;
                    SalesCommentLine.TRANSFERFIELDS(SalesCommentLineArchive);
                    SalesCommentLine.INSERT;
                UNTIL SalesCommentLineArchive.NEXT = 0;

            SalesCommentLine.SETRANGE("Document Type", SalesHeader."Document Type");
            SalesCommentLine.SETRANGE("No.", SalesHeader."No.");
            SalesCommentLine.SETRANGE("Document Line No.", 0);
            IF SalesCommentLine.FINDLAST THEN
                NextLine := SalesCommentLine."Line No.";
            NextLine += 10000;
            SalesCommentLine.INIT;
            SalesCommentLine."Document Type" := SalesHeader."Document Type";
            SalesCommentLine."No." := SalesHeader."No.";
            SalesCommentLine."Document Line No." := 0;
            SalesCommentLine."Line No." := NextLine;
            SalesCommentLine.Date := WORKDATE;
            SalesCommentLine.Comment := STRSUBSTNO(Text004, FORMAT(SalesHeaderArchive."Version No."));
            SalesCommentLine.INSERT;

            SalesLineArchive.SETRANGE("Document Type", SalesHeaderArchive."Document Type");
            SalesLineArchive.SETRANGE("Document No.", SalesHeaderArchive."No.");
            SalesLineArchive.SETRANGE("Doc. No. Occurrence", SalesHeaderArchive."Doc. No. Occurrence");
            SalesLineArchive.SETRANGE("Version No.", SalesHeaderArchive."Version No.");
            IF SalesLineArchive.FINDSET THEN BEGIN
                REPEAT
                    WITH SalesLine DO BEGIN
                        INIT;
                        TRANSFERFIELDS(SalesLineArchive);
                        INSERT(TRUE);
                        IF Type <> Type::" " THEN BEGIN
                            VALIDATE("No.");
                            IF SalesLineArchive."Variant Code" <> '' THEN
                                VALIDATE("Variant Code", SalesLineArchive."Variant Code");
                            IF SalesLineArchive."Unit of Measure Code" <> '' THEN
                                VALIDATE("Unit of Measure Code", SalesLineArchive."Unit of Measure Code");
                            IF Quantity <> 0 THEN
                                VALIDATE(Quantity, SalesLineArchive.Quantity);
                            VALIDATE("Unit Price", SalesLineArchive."Unit Price");
                            VALIDATE("Line Discount %", SalesLineArchive."Line Discount %");
                            IF SalesLineArchive."Inv. Discount Amount" <> 0 THEN
                                VALIDATE("Inv. Discount Amount", SalesLineArchive."Inv. Discount Amount");
                            IF Amount <> SalesLineArchive.Amount THEN
                                VALIDATE(Amount, SalesLineArchive.Amount);
                            VALIDATE(Description, SalesLineArchive.Description);
                        END;
                        "Shortcut Dimension 1 Code" := SalesLineArchive."Shortcut Dimension 1 Code";
                        "Shortcut Dimension 2 Code" := SalesLineArchive."Shortcut Dimension 2 Code";
                        //DocDimArchv.SETRANGE("Line No.",SalesLineArchive."Line No.");

                        /*DocDim.SETRANGE("Line No.","Line No.");
                        DocDim.DELETEALL;

                        DimMgt.MoveDocDimArchvToDocDim(
                          DocDimArchv,
                          DATABASE::"Sales Line",
                          "No.","Document Type","Line No.");*/

                        "Dimension Set ID" := SalesLineArchive."Dimension Set ID";
                        COPYLINKS(SalesLineArchive);
                        MODIFY(TRUE);
                    END
                UNTIL SalesLineArchive.NEXT = 0;
            END;
            SalesHeader.Status := SalesHeader.Status::Released;
            ReleaseSalesDoc.Reopen(SalesHeader);
            MESSAGE(Text003, SalesHeader."Document Type", SalesHeader."No.");
        END;

    end;

    /// <summary>
    /// Description for GetNextOccurrenceNo.
    /// </summary>
    /// <param name="TableId">Parameter of type Integer.</param>
    /// <param name="DocType">Parameter of type Option "Store Requisition","Purchase Requisition".</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <returns>Return variable "Integer".</returns>
    procedure GetNextOccurrenceNo(TableId: Integer; DocType: Option "Store Requisition","Purchase Requisition"; DocNo: Code[20]): Integer;
    var
        SalesHeaderArchive: Record "Sales Header Archive";
        PurchHeaderArchive: Record "NFL Requisition Header Archive";
    begin
        CASE TableId OF
            DATABASE::"Sales Header":
                BEGIN
                    SalesHeaderArchive.LOCKTABLE;
                    SalesHeaderArchive.SETRANGE("Document Type", DocType);
                    SalesHeaderArchive.SETRANGE("No.", DocNo);
                    IF SalesHeaderArchive.FINDLAST THEN
                        EXIT(SalesHeaderArchive."Doc. No. Occurrence" + 1)
                    ELSE
                        EXIT(1);
                END;
            DATABASE::"NFL Requisition Header":
                BEGIN
                    PurchHeaderArchive.LOCKTABLE;
                    PurchHeaderArchive.SETRANGE("Document Type", DocType);
                    PurchHeaderArchive.SETRANGE("No.", DocNo);
                    IF PurchHeaderArchive.FINDLAST THEN
                        EXIT(PurchHeaderArchive."Doc. No. Occurrence" + 1)
                    ELSE
                        EXIT(1);
                END;
        END;
    end;

    /// <summary>
    /// Description for GetNextVersionNo.
    /// </summary>
    /// <param name="TableId">Parameter of type Integer.</param>
    /// <param name="DocType">Parameter of type Option "Store Requisition","Purchase Requisition".</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="DocNoOccurrence">Parameter of type Integer.</param>
    /// <returns>Return variable "Integer".</returns>
    procedure GetNextVersionNo(TableId: Integer; DocType: Option "Store Requisition","Purchase Requisition"; DocNo: Code[20]; DocNoOccurrence: Integer): Integer;
    var
        SalesHeaderArchive: Record "Sales Header Archive";
        PurchHeaderArchive: Record "NFL Requisition Header Archive";
    begin
        CASE TableId OF
            DATABASE::"Sales Header":
                BEGIN
                    SalesHeaderArchive.LOCKTABLE;
                    SalesHeaderArchive.SETRANGE("Document Type", DocType);
                    SalesHeaderArchive.SETRANGE("No.", DocNo);
                    SalesHeaderArchive.SETRANGE("Doc. No. Occurrence", DocNoOccurrence);
                    IF SalesHeaderArchive.FINDLAST THEN
                        EXIT(SalesHeaderArchive."Version No." + 1)
                    ELSE
                        EXIT(1);
                END;
            DATABASE::"NFL Requisition Header":
                BEGIN
                    PurchHeaderArchive.LOCKTABLE;
                    PurchHeaderArchive.SETRANGE("Document Type", DocType);
                    PurchHeaderArchive.SETRANGE("No.", DocNo);
                    PurchHeaderArchive.SETRANGE("Doc. No. Occurrence", DocNoOccurrence);
                    IF PurchHeaderArchive.FINDLAST THEN
                        EXIT(PurchHeaderArchive."Version No." + 1)
                    ELSE
                        EXIT(1);
                END;
        END;
    end;

    /// <summary>
    /// Description for SalesDocArchiveGranule.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure SalesDocArchiveGranule(): Boolean;
    var
        SalesHeaderArchive: Record "Sales Header Archive";
    begin
        EXIT(SalesHeaderArchive.WRITEPERMISSION);
    end;

    /// <summary>
    /// Description for StoreDocDim.
    /// </summary>
    /// <param name="TableId">Parameter of type Integer.</param>
    /// <param name="DocType">Parameter of type Option.</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="LineNo">Parameter of type Integer.</param>
    /// <param name="DocNoOccurrence">Parameter of type Integer.</param>
    /// <param name="VersionNo">Parameter of type Integer.</param>
    /// <param name="NewTableID">Parameter of type Integer.</param>
    procedure StoreDocDim(TableId: Integer; DocType: Option; DocNo: Code[20]; LineNo: Integer; DocNoOccurrence: Integer; VersionNo: Integer; NewTableID: Integer);
    var
        DocDim: Record "Document Dimension";
    //DocDimArchive: Record "5106"; IE
    begin
        DocDim.SETRANGE("Table ID", TableId);
        IF DocType = 0 THEN
            DocDim.SETRANGE("Document Type", DocDim."Document Type"::"Store Requisition");
        IF DocType = 1 THEN
            DocDim.SETRANGE("Document Type", DocDim."Document Type"::"Purchase Requisition");
        IF DocType = 2 THEN
            DocDim.SETRANGE("Document Type", DocDim."Document Type"::"Store Return");

        //DocDim.SETRANGE("Document Type",DocType);
        // DocDim.SETRANGE("Document No.", DocNo);
        // DocDim.SETRANGE("Line No.", LineNo);
        // IF DocDim.FINDSET THEN
        //     REPEAT
        //         DocDimArchive.INIT;
        //         DocDimArchive.TRANSFERFIELDS(DocDim);
        //         DocDimArchive."Table ID" := NewTableID;
        //         DocDimArchive."Version No." := VersionNo;
        //         DocDimArchive."Doc. No. Occurrence" := DocNoOccurrence;
        //         DocDimArchive.INSERT;
        //     UNTIL DocDim.NEXT = 0;
    end;

    /// <summary>
    /// Description for PurchaseDocArchiveGranule.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure PurchaseDocArchiveGranule(): Boolean;
    var
        PurchaseHeaderArchive: Record "NFL Requisition Header Archive";
    begin
        EXIT(PurchaseHeaderArchive.WRITEPERMISSION);
    end;

    /// <summary>
    /// Description for StoreSalesDocumentComments.
    /// </summary>
    /// <param name="DocType">Parameter of type Option.</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="DocNoOccurrence">Parameter of type Integer.</param>
    /// <param name="VersionNo">Parameter of type Integer.</param>
    local procedure StoreSalesDocumentComments(DocType: Option; DocNo: Code[20]; DocNoOccurrence: Integer; VersionNo: Integer);
    var
        SalesCommentLine: Record "Sales Comment Line";
        SalesCommentLineArch: Record "Sales Comment Line Archive";
    begin
        SalesCommentLine.SETRANGE("Document Type", DocType);
        SalesCommentLine.SETRANGE("No.", DocNo);
        IF SalesCommentLine.FINDSET THEN
            REPEAT
                SalesCommentLineArch.INIT;
                SalesCommentLineArch.TRANSFERFIELDS(SalesCommentLine);
                SalesCommentLineArch."Doc. No. Occurrence" := DocNoOccurrence;
                SalesCommentLineArch."Version No." := VersionNo;
                SalesCommentLineArch.INSERT;
            UNTIL SalesCommentLine.NEXT = 0;
    end;

    /// <summary>
    /// Description for StorePurchDocumentComments.
    /// </summary>
    /// <param name="DocType">Parameter of type Option.</param>
    /// <param name="DocNo">Parameter of type Code[20].</param>
    /// <param name="DocNoOccurrence">Parameter of type Integer.</param>
    /// <param name="VersionNo">Parameter of type Integer.</param>
    local procedure StorePurchDocumentComments(DocType: Option; DocNo: Code[20]; DocNoOccurrence: Integer; VersionNo: Integer);
    var
        PurchCommentLine: Record "Purch. Comment Line";
        PurchCommentLineArch: Record "Purch. Comment Line Archive";
    begin
        //ERROR('%1',DocType);  IE
        IF DocType = 1 THEN
            PurchCommentLine.SETRANGE("Document Type", PurchCommentLine."Document Type"::"Return Order");

        IF DocType = 0 THEN
            PurchCommentLine.SETRANGE("Document Type", PurchCommentLine."Document Type"::Receipt);

        PurchCommentLine.SETRANGE("Document Type", DocType);
        PurchCommentLine.SETRANGE("No.", DocNo);
        IF PurchCommentLine.FINDSET THEN
            REPEAT
                PurchCommentLineArch.INIT;
                PurchCommentLineArch.TRANSFERFIELDS(PurchCommentLine);
                PurchCommentLineArch."Doc. No. Occurrence" := DocNoOccurrence;
                PurchCommentLineArch."Version No." := VersionNo;
                PurchCommentLineArch.INSERT;
            UNTIL PurchCommentLine.NEXT = 0;
    end;

    /// <summary>
    /// Description for ArchSalesDocumentNoConfirm.
    /// </summary>
    /// <param name="SalesHeader">Parameter of type Record "36".</param>
    procedure ArchSalesDocumentNoConfirm(var SalesHeader: Record "Sales Header");
    begin
        StoreSalesDocument(SalesHeader, FALSE);
    end;

    /// <summary>
    /// Description for ArchPurchDocumentNoConfirm.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "51407290".</param>
    procedure ArchPurchDocumentNoConfirm(var PurchHeader: Record "NFL Requisition Header");
    begin
        StorePurchDocument(PurchHeader, FALSE);
    end;

    /// <summary>
    /// Description for SalesEnquiryDocument.
    /// </summary>
    /// <param name="SalesENQHeader">Parameter of type Record "51407300".</param>
    // procedure SalesEnquiryDocument(var SalesENQHeader: Record "Sales Enquiry Header");
    // var
    //     SalesENQLine: Record "Sales Enquiry Lines";
    //     SalesHeaderArchive: Record "Sales Enquiry Header Arch.";
    //     SalesLineArchive: Record "Sales Enquiry Lines Arch.";
    // begin
    //     SalesHeaderArchive.INIT;
    //     SalesHeaderArchive.TRANSFERFIELDS(SalesENQHeader);
    //     SalesHeaderArchive."Archived By" := USERID;
    //     SalesHeaderArchive."Date Archived" := WORKDATE;
    //     SalesHeaderArchive."Time Archived" := TIME;
    //     SalesHeaderArchive."Doc. No. Occurrence" := 1;
    //     SalesHeaderArchive."Version No." := 1;
    //     SalesHeaderArchive.INSERT;

    //     SalesENQLine.SETRANGE("Document Type", SalesENQHeader."Document Type");
    //     SalesENQLine.SETRANGE("Sales Enquiry No.", SalesENQHeader.No);
    //     IF SalesENQLine.FINDSET THEN
    //         REPEAT
    //             WITH SalesLineArchive DO BEGIN
    //                 INIT;
    //                 TRANSFERFIELDS(SalesENQLine);
    //                 "Doc. No. Occurrence" := 1;
    //                 "Version No." := 1;
    //                 INSERT;
    //             END
    //         UNTIL SalesENQLine.NEXT = 0;
    // end;

    /// <summary>
    /// Description for ArchPurchDocumentNoConfirm2.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "51407290".</param>
    /// <param name="ArchiveFrom">Parameter of type Option " ",ltemJnl,PurchReq.</param>
    procedure ArchPurchDocumentNoConfirm2(var PurchHeader: Record "NFL Requisition Header"; ArchiveFrom: Option " ",ltemJnl,PurchReq);
    begin
        StoreReqArchiveType := ArchiveFrom;
        StorePurchDocument(PurchHeader, FALSE);
    end;

    /// <summary>
    /// Description for StorePurchDocument2.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "51407290".</param>
    /// <param name="InteractionExist">Parameter of type Boolean.</param>
    /// <param name="ArchiveFrom">Parameter of type Option " ",ltemJnl,PurchReq.</param>
    procedure StorePurchDocument2(var PurchHeader: Record "NFL Requisition Header"; InteractionExist: Boolean; ArchiveFrom: Option " ",ltemJnl,PurchReq);
    var
        PurchLine: Record "NFL Requisition Line";
        PurchHeaderArchive: Record "NFL Requisition Header Archive";
        PurchLineArchive: Record "NFL Requisition Line Archive";
        NFLSetup: Record "NFL Setup";
        NoSeriesMgt: Codeunit "NoSeriesManagement";
    begin
        StoreReqArchiveType := ArchiveFrom;
        StorePurchDocument(PurchHeader, InteractionExist);
    end;

    /// <summary>
    /// Description for StoreReturnDocument.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "51407290".</param>
    /// <param name="InteractionExist">Parameter of type Boolean.</param>
    /// <param name="ArchiveFrom">Parameter of type Option ltemJnl.</param>
    procedure StoreReturnDocument(var PurchHeader: Record "NFL Requisition Header"; InteractionExist: Boolean; ArchiveFrom: Option ltemJnl);
    var
        PurchLine: Record "NFL Requisition Line";
        PurchHeaderArchive: Record "NFL Requisition Header Archive";
        PurchLineArchive: Record "NFL Requisition Line Archive";
        NFLSetup: Record "NFL Setup";
        NoSeriesMgt: Codeunit "NoSeriesManagement";
    begin
        StoreReqArchiveType := ArchiveFrom;
        StorePurchDocument(PurchHeader, InteractionExist);
    end;
}

