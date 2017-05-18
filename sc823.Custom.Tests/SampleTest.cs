using System;
using FluentAssertions;
using NSubstitute;
using NUnit.Framework;
using Sitecore.Data;
using Sitecore.Data.Items;
using Sitecore.Data.Managers;
using Sitecore.FakeDb;
using Sitecore.Rules.RuleMacros;

namespace sc823.Custom.Tests
{
    public class SampleTest
    {
        [Test]
        public void ShouldHaveAllDependencies()
        {
            true.Should().BeTrue();

            var sample = Substitute.ForPartsOf<SampleClass>();
            var result = sample.TestMe("a");

            result.Should().Be("a");
            sample.Received().CallMe();
            sample.DidNotReceive().DontCallMe();
        }

        [Test]
        public void SitecoreFakeDbShouldWork()
        {
            var templateId = ID.NewID;
            
            using (var db = new Db
            {
                new DbTemplate("Template", templateId),
                new DbItem("home", ID.NewID, templateId)
            })
            {
                Item item = db.GetItem("/sitecore/content/home");

                item.Should().NotBeNull();
                item.TemplateID.Should().Be(templateId);
                item.Template.Should().NotBeNull();
                item.Template.ID.Should().Be(templateId);

                TemplateManager.GetTemplate(templateId, db.Database).Should().NotBeNull();
            }
        }
    }

}
