namespace central.Models
{
    public class VoteResult
    {
        public bool IsOk { get; set; }
        public bool IsChecked { get; set; }
        public string ErrorReason { get; set; }

        public static VoteResult Ok(bool IsChecked)
        {
            return new() { IsChecked = IsChecked, IsOk = true };
        }

        public static VoteResult Error(string error)
        {
            return new() { ErrorReason = error, IsOk = false };
        }
    }
}
