using NUnit.Framework;

namespace TestDeployableComponent.Tests.Unit
{
    [TestFixture]
    public class DefaultThingoTests
    {
        [Test]
        public void DoSomething_ReturnsOne()
        {
            var target = new DefaultThingo();

            var result = target.DoSomething();

            Assert.AreEqual(1, result);
        }
    }
}
