/// <summary>
/// Codeunit Custom Functions And EVents (ID 50063).
/// </summary>
codeunit 50000 "Custom Functions And EVents"
{
    trigger OnRun()
    begin

    end;


    var
        Text0001: Label 'There is not enough space to insert extended text lines.';
        GLAcc: Record "G/L Account";
        Items: Record Item;
        Res: Record Resource;
        TmpExtTextLine: Record "Extended Text Line" temporary;
        NextLineNo: Integer;
        LineSpacing: Integer;
        MakeUpdateRequired: Boolean;
        AutoText: Boolean;

        Text000: Label 'Firm Planned %1';
        Text001: Label 'Released %1';
        Text003: Label 'CU99000845: CalculateRemainingQty - Source type missing';
        Text004: Label 'Codeunit 99000845: Illegal FieldFilter parameter';
        Text006: Label 'Outbound,Inbound';
        Text007: Label 'CU99000845 DeleteReservEntries2: Surplus order tracking double record detected.';
        CalcReservEntry: Record "Reservation Entry";
        CalcReservEntry2: Record "Reservation Entry";
        ForItemLedgEntry: Record "Item Ledger Entry";
        CalcItemLedgEntry: Record "Item Ledger Entry";
        ForSalesLine: Record "Sales Line";
        CalcSalesLine: Record "Sales Line";
        ForPurchLine: Record "Purchase Line";
        CalcPurchLine: Record "Purchase Line";
        ForItemJnlLine: Record "Item Journal Line";
        ForReqLine: Record "Requisition Line";
        CalcReqLine: Record "Requisition Line";
        ForProdOrderLine: Record "Prod. Order Line";
        CalcProdOrderLine: Record "Prod. Order Line";
        ForProdOrderComp: Record "Prod. Order Component";
        CalcProdOrderComp: Record "Prod. Order Component";
        ForPlanningComponent: Record "Planning Component";
        CalcPlanningComponent: Record "Planning Component";
        ForAssemblyHeader: Record "Assembly Header";
        CalcAssemblyHeader: Record "Assembly Header";
        ForAssemblyLine: Record "Assembly Line";
        CalcAssemblyLine: Record "Assembly Line";
        ForTransLine: Record "Transfer Line";
        CalcTransLine: Record "Transfer Line";
        ForServiceLine: Record "Service Line";
        CalcServiceLine: Record "Service Line";
        ForJobPlanningLine: Record "Job Planning Line";
        CalcJobPlanningLine: Record "Job Planning Line";
        ActionMessageEntry: Record "Action Message Entry";
        Item: Record "Item";
        Location: Record "Location";
        MfgSetup: Record "Manufacturing Setup";
        SKU: Record "Stockkeeping Unit";
        ItemTrackingCode: Record "Item Tracking Code";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        CallTrackingSpecification: Record "Tracking Specification";
        ForJobJnlLine: Record "Job Journal Line";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
        ReserveSalesLine: Codeunit "Sales Line-Reserve";
        ReserveReqLine: Codeunit "Req. Line-Reserve";
        ReservePurchLine: Codeunit "Purch. Line-Reserve";
        ReserveItemJnlLine: Codeunit "Item Jnl. Line-Reserve";
        ReserveProdOrderLine: Codeunit "Prod. Order Line-Reserve";
        ReserveProdOrderComp: Codeunit "Prod. Order Comp.-Reserve";
        AssemblyHeaderReserve: Codeunit "Assembly Header-Reserve";
        AssemblyLineReserve: Codeunit "Assembly Line-Reserve";
        ReservePlanningComponent: Codeunit "Plng. Component-Reserve";
        ReserveServiceInvLine: Codeunit "Service Line-Reserve";
        ReserveTransLine: Codeunit "Transfer Line-Reserve";
        JobPlanningLineReserve: Codeunit "Job Planning Line-Reserve";
        GetPlanningParameters: Codeunit "Planning-Get Parameters";
        CreatePick: Codeunit "Create Pick";
        Positive: Boolean;
        CurrentBindingIsSet: Boolean;
        HandleItemTracking: Boolean;
        InvSearch: Text[1];
        FieldFilter: Text[80];
        InvNextStep: Integer;
        ValueArray: array[18] of Integer;
        CurrentBinding: Option "Order-to-Order";
        ItemTrackingHandling: Option "None","Allow deletion",Match;
        Text008: Label 'Item tracking defined for item %1 in the %2 accounts for more than the quantity you have entered.\You must adjust the existing item tracking and then reenter the new quantity.';
        Text009: Label 'Item Tracking cannot be fully matched.\Serial No.: %1, Lot No.: %2, outstanding quantity: %3.';
        Text010: Label 'Item tracking is defined for item %1 in the %2.\You must delete the existing item tracking before modifying or deleting the %2.';
        TotalAvailQty: Decimal;
        QtyAllocInWhse: Decimal;
        QtyOnOutBound: Decimal;
        Text011: Label 'Item tracking is defined for item %1 in the %2.\Do you want to delete the %2 and the item tracking lines?';
        QtyReservedOnPickShip: Decimal;
        Text012: Label 'Assembly';
        "==CMM==": Integer;
        ForNFLReqLine: Record "NFL Requisition Line";
    // ReserveNFLReqLine: Codeunit "Req-Line Reserve2";

    /// <summary>
    /// EditDimensionSet2.
    /// </summary>
    /// <param name="DimSetID">Integer.</param>
    /// <param name="NewCaption">Text[250].</param>
    /// <param name="VAR GlobalDimVal1">Code[20].</param>
    /// <param name="VAR GlobalDimVal2">Code[20].</param>
    /// <returns>Return value of type Integer.</returns>
    procedure EditDimensionSet2(DimSetID: Integer; NewCaption: Text[250]; VAR GlobalDimVal1: Code[20]; VAR GlobalDimVal2: Code[20]): Integer
    var
        EditDimSetEntries: Page "Edit Dimension Set Entries";
        NewDimSetID: Integer;
        DimSetEntry: Record "Dimension Set Entry";
        dimensionMgt: Codeunit DimensionManagement;
    begin
        NewDimSetID := DimSetID;
        DimSetEntry.RESET;
        DimSetEntry.FILTERGROUP(2);
        DimSetEntry.SETRANGE("Dimension Set ID", DimSetID);
        DimSetEntry.FILTERGROUP(0);
        EditDimSetEntries.SETTABLEVIEW(DimSetEntry);
        EditDimSetEntries.SetFormCaption(NewCaption);
        EditDimSetEntries.RUNMODAL;
        NewDimSetID := EditDimSetEntries.GetDimensionID;
        dimensionMgt.UpdateGlobalDimFromDimSetID(NewDimSetID, GlobalDimVal1, GlobalDimVal2);
        DimSetEntry.RESET;
        EXIT(NewDimSetID);
    end;


    //=========================Document Totals============================
    /// <summary>
    /// PaymentDetailsUpdateTotalsControls.
    /// </summary>
    /// <param name="CurrentPurchaseLine">Record "Payment Voucher Detail".</param>
    /// <param name="TotalPurchaseHeader">Record "Payment Voucher Header".</param>
    /// <param name="TotalsPurchaseLine">Record "Payment Voucher Detail".</param>
    /// <param name="RefreshMessageEnabled">Boolean.</param>
    /// <param name="ControlStyle">Text.</param>
    /// <param name="RefreshMessageText">Text.</param>
    /// <param name="InvDiscAmountEditable">Boolean.</param>
    /// <param name="VATAmount">Decimal.</param>
    procedure PaymentDetailsUpdateTotalsControls(CurrentPurchaseLine: Record "Payment Voucher Detail"; TotalPurchaseHeader: Record "Payment Voucher Header"; TotalsPurchaseLine: Record "Payment Voucher Detail"; RefreshMessageEnabled: Boolean; ControlStyle: Text; RefreshMessageText: Text; InvDiscAmountEditable: Boolean; VATAmount: Decimal)
    var
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
        DocumentTotals: Codeunit "Document Totals";
    begin

        IF CurrentPurchaseLine."Document No." = '' THEN
            EXIT;

        TotalPurchaseHeader.GET(CurrentPurchaseLine."Document No.", CurrentPurchaseLine."Document Type");
        RefreshMessageEnabled := FALSE;// PurchCalcDiscByType.ShouldRedistributeInvoiceDiscountAmount(TotalPurchaseHeader);

        IF NOT RefreshMessageEnabled THEN
            RefreshMessageEnabled := NOT PaymentUpdateTotals(TotalPurchaseHeader, CurrentPurchaseLine, TotalsPurchaseLine, VATAmount);

        // InvDiscAmountEditable := PurchCalcDiscByType.InvoiceDiscIsAllowed(TotalPurchaseHeader."Invoice Disc. Code") AND
        // (NOT RefreshMessageEnabled);
        TotalControlsUpdateStyle(RefreshMessageEnabled, ControlStyle, RefreshMessageText);

        IF RefreshMessageEnabled THEN BEGIN
            TotalsPurchaseLine.Amount := 0;
            VATAmount := 0;
        END;
    end;

    local procedure PaymentUpdateTotals(VAR PurchaseHeader: Record "Payment Voucher Header"; CurrentPurchaseLine: Record "Payment Voucher Detail"; VAR TotalsPurchaseLine: Record "Payment Voucher Detail"; VAR VATAmount: Decimal): Boolean
    var
        PreviousTotalPurchaseHeader: Record "Purchase Header";
    begin

        PurchaseHeader.CALCFIELDS(PurchaseHeader."Payment Voucher Details Total");

        IF PreviousTotalPurchaseHeader.Amount = PurchaseHeader."Payment Voucher Details Total"
        THEN
            EXIT(TRUE);

        IF NOT PaymentVoucherCheckNumberOfLinesLimit(PurchaseHeader) THEN
            EXIT(FALSE);
    end;

    /// <summary>
    /// PaymentVoucherCheckNumberOfLinesLimit.
    /// </summary>
    /// <param name="PurchaseHeader">Record "Payment Voucher Header".</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure PaymentVoucherCheckNumberOfLinesLimit(PurchaseHeader: Record "Payment Voucher Header"): Boolean
    var
        PurchaseLine: Record "Payment Voucher Detail";
    begin
        PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
        PurchaseLine.SETRANGE("Document Type", PurchaseHeader."Document Type");

        EXIT(PurchaseLine.COUNT <= 100);
    end;

    /// <summary>
    /// TotalControlsUpdateStyle.
    /// </summary>
    /// <param name="RefreshMessageEnabled">Boolean.</param>
    /// <param name="VAR ControlStyle">Text.</param>
    /// <param name="VAR RefreshMessageText">Text.</param>
    procedure TotalControlsUpdateStyle(RefreshMessageEnabled: Boolean; VAR ControlStyle: Text; VAR RefreshMessageText: Text)
    var
        RefreshMsgTxt: TextConst ENU = 'Totals or discounts may not be up-to-date. Choose the link to update.';
    begin
        IF RefreshMessageEnabled THEN BEGIN
            ControlStyle := 'Subordinate';
            RefreshMessageText := RefreshMsgTxt;
        END ELSE BEGIN
            ControlStyle := 'Strong';
            RefreshMessageText := '';
        END;
    end;
    //==========================End Document Totals=======================


    /// <summary>
    /// CreateBookAndOpenExcel.
    /// </summary>
    /// <param name="SheetName">Text[250].</param>
    /// <param name="ReportHeader">Text[80].</param>
    /// <param name="CompanyName">Text[30].</param>
    /// <param name="UserID2">Text.</param>
    procedure CreateBookAndOpenExcel(SheetName: Text[250]; ReportHeader: Text[80]; CompanyName: Text[30]; UserID2: Text)
    var
        ExcelBuffer: Record "Excel Buffer";
    begin
        // LF  ExcelBuffer.CreateBook('', SheetName);
        ExcelBuffer.WriteSheet(ReportHeader, CompanyName, UserID2);
        ExcelBuffer.CloseBook;
        ExcelBuffer.OpenExcel;
        // ExcelBuffer.GiveUserControl;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchInvLineInsert', '', true, true)]
    local procedure OnBeforePurchInvLineInsert(var PurchInvLine: Record "Purch. Inv. Line"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchaseLine: Record "Purchase Line"; CommitIsSupressed: Boolean)
    var
        gvCommitmentEntry: Record "Commitment Entry";
        lastCommitmentEntry: Record "Commitment Entry";
        reversedCommitmentEntry: Record "Commitment Entry";
        GLAccount: Record "G/L Account";
    begin
        PurchInvLine."Control Account" := PurchaseLine."Control Account";
        PurchInvLine."Commitment Entry No." := PurchaseLine."Commitment Entry No.";

        //Reverse commitment on posting the invoice.
        gvCommitmentEntry.SETRANGE(gvCommitmentEntry."Entry No.", PurchaseLine."Commitment Entry No.");
        IF gvCommitmentEntry.FIND('-') THEN BEGIN
            IF NOT lastCommitmentEntry.FINDLAST THEN
                lastCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No." + 1
            ELSE
                lastCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No." + 1;

            reversedCommitmentEntry.INIT;
            reversedCommitmentEntry := lastCommitmentEntry;
            reversedCommitmentEntry."Entry No." := lastCommitmentEntry."Entry No.";
            reversedCommitmentEntry."G/L Account No." := gvCommitmentEntry."G/L Account No.";
            reversedCommitmentEntry."Posting Date" := gvCommitmentEntry."Posting Date";
            reversedCommitmentEntry."Document No." := gvCommitmentEntry."Document No.";
            reversedCommitmentEntry.Description := gvCommitmentEntry.Description;
            reversedCommitmentEntry."External Document No." := gvCommitmentEntry."External Document No.";
            reversedCommitmentEntry."Global Dimension 1 Code" := gvCommitmentEntry."Global Dimension 1 Code";
            reversedCommitmentEntry."Global Dimension 2 Code" := gvCommitmentEntry."Global Dimension 2 Code";
            reversedCommitmentEntry."Dimension Set ID" := gvCommitmentEntry."Dimension Set ID";
            reversedCommitmentEntry.Quantity := -1 * gvCommitmentEntry.Quantity;
            reversedCommitmentEntry.Amount := -1 * gvCommitmentEntry.Amount;
            reversedCommitmentEntry."Debit Amount" := -1 * gvCommitmentEntry."Debit Amount";
            reversedCommitmentEntry."Credit Amount" := -1 * gvCommitmentEntry."Credit Amount";
            reversedCommitmentEntry."Additional-Currency Amount" := -1 * gvCommitmentEntry."Additional-Currency Amount";
            reversedCommitmentEntry."Add.-Currency Debit Amount" := -1 * gvCommitmentEntry."Add.-Currency Debit Amount";
            reversedCommitmentEntry."Add.-Currency Credit Amount" := -1 * gvCommitmentEntry."Add.-Currency Credit Amount";
            reversedCommitmentEntry.Reversed := TRUE;
            reversedCommitmentEntry."Reversed Entry No." := gvCommitmentEntry."Entry No.";
            reversedCommitmentEntry."User ID" := USERID;
            reversedCommitmentEntry."Source Code" := 'Invoice';
            reversedCommitmentEntry.INSERT;
            gvCommitmentEntry.Reversed := TRUE;
            gvCommitmentEntry."Reversed by Entry No." := reversedCommitmentEntry."Entry No.";
            gvCommitmentEntry.MODIFY;
        END;
        //END
    end;

    //Solving the Qty to order issues

    /// <summary>
    /// TransferQty.
    /// </summary>
    procedure TransferQty()
    var
        PurchaseRequisitionLines: Record "NFL Requisition Line";
    begin
        PurchaseRequisitionLines.Reset();
        PurchaseRequisitionLines.SetRange(PurchaseRequisitionLines.Finished, false);
        if PurchaseRequisitionLines.FindFirst() then
            repeat
                PurchaseRequisitionLines."Save Qty. to Order" := PurchaseRequisitionLines.Quantity;
                PurchaseRequisitionLines.Modify();
            until PurchaseRequisitionLines.Next() = 0;
    end;

    /// <summary>
    /// FillinQtyToOrder.
    /// </summary>
    procedure FillinQtyToOrder()
    var
        PurchaseRequisitionLines: Record "NFL Requisition Line";
    begin
        PurchaseRequisitionLines.Reset();
        PurchaseRequisitionLines.SetRange(PurchaseRequisitionLines.Finished, false);
        if PurchaseRequisitionLines.FindFirst() then
            repeat
                PurchaseRequisitionLines."Qty. to Order" := PurchaseRequisitionLines."Save Qty. to Order";
                PurchaseRequisitionLines.Modify();
            until PurchaseRequisitionLines.Next() = 0;
    end;


    /// <summary>
    /// Description for PurchCheckIfAnyExtText.
    /// </summary>
    /// <param name="PurchLine">Parameter of type Record "51407291".</param>
    /// <param name="Unconditionally">Parameter of type Boolean.</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure PurchCheckIfAnyExtText(var PurchLine: Record "NFL Requisition Line"; Unconditionally: Boolean): Boolean;
    var
        PurchHeader: Record "NFL Requisition Header";
        ExtTextHeader: Record "Extended Text Header";
    begin
        MakeUpdateRequired := FALSE;
        IF PurchLine."Line No." <> 0 THEN
            MakeUpdateRequired := DeletePurchLines(PurchLine);

        AutoText := FALSE;

        IF Unconditionally THEN
            AutoText := TRUE
        ELSE
            CASE PurchLine.Type OF
                PurchLine.Type::" ":
                    AutoText := TRUE;
                PurchLine.Type::"G/L Account":
                    BEGIN
                        IF GLAcc.GET(PurchLine."No.") THEN
                            AutoText := GLAcc."Automatic Ext. Texts";
                    END;
                PurchLine.Type::Item:
                    BEGIN
                        IF Items.GET(PurchLine."No.") THEN
                            AutoText := Items."Automatic Ext. Texts";
                    END;
            END;

        IF AutoText THEN BEGIN
            PurchLine.TESTFIELD("Document No.");
            PurchHeader.GET(PurchLine."Document Type", PurchLine."Document No.");
            ExtTextHeader.SETRANGE("Table Name", PurchLine.Type);
            ExtTextHeader.SETRANGE("No.", PurchLine."No.");
            CASE PurchLine."Document Type" OF
                PurchLine."Document Type"::"Store Requisition":
                    ExtTextHeader.SETRANGE("Purchase Quote", TRUE);
                PurchLine."Document Type"::"Purchase Requisition":
                    ExtTextHeader.SETRANGE("Purchase Quote", TRUE);
            END;
            EXIT(ReadLines(ExtTextHeader, PurchHeader."Document Date", PurchHeader."Language Code"));
        END;
    end;

    /// <summary>
    /// Description for InsertPurchExtText.
    /// </summary>
    /// <param name="PurchLine">Parameter of type Record "51407291".</param>
    procedure InsertPurchExtText(var PurchLine: Record "NFL Requisition Line");
    var
        ToPurchLine: Record "NFL Requisition Line";
    begin
        ToPurchLine.RESET;
        ToPurchLine.SETRANGE("Document Type", PurchLine."Document Type");
        ToPurchLine.SETRANGE("Document No.", PurchLine."Document No.");
        ToPurchLine := PurchLine;
        IF ToPurchLine.FIND('>') THEN BEGIN
            LineSpacing :=
              (ToPurchLine."Line No." - PurchLine."Line No.") DIV
              (1 + TmpExtTextLine.COUNT);
            IF LineSpacing = 0 THEN
                ERROR(Text0001);
        END ELSE
            LineSpacing := 10000;

        NextLineNo := PurchLine."Line No." + LineSpacing;

        TmpExtTextLine.RESET;
        IF TmpExtTextLine.FIND('-') THEN BEGIN
            REPEAT
                ToPurchLine.INIT;
                ToPurchLine."Document Type" := PurchLine."Document Type";
                ToPurchLine."Document No." := PurchLine."Document No.";
                ToPurchLine."Line No." := NextLineNo;
                NextLineNo := NextLineNo + LineSpacing;
                ToPurchLine.Description := TmpExtTextLine.Text;
                ToPurchLine."Attached to Line No." := PurchLine."Line No.";
                ToPurchLine.INSERT;
            UNTIL TmpExtTextLine.NEXT = 0;
            MakeUpdateRequired := TRUE;
        END;
        TmpExtTextLine.DELETEALL;
    end;

    /// <summary>
    /// Description for DeletePurchLines.
    /// </summary>
    /// <param name="PurchLine">Parameter of type Record "51407291".</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure DeletePurchLines(var PurchLine: Record "NFL Requisition Line"): Boolean;
    var
        PurchLine2: Record "NFL Requisition Line";
    begin
        PurchLine2.SETRANGE("Document Type", PurchLine."Document Type");
        PurchLine2.SETRANGE("Document No.", PurchLine."Document No.");
        PurchLine2.SETRANGE("Attached to Line No.", PurchLine."Line No.");
        PurchLine2 := PurchLine;
        IF PurchLine2.FIND('>') THEN BEGIN
            REPEAT
                PurchLine2.DELETE(TRUE);
            UNTIL PurchLine2.NEXT = 0;
            EXIT(TRUE);
        END;
    end;

    /// <summary>
    /// Description for MakeUpdate.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure MakeUpdate(): Boolean;
    begin
        EXIT(MakeUpdateRequired);
    end;

    /// <summary>
    /// Description for ReadLines.
    /// </summary>
    /// <param name="ExtTextHeader">Parameter of type Record "279".</param>
    /// <param name="DocDate">Parameter of type Date.</param>
    /// <param name="LanguageCode">Parameter of type Code[10].</param>
    /// <returns>Return variable "Boolean".</returns>
    local procedure ReadLines(var ExtTextHeader: Record "Extended Text Header"; DocDate: Date; LanguageCode: Code[10]): Boolean;
    var
        ExtTextLine: Record "Extended Text Line";
    begin
        ExtTextHeader.SETCURRENTKEY(
          "Table Name", "No.", "Language Code", "All Language Codes", "Starting Date", "Ending Date");
        ExtTextHeader.SETRANGE("Starting Date", 0D, DocDate);
        ExtTextHeader.SETFILTER("Ending Date", '%1..|%2', DocDate, 0D);
        IF LanguageCode = '' THEN BEGIN
            ExtTextHeader.SETRANGE("Language Code", '');
            IF NOT ExtTextHeader.FIND('+') THEN
                EXIT;
        END ELSE BEGIN
            ExtTextHeader.SETRANGE("Language Code", LanguageCode);
            IF NOT ExtTextHeader.FIND('+') THEN BEGIN
                ExtTextHeader.SETRANGE("All Language Codes", TRUE);
                ExtTextHeader.SETRANGE("Language Code", '');
                IF NOT ExtTextHeader.FIND('+') THEN
                    EXIT;
            END;
        END;

        ExtTextLine.SETRANGE("Table Name", ExtTextHeader."Table Name");
        ExtTextLine.SETRANGE("No.", ExtTextHeader."No.");
        ExtTextLine.SETRANGE("Language Code", ExtTextHeader."Language Code");
        ExtTextLine.SETRANGE("Text No.", ExtTextHeader."Text No.");
        IF ExtTextLine.FIND('-') THEN BEGIN
            TmpExtTextLine.DELETEALL;
            REPEAT
                TmpExtTextLine := ExtTextLine;
                TmpExtTextLine.INSERT;
            UNTIL ExtTextLine.NEXT = 0;
            EXIT(TRUE);
        END;
    end;

    /// <summary>
    /// Description for SetRequisitionLine.
    /// </summary>
    /// <param name="NewReqLine">Parameter of type Record "NFL Requisition Line".</param>
    procedure SetRequisitionLine(NewReqLine: Record "NFL Requisition Line")
    var
        CalcReservEntry: Record "Reservation Entry";
        CalcReservEntry2: Record "Reservation Entry";
        ForItemLedgEntry: Record "Item Ledger Entry";
        CalcItemLedgEntry: Record "Item Ledger Entry";
        ForSalesLine: Record "Sales Line";
        CalcSalesLine: Record "Sales Line";
        ForPurchLine: Record "Purchase Line";
        CalcPurchLine: Record "Purchase Line";
        ForItemJnlLine: Record "Item Journal Line";
        ForReqLine: Record "Requisition Line";
        CalcReqLine: Record "Requisition Line";
        ForProdOrderLine: Record "Prod. Order Line";
        CalcProdOrderLine: Record "Prod. Order Line";
        ForProdOrderComp: Record "Prod. Order Component";
        CalcProdOrderComp: Record "Prod. Order Component";
        ForPlanningComponent: Record "Planning Component";
        CalcPlanningComponent: Record "Planning Component";
        ForAssemblyHeader: Record "Assembly Header";
        CalcAssemblyHeader: Record "Assembly Header";
        ForAssemblyLine: Record "Assembly Line";
        CalcAssemblyLine: Record "Assembly Line";
        ForTransLine: Record "Transfer Line";
        CalcTransLine: Record "Transfer Line";
        ForServiceLine: Record "Service Line";
        CalcServiceLine: Record "Service Line";
        ForJobPlanningLine: Record "Job Planning Line";
        CalcJobPlanningLine: Record "Job Planning Line";
        ActionMessageEntry: Record "Action Message Entry";
        ForNFLReqLine: Record "NFL Requisition Line";
        // ReserveNFLReqLine: Codeunit "Req-Line Reserve2";
        Location: Record Location;
        TempTrackingSpecification: Record "Tracking Specification";
        ReservationManagement: Codeunit "Reservation Management";
    begin

        //cmm 130809 added for setting up line for NFL req line IE
        CLEARALL;
        TempTrackingSpecification.DELETEALL;

        ForNFLReqLine := NewReqLine;

        //CalcReservEntry."Source Type" := DATABASE::Table 51406291; IE
        CalcReservEntry."Source Subtype" := ForNFLReqLine."Document Type";
        CalcReservEntry."Source ID" := NewReqLine."Document No.";
        CalcReservEntry."Source Ref. No." := NewReqLine."Line No.";

        IF NewReqLine.Type = NewReqLine.Type::Item THEN
            CalcReservEntry."Item No." := NewReqLine."No.";
        CalcReservEntry."Variant Code" := NewReqLine."Variant Code";
        CalcReservEntry."Location Code" := NewReqLine."Location Code";
        CalcReservEntry."Serial No." := '';
        CalcReservEntry."Lot No." := '';
        CalcReservEntry."Qty. per Unit of Measure" := NewReqLine."Qty. per Unit of Measure";
        CalcReservEntry."Expected Receipt Date" := NewReqLine."Planned Receipt Date";
        CalcReservEntry."Shipment Date" := NewReqLine."Planned Receipt Date";
        CalcReservEntry.Description := NewReqLine.Description;
        CalcReservEntry2 := CalcReservEntry;
        IF (CalcReservEntry."Location Code" <> '') AND
           Location.GET(CalcReservEntry."Location Code") AND
           (Location."Bin Mandatory" OR Location."Require Pick")
        THEN
            ;
        //ReservationManagement.CalcReservedQtyOnPick(TotalAvailQty, QtyAllocInWhse); IE
    end;
}