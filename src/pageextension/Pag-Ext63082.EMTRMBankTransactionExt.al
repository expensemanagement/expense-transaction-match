pageextension 63082 "EMTRM Bank Transaction Ext" extends "CEM Bank Transactions"
{
    actions
    {
        addlast(processing)
        {
            action(ExpenseTransactions)
            {
                ApplicationArea = All;
                Caption = 'Show Matched Entries';
                Image = GetEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "CEM Expense Match";
                RunPageMode = View;
                ToolTip = 'Show Expense Entries matched with bank transactions.';
            }
        }
    }
}