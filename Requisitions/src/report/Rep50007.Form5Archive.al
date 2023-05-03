/// <summary>
/// Report Form 5 Archive (ID 50056).
/// </summary>
report 50007 "Form 5 Archive"
{
    // version NFL02.000

    DefaultLayout = RDLC;
    RDLCLayout = './Form 5 Archive.rdlc';

    dataset
    {
        dataitem("NFL Requisition Header Archive"; "NFL Requisition Header Archive")
        {
            DataItemTableView = SORTING("Document Type", "No.")
                                WHERE("Document Type" = CONST("Purchase Requisition"),
                                      "No." = FILTER(<> ''));
            RequestFilterFields = "Document Type", "No.", "Request-By No.";
            column(PageConst_________FORMAT_CurrReport_PAGENO_; PageConst + ' ' + FORMAT(CurrReport.PAGENO))
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            column(FORMAT_TODAY_0_4_; FORMAT(TODAY, 0, 4))
            {
            }
            column(USERID; USERID)
            {
            }
            column(AccountingPeriodEndDate_NFLRequisitionHeader; "NFL Requisition Header Archive"."Accounting Period End Date")
            {
            }
            column(AccountingPeriodStartDate_NFLRequisitionHeader; "NFL Requisition Header Archive"."Accounting Period Start Date")
            {
            }
            column(FiscalYearEndDate_NFLRequisitionHeader; "NFL Requisition Header Archive"."Fiscal Year End Date")
            {
            }
            column(FiscalYearStartDate_NFLRequisitionHeader; "NFL Requisition Header Archive"."Fiscal Year Start Date")
            {
            }
            column(NFL_Requisition_Header__No__; "No.")
            {
            }
            column(NFL_Requisition_Header__Requestor_ID_; "Requestor ID")
            {
            }
            column(NFL_Requisition_Header_Status; Status)
            {
            }
            column(NFL_Requisition_Header__Store_Requisition_No__; "Store Requisition No.")
            {
            }
            column(NFL_Requisition_Header__Request_By_No__; "Request-By No.")
            {
            }
            column(NFL_Requisition_Header__Request_By_Name_; "Request-By Name")
            {
            }
            column(NFL_Requisition_Header__Order_Date_; "Order Date")
            {
            }
            column(Requested_Receipt_Date; "NFL Requisition Header Archive"."Requested Receipt Date")
            {
            }
            column(NFL_Requisition_Header__Expected_Receipt_Date_; "Expected Receipt Date")
            {
            }
            column(Purchase_RequisitionCaption; Purchase_RequisitionCaptionLbl)
            {
            }
            column(NFL_Requisition_Header__No__Caption; FIELDCAPTION("No."))
            {
            }
            column(NFL_Requisition_Header__Requestor_ID_Caption; FIELDCAPTION("Requestor ID"))
            {
            }
            column(NFL_Requisition_Header_StatusCaption; FIELDCAPTION(Status))
            {
            }
            column(NFL_Requisition_Header__Store_Requisition_No__Caption; FIELDCAPTION("Store Requisition No."))
            {
            }
            column(NFL_Requisition_Header__Request_By_No__Caption; FIELDCAPTION("Request-By No."))
            {
            }
            column(NFL_Requisition_Header__Request_By_Name_Caption; FIELDCAPTION("Request-By Name"))
            {
            }
            column(Request_DateCaption; Request_DateCaptionLbl)
            {
            }
            column(NFL_Requisition_Header__Expected_Receipt_Date_Caption; FIELDCAPTION("Expected Receipt Date"))
            {
            }
            column(NFL_Requisition_Header_Document_Type; "Document Type")
            {
            }
            column(Currency_Code; CurrencyCode)
            {
            }
            column(Posting_Description; "NFL Requisition Header Archive"."Posting Description")
            {
            }
            column(Location_Code; "NFL Requisition Header Archive"."Location Code")
            {
            }
            column(LocationCode; LocationCode)
            {
            }
            column(SignatureOne; LvUser.Signature)
            {
            }
            column(SignatureTwo; LvUser2.Signature)
            {
            }
            column(SignatureThree; LvUser3.Signature)
            {
            }
            column(SignatureFour; LvUser4.Signature)
            {
            }
            column(FirstApprover; Approver1)
            {
            }
            column(SecondApprover; Approver2)
            {
            }
            column(ThirdApprover; Approver3)
            {
            }
            column(FourthApprover; Approver4)
            {
            }
            column(FirstDateOfApproval; ApprovalDate1)
            {
            }
            column(SecondDateOfApproval; ApprovalDate2)
            {
            }
            column(ThirdDateOfApproval; ApprovalDate3)
            {
            }
            column(FourthDateOfApproval; ApprovalDate4)
            {
            }
            column(AppPositionOne; JobTitle1)
            {
            }
            column(AppPositionTwo; JobTitle2)
            {
            }
            column(AppPositionThree; JobTitle3)
            {
            }
            column(AppPositionFour; JobTitle4)
            {
            }
            column(PDEntity_NFLRequisitionHeader; "NFL Requisition Header Archive"."PD Entity")
            {
            }
            column(WrksSrvcsSup_NFLRequisitionHeader; "NFL Requisition Header Archive"."Wrks/Srvcs/Sup")
            {
            }
            column(ProcumentPlanReference_NFLRequisitionHeader; "NFL Requisition Header Archive"."Procument Plan Reference")
            {
            }
            column(Name; CompanyInfor.Name)
            {
            }
            column(StartYear; StartDate)
            {
            }
            column(EndYear; EndDate)
            {
            }
            column(user1; username[1])
            {
            }
            column(user2; username[2])
            {
            }
            column(user3; username[3])
            {
            }
            column(date1; date[1])
            {
            }
            column(date2; date[2])
            {
            }
            column(date3; date[3])
            {
            }
            column(JobTitle1; Title[1])
            {
            }
            column(JobTitle2; Title[2])
            {
            }
            column(JobTitle3; Title[3])
            {
            }
            dataitem("NFL Requisition Line Archive"; "NFL Requisition Line Archive")
            {
                DataItemLinkReference = "NFL Requisition Header Archive";
                DataItemLink = "Document Type" = FIELD("Document Type"),
                               "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");
                column(LineAmount_NFLRequisitionLine; "NFL Requisition Line Archive"."Line Amount")
                {
                }
                column(AmountIncludingVAT_NFLRequisitionLine; "NFL Requisition Line Archive"."Amount Including VAT")
                {
                }
                column(NFL_Requisition_Line_Type; Type)
                {
                }
                column(NFL_Requisition_Line__No__; "No.")
                {
                }
                column(NFL_Requisition_Line__Location_Code_; "Location Code")
                {
                }
                column(NFL_Requisition_Line_Description; Description)
                {
                }
                column(NFL_Requisition_Line__Unit_of_Measure_; "Unit of Measure")
                {
                }
                column(NFL_Requisition_Line_Quantity; Quantity)
                {
                }
                column(NFL_Requisition_Line_Amount; Amount)
                {
                }
                column(NFL_Requisition_Line__Buy_from_Vendor_No__; "Buy-from Vendor No.")
                {
                }
                column(NFL_Requisition_Line__Unit_Cost__LCY__; "Unit Cost (LCY)")
                {
                }
                column(NFL_Requisition_Line_TypeCaption; FIELDCAPTION(Type))
                {
                }
                column(NFL_Requisition_Line__No__Caption; FIELDCAPTION("No."))
                {
                }
                column(NFL_Requisition_Line__Location_Code_Caption; FIELDCAPTION("Location Code"))
                {
                }
                column(NFL_Requisition_Line_DescriptionCaption; FIELDCAPTION(Description))
                {
                }
                column(NFL_Requisition_Line__Unit_of_Measure_Caption; NFL_Requisition_Line__Unit_of_Measure_CaptionLbl)
                {
                }
                column(QtyCaption; QtyCaptionLbl)
                {
                }
                column(NFL_Requisition_Line_AmountCaption; FIELDCAPTION(Amount))
                {
                }
                column(NFL_Requisition_Line__Buy_from_Vendor_No__Caption; FIELDCAPTION("Buy-from Vendor No."))
                {
                }
                column(NFL_Requisition_Line__Unit_Cost__LCY__Caption; FIELDCAPTION("Unit Cost (LCY)"))
                {
                }
                column(NFL_Requisition_Line_Document_Type; "Document Type")
                {
                }
                column(NFL_Requisition_Line_Document_No_; "Document No.")
                {
                }
                column(NFL_Requisition_Line_Line_No_; "Line No.")
                {
                }
                column(on; x)
                {
                }

                trigger OnAfterGetRecord();
                begin
                    x := x + 1;
                end;
            }

            trigger OnAfterGetRecord();
            begin

                IF "NFL Requisition Header Archive"."Currency Code" <> '' THEN
                    CurrencyCode := 'Currency:' + ' ' + "NFL Requisition Header Archive"."Currency Code"
                ELSE
                    CurrencyCode := 'Currency: UGX';

                GetApprovers;

                IF "NFL Requisition Header Archive"."Location Code" <> '' THEN BEGIN
                    LocRec.GET("NFL Requisition Header Archive"."Location Code");
                    LocationCode := LocRec.Name;
                END;
                /*
                ApproverRec.SETRANGE(ApproverRec."Table ID",51407290);
                ApproverRec.SETRANGE(ApproverRec."Document Type",ApproverRec."Document Type"::"Purchase Requisition");
                ApproverRec.SETRANGE(ApproverRec."Document No.","NFL Requisition Header"."No.");
                ApproverRec.SETRANGE(ApproverRec.Status,ApproverRec.Status::Approved);
                IF ApproverRec.FINDSET THEN REPEAT
                   CASE ApproverRec."Sequence No." OF
                    1:
                      BEGIN
                        LvUser.SETFILTER(LvUser."User ID",ApproverRec."Approver ID");
                        IF LvUser.FINDSET  THEN BEGIN
                          LvUser.CALCFIELDS(LvUser.Signature);
                          JobTitle1 := LvUser."Job Title";
                        END;
                        ApprovalDate1 := DT2DATE(ApproverRec."Date-Time Sent for Approval");
                      END;
                    2:
                      BEGIN
                        LvUser2.SETFILTER(LvUser2."User ID",ApproverRec."Approver ID");
                        IF LvUser2.FINDSET  THEN
                        BEGIN
                          LvUser2.CALCFIELDS(LvUser2.Signature);
                          JobTitle2 := LvUser2."Job Title";
                        END;
                        ApprovalDate2 := DT2DATE(ApproverRec."Date-Time Sent for Approval");
                      END;
                    3:
                      BEGIN
                        LvUser3.SETFILTER(LvUser3."User ID",ApproverRec."Approver ID");
                        IF LvUser3.FINDSET  THEN BEGIN
                          LvUser3.CALCFIELDS(LvUser3.Signature);
                          JobTitle3 := LvUser3."Job Title";
                        END;
                        ApprovalDate3 := DT2DATE(ApproverRec."Date-Time Sent for Approval");
                      END;
                    4:
                      BEGIN
                        LvUser4.SETFILTER(LvUser4."User ID",ApproverRec."Approver ID");
                        IF LvUser4.FINDSET  THEN BEGIN
                          LvUser4.CALCFIELDS(LvUser4.Signature);
                          JobTitle4 := LvUser4."Job Title";
                        END;
                        ApprovalDate4 := DT2DATE(ApproverRec."Date-Time Sent for Approval");
                      END;
                    END;
                UNTIL ApproverRec.NEXT = 0;*/

                //DEO 07.15.19 To add approvers on the report
                ApproverRec.RESET;
                ApproverRec.SETRANGE(ApproverRec."Document No.", "NFL Requisition Header Archive"."No.");
                ApproverRec.SETRANGE(ApproverRec.Status, ApproverRec.Status::Approved);
                INT := 1;
                IF ApproverRec.FINDFIRST THEN
                    REPEAT
                        User.SETRANGE("User Name", ApproverRec."Approver ID");
                        IF User.FINDFIRST THEN
                            //Employee.SETRANGE("No.", User."Employee ID"); IE
                        date[INT] := ApproverRec."Date-Time Sent for Approval";
                        username[INT] := User."Full Name";
                        IF Employee.FINDFIRST THEN
                            Title[INT] := Employee."Job Title";
                        INT := INT + 1;
                    UNTIL
                      ApproverRec.NEXT = 0;

            end;

            trigger OnPreDataItem();
            begin
                LastFieldNo := FIELDNO("No.");
                Year1 := DATE2DMY(WORKDATE, 3);
                Year2 := Year1 + 1;
                StartDate := FORMAT(Year1);
                EndDate := FORMAT(Year2);
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport();
    begin
        CompanyInfor.GET;
    end;

    var
        PageConst: Label 'Page';
        LastFieldNo: Integer;
        FooterPrinted: Boolean;
        Purchase_RequisitionCaptionLbl: Label 'Purchase Requisition';
        Request_DateCaptionLbl: Label 'Request Date';
        NFL_Requisition_Line__Unit_of_Measure_CaptionLbl: Label 'UOM';
        QtyCaptionLbl: Label 'Qty';
        CurrencyCode: Text[50];
        x: Integer;
        Approver1: Text[80];
        Approver2: Text[80];
        Approver3: Text[80];
        Approver4: Text[80];
        LocationCode: Text[40];
        LocRec: Record Location;
        ApproverRec: Record "Approval Entry";
        ApprovalDate1: Date;
        ApprovalDate2: Date;
        ApprovalDate3: Date;
        ApprovalDate4: Date;
        Signature1: Integer;
        JobTitle1: Text[80];
        JobTitle2: Text[80];
        JobTitle3: Text[80];
        JobTitle4: Text[80];
        LvUser: Record "User Setup";
        LvUser2: Record "User Setup";
        LvUser3: Record "User Setup";
        LvUser4: Record "User Setup";
        GvUsers: Record User;
        CompanyInfor: Record "Company Information";
        Year1: Integer;
        Year2: Integer;
        StartDate: Text;
        EndDate: Text;
        User: Record User;
        username: array[10] of Text[80];
        date: array[10] of DateTime;
        INT: Integer;
        Employee: Record Employee;
        Title: array[10] of Text[80];

    /// <summary>
    /// Description for GetApprovers.
    /// </summary>
    procedure GetApprovers();
    var
        i: Integer;
        LvPurchReq: Record "NFL Requisition Header";
        LvApprovalEntry: Record "Approval Entry";
        ApproverName: array[5] of Text[80];
        LvUser: Record User;
    begin
        Approver1 := '';
        Approver2 := '';
        Approver3 := '';
        Approver4 := '';
        LvApprovalEntry.SETFILTER(LvApprovalEntry."Table ID", '50069');
        LvApprovalEntry.SETFILTER(LvApprovalEntry."Document No.", "NFL Requisition Header Archive"."No.");
        LvApprovalEntry.SETFILTER(LvApprovalEntry.Status, '<>Canceled|Rejected');
        IF LvApprovalEntry.FINDSET THEN
            REPEAT
                IF LvApprovalEntry.Status = LvApprovalEntry.Status::Approved THEN BEGIN
                    i := i + 1;
                    GvUsers.SETCURRENTKEY(GvUsers."User Name");
                    GvUsers.SETFILTER(GvUsers."User Name", LvApprovalEntry."Approver ID");

                    IF GvUsers.FINDSET THEN //begin
                        CASE i OF
                            1:
                                Approver1 := GvUsers."Full Name";
                            2:
                                Approver2 := GvUsers."Full Name";
                            3:
                                Approver3 := GvUsers."Full Name";
                            4:
                                Approver4 := GvUsers."Full Name";
                        END;
                END;
            UNTIL LvApprovalEntry.NEXT = 0;
    end;
}

