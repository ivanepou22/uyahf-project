/// <summary>
/// Page Cash Voucher Details Subform (ID 50000).
/// </summary>
page 50000 "Cash Voucher Details Subform"
{
    // version

    AutoSplitKey = true;
    Caption = 'Cash Voucher Details Subform';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Payment Voucher Detail";
    SourceTableView = WHERE("Document Type" = FILTER("Cash Voucher"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Details; Rec.Details)
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord();
    var
        CustomFunctions: Codeunit "Custom Functions And EVents";
    begin
        IF PaymentVoucherHeader.GET(Rec."Document No.", Rec."Document Type") THEN;

        CustomFunctions.PaymentDetailsUpdateTotalsControls(Rec, TotalPurchaseHeader, TotalPurchaseLine, RefreshMessageEnabled,
          TotalAmountStyle, RefreshMessageText, InvDiscAmountEditable, VATAmount);

    end;

    trigger OnOpenPage();
    var
        lvPayVouchLine: Record "Payment Voucher Line";
    begin
    end;

    var
        PaymentVoucherHeader: Record "Payment Voucher Header";
        TotalVoucherDetail: Record "Payment Voucher Detail";
        RefreshMessageEnabled: Boolean;
        DocumentTotals: Codeunit "Document Totals";
        TotalPurchaseHeader: Record "Payment Voucher Header";
        TotalPurchaseLine: Record "Payment Voucher Detail";
        PurchHeader: Record "Payment Voucher Header";
        TotalAmountStyle: Text;
        RefreshMessageText: Text;
        InvDiscAmountEditable: Boolean;
        VATAmount: Decimal;

    /// <summary>
    /// Description for GetReqnHeader.
    /// </summary>
    local procedure GetReqnHeader();
    var
        Currency: Record Currency;
    begin
        Rec.TESTFIELD("Document No.");
        IF (Rec."Document Type" <> PaymentVoucherHeader."Document Type") OR (Rec."Document No." <> PaymentVoucherHeader."No.") THEN BEGIN
            PaymentVoucherHeader.GET(Rec."Document Type", Rec."Document No.");
            IF PaymentVoucherHeader."Currency Code" = '' THEN
                Currency.InitRoundingPrecision
            ELSE BEGIN
                PaymentVoucherHeader.TESTFIELD("Currency Factor");
                Currency.GET(PaymentVoucherHeader."Currency Code");
                Currency.TESTFIELD("Amount Rounding Precision");
            END;
        END;
    end;
}

