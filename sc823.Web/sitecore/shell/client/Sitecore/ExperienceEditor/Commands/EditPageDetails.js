require.config({
    paths: {
        scoreFieldEditor: "/-/speak/v1/score/FieldEditor"
    }
});

define(["sitecore", "scoreFieldEditor"], function (Sitecore, Score) {
    Sitecore.Commands.EditPageDetails = {
        canExecute: function (context) {
            if (context.currentContext.webEditMode !== "edit") {
                return false;
            }

            context.currentContext.argument = "{734B09D5-5412-4173-B1CC-BE6295BB30D7}"; // Custom Page Data

            return context.app.canExecute("ExperienceEditor.Score.IsScorePage", context.currentContext);
        },

        execute: function (context) {
            context.app.disableButtonClickEvents();

            Score.FieldEditor({
                saveItem: false,
                header: "Manage Custom Data",
                title: "Assign Custom Data to the current page",
                sections: "Page Details",
                width: "900px",
                height: "750px"
            }).execute(context);

            context.app.enableButtonClickEvents();
        }
    };
});