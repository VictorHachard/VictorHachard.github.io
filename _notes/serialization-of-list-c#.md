---
layout: htd
draft: false
date: 2019-06-17 20:48:00 +0200
author: Victor Hachard
---

Serialization is the process of converting an object into a stream of bytes to store the object or transmit it to memory, a database, or a file. Its main purpose is to save the state of an object in order to be able to recreate it when needed. The reverse process is called deserialization.

## Serializable class

Add the `[Serializable()]` to the class that will be serialize.

```c++
namespace XX
{
    [Serializable()]
    public class Object
    {

    }
}
```

## Serialization methode

```c++
public void toSerialize(string fileName, List lstObject)
{
    FileStream stream = File.Create(fileName);
    var formatter = new BinaryFormatter();
    formatter.Serialize(stream, lstObject);
    stream.Close();
}
```

## Deserialization methode

```c++
public List deSerialize(string fileName)
{
    var formatter = new BinaryFormatter();
    FileStream stream = File.OpenRead(fileName);
    ObservableCollection<Object> lstTmp = (ObservableCollection<Object>)formatter.Deserialize(stream);
    stream.Close();
    foreach (Object obj in lstTmp)
    {
        lstObject.Add(obj);
    }
    return lstObject;
}
```
