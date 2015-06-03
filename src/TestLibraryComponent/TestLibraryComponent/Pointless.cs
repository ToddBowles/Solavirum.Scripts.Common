using Serilog;

namespace TestLibraryComponent
{
    public class Pointless
    {
        private readonly ILogger _logger;

        public Pointless(ILogger logger)
        {
            _logger = logger;
        }

        public int DoSomething()
        {
            return 1;
        }
    }
}
