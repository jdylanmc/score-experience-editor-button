using FluentAssertions;
using NSubstitute;
using NUnit.Framework;

namespace sc823.Data.Tests
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
    }
}
