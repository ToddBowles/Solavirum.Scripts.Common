using NUnit.Framework;

namespace TestDeployableComponent.Tests.Integration
{
    [TestFixture]
    public class ProgramTests
    {
        [Test]
        public void I_ProgramDoesThings()
        {
            var program = new Program();
            var result = program.Run(new string[] {});

            Assert.AreEqual(1, result);
        }
    }
}
