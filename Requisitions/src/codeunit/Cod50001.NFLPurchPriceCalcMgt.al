/// <summary>
/// Codeunit NFL Purch. Price Calc. Mgt. (ID 50001).
/// </summary>
codeunit 50001 "NFL Purch. Price Calc. Mgt."
{
    trigger OnRun();
    begin
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        Vend: Record Vendor;
        ResCost: Record "Resource Cost";
        Currency: Record Currency;
        TempPurchPrice: Record "Purchase Price" temporary;
        TempPurchLineDisc: Record "Purchase Line Discount" temporary;
        ResFindUnitCost: Codeunit "Resource-Find Cost";
        LineDiscPerCent: Decimal;
        Qty: Decimal;
        QtyPerUOM: Decimal;
        VATPerCent: Decimal;
        PricesInclVAT: Boolean;
        VATBusPostingGr: Code[10];
        PricesInCurrency: Boolean;
        PriceInSKU: Boolean;
        CurrencyFactor: Decimal;
        ExchRateDate: Date;
        FoundPurchPrice: Boolean;
        DateCaption: Text[30];
        Text000: Label '%1 is less than %2 in the %3.';
        Text010: Label 'Cost including VAT cannot be calculated when %1 is %2.';
        Text018: Label '%1 %2 is greater than %3 and was adjusted to %4.';
        Text001: Label 'The %1 in the %2 must be same as in the %3.';

    /// <summary>
    /// Description for FindPurchLinePrice.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "51407290".</param>
    /// <param name="PurchLine">Parameter of type Record "51407291".</param>
    /// <param name="CalledByFieldNo">Parameter of type Integer.</param>
    procedure FindPurchLinePrice(PurchHeader: Record "NFL Requisition Header"; var PurchLine: Record "NFL Requisition Line"; CalledByFieldNo: Integer);
    begin
        WITH PurchLine DO BEGIN
            SetCurrency(
              PurchHeader."Currency Code", PurchHeader."Currency Factor", PurchHeaderExchDate(PurchHeader));
            SetVAT(PurchHeader."Prices Including VAT", "VAT %", "VAT Bus. Posting Group");
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");
            SetLineDisc("Line Discount %");

            TESTFIELD("Qty. per Unit of Measure");
            IF PricesInCurrency THEN
                PurchHeader.TESTFIELD("Currency Factor");

            CASE Type OF
                Type::Item:
                    BEGIN
                        Item.GET("No.");
                        //Vend.GET("Buy-from Vendor No.");
                        PriceInSKU := SKU.GET("Location Code", "No.", "Variant Code");

                        PurchLinePriceExists(PurchHeader, PurchLine, FALSE);
                        CalcBestDirectUnitCost(TempPurchPrice);

                        IF FoundPurchPrice OR
                           NOT ((CalledByFieldNo = FIELDNO(Quantity)) OR
                                (((CalledByFieldNo = FIELDNO("Variant Code")) AND NOT PriceInSKU)))
                        THEN
                            "Direct Unit Cost" := TempPurchPrice."Direct Unit Cost";
                    END;
            END;
        END;
    end;

    /// <summary>
    /// Description for FindItemJnlLinePrice.
    /// </summary>
    /// <param name="ItemJnlLine">Parameter of type Record "Item Journal Line".</param>
    /// <param name="CalledByFieldNo">Parameter of type Integer.</param>
    procedure FindItemJnlLinePrice(var ItemJnlLine: Record "Item Journal Line"; CalledByFieldNo: Integer);
    begin
        WITH ItemJnlLine DO BEGIN
            TESTFIELD("Qty. per Unit of Measure");
            SetCurrency('', 0, 0D);
            SetVAT(FALSE, 0, '');
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

            Item.GET("Item No.");
            PriceInSKU := SKU.GET("Location Code", "Item No.", "Variant Code");

            FindPurchPrice(
              TempPurchPrice, '', "Item No.", "Variant Code",
              "Unit of Measure Code", '', "Posting Date", FALSE);
            CalcBestDirectUnitCost(TempPurchPrice);

            IF FoundPurchPrice OR
               NOT ((CalledByFieldNo = FIELDNO(Quantity)) OR
                    (((CalledByFieldNo = FIELDNO("Variant Code")) AND NOT PriceInSKU)))
            THEN
                "Unit Amount" := TempPurchPrice."Direct Unit Cost";
        END;
    end;

    procedure FindReqLinePrice(var ReqLine: Record "Requisition Line"; CalledByFieldNo: Integer);
    begin
        WITH ReqLine DO BEGIN
            IF Type = Type::Item THEN BEGIN
                IF NOT Vend.GET("Vendor No.") THEN
                    Vend.INIT;

                SetCurrency("Currency Code", "Currency Factor", "Order Date");
                SetVAT(Vend."Prices Including VAT", 0, '');
                SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

                TESTFIELD("Qty. per Unit of Measure");
                IF PricesInCurrency THEN
                    ReqLine.TESTFIELD("Currency Factor");

                Item.GET("No.");
                PriceInSKU := SKU.GET("Location Code", "No.", "Variant Code");

                FindPurchPrice(
                  TempPurchPrice, "Vendor No.", "No.", "Variant Code",
                  "Unit of Measure Code", "Currency Code", "Order Date", FALSE);
                CalcBestDirectUnitCost(TempPurchPrice);

                IF FoundPurchPrice OR
                   NOT ((CalledByFieldNo = FIELDNO(Quantity)) OR
                        (((CalledByFieldNo = FIELDNO("Variant Code")) AND NOT PriceInSKU)))
                THEN
                    "Direct Unit Cost" := TempPurchPrice."Direct Unit Cost";
            END;
        END;
    end;

    procedure FindPurchLineLineDisc(PurchHeader: Record "NFL Requisition Header"; var PurchLine: Record "NFL Requisition Line");
    begin
        WITH PurchLine DO BEGIN
            SetCurrency(PurchHeader."Currency Code", 0, 0D);
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

            TESTFIELD("Qty. per Unit of Measure");

            IF PurchLine.Type = Type::Item THEN BEGIN
                PurchLineLineDiscExists(PurchHeader, PurchLine, FALSE);
                CalcBestLineDisc(TempPurchLineDisc);

                "Line Discount %" := TempPurchLineDisc."Line Discount %";
            END;
        END;
    end;

    /// <summary>
    /// Description for FindStdItemJnlLinePrice.
    /// </summary>
    /// <param name="StdItemJnlLine">Parameter of type Record "Standard Item Journal Line".</param>
    /// <param name="CalledByFieldNo">Parameter of type Integer.</param>
    procedure FindStdItemJnlLinePrice(var StdItemJnlLine: Record "Standard Item Journal Line"; CalledByFieldNo: Integer);
    begin
        WITH StdItemJnlLine DO BEGIN
            TESTFIELD("Qty. per Unit of Measure");
            SetCurrency('', 0, 0D);
            SetVAT(FALSE, 0, '');
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

            Item.GET("Item No.");
            PriceInSKU := SKU.GET("Location Code", "Item No.", "Variant Code");

            FindPurchPrice(
              TempPurchPrice, '', "Item No.", "Variant Code",
              "Unit of Measure Code", '', WORKDATE, FALSE);
            CalcBestDirectUnitCost(TempPurchPrice);

            IF FoundPurchPrice OR
               NOT ((CalledByFieldNo = FIELDNO(Quantity)) OR
                    (((CalledByFieldNo = FIELDNO("Variant Code")) AND NOT PriceInSKU)))
            THEN
                "Unit Amount" := TempPurchPrice."Direct Unit Cost";
        END;
    end;

    /// <summary>
    /// Description for FindReqLineDisc.
    /// </summary>
    /// <param name="ReqLine">Parameter of type Record "Requisition Line".</param>
    procedure FindReqLineDisc(var ReqLine: Record "Requisition Line");
    begin
        WITH ReqLine DO BEGIN
            SetCurrency("Currency Code", 0, 0D);
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

            TESTFIELD("Qty. per Unit of Measure");

            IF ReqLine.Type = Type::Item THEN BEGIN

                FindPurchLineDisc(
                  TempPurchLineDisc, "Vendor No.", "No.", "Variant Code",
                  "Unit of Measure Code", "Currency Code", "Order Date", FALSE);
                CalcBestLineDisc(TempPurchLineDisc);

                "Line Discount %" := TempPurchLineDisc."Line Discount %";
            END;
        END;
    end;

    /// <summary>
    /// Description for CalcBestDirectUnitCost.
    /// </summary>
    /// <param name="PurchPrice">Parameter of type Record "7012".</param>
    local procedure CalcBestDirectUnitCost(var PurchPrice: Record "Purchase Price");
    var
        BestPurchPrice: Record "Purchase Price";
    begin
        WITH PurchPrice DO BEGIN
            FoundPurchPrice := PurchPrice.FIND('-');
            IF FoundPurchPrice THEN
                REPEAT
                    IF IsInMinQty("Unit of Measure Code", "Minimum Quantity") THEN BEGIN
                        ConvertPriceToVAT(
                          Vend."Prices Including VAT", Item."VAT Prod. Posting Group",
                          Vend."VAT Bus. Posting Group", "Direct Unit Cost");
                        ConvertPriceToUoM("Unit of Measure Code", "Direct Unit Cost");
                        ConvertPriceLCYToFCY("Currency Code", "Direct Unit Cost");

                        CASE TRUE OF
                            ((BestPurchPrice."Currency Code" = '') AND ("Currency Code" <> '')) OR
                          ((BestPurchPrice."Variant Code" = '') AND ("Variant Code" <> '')):
                                BestPurchPrice := PurchPrice;
                            ((BestPurchPrice."Currency Code" = '') OR ("Currency Code" <> '')) AND
                          ((BestPurchPrice."Variant Code" = '') OR ("Variant Code" <> '')):
                                IF (BestPurchPrice."Direct Unit Cost" = 0) OR
                                   (CalcLineAmount(BestPurchPrice) > CalcLineAmount(PurchPrice))
                                THEN
                                    BestPurchPrice := PurchPrice;
                        END;
                    END;
                UNTIL NEXT = 0;
        END;

        // No price found in agreement
        IF BestPurchPrice."Direct Unit Cost" = 0 THEN BEGIN
            PriceInSKU := PriceInSKU AND (SKU."Last Direct Cost" <> 0);
            IF PriceInSKU THEN
                BestPurchPrice."Direct Unit Cost" := SKU."Last Direct Cost"
            ELSE
                BestPurchPrice."Direct Unit Cost" := Item."Last Direct Cost";

            ConvertPriceToVAT(FALSE, Item."VAT Prod. Posting Group", '', BestPurchPrice."Direct Unit Cost");
            ConvertPriceToUoM('', BestPurchPrice."Direct Unit Cost");
            ConvertPriceLCYToFCY('', BestPurchPrice."Direct Unit Cost");
        END;

        PurchPrice := BestPurchPrice;
    end;

    local procedure CalcBestLineDisc(var PurchLineDisc: Record "Purchase Line Discount");
    var
        BestPurchLineDisc: Record "Purchase Line Discount";
    begin
        WITH PurchLineDisc DO
            IF FIND('-') THEN
                REPEAT
                    IF IsInMinQty("Unit of Measure Code", "Minimum Quantity") THEN
                        CASE TRUE OF
                            ((BestPurchLineDisc."Currency Code" = '') AND ("Currency Code" <> '')) OR
                          ((BestPurchLineDisc."Variant Code" = '') AND ("Variant Code" <> '')):
                                BestPurchLineDisc := PurchLineDisc;
                            ((BestPurchLineDisc."Currency Code" = '') OR ("Currency Code" <> '')) AND
                          ((BestPurchLineDisc."Variant Code" = '') OR ("Variant Code" <> '')):
                                IF BestPurchLineDisc."Line Discount %" < "Line Discount %" THEN
                                    BestPurchLineDisc := PurchLineDisc;
                        END;
                UNTIL NEXT = 0;

        PurchLineDisc := BestPurchLineDisc;
    end;

    /// <summary>
    /// Description for FindPurchPrice.
    /// </summary>
    /// <param name="ToPurchPrice">Parameter of type Record "7012".</param>
    /// <param name="VendorNo">Parameter of type Code[20].</param>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="VariantCode">Parameter of type Code[10].</param>
    /// <param name="UOM">Parameter of type Code[10].</param>
    /// <param name="CurrencyCode">Parameter of type Code[10].</param>
    /// <param name="StartingDate">Parameter of type Date.</param>
    /// <param name="ShowAll">Parameter of type Boolean.</param>
    procedure FindPurchPrice(var ToPurchPrice: Record "Purchase Price"; VendorNo: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date; ShowAll: Boolean);
    var
        FromPurchPrice: Record "Purchase Price";
    begin
        WITH FromPurchPrice DO BEGIN
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Vendor No.", VendorNo);
            SETFILTER("Ending Date", '%1|>=%2', 0D, StartingDate);
            SETFILTER("Variant Code", '%1|%2', VariantCode, '');
            IF NOT ShowAll THEN BEGIN
                SETRANGE("Starting Date", 0D, StartingDate);
                SETFILTER("Currency Code", '%1|%2', CurrencyCode, '');
                SETFILTER("Unit of Measure Code", '%1|%2', UOM, '');
            END;

            ToPurchPrice.RESET;
            ToPurchPrice.DELETEALL;
            IF FromPurchPrice.FIND('-') THEN
                REPEAT
                    IF FromPurchPrice."Direct Unit Cost" <> 0 THEN BEGIN
                        ToPurchPrice := FromPurchPrice;
                        ToPurchPrice.INSERT;
                    END;
                UNTIL FromPurchPrice.NEXT = 0;
        END;
    end;

    /// <summary>
    /// Description for FindPurchLineDisc.
    /// </summary>
    /// <param name="ToPurchLineDisc">Parameter of type Record "Purchase Line Discount".</param>
    /// <param name="VendorNo">Parameter of type Code[20].</param>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="VariantCode">Parameter of type Code[10].</param>
    /// <param name="UOM">Parameter of type Code[10].</param>
    /// <param name="CurrencyCode">Parameter of type Code[10].</param>
    /// <param name="StartingDate">Parameter of type Date.</param>
    /// <param name="ShowAll">Parameter of type Boolean.</param>
    procedure FindPurchLineDisc(var ToPurchLineDisc: Record "Purchase Line Discount"; VendorNo: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date; ShowAll: Boolean);
    var
        FromPurchLineDisc: Record "Purchase Line Discount";
    begin
        WITH FromPurchLineDisc DO BEGIN
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Vendor No.", VendorNo);
            SETFILTER("Ending Date", '%1|>=%2', 0D, StartingDate);
            SETFILTER("Variant Code", '%1|%2', VariantCode, '');
            IF NOT ShowAll THEN BEGIN
                SETRANGE("Starting Date", 0D, StartingDate);
                SETFILTER("Currency Code", '%1|%2', CurrencyCode, '');
                SETFILTER("Unit of Measure Code", '%1|%2', UOM, '');
            END;

            ToPurchLineDisc.RESET;
            ToPurchLineDisc.DELETEALL;

            IF FIND('-') THEN
                REPEAT
                    IF FromPurchLineDisc."Line Discount %" <> 0 THEN BEGIN
                        ToPurchLineDisc := FromPurchLineDisc;
                        ToPurchLineDisc.INSERT;
                    END;
                UNTIL FromPurchLineDisc.NEXT = 0;
        END;
    end;

    /// <summary>
    /// Description for SetCurrency.
    /// </summary>
    /// <param name="CurrencyCode2">Parameter of type Code[10].</param>
    /// <param name="CurrencyFactor2">Parameter of type Decimal.</param>
    /// <param name="ExchRateDate2">Parameter of type Date.</param>
    local procedure SetCurrency(CurrencyCode2: Code[10]; CurrencyFactor2: Decimal; ExchRateDate2: Date);
    begin
        PricesInCurrency := CurrencyCode2 <> '';
        IF PricesInCurrency THEN BEGIN
            Currency.GET(CurrencyCode2);
            Currency.TESTFIELD("Unit-Amount Rounding Precision");
            CurrencyFactor := CurrencyFactor2;
            ExchRateDate := ExchRateDate2;
        END ELSE
            GLSetup.GET;
    end;

    /// <summary>
    /// Description for SetVAT.
    /// </summary>
    /// <param name="PriceInclVAT2">Parameter of type Boolean.</param>
    /// <param name="VATPerCent2">Parameter of type Decimal.</param>
    /// <param name="VATBusPostingGr2">Parameter of type Code[10].</param>
    local procedure SetVAT(PriceInclVAT2: Boolean; VATPerCent2: Decimal; VATBusPostingGr2: Code[10]);
    begin
        PricesInclVAT := PriceInclVAT2;
        VATPerCent := VATPerCent2;
        VATBusPostingGr := VATBusPostingGr2;
    end;

    /// <summary>
    /// Description for SetUoM.
    /// </summary>
    /// <param name="Qty2">Parameter of type Decimal.</param>
    /// <param name="QtyPerUoM2">Parameter of type Decimal.</param>
    local procedure SetUoM(Qty2: Decimal; QtyPerUoM2: Decimal);
    begin
        Qty := Qty2;
        QtyPerUOM := QtyPerUoM2;
    end;

    /// <summary>
    /// Description for SetLineDisc.
    /// </summary>
    /// <param name="LineDiscPerCent2">Parameter of type Decimal.</param>
    local procedure SetLineDisc(LineDiscPerCent2: Decimal);
    begin
        LineDiscPerCent := LineDiscPerCent2;
    end;

    /// <summary>
    /// Description for IsInMinQty.
    /// </summary>
    /// <param name="UnitofMeasureCode">Parameter of type Code[10].</param>
    /// <param name="MinQty">Parameter of type Decimal.</param>
    /// <returns>Return variable "Boolean".</returns>
    local procedure IsInMinQty(UnitofMeasureCode: Code[10]; MinQty: Decimal): Boolean;
    begin
        IF UnitofMeasureCode = '' THEN
            EXIT(MinQty <= QtyPerUOM * Qty);
        EXIT(MinQty <= Qty);
    end;

    /// <summary>
    /// Description for ConvertPriceToVAT.
    /// </summary>
    /// <param name="FromPriceInclVAT">Parameter of type Boolean.</param>
    /// <param name="FromVATProdPostingGr">Parameter of type Code[10].</param>
    /// <param name="FromVATBusPostingGr">Parameter of type Code[10].</param>
    /// <param name="UnitPrice">Parameter of type Decimal.</param>
    local procedure ConvertPriceToVAT(FromPriceInclVAT: Boolean; FromVATProdPostingGr: Code[10]; FromVATBusPostingGr: Code[10]; var UnitPrice: Decimal);
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        IF FromPriceInclVAT THEN BEGIN
            IF NOT VATPostingSetup.GET(FromVATBusPostingGr, FromVATProdPostingGr) THEN
                VATPostingSetup.INIT;

            IF PricesInclVAT THEN BEGIN
                IF VATBusPostingGr <> FromVATBusPostingGr THEN
                    UnitPrice := UnitPrice * (100 + VATPerCent) / (100 + VATPostingSetup."VAT %");
            END ELSE
                UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
        END ELSE
            IF PricesInclVAT THEN
                UnitPrice := UnitPrice * (1 + VATPerCent / 100);
    end;

    /// <summary>
    /// Description for ConvertPriceToUoM.
    /// </summary>
    /// <param name="UnitOfMeasureCode">Parameter of type Code[10].</param>
    /// <param name="UnitPrice">Parameter of type Decimal.</param>
    local procedure ConvertPriceToUoM(UnitOfMeasureCode: Code[10]; var UnitPrice: Decimal);
    begin
        IF UnitOfMeasureCode = '' THEN
            UnitPrice := UnitPrice * QtyPerUOM;
    end;

    /// <summary>
    /// Description for ConvertPriceLCYToFCY.
    /// </summary>
    /// <param name="CurrencyCode">Parameter of type Code[10].</param>
    /// <param name="UnitPrice">Parameter of type Decimal.</param>
    local procedure ConvertPriceLCYToFCY(CurrencyCode: Code[10]; var UnitPrice: Decimal);
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        IF PricesInCurrency THEN BEGIN
            IF CurrencyCode = '' THEN
                UnitPrice :=
                  CurrExchRate.ExchangeAmtLCYToFCY(ExchRateDate, Currency.Code, UnitPrice, CurrencyFactor);
            UnitPrice := ROUND(UnitPrice, Currency."Unit-Amount Rounding Precision");
        END ELSE
            UnitPrice := ROUND(UnitPrice, GLSetup."Unit-Amount Rounding Precision");
    end;

    /// <summary>
    /// Description for CalcLineAmount.
    /// </summary>
    /// <param name="PurchPrice">Parameter of type Record "Purchase Price".</param>
    /// <returns>Return variable "Decimal".</returns>
    local procedure CalcLineAmount(PurchPrice: Record "Purchase Price"): Decimal;
    begin
        WITH PurchPrice DO
            EXIT("Direct Unit Cost" * (1 - LineDiscPerCent / 100));
    end;

    /// <summary>
    /// Description for PurchLinePriceExists.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "51407290".</param>
    /// <param name="PurchLine">Parameter of type Record "51407291".</param>
    /// <param name="ShowAll">Parameter of type Boolean.</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure PurchLinePriceExists(PurchHeader: Record "NFL Requisition Header"; var PurchLine: Record "NFL Requisition Line"; ShowAll: Boolean): Boolean;
    begin
        WITH PurchLine DO
            IF (Type = Type::Item) AND Item.GET("No.") THEN BEGIN
                FindPurchPrice(
                  TempPurchPrice, "Buy-from Vendor No.", "No.", "Variant Code", "Unit of Measure Code",
                  PurchHeader."Currency Code", PurchHeaderStartDate(PurchHeader, DateCaption), ShowAll);
                EXIT(TempPurchPrice.FIND('-'));
            END;
        EXIT(FALSE);
    end;

    /// <summary>
    /// Description for PurchLineLineDiscExists.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "NFL Requisition Header".</param>
    /// <param name="PurchLine">Parameter of type Record "NFL Requisition Line".</param>
    /// <param name="ShowAll">Parameter of type Boolean.</param>
    /// <returns>Return variable "Boolean".</returns>
    procedure PurchLineLineDiscExists(PurchHeader: Record "NFL Requisition Header"; var PurchLine: Record "NFL Requisition Line"; ShowAll: Boolean): Boolean;
    begin
        WITH PurchLine DO
            IF (Type = Type::Item) AND Item.GET("No.") THEN BEGIN
                FindPurchLineDisc(
                  TempPurchLineDisc, "Buy-from Vendor No.", "No.", "Variant Code", "Unit of Measure Code",
                  PurchHeader."Currency Code", PurchHeaderStartDate(PurchHeader, DateCaption), ShowAll);
                EXIT(TempPurchLineDisc.FIND('-'));
            END;
        EXIT(FALSE);
    end;

    /// <summary>
    /// Description for PurchHeaderExchDate.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "51407290".</param>
    /// <returns>Return variable "Date".</returns>
    local procedure PurchHeaderExchDate(PurchHeader: Record "NFL Requisition Header"): Date;
    begin
        WITH PurchHeader DO BEGIN
            IF ("Document Type" IN ["Document Type"::"Store Requisition", "Document Type"::"Purchase Requisition"]) AND
               ("Posting Date" = 0D)
            THEN
                EXIT(WORKDATE);
            EXIT("Posting Date");
        END;
    end;

    /// <summary>
    /// Description for PurchHeaderStartDate.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "51407290".</param>
    /// <param name="DateCaption">Parameter of type Text[30].</param>
    /// <returns>Return variable "Date".</returns>
    local procedure PurchHeaderStartDate(PurchHeader: Record "NFL Requisition Header"; var DateCaption: Text[30]): Date;
    begin
        WITH PurchHeader DO BEGIN
            /*IF "Document Type" IN ["Document Type"::Invoice,"Document Type"::"Credit Memo"] THEN BEGIN
              DateCaption := FIELDCAPTION("Posting Date");
              EXIT("Posting Date")
            END ELSE BEGIN*/
            DateCaption := FIELDCAPTION("Order Date");
            EXIT("Order Date");
        END;

    end;

    /// <summary>
    /// Description for FindJobPlanningLinePrice.
    /// </summary>
    /// <param name="JobPlanningLine">Parameter of type Record "Job Planning Line".</param>
    /// <param name="CalledByFieldNo">Parameter of type Integer.</param>
    procedure FindJobPlanningLinePrice(var JobPlanningLine: Record "Job Planning Line"; CalledByFieldNo: Integer);
    var
        JTHeader: Record Job;
    begin
        WITH JobPlanningLine DO BEGIN
            SetCurrency("Currency Code", "Currency Factor", "Planning Date");
            SetVAT(FALSE, 0, '');
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

            TESTFIELD("Qty. per Unit of Measure");

            CASE Type OF
                Type::Item:
                    BEGIN
                        Item.GET("No.");
                        PriceInSKU := SKU.GET('', "No.", "Variant Code");
                        JTHeader.GET("Job No.");

                        FindPurchPrice(
                          TempPurchPrice, '', "No.", "Variant Code", "Unit of Measure Code", '', "Planning Date", FALSE);
                        PricesInCurrency := FALSE;
                        GLSetup.GET;
                        CalcBestDirectUnitCost(TempPurchPrice);
                        SetCurrency("Currency Code", "Currency Factor", "Planning Date");

                        IF FoundPurchPrice OR
                           NOT ((CalledByFieldNo = FIELDNO(Quantity)) OR
                                (((CalledByFieldNo = FIELDNO("Variant Code")) AND NOT PriceInSKU)))
                        THEN
                            "Direct Unit Cost (LCY)" := TempPurchPrice."Direct Unit Cost";

                    END;
                Type::Resource:
                    BEGIN
                        ResCost.INIT;
                        ResCost.Code := "No.";
                        ResCost."Work Type Code" := "Work Type Code";
                        ResFindUnitCost.RUN(ResCost);

                        ConvertPriceLCYToFCY("Currency Code", ResCost."Unit Cost");
                        "Direct Unit Cost (LCY)" := ResCost."Direct Unit Cost";
                        VALIDATE("Unit Cost (LCY)", ResCost."Unit Cost");
                    END;
            END;
            VALIDATE("Direct Unit Cost (LCY)");
        END;
    end;

    procedure FindJobJnlLinePrice(var JobJnlLine: Record "Job Journal Line"; CalledByFieldNo: Integer);
    var
        JTHeader: Record Job;
    begin
        WITH JobJnlLine DO BEGIN
            SetCurrency("Currency Code", "Currency Factor", "Posting Date");
            SetVAT(FALSE, 0, '');
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

            TESTFIELD("Qty. per Unit of Measure");

            CASE Type OF
                Type::Item:
                    BEGIN
                        Item.GET("No.");
                        PriceInSKU := SKU.GET('', "No.", "Variant Code");
                        JTHeader.GET("Job No.");

                        FindPurchPrice(
                          TempPurchPrice, '', "No.", "Variant Code", "Unit of Measure Code", "Country/Region Code", "Posting Date", FALSE);
                        PricesInCurrency := FALSE;
                        GLSetup.GET;
                        CalcBestDirectUnitCost(TempPurchPrice);
                        SetCurrency("Currency Code", "Currency Factor", "Posting Date");

                        IF FoundPurchPrice OR
                           NOT ((CalledByFieldNo = FIELDNO(Quantity)) OR
                                (((CalledByFieldNo = FIELDNO("Variant Code")) AND NOT PriceInSKU)))
                        THEN
                            "Direct Unit Cost (LCY)" := TempPurchPrice."Direct Unit Cost";

                    END;
                Type::Resource:
                    BEGIN
                        ResCost.INIT;
                        ResCost.Code := "No.";
                        ResCost."Work Type Code" := "Work Type Code";
                        ResFindUnitCost.RUN(ResCost);

                        ConvertPriceLCYToFCY("Currency Code", ResCost."Unit Cost");
                        "Direct Unit Cost (LCY)" := ResCost."Direct Unit Cost";
                        VALIDATE("Unit Cost (LCY)", ResCost."Unit Cost");
                    END;
            END;
            VALIDATE("Direct Unit Cost (LCY)");
        END;
    end;

    /// <summary>
    /// Description for NoOfPurchLinePrice.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "NFL Requisition Header".</param>
    /// <param name="PurchLine">Parameter of type Record "NFL Requisition Line".</param>
    /// <param name="ShowAll">Parameter of type Boolean.</param>
    /// <returns>Return variable "Integer".</returns>
    procedure NoOfPurchLinePrice(PurchHeader: Record "NFL Requisition Header"; var PurchLine: Record "NFL Requisition Line"; ShowAll: Boolean): Integer;
    begin
        IF PurchLinePriceExists(PurchHeader, PurchLine, ShowAll) THEN
            EXIT(TempPurchPrice.COUNT);
    end;

    /// <summary>
    /// Description for NoOfPurchLineLineDisc.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "NFL Requisition Header".</param>
    /// <param name="PurchLine">Parameter of type Record "NFL Requisition Line".</param>
    /// <param name="ShowAll">Parameter of type Boolean.</param>
    /// <returns>Return variable "Integer".</returns>
    procedure NoOfPurchLineLineDisc(PurchHeader: Record "NFL Requisition Header"; var PurchLine: Record "NFL Requisition Line"; ShowAll: Boolean): Integer;
    begin
        IF PurchLineLineDiscExists(PurchHeader, PurchLine, ShowAll) THEN
            EXIT(TempPurchLineDisc.COUNT);
    end;

    /// <summary>
    /// Description for GetPurchLinePrice.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "NFL Requisition Header".</param>
    /// <param name="PurchLine">Parameter of type Record "NFL Requisition Line".</param>
    procedure GetPurchLinePrice(PurchHeader: Record "NFL Requisition Header"; var PurchLine: Record "NFL Requisition Line");
    begin
        PurchLinePriceExists(PurchHeader, PurchLine, TRUE);

        WITH PurchLine DO
            IF PAGE.RUNMODAL(PAGE::"Get Purchase Price", TempPurchPrice) = ACTION::LookupOK THEN BEGIN

                SetVAT(PurchHeader."Prices Including VAT", "VAT %", "VAT Bus. Posting Group");
                SetUoM(ABS(Quantity), "Qty. per Unit of Measure");
                SetCurrency(
                  PurchHeader."Currency Code", PurchHeader."Currency Factor", PurchHeaderExchDate(PurchHeader));

                IF NOT IsInMinQty(TempPurchPrice."Unit of Measure Code", TempPurchPrice."Minimum Quantity") THEN
                    ERROR(
                      Text000,
                      FIELDCAPTION(Quantity),
                      TempPurchPrice.FIELDCAPTION("Minimum Quantity"),
                      TempPurchPrice.TABLECAPTION);
                IF NOT (TempPurchPrice."Currency Code" IN ["Currency Code", '']) THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("Currency Code"),
                      TABLECAPTION,
                      TempPurchPrice.TABLECAPTION);
                IF NOT (TempPurchPrice."Unit of Measure Code" IN ["Unit of Measure Code", '']) THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("Unit of Measure Code"),
                      TABLECAPTION,
                      TempPurchPrice.TABLECAPTION);
                IF TempPurchPrice."Starting Date" > PurchHeaderStartDate(PurchHeader, DateCaption) THEN
                    ERROR(
                      Text000,
                      DateCaption,
                      TempPurchPrice.FIELDCAPTION("Starting Date"),
                      TempPurchPrice.TABLECAPTION);

                ConvertPriceToVAT(
                  PurchHeader."Prices Including VAT", Item."VAT Prod. Posting Group",
                 "VAT Bus. Posting Group", TempPurchPrice."Direct Unit Cost");
                ConvertPriceToUoM("Unit of Measure Code", TempPurchPrice."Direct Unit Cost");
                ConvertPriceLCYToFCY(TempPurchPrice."Currency Code", TempPurchPrice."Direct Unit Cost");

                VALIDATE("Direct Unit Cost", TempPurchPrice."Direct Unit Cost");
            END;
    end;

    /// <summary>
    /// Description for GetPurchLineLineDisc.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "NFL Requisition Header".</param>
    /// <param name="PurchLine">Parameter of type Record "NFL Requisition Line".</param>
    procedure GetPurchLineLineDisc(PurchHeader: Record "NFL Requisition Header"; var PurchLine: Record "NFL Requisition Line");
    begin
        PurchLineLineDiscExists(PurchHeader, PurchLine, TRUE);

        WITH PurchLine DO
            IF PAGE.RUNMODAL(PAGE::"Get Purchase Line Disc.", TempPurchLineDisc) = ACTION::LookupOK THEN BEGIN
                SetCurrency(PurchHeader."Currency Code", 0, 0D);
                SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

                IF NOT IsInMinQty(TempPurchLineDisc."Unit of Measure Code", TempPurchLineDisc."Minimum Quantity")
                THEN
                    ERROR(
                      Text000, FIELDCAPTION(Quantity),
                      TempPurchLineDisc.FIELDCAPTION("Minimum Quantity"),
                      TempPurchLineDisc.TABLECAPTION);
                IF NOT (TempPurchLineDisc."Currency Code" IN ["Currency Code", '']) THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("Currency Code"),
                      TABLECAPTION,
                      TempPurchLineDisc.TABLECAPTION);
                IF NOT (TempPurchLineDisc."Unit of Measure Code" IN ["Unit of Measure Code", '']) THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("Unit of Measure Code"),
                      TABLECAPTION,
                      TempPurchLineDisc.TABLECAPTION);
                IF TempPurchLineDisc."Starting Date" > PurchHeaderStartDate(PurchHeader, DateCaption) THEN
                    ERROR(
                      Text000,
                      DateCaption,
                      TempPurchLineDisc.FIELDCAPTION("Starting Date"),
                      TempPurchLineDisc.TABLECAPTION);

                VALIDATE("Line Discount %", TempPurchLineDisc."Line Discount %");
            END;
    end;
}

