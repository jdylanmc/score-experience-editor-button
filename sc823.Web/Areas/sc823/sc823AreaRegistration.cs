using System.Web.Mvc;

namespace sc823.Web.Areas.sc823
{
    public class sc823AreaRegistration : AreaRegistration
    {
        public override string AreaName
        {
            get
            {
                return "sc823";
            }
        }

        public override void RegisterArea(AreaRegistrationContext context)
        {
            // Register your MVC routes in here
        }
    }
}
