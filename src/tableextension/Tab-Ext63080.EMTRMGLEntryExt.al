tableextension 63080 "EMTRM GL Entry Ext" extends "G/L Entry"
{
    fields
    {
        field(63080; "Bank Transaction Entry No."; Integer)
        {
            Caption = 'Bank Transaction Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "CEM Bank Transaction";
        }
    }
}