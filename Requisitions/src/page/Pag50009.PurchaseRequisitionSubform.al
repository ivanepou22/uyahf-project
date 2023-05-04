/// <summary>
/// Page Purchase Requisition Subform (ID 50200).
/// </summary>
page 50009 "Purchase Requisition Subform"
{
    // version NFL02.000

    AutoSplitKey = true;
    Caption = 'Purchase Requisition Subform';
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "NFL Requisition Line";
    SourceTableView = WHERE("Document Type" = FILTER("Purchase Requisition"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                }
                field("No."; Rec."No.")
                {

                    trigger OnValidate();
                    begin
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                        NoOnAfterValidate;
                        // MAG 28TH AUG. 2018 - BEGIN
                        Rec.VALIDATE("Balance on Budget as at Date");
                        Rec.VALIDATE("Balance on Budget for the Year");
                        Rec.VALIDATE("Bal. on Budget for the Month");
                        Rec.VALIDATE("Bal. on Budget for the Quarter");
                        CurrPage.UPDATE;
                        // MAG - END.
                    end;
                }
                field("Budget Code"; Rec."Budget Code")
                {

                    trigger OnValidate();
                    begin
                        Rec.VALIDATE("Balance on Budget as at Date");
                        Rec.VALIDATE("Balance on Budget for the Year");
                        Rec.VALIDATE("Bal. on Budget for the Month");
                        Rec.VALIDATE("Bal. on Budget for the Quarter");
                        CurrPage.UPDATE;
                    end;
                }
                field("Control Account"; Rec."Control Account")
                {
                    Caption = 'Expense Account';

                    trigger OnValidate();
                    begin
                        Rec.VALIDATE("Balance on Budget as at Date");
                        Rec.VALIDATE("Balance on Budget for the Year");
                        Rec.VALIDATE("Bal. on Budget for the Month");
                        Rec.VALIDATE("Bal. on Budget for the Quarter");
                        CurrPage.UPDATE;
                    end;
                }
                field("Deferral Code"; Rec."Deferral Code")
                {
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {

                    trigger OnValidate();
                    begin
                        Rec.VALIDATE("Balance on Budget as at Date");
                        Rec.VALIDATE("Balance on Budget for the Year");
                        Rec.VALIDATE("Bal. on Budget for the Month");
                        Rec.VALIDATE("Bal. on Budget for the Quarter");
                        CurrPage.UPDATE;
                    end;
                }
                field("Cross-Reference No."; Rec."Cross-Reference No.")
                {
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        Rec.CrossReferenceNoLookUp;
                        InsertExtendedText(FALSE);
                    end;

                    trigger OnValidate();
                    begin
                        CrossReferenceNoOnAfterValidat;
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Visible = false;
                }
                field(Nonstock; Rec.Nonstock)
                {
                    Visible = false;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                }
                field("Location Code"; Rec."Location Code")
                {
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    BlankZero = true;

                    trigger OnValidate();
                    begin
                        Rec.VALIDATE("Balance on Budget as at Date");
                        Rec.VALIDATE("Balance on Budget for the Year");
                        Rec.VALIDATE("Bal. on Budget for the Month");
                        Rec.VALIDATE("Bal. on Budget for the Quarter");
                        CurrPage.UPDATE;
                    end;
                }
                field(Convert; Rec.Convert)
                {
                    ApplicationArea = All;
                    Editable = RecState;
                }
                field(Converted; Rec.Converted)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    Visible = false;
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    BlankZero = true;

                    trigger OnValidate();
                    begin
                        Rec.VALIDATE("Balance on Budget as at Date");
                        Rec.VALIDATE("Balance on Budget for the Year");
                        Rec.VALIDATE("Bal. on Budget for the Month");
                        Rec.VALIDATE("Bal. on Budget for the Quarter");
                        CurrPage.UPDATE;
                    end;
                }
                field("Indirect Cost %"; Rec."Indirect Cost %")
                {
                    Visible = false;
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {
                    Visible = false;
                }
                field("Unit Price (LCY)"; Rec."Unit Price (LCY)")
                {
                    Visible = false;
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    BlankZero = true;

                    trigger OnValidate();
                    begin
                        Rec.VALIDATE("Balance on Budget as at Date");
                        Rec.VALIDATE("Balance on Budget for the Year");
                        Rec.VALIDATE("Bal. on Budget for the Month");
                        Rec.VALIDATE("Bal. on Budget for the Quarter");
                        CurrPage.UPDATE;
                    end;
                }
                field("Direct Unit Cost (LCY)"; Rec."Direct Unit Cost (LCY)")
                {
                }
                field("Line Amount (LCY)"; Rec."Line Amount (LCY)")
                {
                }
                field("Posting Date"; Rec."Posting Date")
                {
                }
                field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
                {
                    Visible = false;
                }
                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    Visible = false;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    BlankZero = true;
                    Visible = false;
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                    Visible = false;
                }
                field("Allow Invoice Disc."; Rec."Allow Invoice Disc.")
                {
                    Visible = false;
                }
                field("Allow Item Charge Assignment"; Rec."Allow Item Charge Assignment")
                {
                    Visible = false;
                }
                field("Qty. to Order"; Rec."Qty. to Order")
                {
                }
                field("Qty. to Assign"; Rec."Qty. to Assign")
                {
                    BlankZero = true;
                    Visible = false;

                    trigger OnDrillDown();
                    begin
                        CurrPage.SAVERECORD;
                        Rec.ShowItemChargeAssgnt;
                        UpdateForm(FALSE);
                    end;
                }
                field("Qty. Assigned"; Rec."Qty. Assigned")
                {
                    BlankZero = true;
                    Visible = false;

                    trigger OnDrillDown();
                    begin
                        CurrPage.SAVERECORD;
                        Rec.ShowItemChargeAssgnt;
                        UpdateForm(FALSE);
                    end;
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    Visible = false;
                }
                field("Blanket Order No."; Rec."Blanket Order No.")
                {
                    Visible = false;
                }
                field("Blanket Order Line No."; Rec."Blanket Order Line No.")
                {
                    Visible = false;
                }
                field("Appl.-to Item Entry"; Rec."Appl.-to Item Entry")
                {
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    Visible = true;
                }
                field(Control300; ShortcutDimCode[3])
                {
                    ApplicationArea = All;
                    Visible = true;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(3), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field(Control301; ShortcutDimCode[4])
                {
                    ApplicationArea = All;
                    Visible = true;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(4), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field(Control302; ShortcutDimCode[5])
                {
                    ApplicationArea = All;
                    Visible = true;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(5), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field(Control303; ShortcutDimCode[6])
                {
                    ApplicationArea = All;
                    Visible = false;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(6), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field(Control304; ShortcutDimCode[7])
                {
                    ApplicationArea = All;
                    Visible = false;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(7), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field(Control305; ShortcutDimCode[8])
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(8), "Dimension Value Type" = const(Standard), Blocked = const(false));
                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Budget Amount as at Date"; Rec."Budget Amount as at Date")
                {
                    Visible = false;
                }
                field("Actual Amount as at Date"; Rec."Actual Amount as at Date")
                {
                    Visible = false;
                }
                field("Commitment Amount as at Date"; Rec."Commitment Amount as at Date")
                {
                    Visible = false;
                }
                field("Balance on Budget as at Date"; Rec."Balance on Budget as at Date")
                {
                    Visible = false;
                }
                field("Budget Comment as at Date"; Rec."Budget Comment as at Date")
                {
                    Visible = false;
                }
                field("Budget Amount for the Year"; Rec."Budget Amount for the Year")
                {
                    Visible = false;
                }
                field("Actual Amount for the Year"; Rec."Actual Amount for the Year")
                {
                    Visible = false;
                }
                field("Commitment Amount for the Year"; Rec."Commitment Amount for the Year")
                {
                    Visible = false;
                }
                field("Balance on Budget for the Year"; Rec."Balance on Budget for the Year")
                {
                    Visible = false;

                    trigger OnValidate();
                    begin
                        CurrPage.UPDATE;
                    end;
                }
                field("Budget Comment for the Year"; Rec."Budget Comment for the Year")
                {
                    Visible = false;
                }
                field("Budget Comment"; Rec."Budget Comment")
                {
                }
                field(Committed; Rec.Committed)
                {
                    ApplicationArea = All;
                }

                field("Exceeded at Date Budget"; Rec."Exceeded at Date Budget")
                {
                    ToolTip = 'Specifies the value of the Exceeded at Date Budget field';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Exceeded Month Budget"; Rec."Exceeded Month Budget")
                {
                    ToolTip = 'Specifies the value of the Exceeded Month Budget field';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Exceeded Quarter Budget"; Rec."Exceeded Quarter Budget")
                {
                    ToolTip = 'Specifies the value of the Exceeded Quarter Budget field';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Exceeded Year Budget"; Rec."Exceeded Year Budget")
                {
                    ToolTip = 'Specifies the value of the Exceeded Year Budget field';
                    Visible = false;
                    ApplicationArea = All;
                }
            }
            group(ItemPanel)
            {
                Caption = 'Item Information';
                Visible = false;
                field(Contr0001; STRSUBSTNO('(%1)', PurchInfoPaneMgt.CalcAvailability(Rec)))
                {
                    ShowCaption = false;
                    Editable = false;
                }
                field(Contr0002; STRSUBSTNO('(%1)', PurchInfoPaneMgt.CalcNoOfPurchasePrices(Rec)))
                {
                    ShowCaption = false;
                    Editable = false;
                }
                field(Contr0003; STRSUBSTNO('(%1)', PurchInfoPaneMgt.CalcNoOfPurchLineDisc(Rec)))
                {
                    ShowCaption = false;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    action(Period)
                    {
                        Caption = 'Period';

                        trigger OnAction();
                        begin
                            //This functionality was copied from page #51406300. Unsupported part was commented. Please check it.
                            /*CurrPage.PurchLines.PAGE.*/
                            _ItemAvailability(0);

                        end;
                    }
                    action(Variant)
                    {
                        Caption = 'Variant';

                        trigger OnAction();
                        begin
                            //This functionality was copied from page #51406300. Unsupported part was commented. Please check it.
                            /*CurrPage.PurchLines.PAGE.*/
                            _ItemAvailability(1);

                        end;
                    }
                    action(Location)
                    {
                        Caption = 'Location';

                        trigger OnAction();
                        begin
                            //This functionality was copied from page #51406300. Unsupported part was commented. Please check it.
                            /*CurrPage.PurchLines.PAGE.*/
                            _ItemAvailability(2);

                        end;
                    }
                }
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction();
                    begin
                        //This functionality was copied from page #51406300. Unsupported part was commented. Please check it.
                        /*CurrPage.PurchLines.PAGE.*/
                        _ShowDimensions;

                    end;
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;

                    trigger OnAction();
                    begin
                        ShowLineComments;
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("E&xplode BOM")
                {
                    Caption = 'E&xplode BOM';
                    Image = ExplodeBOM;

                    trigger OnAction();
                    begin
                        //This functionality was copied from page #51406300. Unsupported part was commented. Please check it.
                        /*CurrPage.PurchLines.PAGE.*/
                        ExplodeBOM;

                    end;
                }
                action("Insert &Ext. Texts")
                {
                    Caption = 'Insert &Ext. Texts';

                    trigger OnAction();
                    begin
                        //This functionality was copied from page #51406300. Unsupported part was commented. Please check it.
                        /*CurrPage.PurchLines.PAGE.*/
                        _InsertExtendedText(TRUE);

                    end;
                }
            }
            action("Purchase Line &Discounts")
            {
                Caption = 'Purchase Line &Discounts';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    ShowLineDisc;
                    CurrPage.UPDATE;
                end;
            }
            action("Purcha&se Prices")
            {
                Caption = 'Purcha&se Prices';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    ShowPrices;
                    CurrPage.UPDATE;
                end;
            }
            action("Availa&bility")
            {
                Caption = 'Availa&bility';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    ItemAvailability(0);
                    CurrPage.UPDATE(TRUE);
                end;
            }
            action("Ite&m Card")
            {
                Caption = 'Ite&m Card';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    PurchInfoPaneMgt.LookupItem(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    begin

    end;

    trigger OnAfterGetRecord();
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
        // MAG 6TH AUG. 2018.
        Rec.SETFILTER("Fiscal Year Date Filter", '%1..%2', Rec."Fiscal Year Start Date", Rec."Fiscal Year End Date");
        Rec.SETFILTER("Filter to Date Filter", '%1..%2', Rec."Filter to Date Start Date", Rec."Fiscal Year End Date");
        Rec.SETFILTER("Month Date Filter", '%1..%2', Rec."Accounting Period Start Date", Rec."Accounting Period End Date");
        Rec.SETFILTER("Quarter Date Filter", '%1..%2', Rec."Quarter Start Date", Rec."Quarter End Date");

        Rec.VALIDATE("Balance on Budget as at Date");
        Rec.VALIDATE("Balance on Budget for the Year");
        Rec.VALIDATE("Bal. on Budget for the Month");
        Rec.VALIDATE("Bal. on Budget for the Quarter");
        // MAG - END


        //DEO---03/02/2020
        IF Rec.Converted = TRUE THEN
            RecState := FALSE
        ELSE
            RecState := TRUE;
    end;

    trigger OnDeleteRecord(): Boolean;
    var
        ReservePurchLine: Codeunit "Purch. Line-Reserve";
    begin
        UpdateHeader(0);
        IF (Rec.Quantity <> 0) AND Rec.ItemExists(Rec."No.") THEN BEGIN
            COMMIT;
            //AMI
            /*IF NOT ReservePurchLine.DeleteLineConfirm(Rec) THEN
              EXIT(FALSE);
            ReservePurchLine.DeleteLine(Rec);*/
        END;

    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean;
    begin
        UpdateHeader(1);
    end;

    trigger OnModifyRecord(): Boolean;
    begin
        UpdateHeader(1);
    end;

    trigger OnNewRecord(BelowxRec: Boolean);
    begin
        Rec.Type := xRec.Type;
        CLEAR(ShortcutDimCode);
    end;

    trigger OnOpenPage();
    begin
        // MAG 6TH AUG. 2018.
        Rec.SETFILTER("Fiscal Year Date Filter", '%..%2', Rec."Fiscal Year Start Date", Rec."Fiscal Year End Date");
        Rec.SETFILTER("Filter to Date Filter", '%1..%2', Rec."Filter to Date Start Date", Rec."Fiscal Year End Date");
        Rec.SETFILTER("Month Date Filter", '%1..%2', Rec."Accounting Period Start Date", Rec."Accounting Period End Date");
        Rec.SETFILTER("Quarter Date Filter", '%1..%2', Rec."Quarter Start Date", Rec."Quarter End Date");

        Rec.VALIDATE("Balance on Budget as at Date");
        Rec.VALIDATE("Balance on Budget for the Year");
        Rec.VALIDATE("Bal. on Budget for the Month");
        Rec.VALIDATE("Bal. on Budget for the Quarter");
        // MAG - END
    end;

    var
        TransferExtendedText: Codeunit "Custom Functions And EVents";
        ShortcutDimCode: array[9] of Code[20];
        PurchInfoPaneMgt: Codeunit "NFL Reqn Info-Pane Management";
        "---MAG---": Integer;
        TotalPurchaseHeader: Record "NFL Requisition Header";
        TotalPurchaseLine: Record "NFL Requisition Line";
        PurchHeader: Record "NFL Requisition Header";
        DocumentTotals: Codeunit "Document Totals";
        gvNFLRequisitionHeader: Record "NFL Requisition Header";
        RefreshMessageEnabled: Boolean;
        TotalAmountStyle: Text;
        VATAmount: Decimal;
        InvDiscAmountEditable: Boolean;
        RefreshMessageText: Text;
        globalVarNFLRequisitionHeader: Record "NFL Requisition Header";
        RecState: Boolean;

    /// <summary>
    /// Description for ApproveCalcInvDisc.
    /// </summary>
    procedure ApproveCalcInvDisc();
    begin
        CODEUNIT.RUN(CODEUNIT::"Purch.-Disc. (Yes/No)", Rec);
    end;

    /// <summary>
    /// Description for CalcInvDisc.
    /// </summary>
    procedure CalcInvDisc();
    begin
        CODEUNIT.RUN(CODEUNIT::"Purch.-Calc.Discount", Rec);
    end;

    /// <summary>
    /// Description for ExplodeBOM.
    /// </summary>
    procedure ExplodeBOM();
    begin
        CODEUNIT.RUN(CODEUNIT::"Purch.-Explode BOM", Rec);
    end;

    /// <summary>
    /// Description for _InsertExtendedText.
    /// </summary>
    /// <param name="Unconditionally">Parameter of type Boolean.</param>
    procedure _InsertExtendedText(Unconditionally: Boolean);
    begin

        IF TransferExtendedText.PurchCheckIfAnyExtText(Rec, Unconditionally) THEN BEGIN
            CurrPage.SAVERECORD;
            TransferExtendedText.InsertPurchExtText(Rec);
        END;
        IF TransferExtendedText.MakeUpdate THEN
            UpdateForm(TRUE);
    end;

    /// <summary>
    /// Description for InsertExtendedText.
    /// </summary>
    /// <param name="Unconditionally">Parameter of type Boolean.</param>
    procedure InsertExtendedText(Unconditionally: Boolean);
    begin

        IF TransferExtendedText.PurchCheckIfAnyExtText(Rec, Unconditionally) THEN BEGIN
            CurrPage.SAVERECORD;
            TransferExtendedText.InsertPurchExtText(Rec);
        END;
        IF TransferExtendedText.MakeUpdate THEN
            UpdateForm(TRUE);
    end;

    /// <summary>
    /// Description for _ItemAvailability.
    /// </summary>
    /// <param name="AvailabilityType">Parameter of type Option Date,Variant,Location,Bin.</param>
    procedure _ItemAvailability(AvailabilityType: Option Date,Variant,Location,Bin);
    begin
        Rec.ItemAvailability(AvailabilityType);
    end;

    /// <summary>
    /// Description for ItemAvailability.
    /// </summary>
    /// <param name="AvailabilityType">Parameter of type Option Date,Variant,Location,Bin.</param>
    procedure ItemAvailability(AvailabilityType: Option Date,Variant,Location,Bin);
    begin
        Rec.ItemAvailability(AvailabilityType);
    end;

    /// <summary>
    /// Description for _ShowDimensions.
    /// </summary>
    procedure _ShowDimensions();
    begin
        Rec.ShowDimensions;
    end;

    /// <summary>
    /// Description for ShowDimensions.
    /// </summary>
    procedure ShowDimensions();
    begin
        Rec.ShowDimensions;
    end;

    /// <summary>
    /// Description for ItemChargeAssgnt.
    /// </summary>
    procedure ItemChargeAssgnt();
    begin
        Rec.ShowItemChargeAssgnt;
    end;

    /// <summary>
    /// Description for OpenItemTrackingLines.
    /// </summary>
    procedure OpenItemTrackingLines();
    begin
        Rec.OpenItemTrackingLines;
    end;

    /// <summary>
    /// Description for UpdateForm.
    /// </summary>
    /// <param name="SetSaveRecord">Parameter of type Boolean.</param>
    procedure UpdateForm(SetSaveRecord: Boolean);
    begin
        CurrPage.UPDATE(SetSaveRecord);
    end;

    /// <summary>
    /// Description for ShowPrices.
    /// </summary>
    procedure ShowPrices();
    var
        PurchHeader: Record "NFL Requisition Header";
        PurchPriceCalcMgt: Codeunit "NFL Purch. Price Calc. Mgt.";
    begin
        PurchHeader.GET(Rec."Document Type", Rec."Document No.");
        CLEAR(PurchPriceCalcMgt);
        PurchPriceCalcMgt.GetPurchLinePrice(PurchHeader, Rec);
    end;

    /// <summary>
    /// Description for ShowLineDisc.
    /// </summary>
    procedure ShowLineDisc();
    var
        PurchHeader: Record "NFL Requisition Header";
        PurchPriceCalcMgt: Codeunit "NFL Purch. Price Calc. Mgt.";
    begin
        PurchHeader.GET(Rec."Document Type", Rec."Document No.");
        CLEAR(PurchPriceCalcMgt);
        PurchPriceCalcMgt.GetPurchLineLineDisc(PurchHeader, Rec);
    end;

    /// <summary>
    /// Description for ShowLineComments.
    /// </summary>
    procedure ShowLineComments();
    begin
        Rec.ShowLineComments;
    end;

    /// <summary>
    /// Description for NoOnAfterValidate.
    /// </summary>
    local procedure NoOnAfterValidate();
    begin
        InsertExtendedText(FALSE);
        IF (Rec.Type = Rec.Type::"Charge (Item)") AND (Rec."No." <> xRec."No.") AND
           (xRec."No." <> '')
        THEN
            CurrPage.SAVERECORD;
    end;

    /// <summary>
    /// Description for CrossReferenceNoOnAfterValidat.
    /// </summary>
    local procedure CrossReferenceNoOnAfterValidat();
    begin
        InsertExtendedText(FALSE);
    end;

    /// <summary>
    /// Description for UpdateHeader.
    /// </summary>
    /// <param name="Operation">Parameter of type Option Delete,Modify.</param>
    local procedure UpdateHeader(Operation: Option Delete,Modify);
    var
    // PaymentRequisitionHeader : Record "50000";
    // PaymentRequisitionHeader2 : Record "50000";
    begin

        /*
        globalVarNFLRequisitionHeader.RESET;
        globalVarNFLRequisitionHeader.SETRANGE("No.", "Document No.");
        IF globalVarNFLRequisitionHeader.FINDFIRST THEN BEGIN
          globalVarNFLRequisitionHeader.CALCFIELDS("Amount Including VAT","Budget Amount", "Commited Amount", "Actual Amount");
          IF Operation = Operation::Modify THEN
            globalVarNFLRequisitionHeader."Amount Including VAT" := (globalVarNFLRequisitionHeader."Amount Including VAT" - xRec."Amount Including VAT") + "Amount Including VAT";
          IF Operation = Operation::Delete THEN
            globalVarNFLRequisitionHeader."Amount Including VAT" := (globalVarNFLRequisitionHeader."Amount Including VAT") - "Amount Including VAT";
          globalVarNFLRequisitionHeader.VALIDATE("Balance on Budget");
          globalVarNFLRequisitionHeader.MODIFY;
        END ;
         */

    end;
}