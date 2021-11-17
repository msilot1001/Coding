using System;
using System.IO;
using System.Collections.Generic;

class DataStruct
{
    public string? fieldvalue;
    public string? boolean;
}

class Program
{
    public string fileDelimiter = ";";
    public List<DataStruct> datalist = new List<DataStruct>();
    

    public static void Main(string[] args)
    {
        Program program = new Program();
        List<DataStruct> datalist = program.datalist;

        #region Read

        int i = 0;

        foreach(string line in File.ReadLines(@"C:\Coding\CsvMaker\CsvMaker\data.txt"))
        {
            //읽기
            string search = "|";
            int index = line.IndexOf(search);
            if (index < 0)
                continue;

            //문자열 분리 , 값 추출
            string fieldvalue = line.Substring(0, index-1);
            string booleanval = line.Substring(index+1);
            

            //Debug
            Console.WriteLine($"Reading {i+1}th line, {search} located at {line.IndexOf(search)}, splited with {fieldvalue} : {booleanval}");

            //List에 값 삽입
            DataStruct dataStruct = new DataStruct();
            dataStruct.fieldvalue = fieldvalue;
            dataStruct.boolean = booleanval;
            datalist.Add(dataStruct);

            i++;
        }

        //블로킹
        Console.ReadLine();

        //콘솔 초기화
        Console.Clear();

        //데이터 Debug
        for(int j = 0; j < datalist.Count; j++)
        {
            DataStruct data = datalist[j];
            bool boolean = false;
            if (data.boolean == "1")
                boolean = true;

            Console.WriteLine($"{j} [ field : {data.fieldvalue} ] [ {boolean} ] ");
        }

        //블로킹
        Console.ReadLine();

        //콘솔 초기화
        Console.Clear();

        //Csv 파일 존재시 재생성 또는 없을시 생성
        string path = @"C:\Coding\CsvMaker\CsvMaker\data.csv";

        if(!File.Exists(path))
        {
            using(File.Create(path))
            {
                Console.WriteLine("파일이 생성되었습니다.");
            }
        }
        else
        {
            File.Delete(path);
            Console.WriteLine("파일이 삭제되었습니다.");
            using (File.Create(path))
            {
                Console.WriteLine("파일이 생성되었습니다.");
            }
        }

        //파일 작성
        using (StreamWriter file = new StreamWriter(@"..\..\..\data.csv", false, System.Text.Encoding.GetEncoding("utf-8")))
        {
            for (int k = 0; k < datalist.Count; k++)
            {
                DataStruct data = datalist[k];
                file.WriteLine("{0},{1}", data.fieldvalue, data.boolean);
                Console.WriteLine($"Wrote {data.fieldvalue}({k + 1},1) , {data.boolean}({k + 1},1)");
            }
        }


        //블로킹
        Console.WriteLine("Enter 를 눌러서 종료하세요"); 
        Console.ReadLine();

        #endregion
    }
}