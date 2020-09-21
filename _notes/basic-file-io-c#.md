---
layout: note
draft: false
date: 2019-06-17 19:19:00 +0200
author: Victor Hachard
---

## Open a file

```c++
OpenFileDialog openFileDialog = new OpenFileDialog();

openFileDialog.Filter = "Text files (*.txt)|*.txt";
openFileDialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);

if (openFileDialog.ShowDialog() == true)
{
    //Do what you want to the file
}
```

## Save a file

```c++
SaveFileDialog saveFileDialog = new SaveFileDialog();

saveFileDialog.Filter = "Text files (*.txt)|*.txt";
saveFileDialog.DefaultExt = "txt";
saveFileDialog.FileName = "database.txt";
saveFileDialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);

if (saveFileDialog.ShowDialog() == true)
{
    //Do what you want to the save
}
```
