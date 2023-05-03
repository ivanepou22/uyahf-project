/// <summary>
/// TableExtension ProfileQuestionnaire HeaderExt (ID 50062) extends Record Profile Questionnaire Header.
/// </summary>
tableextension 50007 "ProfileQuestionnaire HeaderExt" extends "Profile Questionnaire Header"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Entry No."; Integer)
        {
            //AutoIncrement = true;
        }
        field(50001; "Posting Date"; Date)
        {
            NotBlank = true;
        }
        field(50002; "Contributor's No."; Code[20])
        {
            TableRelation = "Staff Advances" WHERE(Blocked = CONST(false));

            trigger OnValidate();
            begin
                IF recEmp.GET("Contributor's No.") THEN
                    VALIDATE("Contributor's Name", (recEmp.Name));
            end;
        }
        field(50003; "Contributor's Name"; Text[150])
        {
        }
        field(50004; "Cost Centre Code"; Code[20])
        {
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FILTER('COST CENTRE'));

            trigger OnValidate();
            begin
                IF recDimValue.GET('COST CENTRE', "Cost Centre Code") THEN
                    VALIDATE("Revenue Stream", recDimValue.Name);
            end;
        }
        field(50005; Section; Text[100])
        {
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FILTER('SUB COST CENTRE'));
        }
        field(50006; Headline; Text[250])
        {
        }
        field(50007; Amount; Decimal)
        {
        }
        field(50008; Transferred; Boolean)
        {
        }
        field(50009; "Page"; Text[30])
        {
        }
        field(50010; "Revenue Stream"; Text[150])
        {
        }
        field(50011; Transfer; Boolean)
        {
        }
        field(50012; UnPaid; Boolean)
        {
        }
        field(50013; "Payroll ID"; Code[50])
        {
            NotBlank = true;
            // TableRelation = Periods."Period ID";
            // ValidateTableRelation = false;
        }
        field(50014; "Sub Photo"; Option)
        {
            OptionCaption = '" ,Photo,General News,Photo Desk,Leisure,Features,Sports,Sande"';
            OptionMembers = " ",Photo,"General News","Photo Desk",Leisure,Features,Sports,Sande;
        }
        field(50015; "Freelancer Category"; Option)
        {
            OptionCaption = '" ,Columnist,Presenter,Video Editor, Photo Journalist,Camera Person,News Anchors,Producer,Technician/Transmission Team,Graphic Editors,Script Writer,Make-up Artist,News Reporter/Writer,Program,Social media,News Editor,Segment,Voicing,Production Assistant,Actor,Sign Language"';
            OptionMembers = " ",Columnist,Presenter,"Video Editor"," Photo Journalist","Camera Person","News Anchors",Producer,"Technician/Transmission Team","Graphic Editors","Script Writer","Make-up Artist","News Reporter/Writer","Program","Social media","News Editor",Segment,Voicing,"Production Assistant",Actor,"Sign Language";
        }
        field(50016; "Contact Classification Type"; Option)
        {
            OptionMembers = " ",Department,Branch,Location,Make,OrgUnit,Position;
        }
        field(50017; "HR Period"; Code[50])
        {
            // TableRelation = Periods."Period ID";
        }
        field(50018; Appraisal; Boolean)
        {
        }
        field(50019; "Contact Classification Type1"; Option)
        {
            OptionMembers = " ",Department,Branch,Location,Make,OrgUnit,Position;
        }
        field(50020; "HR Period1"; Code[50])
        {
            // TableRelation = Periods."Period ID";
        }
        field(50021; Appraisal1; Boolean)
        {
        }
    }

    var
        recEmp: Record "Staff Advances";
        recDimValue: Record "Dimension Value";
}