namespace TestDeployableComponent
{
    public class Program
    {
        private readonly IThingo _thingo;

        public Program()
            : this(new DefaultThingo())
        {
            
        }

        public Program(IThingo thingo)
        {
            _thingo = thingo;
        }

        public int Run(string[] args)
        {
            return _thingo.DoSomething();
        }

        private static int Main(string[] args)
        {
            var program = new Program();
            return program.Run(args);
        }
    }
}