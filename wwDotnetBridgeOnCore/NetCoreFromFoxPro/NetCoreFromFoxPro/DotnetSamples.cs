using System;

namespace NetCoreFromFoxPro
{
    public class DotnetSamples 
    {
        public string Name { get; set; }

        public string HelloWorld(string name)
        {
            if (string.IsNullOrEmpty(name))
                name = "Mr. Anonymous";

            Name = name;

            return $"Hello {name}. Time is: {DateTime.Now.ToString("HH:mm:ss")}";
        }

        public Person GetPerson()
        {
            return new Person
            {
                Name = "Rick Strahl",
                Company = "West Wind",
                Entered = DateTime.Now
            };
        }

        public bool SetPerson(Person person)
        {
            if (person != null && !string.IsNullOrEmpty(person.Name))
                return true;

            return false;
        }
    }

    public class Person
    {
        public string Name { get; set; }
        public string Company { get; set; }
        public DateTime Entered { get; set; }
    }

}