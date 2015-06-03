using NSubstitute;
using NUnit.Framework;
using Serilog;

namespace TestLibraryComponent.Tests.Integration
{
    [TestFixture]
    public class PointlessTests
    {
        [Test]
        public void I_DoSomething_ReturnsOne()
        {
            var logger = Substitute.For<ILogger>();
            var target = new Pointless(logger);

            var result = target.DoSomething();

            Assert.AreEqual(1, result);
        }
    }
}
