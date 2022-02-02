using System;

class Program
{
    static void Main(string[] args)
    {
        int result = Intro();
        Console.WriteLine(result     );
    }
    static int Intro()
    {
        int result = 0;
        Console.WriteLine("E/K Translater v0.1.0 developed by \"Msilot\"");
        Console.WriteLine("Select Mode to translate");
        Console.WriteLine("Press [1] to translate English to Korean");
        Console.WriteLine("Press [2] to translate Korean to English");
        string? val = Console.ReadLine();
        switch (val)
        {
            case "1":
                Console.WriteLine("Selected English to Korean");
                result = Convert.ToInt32(val);
                break;
            case "2":
                Console.WriteLine("Selected Korean to English");
                result = Convert.ToInt32(val);
                break;
            default:
                break;
        }
        return result;
    }
}

