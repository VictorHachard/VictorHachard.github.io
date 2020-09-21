---
layout: note
draft: false
date: 2019-06-17 23:33:00 +0200
author: Victor Hachard
---

An event handler typically is a software routine that processes actions such as keystrokes and mouse movements. With Web sites, event handlers make Web content dynamic. JavaScript is a common method of scripting event handlers for Web content.

## Create an timed event handler

```c++
public partial class MainWindow : Window
{
    System.Windows.Threading.DispatcherTimer dt = new System.Windows.Threading.DispatcherTimer();

    public MainWindow()
    {
        InitializeComponent();

        dt.Interval = new TimeSpan(0, 0, 0, 0, 500); //500 Milliseconds
        dt.Tick += new EventHandler(dt_Tick);
    }

    void dt_Tick(object sender, EventArgs e)
    {
        MessageBox.Show("Event");
        dt.Stop();
    }

    private void Btn_Click(object sender, RoutedEventArgs e)
    {
        dt.Start();
    }
}
```
