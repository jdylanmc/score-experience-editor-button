namespace sc823.Data
{
    public class SampleClass
    {
        public virtual string TestMe(string arg)
        {
            CallMe();

            return arg;
        }

        public virtual void CallMe()
        {   
        }

        public virtual void DontCallMe()
        {
        }
    }
}
