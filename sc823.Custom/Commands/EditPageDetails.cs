using Score.Custom.Commands;

namespace sc823.Custom.Commands
{
    public class ManageCustomData : ScoreFieldEditorCommand
    {
        public ManageCustomData()
        {
            var articleId = "{734B09D5-5412-4173-B1CC-BE6295BB30D7}";

            Dialog = new FieldEditorConfiguration
            {
                ScopeToTemplates = new string[] { articleId },
                FieldsSectionsToEdit = new string[] { "Page Details" },
                Title = "Assign stuff to the current page",
                Width = "750",
                Height = "900"
            };
        }
    }
}