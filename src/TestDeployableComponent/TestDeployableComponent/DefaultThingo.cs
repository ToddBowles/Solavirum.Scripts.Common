namespace TestDeployableComponent
{
    public class DefaultThingo : IThingo
    {
        private const bool _shouldThingoReturnOne = true;

        public int DoSomething()
        {
            if (_shouldThingoReturnOne) return 1;
            else return 0;
        }
    }
}