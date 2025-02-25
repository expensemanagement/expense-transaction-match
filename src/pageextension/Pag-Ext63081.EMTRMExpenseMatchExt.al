pageextension 63081 "EMTRM Expense Match Ext" extends "CEM Expense Match"
{
    layout
    {
        addafter("Transaction Entry No.")
        {
            field(Processed; Rec.Processed)
            {
                ApplicationArea = All;
                Caption = 'Processed';
                ToolTip = 'Shows if the record has been processed.';
            }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(UpdateGLAccountWithExpenseEntryNo)
            {
                ApplicationArea = All;
                Caption = 'Update G/L Accounts ';
                Image = SetupLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Update G/L Entries related to Expense Entries.';

                trigger OnAction()
                var
                    TransactionMatchMgt: Codeunit "EMADV Transaction Match Mgt.";
                begin
                    TransactionMatchMgt.UpdateAccountsExpenseEntries(true);
                end;
            }

            action(ResetProcessedEntries)
            {
                ApplicationArea = All;
                Caption = 'Reset Processed Entries';
                Image = ResetStatus;
                ToolTip = 'Reset Processed Entries.';

                trigger OnAction()
                var
                    TransactionMatchMgt: Codeunit "EMADV Transaction Match Mgt.";
                begin
                    TransactionMatchMgt.ResetProcessedEntries();
                end;
            }
        }
    }
}
